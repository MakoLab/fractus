using System;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.ObjectFactories
{
    internal static class WarehouseShiftDocumentFactory
    {
        public static void CreateIncomeShiftDocumentFromOutcomeShift(XElement source, WarehouseDocument destination)
        {
            //TODO: tutaj powinno byc odczytywanie z MM- jaki jest typ dokumentu lustrzanego
            destination.DocumentTypeId = DictionaryMapper.Instance.GetDocumentType("MM+").Id.Value;

            if (source.Element("root").Element("warehouseDocumentHeader").Element("entry").Element("contractorId") != null)
            {
                ContractorMapper contractorMapper = DependencyContainerManager.Container.Get<ContractorMapper>();
                Contractor contractor = (Contractor)contractorMapper.CreateNewBusinessObject(BusinessObjectType.Contractor, null);
                contractor.Id = new Guid(source.Element("root").Element("warehouseDocumentHeader").Element("entry").Element("contractorId").Value);
                destination.Contractor = contractor;
            }

            destination.Number.FullNumber = source.Element("root").Element("warehouseDocumentHeader").Element("entry").Element("fullNumber").Value;
            destination.Number.Number = Convert.ToInt32(source.Element("root").Element("warehouseDocumentHeader").Element("entry").Element("number").Value, CultureInfo.InvariantCulture);
            destination.Number.SeriesId = new Guid(source.Element("root").Element("warehouseDocumentHeader").Element("entry").Element("seriesId").Value);
            destination.Value = Convert.ToDecimal(source.Element("root").Element("warehouseDocumentHeader").Element("entry").Element("value").Value, CultureInfo.InvariantCulture);
            destination.DocumentStatus = DocumentStatus.Saved;

            //set warehouse as destination wh in the source
            Guid whDocumentFieldId = DictionaryMapper.Instance.GetDocumentField(DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId).Id.Value;

            string warehouseId = (from node in source.Element("root").Element("documentAttrValue").Elements()
                                  where node.Element("documentFieldId").Value == whDocumentFieldId.ToUpperString()
                              select node).ElementAt(0).Element("textValue").Value;

            destination.WarehouseId = new Guid(warehouseId);

            //create attributes
            DocumentAttrValue attr = null;

            var attrs = destination.Attributes.Children.Where(a => a.DocumentFieldName == DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId);

            if (attrs.Count() == 1)
                attr = attrs.ElementAt(0);
            else
            {
                attr = destination.Attributes.CreateNew();
                attr.DocumentFieldName = DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId;
            }

            attr.Value.Value = source.Element("root").Element("warehouseDocumentHeader").Element("entry").Element("warehouseId").Value;

            attr = destination.Attributes.CreateNew();
            attr.DocumentFieldName = DocumentFieldName.ShiftDocumentAttribute_OppositeDocumentStatus;
            attr.Value.Value = source.Element("root").Element("warehouseDocumentHeader").Element("entry").Element("status").Value;

            attr = destination.Attributes.CreateNew();
            attr.DocumentFieldName = DocumentFieldName.ShiftDocumentAttribute_OppositeDocumentId;
            attr.Value.Value = source.Element("root").Element("warehouseDocumentHeader").Element("entry").Element("id").Value;

            DocumentField df = DictionaryMapper.Instance.GetDocumentField(DocumentFieldName.Attribute_IncomeShiftOrderId);

            if (df != null)
            {
                var srcAttr = source.Element("root").Element("documentAttrValue").Elements("entry").Where(e => e.Element("documentFieldId").Value == df.Id.ToUpperString()).FirstOrDefault();
                
                if (srcAttr != null)
                {
                    attr = destination.Attributes.CreateNew();
                    attr.DocumentFieldName = DocumentFieldName.Attribute_IncomeShiftOrderId;
                    attr.Value.Value = srcAttr.Element("textValue").Value;
                }
            }
            //

            bool isLocalShift = destination.IsLocalShift();

            if (isLocalShift)
                destination.DocumentStatus = DocumentStatus.Committed;

            //create lines
            foreach (XElement entry in source.Element("root").Element("warehouseDocumentLine").Elements().OrderBy(e => Convert.ToInt32(e.Element("ordinalNumber").Value, CultureInfo.InvariantCulture)))
            {
                WarehouseDocumentLine line = destination.Lines.CreateNew();
                
                if (!isLocalShift)
                    line.Direction = 0;
                
                line.ItemId = new Guid(entry.Element("itemId").Value);
                line.IncomeDate = DateTime.Parse(entry.Element("outcomeDate").Value, CultureInfo.InvariantCulture);
                line.Quantity = Convert.ToDecimal(entry.Element("quantity").Value, CultureInfo.InvariantCulture);
                line.Price = Convert.ToDecimal(entry.Element("price").Value, CultureInfo.InvariantCulture);
                line.Value = Convert.ToDecimal(entry.Element("value").Value, CultureInfo.InvariantCulture);
                line.UnitId = new Guid(entry.Element("unitId").Value);
                line.WarehouseId = destination.WarehouseId;
            }
            //
        }

        public static void CreateOutcomeShiftFromWarehouseDocument(XElement source, WarehouseDocument destination)
        {
            /*
             * <root>
             *   <warehouseDocumentId>GUID</warehouseDocumentId>
             * </root>
             */
            DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
			WarehouseDocument incomeDocument = (WarehouseDocument)mapper.LoadBusinessObject(BusinessObjectType.WarehouseDocument, new Guid(source.Element("warehouseDocumentId").Value));
            destination.WarehouseId = incomeDocument.WarehouseId;

            //create lines
            foreach (var incLine in incomeDocument.Lines)
            {
                WarehouseDocumentLine line = destination.Lines.CreateNew();

                line.ItemId = incLine.ItemId;
                line.ItemName = incLine.ItemName;
                line.Quantity = incLine.Quantity;
                line.UnitId = incLine.UnitId;
                line.ItemTypeId = incLine.ItemTypeId;
            }

			//Duplicate attributes
			DuplicableAttributeFactory.DuplicateAttributes(incomeDocument, destination);
        }
    }
}

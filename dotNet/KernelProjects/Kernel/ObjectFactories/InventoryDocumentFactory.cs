using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.HelperObjects;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;

namespace Makolab.Fractus.Kernel.ObjectFactories
{
    internal class InventoryDocumentFactory
    {
        public static ICollection<WarehouseDocument> GenerateDifferentialDocuments(InventoryDocument document, ICollection<InventorySheet> sheets)
        {
            string incomeTemplate = document.DocumentType.InventoryDocumentOptions.IncomeDifferentialDocumentTemplate;
            string outcomeTemplate = document.DocumentType.InventoryDocumentOptions.OutcomeDifferentialDocumentTemplate;

            WarehouseItemQuantityInventoryDocumentDictionary dict = new WarehouseItemQuantityInventoryDocumentDictionary();

            foreach (InventorySheet sheet in sheets)
            {
                if (sheet.WarehouseId == null)
                    throw new ClientException(ClientExceptionId.NoWarehouseIdOnInventorySheet, null, "ordinalNumber:" + sheet.OrdinalNumber.ToString(CultureInfo.InvariantCulture));

                foreach (InventorySheetLine line in sheet.Lines)
                {
                    if (line.Direction == 0)
                        continue;

                    if (line.UserQuantity == null)
                        throw new ClientException(ClientExceptionId.NoUserQuantityOnInventorySheetLine, null, "lineOrdinalNumber:" + line.OrdinalNumber.ToString(CultureInfo.InvariantCulture), "sheetOrdinalNumber:" + sheet.OrdinalNumber.ToString(CultureInfo.InvariantCulture));

                    dict.Add(sheet.WarehouseId.Value, line.ItemId, line.UserQuantity.Value, line.SystemQuantity, line.UnitId);
                }
            }
            
            //majac juz wszystkie towary i ilosci posumowane sprawdzamy w ktorym przypadku userQuantity != systemQuantity i generujemy odpowiedni dokumencik

            List<WarehouseDocument> incomeDocuments = new List<WarehouseDocument>();
            List<WarehouseDocument> outcomeDocuments = new List<WarehouseDocument>();

            foreach (Guid warehouseId in dict.Dictionary.Keys)
            {
                var innerDict = dict.Dictionary[warehouseId];

                foreach (Guid itemId in innerDict.Keys)
                {
                    var qty = innerDict[itemId];

                    if (qty.Quantity != qty.SystemQuantity)
                    {
                        WarehouseDocument doc = null;
                        
                        if (qty.Quantity > qty.SystemQuantity)
                            doc = InventoryDocumentFactory.GetDocumentFromList(warehouseId, incomeTemplate, incomeDocuments);
                        else
                            doc = InventoryDocumentFactory.GetDocumentFromList(warehouseId, outcomeTemplate, outcomeDocuments);                        

                        WarehouseDocumentLine line = doc.Lines.CreateNew();
                        line.ItemId = itemId;
                        line.Quantity = Math.Abs(qty.Quantity - qty.SystemQuantity);
                        line.UnitId = qty.UnitId;
                    }
                }

            }

			foreach (WarehouseDocument wDoc in outcomeDocuments)
			{
				if (DictionaryMapper.Instance.GetWarehouse(wDoc.WarehouseId).ValuationMethod == ValuationMethod.DeliverySelection)
				{
					CommercialWarehouseDocumentFactory.GenerateRelationsAndShiftsForOutcomeWarehouseDocument(wDoc);
				}
			}

            List<WarehouseDocument> retList = new List<WarehouseDocument>();

            foreach (var doc in incomeDocuments)
                retList.Add(doc);

            foreach (var doc in outcomeDocuments)
                retList.Add(doc);

            return retList;
        }

        private static WarehouseDocument GetDocumentFromList(Guid warehouseId, string template, List<WarehouseDocument> list)
        {
            WarehouseDocument doc = list.Where(d => d.WarehouseId == warehouseId).FirstOrDefault();

            if (doc != null)
                return doc;
            else
            {
                using (DocumentCoordinator c = new DocumentCoordinator(false, false))
                {
                    doc = (WarehouseDocument)c.CreateNewBusinessObject(BusinessObjectType.WarehouseDocument, template, null);
                }

                doc.WarehouseId = warehouseId;
                list.Add(doc);
                return doc;
            }
        }

        public static void CreateInventorySheetToInventoryDocument(InventorySheet destination, XElement source)
        {
            Guid inventoryDocumentId = new Guid(source.Element("inventoryDocumentId").Value);
            destination.InventoryDocumentHeaderId = inventoryDocumentId;

            using(DocumentCoordinator c = new DocumentCoordinator(false, false))
            {
                InventoryDocument inventoryDocument = (InventoryDocument)c.LoadBusinessObject(BusinessObjectType.InventoryDocument, inventoryDocumentId);
                destination.Tag = inventoryDocument.Version.ToUpperString();
                destination.OrdinalNumber = inventoryDocument.Sheets.Children.Count + 1;
                destination.InventoryDocumentFullNumber = inventoryDocument.Number.FullNumber;
                destination.WarehouseId = inventoryDocument.WarehouseId;
            }
        }
    }
}

using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.BusinessObjects.Service;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.HelperObjects;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.Exceptions;

namespace Makolab.Fractus.Kernel.Managers
{
    internal class ProcessManager
    {
        private static ProcessManager instance = new ProcessManager();

        public static ProcessManager Instance
        {
            get { return ProcessManager.instance; }
        }

        protected ProcessManager()
        {
        }

        public XElement GetDocumentOperations(BusinessObjectType type, Guid id)
        {
            Document document = null;

            using (Coordinator c = Coordinator.GetCoordinatorForSpecifiedType(type))
            {
                document = (Document)c.LoadBusinessObject(type, id);
            }

            return this.GetDocumentOperations(document);
        }

        public Guid GetServiceWarehouse(ServiceDocument document)
        {
            return this.GetGuidProcessConciguration(document, "serviceWarehouseId");
        }

        public Guid GetMaterialWarehouse(CommercialDocument document)
        {
            return this.GetGuidProcessConciguration(document, "materialWarehouseId");
        }

        public Guid GetProductWarehouse(CommercialDocument document)
        {
            return this.GetGuidProcessConciguration(document, "productWarehouseId");
        }

        public Guid GetByproductWarehouse(CommercialDocument document)
        {
            return this.GetGuidProcessConciguration(document, "byproductWarehouseId");
        }

        public decimal GetMaxSettlementDifference(CommercialDocument document)
        {
            XElement process = this.GetProcess(document);
            XElement element = process.Element("configuration").Element("maxSettlementDifference");
            
            if (element != null && element.Value.Length != 0)
                return Convert.ToDecimal(element.Value, CultureInfo.InvariantCulture);
            else
                return 0;
        }

        public bool IsServiceReservationEnabled(ServiceDocument document)
        {
            XElement process = this.GetProcess(document);
            XElement serviceReservation = process.Element("configuration").Element("serviceReservation");

            if (serviceReservation != null && serviceReservation.Value.ToUpperInvariant() == "TRUE")
                return true;
            else
                return false;
        }

        private string GetTemplateNameForPrepaidInvoice(CommercialDocument salesOrder)
        {
            XElement process = this.GetProcess(salesOrder);

            if (process.Element("configuration") == null || process.Element("configuration").Element("prepaidTemplate") == null)
                throw new InvalidOperationException("No prepaid template");

            return process.Element("configuration").Element("prepaidTemplate").Value;
        }

        private Guid GetGuidProcessConciguration(Document document, string name)
        {
            XElement process = this.GetProcess(document);

            XElement whId = process.Element("configuration").Element(name);

            if (whId == null)
                throw new InvalidOperationException("No '" + name + "' specified in process configuration");

            return new Guid(whId.Value);
        }

        public Guid GetComplaintWarehouse(ComplaintDocument document)
        {
            return this.GetGuidProcessConciguration(document, "complaintWarehouseId");
        }

        public DocumentRelationType? GetRelationTypeToMainObject(Document document)
        {
            XElement process = this.GetProcess(document);
            var processObjectAttr = document.Attributes.Children.Where(a => a.DocumentFieldName == DocumentFieldName.Attribute_ProcessObject).FirstOrDefault();
            XElement objectDefinition = process.Element("objects").Elements().Where(e => e.Attribute("name").Value == processObjectAttr.Value.Value).First();

            if (objectDefinition.Attribute("relationType") == null)
                return null;
            else
                return (DocumentRelationType)Convert.ToInt32(objectDefinition.Attribute("relationType").Value, CultureInfo.InvariantCulture);
        }

        public XElement GetDocumentOperations(Document document)
        {
            var processTypeAttr = document.Attributes.Children.Where(a => a.DocumentFieldName == DocumentFieldName.Attribute_ProcessType).FirstOrDefault();

            if (processTypeAttr == null) return null;

            var processObjectAttr = document.Attributes.Children.Where(a => a.DocumentFieldName == DocumentFieldName.Attribute_ProcessObject).FirstOrDefault();
            string processObject = processObjectAttr.Value.Value;
            var processStateAttr = document.Attributes.Children.Where(a => a.DocumentFieldName == DocumentFieldName.Attribute_ProcessState).FirstOrDefault();
            
            DocumentRelation processMainObjectRelation = null;

            DocumentRelationType? drt = this.GetRelationTypeToMainObject(document);

            if (drt != null)
                processMainObjectRelation = document.Relations.Children.Where(r => r.RelationType == drt.Value).FirstOrDefault();

            XElement process = ConfigurationMapper.Instance.Processes[processTypeAttr.Value.Value];

            string processState = null;
            Document mainObject = null;

            if (processStateAttr != null) // jestesmy w glownym obiekcie
                processState = processStateAttr.Value.Value.ToLowerInvariant();
            else //wczytujemy glowny obiekt i z niego odczytujemy stan
            {
                if (processMainObjectRelation == null)
                    //throw new InvalidOperationException("Relation to the main object not found in the given document.");
                    return null; //zmienione bo w przypadku SERWIS->FVS->WZ to wz nie ma powiazania z serwisem i narazie upraszczamy

                var moElement = process.Element("objects").Elements().Where(o => o.Attribute("mainObject") != null && o.Attribute("mainObject").Value.ToUpperInvariant() == "TRUE").First();
                string typeSymbol = moElement.Attribute("typeSymbol").Value;

                DocumentType dt = DictionaryMapper.Instance.GetDocumentType(typeSymbol);

                using (Coordinator c = Coordinator.GetCoordinatorForSpecifiedType(dt.BusinessObjectType, false, false))
                {
                    mainObject = (Document)c.LoadBusinessObject(dt.BusinessObjectType, processMainObjectRelation.RelatedDocument.Id.Value);
                }

                processState = mainObject.Attributes.Children.Where(aa => aa.DocumentFieldName == DocumentFieldName.Attribute_ProcessState).First().Value.Value.ToLowerInvariant();
            }

            //mamy stan procesu, mamy role jaka odgrywa biezacy dokument (processObject), wiec teraz sprawdzamy jakie operacje moze miec

            var operationsResult = from node in process.Element("states").Elements("state")
                                   where node.Attribute("name").Value == processState
                                   from operation in node.Elements()
                                   where operation.Attribute("object").Value == processObject
                                   select operation;

            XElement operations = new XElement("operations");
            operations.Add(operationsResult);

            if (document.DocumentType.DocumentCategory == DocumentCategory.SalesOrder)
            {
                CommercialDocument comDoc = document as CommercialDocument;
                
                if (comDoc.SalesOrderSettlements == null) //na wszelki wypadek tylko jak w pozniejszym developmencie zdarzy sie inny przypadek
                {
                    SalesOrderSettlements settlements = new SalesOrderSettlements();
                    settlements.LoadSalesOrder(comDoc);

                    XElement prepaidsXml = DependencyContainerManager.Container.Get<DocumentMapper>().GetSalesOrderSettledAmount(comDoc.Id.Value);
                    settlements.LoadPrepaids(prepaidsXml);
                    comDoc.SalesOrderSettlements = settlements;
                }
            }

            this.FilterOperations(document, operations);
            return operations;
        }

        private void FilterOperations(Document document, XElement operations)
        {
            List<XElement> operationsToDelete = new List<XElement>();

            foreach (XElement operation in operations.Elements())
            {
                if (operation.Attribute("name").Value == "cancel" && document.BOType == BusinessObjectType.ServiceDocument)
                {
                    if (document.Relations.Where(r => r.RelationType == DocumentRelationType.ServiceToInvoice).FirstOrDefault() != null)
                    {
                        operation.Add(new XAttribute("enabled", "0"));
                        operation.Add(new XAttribute("toolTipKey", DisableDocumentChangeReason.DOCUMENT_HAS_INVOICE));
                    }
                }

                //rozliczanie zamowienia sprzedazowego bez faktury mozliwe tylko jezeli roznica z zaliczkami jest w dopuszczalnej granicy
                if (operation.Attribute("name").Value == "settleSalesOrder" && document.BOType == BusinessObjectType.CommercialDocument &&
                    operation.Element("closeOrder") != null && operation.Element("closeOrder").Value.ToUpperInvariant() == "TRUE")
                {
                    CommercialDocument comDoc = (CommercialDocument)document;
                    if (comDoc.SalesOrderSettlements != null)
                    {
                        decimal difference = comDoc.SalesOrderSettlements.GetUnsettledValues().Sum(s => s.GrossValue);

                        decimal allowedDifference = ProcessManager.instance.GetMaxSettlementDifference(comDoc);

                        if (Math.Abs(difference) > allowedDifference)
                        {
                            operation.Add(new XAttribute("enabled", "0"));
                            operation.Add(new XAttribute("toolTipKey", DisableDocumentChangeReason.INSUFFICIENT_PREPAIDS_AMOUNT));
                        }
                    }
                }

                if (operation.Attribute("name").Value == "commit" && document.DocumentType.DocumentCategory == DocumentCategory.SalesOrder)
                {
                    CommercialDocument commercialDocument = (CommercialDocument)document;
                    DependencyContainerManager.Container.Get<DocumentMapper>().AddItemsToItemTypesCache(commercialDocument);
                    var dict = SessionManager.VolatileElements.ItemTypesCache;

                    //sprawdzamy czy zamowienie ma wszelkie wz-ty
                    foreach (var line in commercialDocument.Lines)
                    {
                        if (!DictionaryMapper.Instance.GetItemType(dict[line.ItemId]).IsWarehouseStorable)
                            continue;

                        decimal relQuantity = line.CommercialWarehouseRelations.Sum(r => r.Quantity);

                        if (line.Quantity != relQuantity)
                        {
                            operationsToDelete.Add(operation);
                            break;
                        }
                    }
                }
            }

            foreach (var o in operationsToDelete)
                o.Remove();
        }

        private XElement GetProcess(Document mainProcessDocument)
        {
            var processTypeAttr = mainProcessDocument.Attributes.Children.Where(a => a.DocumentFieldName == DocumentFieldName.Attribute_ProcessType).FirstOrDefault();

            if (processTypeAttr == null)
                throw new InvalidOperationException("Missing ProcessType attribute");

            XElement process = ConfigurationMapper.Instance.Processes[processTypeAttr.Value.Value];
            
            if (process == null)
                throw new InvalidOperationException("Missing process definition '" + processTypeAttr.Value.Value + "'");

            return process;
        }

        public void AppendProcessAttributes(Document document, string processType, string processObject, Guid? processMainObjectId, DocumentRelationType? relationType)
        {
            if (processType != null)
            {
                var attr = document.Attributes[DocumentFieldName.Attribute_ProcessType];

                if (attr == null)
                {
                    attr = document.Attributes.CreateNew();
                    attr.DocumentFieldName = DocumentFieldName.Attribute_ProcessType;
                }
                
                attr.Value.Value = processType;
            }

            if (processObject != null)
            {
                var attr = document.Attributes[DocumentFieldName.Attribute_ProcessObject];

                if (attr == null)
                {
                    attr = document.Attributes.CreateNew();
                    attr.DocumentFieldName = DocumentFieldName.Attribute_ProcessObject;
                }

                attr.Value.Value = processObject;
            }

            if (processMainObjectId != null && relationType != null)
            {
                var relation = document.Relations.Children.Where(r => r.RelationType == relationType).FirstOrDefault();

                if (relation == null)
                {
                    relation = document.Relations.CreateNew();
                    relation.RelationType = relationType.Value;
                }

                relation.RelatedDocument = new ServiceDocument();
                relation.RelatedDocument.Id = processMainObjectId.Value;
            }
        }

        public DocumentType GetDocumentType(Document mainProcessDocument, string documentName)
        {
            if (String.IsNullOrEmpty(documentName))
                throw new InvalidOperationException("No 'generatedDocumentName' node specified");

            XElement process = this.GetProcess(mainProcessDocument);

            XElement objectElement = process.Element("objects").Elements().Where(e => e.Attribute("name").Value == documentName).FirstOrDefault();

            if (objectElement == null)
                throw new InvalidOperationException("Document name '" + documentName + "' not found in the process definition");

            DocumentType dt = DictionaryMapper.Instance.GetDocumentType(objectElement.Attribute("typeSymbol").Value);

            return dt;
        }

        public Guid GetPrepaidItemId(CommercialDocument salesOrder, int stage, Guid vatRateId)
        {
            if(stage < 0)
                throw new ArgumentException("Invalid stage", "stage");

            XElement process = this.GetProcess(salesOrder);

            string stageName = "stage" + stage.ToString(CultureInfo.InvariantCulture);

            XElement vatRateElement = process.Element("configuration").Element("prepaidItems").Elements("vatRate").Where(p => p.Attribute("id").Value == vatRateId.ToUpperString()).FirstOrDefault();

			VatRate vatRate = DictionaryMapper.Instance.GetVatRate(vatRateId);

			if (vatRateElement == null)
				throw new ClientException(ClientExceptionId.UnsupportedVatRate, null, "symbol:" + vatRate.Symbol);

            Guid g = new Guid(vatRateElement.Element(stageName).Value);
            return g;
        }

        public ICollection<Guid> GetPrepaidItems(CommercialDocument invoice)
        {
            List<Guid> items = new List<Guid>();

            XElement process = this.GetProcess(invoice);

            var itemsXml = from node in process.Element("configuration").Element("prepaidItems").Elements()
                           from stage in node.Elements()
                           select stage;

            foreach (var itemXml in itemsXml)
                items.Add(new Guid(itemXml.Value));

            return items;
        }

        public string GetDocumentTemplate(Document mainProcessDocument, string documentName)
        {
            if (String.IsNullOrEmpty(documentName))
                throw new InvalidOperationException("No 'generatedDocumentName' node specified");

            XElement process = this.GetProcess(mainProcessDocument);

            XElement objectElement = process.Element("objects").Elements().Where(e => e.Attribute("name").Value == documentName).FirstOrDefault();

            if (objectElement == null)
                throw new InvalidOperationException("Document name '" + documentName + "' not found in the process definition");

            return objectElement.Attribute("template").Value;
        }

		public void SetProcessStateChangeDate(Document document)
		{
			DocumentAttrValue processStateChangeDateAttr = document.Attributes.GetOrCreateNew(DocumentFieldName.Attribute_ProcessStateChangeDate);
			processStateChangeDateAttr.Value.Value =
				SessionManager.VolatileElements.CurrentDateTime.ToString(CultureInfo.InvariantCulture);
		}
    }
}

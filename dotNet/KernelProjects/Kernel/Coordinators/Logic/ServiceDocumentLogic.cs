using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.BusinessObjects.Service;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.HelperObjects;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.MethodInputParameters;
using Makolab.Fractus.Kernel.ObjectFactories;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    internal class ServiceDocumentLogic
    {
        private DocumentMapper mapper;
        private DocumentCoordinator coordinator;

        public ServiceDocumentLogic(DocumentCoordinator coordinator)
        {
            this.mapper = (DocumentMapper)coordinator.Mapper;
            this.coordinator = coordinator;
        }

        /// <summary>
        /// Executes the custom logic.
        /// </summary>
        /// <param name="document">The document to execute custom logic for.</param>
        private void ExecuteCustomLogic(ServiceDocument document)
        {
            //create new contractor and attach him to the document if its neccesary
            if (document.ReceivingPerson != null && document.ReceivingPerson.IsNew &&
                (document.ReceivingPerson != null && document.Contractor == null) == false)
            {
                using (ContractorCoordinator contractorCoordinator = new ContractorCoordinator(false, false))
                {
                    Contractor newContractor = (Contractor)contractorCoordinator.CreateNewBusinessObject(BusinessObjectType.Contractor, null, null);

                    newContractor.ShortName = document.ReceivingPerson.ShortName;
                    newContractor.FullName = document.ReceivingPerson.FullName;
                    newContractor.IsBusinessEntity = document.ReceivingPerson.IsBusinessEntity;
                    newContractor.Status = BusinessObjectStatus.New;
                    document.ReceivingPerson = newContractor;

                    //load full document contractor data (maybe its not necessary, but we dont know if we already have full info about contractor)
                    Contractor documentContractor = (Contractor)contractorCoordinator.LoadBusinessObject(document.Contractor.BOType,
                        document.Contractor.Id.Value);
                    document.Contractor = documentContractor;
                }
            }

            this.ProcessServiceReservation(document);
            this.ProcessDocumentsGeneration(document);
        }

        private void ProcessServiceReservation(ServiceDocument document)
        {
            if (!ProcessManager.Instance.IsServiceReservationEnabled(document))
                return;

            this.mapper.AddItemsToItemTypesCache(document);
            IDictionary<Guid, Guid> cache = SessionManager.VolatileElements.ItemTypesCache;

            if (document.DocumentStatus != DocumentStatus.Saved)
            {
                foreach (var line in document.Lines)
                    line.OrderDirection = 0;
            }
            else
            {
                foreach (var line in document.Lines)
                {
                    Guid itemTypeId = cache[line.ItemId];
                    ItemType itemType = DictionaryMapper.Instance.GetItemType(itemTypeId);

                    if (!itemType.IsWarehouseStorable)
                        continue;

                    var attr = line.Attributes[DocumentFieldName.LineAttribute_GenerateDocumentOption];

                    if (attr != null && (attr.Value.Value == "1" || attr.Value.Value == "3"))
                        line.OrderDirection = -1;
                    else
                        line.OrderDirection = 0;
                }

                ServiceDocument alternateDocument = document.AlternateVersion as ServiceDocument;

                if (alternateDocument != null)
                {
                    foreach (var line in alternateDocument.Lines)
                    {
                        if (line.Status == BusinessObjectStatus.Deleted)
                            line.OrderDirection = 0;
                    }
                }
            }
        }

        private void ProcessDocumentsGeneration(ServiceDocument document)
        {
            if (document.DocumentStatus == DocumentStatus.Canceled)
                return;

            //przelatujemy po liniach i porownujemy z alternate version co sie zmienilo
            //slowniki w ktorych bedziemy bilansowac
            WarehouseItemQuantityDictionary dctWarehouseItemIdQuantity = new WarehouseItemQuantityDictionary();

            this.mapper.AddItemsToItemTypesCache(document);
            IDictionary<Guid, Guid> cache = SessionManager.VolatileElements.ItemTypesCache;

            foreach (CommercialDocumentLine line in document.Lines.Children)
            {
                Guid itemTypeId = cache[line.ItemId];
                ItemType itemType = DictionaryMapper.Instance.GetItemType(itemTypeId);

                if (!itemType.IsWarehouseStorable)
                    continue;

                DocumentLineAttrValue attr = line.Attributes[DocumentFieldName.LineAttribute_GenerateDocumentOption];

                if (attr.Value.Value != "2" && attr.Value.Value != "4") //czyli opcja ze NIE generujemy MMki
                    continue;

                dctWarehouseItemIdQuantity.Add(line.WarehouseId.Value, line.ItemId, line.Quantity);
            }

            ServiceDocument alternateDocument = document.AlternateVersion as ServiceDocument;

            if (alternateDocument != null)
            {
                this.mapper.AddItemsToItemTypesCache(alternateDocument);
                cache = SessionManager.VolatileElements.ItemTypesCache;

                foreach (CommercialDocumentLine line in alternateDocument.Lines.Children)
                {
                    Guid itemTypeId = cache[line.ItemId];
                    ItemType itemType = DictionaryMapper.Instance.GetItemType(itemTypeId);

                    if (!itemType.IsWarehouseStorable)
                        continue;

                    DocumentLineAttrValue attr = line.Attributes[DocumentFieldName.LineAttribute_GenerateDocumentOption];

                    if (attr.Value.Value != "2" && attr.Value.Value != "4") //czyli opcja ze NIE generujemy MMki
                        continue;

                    dctWarehouseItemIdQuantity.Subtract(line.WarehouseId.Value, line.ItemId, line.Quantity);
                }
            }

            //teraz majac zbilansowane wszystko ladnie co sie zmienilo przystepujemy do generacji MMek.
            //jezeli cos sie zmienilo na plus to oznacza ze musimy z danego warehouseId przesunac na serviceWarehouse podana ilosc
            //jezeli cos sie zmienilo na minus to oznacza ze z serviceWarehouse musimy przesunac na ten magazyn

            ServiceDocumentLogic.GenerateShifts(document, dctWarehouseItemIdQuantity);
        }

        public static void GenerateShifts(ServiceDocument document, WarehouseItemQuantityDictionary dctWarehouseItemIdQuantity)
        {
            ServiceDocument alternateDocument = document.AlternateVersion as ServiceDocument;
            Guid serviceWarehouseId = ProcessManager.Instance.GetServiceWarehouse(document);
            List<WarehouseDocument> shiftDocumentsList = new List<WarehouseDocument>();

            foreach (Guid warehouseId in dctWarehouseItemIdQuantity.Dictionary.Keys)
            {
                foreach (Guid itemId in dctWarehouseItemIdQuantity.Dictionary[warehouseId].Keys)
                {
                    decimal quantity = dctWarehouseItemIdQuantity.Dictionary[warehouseId][itemId];
                    var line = document.Lines.Children.Where(l => l.ItemId == itemId).FirstOrDefault();

                    if (line == null)
                        line = alternateDocument.Lines.Children.Where(l => l.ItemId == itemId).FirstOrDefault();

                    if (quantity > 0) //robimy przelew do serviceWarehouse
                    {
                        ServiceDocumentLogic.AddShiftPosition(document, warehouseId, serviceWarehouseId, shiftDocumentsList, itemId, quantity, line.UnitId);
                    }
                    else if (quantity < 0) //robimy przelew do magazynu wskazanego przez warehouseId
                    {
                        ServiceDocumentLogic.AddShiftPosition(document, serviceWarehouseId, warehouseId, shiftDocumentsList, itemId, -quantity, line.UnitId);
                    }
                }
            }
        }

        private static void AddShiftPosition(ServiceDocument serviceDocument, Guid sourceWarehouseId, Guid destinationWarehouseId, List<WarehouseDocument> shiftDocumentsList, Guid itemId, decimal quantity, Guid unitId)
        {
            WarehouseDocument shift = (from doc in shiftDocumentsList
                                       where doc.WarehouseId == sourceWarehouseId &&
                                       doc.Attributes.Children.Where(a => a.DocumentFieldName == DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId)
                                           .First().Value.Value.ToUpperInvariant() == destinationWarehouseId.ToUpperString()
                                       select doc).FirstOrDefault();

            if (shift == null) //tworzymy takiego szifta
            {
                using (DocumentCoordinator c = new DocumentCoordinator(false, false))
                {
                    string processType = serviceDocument.Attributes[DocumentFieldName.Attribute_ProcessType].Value.Value;
                    string template = ProcessManager.Instance.GetDocumentTemplate(serviceDocument, "outcomeShift");
                    shift = (WarehouseDocument)c.CreateNewBusinessObject(BusinessObjectType.WarehouseDocument, template, null);
                    ProcessManager.Instance.AppendProcessAttributes(shift, processType, "outcomeShift", serviceDocument.Id, DocumentRelationType.ServiceToOutcomeShift);
                    DuplicableAttributeFactory.DuplicateAttributes(serviceDocument, shift);
                    serviceDocument.AddRelatedObject(shift);
                    shiftDocumentsList.Add(shift);
                    shift.WarehouseId = sourceWarehouseId;
                    var dstWarehouseId = shift.Attributes[DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId];

                    if (dstWarehouseId == null)
                    {
                        dstWarehouseId = shift.Attributes.CreateNew();
                        dstWarehouseId.DocumentFieldName = DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId;
                    }

                    dstWarehouseId.Value.Value = destinationWarehouseId.ToUpperString();
                }
            }

            //sprawdzamy czy moze juz jest pozycja na ten sam towar. jak jest to edytujemy quantity, jak nie to tworzymy nowa
            WarehouseDocumentLine line = shift.Lines.Children.Where(l => l.ItemId == itemId).FirstOrDefault();

            if (line == null)
            {
                line = shift.Lines.CreateNew();
                line.ItemId = itemId;
                line.UnitId = unitId;
            }

            line.Quantity += quantity;
        }

        private void ExecuteDocumentOptions(ServiceDocument document)
        {
            foreach (IDocumentOption option in document.DocumentOptions)
            {
                option.Execute(document);
            }
        }

        /// <summary>
        /// Executes the custom logic during transaction.
        /// </summary>
        /// <param name="document">The document to execute custom logic for.</param>
        private void ExecuteCustomLogicDuringTransaction(ServiceDocument document)
        {
            if (document.ReceivingPerson != null && document.ReceivingPerson.IsNew)
            {
                using (ContractorCoordinator contractorCoordinator = new ContractorCoordinator(false, false))
                {
                    Contractor documentContractor = (Contractor)document.Contractor;
                    Contractor receivingContractor = (Contractor)document.ReceivingPerson;

                    ContractorRelation relation = documentContractor.Relations.CreateNew();
                    relation.ContractorRelationTypeName = ContractorRelationTypeName.Contractor_ContactPerson;
                    relation.RelatedObject = receivingContractor;

                    contractorCoordinator.SaveBusinessObject(documentContractor);

                    document.ReceivingPerson.Version = receivingContractor.NewVersion;
                }
            }
        }

        private void ValidateServiceReservation(ServiceDocument document)
        {
            //sumujemy ile towarow potrzebujemy "dorezerwowac"
            //sprawdzamy czy jest an stanie tyle dostepnych
            //jezeli nie to rzucamy wyjatek
            WarehouseItemUnitQuantityDictionary dict = new WarehouseItemUnitQuantityDictionary();

            this.mapper.AddItemsToItemTypesCache(document);
            IDictionary<Guid, Guid> cache = SessionManager.VolatileElements.ItemTypesCache;

            foreach (var line in document.Lines)
            {
                Guid itemTypeId = cache[line.ItemId];
                ItemType itemType = DictionaryMapper.Instance.GetItemType(itemTypeId);

                if (!itemType.IsWarehouseStorable)
                    continue;

                if (line.OrderDirection == -1)
                {
                    decimal quantity = line.Quantity;

                    CommercialDocumentLine altLine = line.AlternateVersion as CommercialDocumentLine;

                    if (altLine != null)
                        quantity -= altLine.Quantity;

                    dict.Add(line.WarehouseId.Value, line.ItemId, line.UnitId, quantity);
                }
            }

            ServiceDocument alternateDocument = document.AlternateVersion as ServiceDocument;

            if (alternateDocument != null)
            {
                foreach (var line in alternateDocument.Lines)
                {
                    if (line.Status == BusinessObjectStatus.Deleted && line.OrderDirection == -1)
                    {
                        dict.Add(line.WarehouseId.Value, line.ItemId, line.UnitId, -line.Quantity);
                    }
                }
            }

            List<DeliveryRequest> deliveryRequests = new List<DeliveryRequest>();

            foreach (Guid warehouseId in dict.Dictionary.Keys)
            {
                var itemUnitQtyDict = dict.Dictionary[warehouseId];

                foreach (Guid itemId in itemUnitQtyDict.Keys)
                {
                    var unitQtyDict = itemUnitQtyDict[itemId];

                    foreach (Guid unitId in unitQtyDict.Keys)
                    {
                        decimal quantity = unitQtyDict[unitId];

                        if (quantity > 0)
                        {
                            DeliveryRequest delivery = deliveryRequests.Where(d => d.ItemId == itemId && d.WarehouseId == warehouseId).FirstOrDefault();

                            if (delivery == null)
                                deliveryRequests.Add(new DeliveryRequest(itemId, warehouseId, unitId));
                        }
                    }
                }
            }

            ICollection<DeliveryResponse> deliveryResponses = this.mapper.GetDeliveries(deliveryRequests);

            foreach (Guid warehouseId in dict.Dictionary.Keys)
            {
                var itemUnitQtyDict = dict.Dictionary[warehouseId];

                foreach (Guid itemId in itemUnitQtyDict.Keys)
                {
                    var unitQtyDict = itemUnitQtyDict[itemId];

                    foreach (Guid unitId in unitQtyDict.Keys)
                    {
                        decimal quantity = unitQtyDict[unitId];

                        if (quantity > 0)
                        {
                            var deliveryResponse = deliveryResponses.Where(d => d.ItemId == itemId && d.WarehouseId == warehouseId).First();

                            if (quantity > deliveryResponse.AvailableQuantity)
                            {
                                string itemName = DependencyContainerManager.Container.Get<ItemMapper>().GetItemName(itemId);
                                string warehouseName = BusinessObjectHelper.GetBusinessObjectLabelInUserLanguage(DictionaryMapper.Instance.GetWarehouse(warehouseId)).Value;

                                throw new ClientException(ClientExceptionId.NoItemInStock, null, "itemName:" + itemName, "warehouseName:" + warehouseName);
                            }
                        }
                    }
                }
            }
        }

        public XDocument SaveBusinessObject(ServiceDocument document)
        {
            DictionaryMapper.Instance.CheckForChanges();

            //load alternate version
            if (!document.IsNew)
            {
                IBusinessObject alternateBusinessObject = this.mapper.LoadBusinessObject(document.BOType, document.Id.Value);
                document.SetAlternateVersion(alternateBusinessObject);
            }

            //update status
            document.UpdateStatus(true);

            if (document.AlternateVersion != null)
                document.AlternateVersion.UpdateStatus(false);

            document.Validate();

            this.ExecuteCustomLogic(document);
            this.ExecuteDocumentOptions(document);

            //validate
            document.Validate();

            //update status
            document.UpdateStatus(true);

            if (document.AlternateVersion != null)
                document.AlternateVersion.UpdateStatus(false);

            SqlConnectionManager.Instance.BeginTransaction();

            try
            {
                DictionaryMapper.Instance.CheckForChanges();
                this.mapper.CheckBusinessObjectVersion(document);

                this.ExecuteCustomLogicDuringTransaction(document);

                DocumentLogicHelper.AssignNumber(document, this.mapper);

                //Make operations list
                XDocument operations = XDocument.Parse("<root/>");

                document.SaveChanges(operations);

                if (document.AlternateVersion != null)
                    document.AlternateVersion.SaveChanges(operations);

                if (operations.Root.HasElements)
                {
                    this.mapper.ExecuteOperations(operations);
                    this.mapper.UpdateDictionaryIndex(document);
                }

                Coordinator.LogSaveBusinessObjectOperation();

                document.SaveRelatedObjects();

                operations = XDocument.Parse("<root/>");

                document.SaveRelations(operations);

                if (document.AlternateVersion != null)
                    ((Document)document.AlternateVersion).SaveRelations(operations);

                if (operations.Root.HasElements)
                    this.mapper.ExecuteOperations(operations);

                if (ProcessManager.Instance.IsServiceReservationEnabled(document))
                {
                    this.ValidateServiceReservation(document);
                    this.mapper.UpdateReservationAndOrderStock(document);
                }

                XDocument returnXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture, "<root><id>{0}</id></root>", document.Id.ToUpperString()));

				//Custom validation
				this.mapper.ExecuteOnCommitValidationCustomProcedure(document);
				
				if (this.coordinator.CanCommitTransaction)
                {
                    if (!ConfigurationMapper.Instance.ForceRollbackTransaction)
                        SqlConnectionManager.Instance.CommitTransaction();
                    else
                        SqlConnectionManager.Instance.RollbackTransaction();
                }

                return returnXml;
            }
            catch (SqlException sqle)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:89");
                Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:90");
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }
    }
}

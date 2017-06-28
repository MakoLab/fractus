using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.HelperObjects;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.ObjectFactories;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    internal class ComplaintDocumentLogic
    {
        private DocumentMapper mapper;
        private DocumentCoordinator coordinator;

        public ComplaintDocumentLogic(DocumentCoordinator coordinator)
        {
            this.mapper = (DocumentMapper)coordinator.Mapper;
            this.coordinator = coordinator;
        }

        private void ExecuteCustomLogic(ComplaintDocument document)
        {
            this.RealizeDecisions(document);
        }

        private void CheckForNecessaryShifts(ComplaintDocument document, IEnumerable<ComplaintDecision> decisions)
        {
            //List<Allocation> necessaryShifts = new List<Allocation>();
            AllocationCollection necessaryAllocations = new AllocationCollection();

            foreach (var decision in decisions)
            {
                Warehouse wh = DictionaryMapper.Instance.GetWarehouse(decision.WarehouseId.Value);

                if (wh.ValuationMethod == ValuationMethod.DeliverySelection)
                {
                    var allocation = necessaryAllocations.Allocations.Where(s => s.ItemId == decision.ReplacementItemId && s.WarehouseId == decision.WarehouseId.Value).FirstOrDefault();

                    //jezeli mamy juz taki shift potrzebny to tylko zwiekszamy ilosc, jesli nie to tworzymy go nowego
                    if (allocation == null)
                    {
                        allocation = new Allocation() { ItemId = decision.ReplacementItemId, WarehouseId = decision.WarehouseId.Value };
                        necessaryAllocations.Allocations.Add(allocation);
                    }

                    allocation.FirstAllocation().Quantity += decision.Quantity;
                }
            }

            bool throwException = false;

            /* sprawdzamy czy na dokumencie wybrano dostawy
             * jezeli wybrano jakies to sprawdzamy czy w wystarczajacych ilosciach
             * jezeli nie wybrano to uzupelniamy je domyslnymi dostawami i rzucamy
             * w postaci wyjatku do panelu
             */

            if (document.AllocationCollection != null) //sprawdzamy czy ilosci starczy
            {
                foreach (var necessaryAllocation in necessaryAllocations.Allocations)
                {
                    var clientAllocation = document.AllocationCollection.Allocations.Where(s => s.ItemId == necessaryAllocation.ItemId && s.WarehouseId == necessaryAllocation.WarehouseId).FirstOrDefault();

                    if (clientAllocation == null //jezeli w ogole nie wybral alokacji dla tej pary item/warehouse
                        || clientAllocation.AllocationShifts.Sum(i => i.Quantity) < necessaryAllocation.FirstAllocation().Quantity //jezeli wybral za malo
                        || clientAllocation.AllocationShifts.Where(x => x.IncomeWarehouseDocumentLineId == Guid.Empty).FirstOrDefault() != null) //jezeli nie wskazal z jakiej linii pz pochodzi
                    {
                        throwException = true;
                        break;
                    }
                }
            }
            else if (necessaryAllocations.Allocations.Count > 0)
                throwException = true;

            if (throwException)
            {
                //teraz uzupelniamy domyslne transze i kopiujemy je do nowej kolekcji (bo starej nie mozemy zmieniac jak bedziemy iterowac po niej)
                AllocationCollection allocations = new AllocationCollection();
                WarehouseMapper whMapper = DependencyContainerManager.Container.Get<WarehouseMapper>();

                foreach (var allocation in necessaryAllocations.Allocations)
                {
                    XElement xml = whMapper.GetAvailableLots(allocation.ItemId, allocation.WarehouseId);
                    XElement ptrLot = (XElement)xml.FirstNode;

                    //w tej petli nie zmieniamy wartosci co sa w xmlu xml bo i tak
                    //kazdy towar jest przerwazany tylko raz (w postaci zagregowanej)
                    while (allocation.FirstAllocation().Quantity > 0 && ptrLot != null)
                    {
                        var newAllocation = allocations.Get(allocation.ItemId, allocation.WarehouseId);

                        newAllocation.ItemName = DependencyContainerManager.Container.Get<ItemMapper>().GetItemName(newAllocation.ItemId);

                        var newAllocationItem = new AllocationShift();
                        newAllocation.AllocationShifts.Add(newAllocationItem);

                        if (ptrLot.Attribute("shiftId") != null)
                            newAllocationItem.SourceShiftId = new Guid(ptrLot.Attribute("shiftId").Value);

                        newAllocationItem.IncomeWarehouseDocumentLineId = new Guid(ptrLot.Attribute("incomeWarehouseDocumentLineId").Value);

                        if (ptrLot.Attribute("containerLabel") != null)
                            newAllocationItem.ContainerLabel = ptrLot.Attribute("containerLabel").Value;

                        if (ptrLot.Attribute("slotContainerLabel") != null)
                            newAllocationItem.SlotContainerLabel = ptrLot.Attribute("slotContainerLabel").Value;

                        decimal lotQuantity = Convert.ToDecimal(ptrLot.Attribute("quantity").Value, CultureInfo.InvariantCulture);

                        if (lotQuantity >= allocation.FirstAllocation().Quantity) //jest wiecej niz potrzebujemy
                        {
                            newAllocationItem.Quantity = allocation.FirstAllocation().Quantity;
                            allocation.FirstAllocation().Quantity = 0;
                        }
                        else
                        {
                            newAllocationItem.Quantity = lotQuantity;
                            allocation.FirstAllocation().Quantity -= lotQuantity;
                        }

                        ptrLot = (XElement)ptrLot.NextNode;
                    }

                    if (allocation.FirstAllocation().Quantity != 0)
                    {
                        string itemName = DependencyContainerManager.Container.Get<ItemMapper>().GetItemName(allocation.ItemId);
                        string warehouseName = DictionaryMapper.Instance.GetWarehouse(allocation.WarehouseId).Symbol;
                        throw new ClientException(ClientExceptionId.NoItemInStock, null, "itemName:" + itemName, "warehouseName:" + warehouseName);
                    }
                }

                XElement xmlData = allocations.Serialize();
                throw new ClientException(ClientExceptionId.SelectLots) { XmlData = xmlData };
            }
        }

        private void RealizeDecisions(ComplaintDocument document)
        {
            var decisionsToRealize = from line in document.Lines.Children
                                     from decision in line.ComplaintDecisions.Children
                                     where decision.IsMarkedForRealization()
                                     select decision;

            this.CheckForNecessaryShifts(document, decisionsToRealize);

            List<WarehouseDocument> generatedWhDocs = new List<WarehouseDocument>();
            List<ComplaintDecision> realizedDecisions = new List<ComplaintDecision>();

            foreach (var decision in decisionsToRealize)
            {
                if (decision.DecisionType == DecisionType.Disposal)
                    this.AddPositionToWarehouseDocument(document, decision.WarehouseId.Value, generatedWhDocs, decision.ReplacementItemId,
                        decision.Quantity, decision.ReplacementUnitId, WarehouseDirection.Outcome);
                else if (decision.DecisionType == DecisionType.ReturnToSupplier)
                {
                    this.AddPositionToWarehouseDocument(document, decision.WarehouseId.Value, generatedWhDocs, decision.ReplacementItemId,
                        decision.Quantity, decision.ReplacementUnitId, WarehouseDirection.Outcome);

                    ComplaintDocumentLine line = (ComplaintDocumentLine)decision.Parent;

                    this.AddPositionToWarehouseDocument(document, ProcessManager.Instance.GetComplaintWarehouse(document), generatedWhDocs, line.ItemId,
                        decision.Quantity, line.UnitId, WarehouseDirection.Income);
                }

                realizedDecisions.Add(decision);
            }

            foreach (var decision in realizedDecisions)
            {
                decision.RealizeOption = RealizationStage.Realized;
            }

            this.ValuateInternalIncomes(generatedWhDocs);
        }

        private void ValuateInternalIncomes(ICollection<WarehouseDocument> generatedWhDocs)
        {
            List<Guid> itemsId = new List<Guid>();

            foreach (var whDoc in generatedWhDocs)
            {
                if (whDoc.WarehouseDirection == WarehouseDirection.Income)
                {
                    foreach (var line in whDoc.Lines.Children)
                    {
                        if (!itemsId.Contains(line.ItemId))
                            itemsId.Add(line.ItemId);
                    }
                }
            }

            XDocument xml = DependencyContainerManager.Container.Get<ItemMapper>().GetItemsDetailsForDocument(true, null, null, itemsId);

            foreach (var whDoc in generatedWhDocs)
            {
                if (whDoc.WarehouseDirection == WarehouseDirection.Income)
                {
                    foreach (var line in whDoc.Lines.Children)
                    {
                        XElement xmlLine = xml.Root.Elements().Where(x => x.Attribute("id").Value == line.ItemId.ToUpperString()).FirstOrDefault();

                        if (xmlLine != null && xmlLine.Attribute("lastPurchasePrice") != null)
                        {
                            line.Price = Convert.ToDecimal(xmlLine.Attribute("lastPurchasePrice").Value, CultureInfo.InvariantCulture);
                            line.Value = Decimal.Round(line.Quantity * line.Price, 2, MidpointRounding.AwayFromZero);
                        }
                    }

                    whDoc.Value = whDoc.Lines.Children.Sum(s => s.Value);
                }
            }
        }

        private void AddPositionToWarehouseDocument(ComplaintDocument complaintDocument, Guid warehouseId, List<WarehouseDocument> generatedWhDocs, Guid itemId, decimal quantity, Guid unitId, WarehouseDirection direction)
        {
            WarehouseDocument document = (from whDoc in generatedWhDocs
                                          where whDoc.WarehouseId == warehouseId &&
                                          whDoc.WarehouseDirection == direction
                                          select whDoc).FirstOrDefault();

            if (document == null)
            {
                string documentName = null;

                if (direction == WarehouseDirection.Outcome)
                    documentName = "internalOutcome";
                else
                    documentName = "internalIncome";

                string template = ProcessManager.Instance.GetDocumentTemplate(complaintDocument, documentName);

                using (DocumentCoordinator c = new DocumentCoordinator(false, false))
                {
                    document = (WarehouseDocument)c.CreateNewBusinessObject(BusinessObjectType.WarehouseDocument, template, null);
                    document.WarehouseId = warehouseId;
                    string processType = complaintDocument.Attributes[DocumentFieldName.Attribute_ProcessType].Value.Value;
                    ProcessManager.Instance.AppendProcessAttributes(document, processType, documentName, null, null);
                    document.Contractor = complaintDocument.Contractor;
                    DuplicableAttributeFactory.DuplicateAttributes(complaintDocument, document);
                    complaintDocument.AddRelatedObject(document);
                    generatedWhDocs.Add(document);

                    var relation = complaintDocument.Relations.CreateNew();
                    relation.RelationType = DocumentRelationType.ComplaintToInternalOutcome;
                    relation.RelatedDocument = document;

                    relation = document.Relations.CreateNew();
                    relation.RelationType = DocumentRelationType.ComplaintToInternalOutcome;
                    relation.RelatedDocument = complaintDocument;
                    relation.DontSave = true;
                }
            }

            WarehouseDocumentLine line = document.Lines.Children.Where(l => l.ItemId == itemId).FirstOrDefault();

            if (line == null)
            {
                line = document.Lines.CreateNew();
                line.ItemId = itemId;
                line.UnitId = unitId;
            }

            line.Quantity += quantity;

            /* sprawdzamy czy jest to rozchod z magazynu wmsowego. jezeli tak to tworzymy shift transaction
             * dodajemy nowego shifta zgodnie z tym co jest w complaintDocument.Shifts, potem
             * shifta wiazemy z pozycja
             */

            if (DictionaryMapper.Instance.GetWarehouse(document.WarehouseId).ValuationMethod == ValuationMethod.DeliverySelection)
            {
                ShiftTransaction shiftTransaction = document.ShiftTransaction;

                if (shiftTransaction == null)
                {
                    shiftTransaction = new ShiftTransaction(null);
                    document.ShiftTransaction = shiftTransaction;
                }

                //wyciagamy shifty z complaintDocumenta
                var shifts = complaintDocument.AllocationCollection.Allocations.Where(s => s.ItemId == itemId && s.WarehouseId == warehouseId).Select(x => x.AllocationShifts).FirstOrDefault();

                decimal quantityToGo = quantity; //kopiujemy shifty na ilosc niewieksza niz na pozycji jest wybrane

                foreach (var shift in shifts)
                {
                    if (shift.Quantity == 0)
                        continue;

                    decimal quantityTaken = 0;

                    if (quantityToGo > shift.Quantity)
                        quantityTaken = shift.Quantity;
                    else //quantityToGo <= shift.Quantity
                        quantityTaken = quantityToGo;
                        
                    shift.Quantity -= quantityTaken;
                    quantityToGo -= quantityTaken;

                    if (shift.SourceShiftId != null) //te ktore nie maja sourceShiftId pomijamy bo tutaj takie luzem w ogole nie maja shifta
                    {
                        var newShift = shiftTransaction.Shifts.CreateNew();
                        newShift.ItemId = itemId;
                        newShift.WarehouseId = warehouseId;
                        newShift.SourceShiftId = shift.SourceShiftId.Value;
                        newShift.IncomeWarehouseDocumentLineId = shift.IncomeWarehouseDocumentLineId;
                        newShift.Quantity = quantityTaken;
                        newShift.RelatedWarehouseDocumentLine = line;
                        newShift.LineOrdinalNumber = line.OrdinalNumber;
                    }

                    //teraz incomeOutcomeRelation dodajemy
                    IncomeOutcomeRelation relation = line.IncomeOutcomeRelations.Children.Where(i => i.RelatedLine.Id.Value == shift.IncomeWarehouseDocumentLineId).FirstOrDefault();

                    if (relation == null)
                    {
                        relation = line.IncomeOutcomeRelations.CreateNew();

                        var incLine = new WarehouseDocumentLine(null);
                        incLine.Id = shift.IncomeWarehouseDocumentLineId;
                        relation.RelatedLine = incLine;
                    }

                    relation.Quantity += quantityTaken;

                    if (quantityToGo == 0)
                        break;
                }
            }
        }

        private void SetIssuingPerson(ComplaintDocument document)
        {
            Guid userId = SessionManager.User.UserId;

            foreach (var line in document.Lines.Children)
            {
                if (line.IsNew)
                    line.IssuingPersonContractorId = userId;

                foreach (var decision in line.ComplaintDecisions.Children)
                {
                    if (decision.IsNew)
                        decision.IssuingPersonContractorId = userId;
                }
            }
        }

        private void ExecuteDocumentOptions(Document document)
        {
            foreach (IDocumentOption option in document.DocumentOptions)
            {
                option.Execute(document);
            }
        }

        /// <summary>
        /// Saves the business object.
        /// </summary>
        /// <param name="document"><see cref="CommercialDocument"/> to save.</param>
        /// <returns>Xml containing result of oper</returns>
        public XDocument SaveBusinessObject(ComplaintDocument document)
        {
            DictionaryMapper.Instance.CheckForChanges();

            //load alternate version
            if (!document.IsNew)
            {
                IBusinessObject alternateBusinessObject = this.mapper.LoadBusinessObject(document.BOType, document.Id.Value);
                document.SetAlternateVersion(alternateBusinessObject);
            }

            this.SetIssuingPerson(document);

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

                DocumentLogicHelper.AssignNumber(document, this.mapper);

                //Make operations list
                XDocument operations = XDocument.Parse("<root/>");

                document.SaveChanges(operations);

                if (document.AlternateVersion != null)
                    document.AlternateVersion.SaveChanges(operations);

                if (operations.Root.HasElements)
                {
                    this.mapper.ExecuteOperations(operations);
                    this.mapper.CreateCommunicationXml(document);
                    this.mapper.UpdateDictionaryIndex(document);
                }

                Coordinator.LogSaveBusinessObjectOperation();

                document.SaveRelatedObjects();

                operations = XDocument.Parse("<root/>");

                document.SaveRelations(operations);

                if (document.AlternateVersion != null)
                    ((ComplaintDocument)document.AlternateVersion).SaveRelations(operations);

                if (operations.Root.HasElements)
                    this.mapper.ExecuteOperations(operations);

                if (operations.Root.HasElements)
                    this.mapper.CreateCommunicationXmlForDocumentRelations(operations); //generowanie paczek dla relacji dokumentow

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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:53");
                Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:54");
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }
    }
}

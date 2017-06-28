using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.MethodInputParameters;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    internal class OutcomeShiftWarehouseDocumentLogic : WarehouseDocumentLogic
    {
        public OutcomeShiftWarehouseDocumentLogic(DocumentCoordinator coordinator)
            : base(coordinator)
        {
        }

        private void GenerateLines(WarehouseDocument sourceDocument, WarehouseDocument destinationDocument)
        {
            //look for new and modified lines
            List<DeliveryRequest> deliveryRequests = new List<DeliveryRequest>();

            //collection of lines that are new, modified or deleted and require further processing.
            List<WarehouseDocumentLine> linesToProcess = new List<WarehouseDocumentLine>();

            foreach (WarehouseDocumentLine line in sourceDocument.Lines.Children)
            {
                DeliveryRequest delivery = deliveryRequests.Where(d => d.ItemId == line.ItemId && d.WarehouseId == line.WarehouseId).FirstOrDefault();

                if (delivery == null)
                    deliveryRequests.Add(new DeliveryRequest(line.ItemId, line.WarehouseId, line.UnitId));

                linesToProcess.Add(line);
            }

            ICollection<DeliveryResponse> deliveryResponses = this.mapper.GetDeliveries(deliveryRequests);

            IOutcomeStrategy strategy = OutcomeStrategyManager.Instance.GetOutcomeStrategy(sourceDocument.WarehouseId);
            strategy.CreateLinesForOutcomeShiftDocument(linesToProcess, deliveryResponses, destinationDocument);
        }

        protected void CorrectDocumentConsistency(WarehouseDocument document)
        {
            DateTime documentIssueDate = document.IssueDate;

            //FIX by ambro
            if (document.IsNew)
            {
                DateTime currentIssueDate = SessionManager.VolatileElements.CurrentDateTime;
                document.IssueDate = currentIssueDate;
                documentIssueDate = currentIssueDate;
            }
            //FIX by ambro
            Guid warehouseId = document.WarehouseId;

            foreach (WarehouseDocumentLine line in document.Lines.Children)
            {
                line.OutcomeDate = documentIssueDate;
                line.WarehouseId = warehouseId;
            }

            if (document.ShiftTransaction != null)
            {
                foreach (Shift shift in document.ShiftTransaction.Shifts.Children)
                {
                    shift.WarehouseId = warehouseId;
                }
            }

            this.DeliverySelectionCheck(document);
        }

        private void ProcessLocalOutcomeShift(WarehouseDocument document)
        {
            if (document.Status != BusinessObjectStatus.New && document.Status != BusinessObjectStatus.Modified
				&& !document.Attributes.IsAnyChildNew() && !document.Attributes.IsAnyChildModified() )
                return;

            if (document.IsLocalShift()) //mamy MMke lokalna
            {
                XElement outcomeShiftDbXml = this.mapper.LoadWarehouseDocumentDbXml(document.Id.Value);

                //zeby xml byl zgodny z takim jaki uzywa komunikacja (bo ja bedziemy "emulowac") to musimy na wycenach poustawiac
                //ordinal number pozycji ktorych dotycza
                foreach (XElement valuation in outcomeShiftDbXml.Element("warehouseDocumentValuation").Elements())
                {
                    string outcomeWarehouseDocumentLineId = valuation.Element("outcomeWarehouseDocumentLineId").Value;
                    string ordinalNumber = outcomeShiftDbXml.Element("warehouseDocumentLine").Elements().Where(l => l.Element("id").Value == outcomeWarehouseDocumentLineId).First().Element("ordinalNumber").Value;
                    valuation.Add(new XAttribute("outcomeShiftOrdinalNumber", ordinalNumber));
                }

                outcomeShiftDbXml.Element("warehouseDocumentValuation").Add(new XAttribute("outcomeShiftId", document.Id.ToUpperString()));

                using (DocumentCoordinator c = new DocumentCoordinator(false, false))
                {
                    c.CreateOrUpdateIncomeShiftDocumentFromOutcomeShift(outcomeShiftDbXml);
                    c.ValuateIncomeShiftDocument(outcomeShiftDbXml);
                }
            }
        }

        public XDocument SaveBusinessObject(WarehouseDocument shiftDocument)
        {
            DictionaryMapper.Instance.CheckForChanges();

            this.CorrectDocumentConsistency(shiftDocument);

            shiftDocument.Validate();

            //WarehouseDocument document = (WarehouseDocument)this.coordinator.CreateNewBusinessObject(BusinessObjectType.WarehouseDocument, "outcomeShift", null);
            //document.Deserialize(shiftDocument.Serialize());
            //zmienione bo shiftTransaction sie nie przenosilo
            WarehouseDocument document = (WarehouseDocument)mapper.ConvertToBusinessObject(shiftDocument.FullXml.Root.Element("warehouseDocument"), shiftDocument.FullXml.Root.Element("options"));

            if (document.IsNew) //jezeli to edycja to nie ruszamy linii
                document.Lines.RemoveAll();

			SqlConnectionManager.Instance.BeginTransaction();

			try
			{
				DictionaryMapper.Instance.CheckForChanges();
                this.mapper.CheckBusinessObjectVersion(document);

                if (document.IsNew) //jezeli to edycja to nie ruszamy linii
                    this.GenerateLines(shiftDocument, document);

				this.ExecuteDocumentOptions(document);

                document.Validate();

                //load alternate version
                if (!document.IsNew)
                {
                    IBusinessObject alternateBusinessObject = this.mapper.LoadBusinessObject(document.BOType, document.Id.Value);
                    document.SetAlternateVersion(alternateBusinessObject);
                }

                DocumentLogicHelper.AssignNumber(document, this.mapper);

                document.UpdateStatus(true);

                if (document.AlternateVersion != null)
                    document.AlternateVersion.UpdateStatus(false);

                this.coordinator.UpdateStock(document);

                this.ValidateShiftsToLinesRelations(document);

                if (document.DocumentStatus == DocumentStatus.Canceled && ConfigurationMapper.Instance.IsWmsEnabled)
                    DependencyContainerManager.Container.Get<WarehouseMapper>().DeleteShiftsForDocument(document.Id.Value);

                XDocument operations = XDocument.Parse("<root/>");

                document.SaveChanges(operations);

                if (document.AlternateVersion != null)
                    document.AlternateVersion.SaveChanges(operations);

                document.SaveRelations(operations);

                if (document.AlternateVersion != null)
                    ((WarehouseDocument)document.AlternateVersion).SaveRelations(operations);

                if (operations.Root.HasElements)
                {
                    //this.mapper.UpdateStockForCanceledDocument(document);
                    this.mapper.ExecuteOperations(operations);

                    if (document.IsNew)
                        this.mapper.ValuateOutcomeWarehouseDocument(document);

                    this.mapper.CreateCommunicationXml(document);
                    this.mapper.CreateCommunicationXmlForDocumentRelations(operations);
                    this.mapper.UpdateDictionaryIndex(document);
                }

				//MM- może realizować rezerwację
				this.mapper.UpdateReservationAndOrderStock(document);
				
				WarehouseCoordinator.ProcessWarehouseManagamentSystem(document.ShiftTransaction);

                Coordinator.LogSaveBusinessObjectOperation();

                this.ProcessLocalOutcomeShift(document);

                if (document.DraftId != null)
                    this.mapper.DeleteDraft(document.DraftId.Value);

                XDocument returnXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture, "<root><id>{0}</id></root>", shiftDocument.Id.Value.ToUpperString()));

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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:78");
                Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:79");
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }
    }
}

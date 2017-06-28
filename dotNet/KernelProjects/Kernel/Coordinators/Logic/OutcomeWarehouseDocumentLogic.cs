using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.MethodInputParameters;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    /// <summary>
    /// Class that contains logic of outcome warehouse documents.
    /// </summary>
    internal class OutcomeWarehouseDocumentLogic : WarehouseDocumentLogic
    {
        public OutcomeWarehouseDocumentLogic(DocumentCoordinator coordinator)
            : base(coordinator)
        {
        }

        /// <summary>
        /// Corrects the document consistency that comes from client and can be incomplete.
        /// </summary>
        /// <param name="document">The document to correct.</param>
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

            this.DeliverySelectionCheck(document);
        }

        /// <summary>
        /// Saves the business object.
        /// </summary>
        /// <param name="document"><see cref="WarehouseDocument"/> to save.</param>
        /// <returns>Xml containing result of oper</returns>
        public XDocument SaveBusinessObject(WarehouseDocument document)
        {
			DictionaryMapper.Instance.CheckForChanges();

            //correct the document that comes from client
            this.CorrectDocumentConsistency(document);

            this.ExecuteDocumentOptions(document);

            //validate
            document.Validate();

			//Walidacja zmian w dokumencie realizującym zamówienie sprzedażowe
			document.CheckDoesRealizeClosedSalesOrder(coordinator);

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

			SqlConnectionManager.Instance.BeginTransaction();

			try
			{
				DictionaryMapper.Instance.CheckForChanges();
                this.mapper.CheckBusinessObjectVersion(document);

				//logika dla automatycznego zamykania ZS w realizacji bezzaliczkowej
				this.coordinator.TryCloseSalesOrdersWhileRealization(document);

				this.coordinator.UpdateStock(document);

                this.ValidationDuringTransaction(document);

                if (document.DocumentStatus == DocumentStatus.Canceled && ConfigurationMapper.Instance.IsWmsEnabled)
                    DependencyContainerManager.Container.Get<WarehouseMapper>().DeleteShiftsForDocument(document.Id.Value);

                if (!document.IsNew && document.DocumentStatus == DocumentStatus.Committed)
                    this.mapper.DeleteIncomeOutcomeRelations(document);

                if (document.DocumentStatus == DocumentStatus.Committed)
                    this.ProcessIncomeOutcome(document);

					DocumentLogicHelper.AssignNumber(document, this.mapper);

                //Make operations list
                XDocument operations = XDocument.Parse("<root/>");

                document.SaveChanges(operations);

                if (document.AlternateVersion != null)
                    document.AlternateVersion.SaveChanges(operations);
				
				if (operations.Root.HasElements)
                {
                   // this.mapper.UpdateStockForCanceledDocument(document);
                    this.mapper.ExecuteOperations(operations);
                    this.mapper.ValuateOutcomeWarehouseDocument(document);
                    this.mapper.CreateCommunicationXml(document);
                    this.mapper.CreateCommunicationXmlForDocumentRelations(operations);
                    this.mapper.UpdateDictionaryIndex(document);
                }


                Coordinator.LogSaveBusinessObjectOperation();

                document.SaveRelatedObjects();

                operations = XDocument.Parse("<root/>");

                document.SaveRelations(operations);

                if (document.AlternateVersion != null)
                    ((WarehouseDocument)document.AlternateVersion).SaveRelations(operations);

                if (operations.Root.HasElements)
                {
                    this.mapper.ExecuteOperations(operations);
                    this.mapper.CreateCommunicationXmlForDocumentRelations(operations); //generowanie paczek dla relacji dokumentow
                }

                this.mapper.DeleteDocumentAccountingData(document);

                this.mapper.UpdateReservationAndOrderStock(document);

                WarehouseCoordinator.ProcessWarehouseManagamentSystem(document.ShiftTransaction);
  
                //Custom validation
                this.mapper.ExecuteOnCommitValidationCustomProcedure(document);
                Coordinator.LogSaveBusinessObjectOperation();

                if (document.DraftId != null)
                    this.mapper.DeleteDraft(document.DraftId.Value);

                XDocument returnXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture, "<root><id>{0}</id></root>", document.Id.ToUpperString()));

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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:80");
                Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:81");
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }

        protected void ProcessIncomeOutcome(WarehouseDocument document)
        {
            //look for new and modified lines
            List<DeliveryRequest> deliveryRequests = new List<DeliveryRequest>();

            //collection of lines that are new, modified or deleted and require further processing.
            List<WarehouseDocumentLine> linesToProcess = new List<WarehouseDocumentLine>();

            foreach (WarehouseDocumentLine line in document.Lines.Children)
            {
                DeliveryRequest delivery = deliveryRequests.Where(d => d.ItemId == line.ItemId && d.WarehouseId == line.WarehouseId).FirstOrDefault();

                if (delivery == null)
                    deliveryRequests.Add(new DeliveryRequest(line.ItemId, line.WarehouseId, line.UnitId));

                linesToProcess.Add(line);
            }

            ICollection<DeliveryResponse> deliveryResponses = this.mapper.GetDeliveries(deliveryRequests);

            IOutcomeStrategy strategy = OutcomeStrategyManager.Instance.GetOutcomeStrategy(document.WarehouseId);
            strategy.CreateOutcomes(linesToProcess, deliveryResponses);
        }

        /// <summary>
        /// Validations the document during transaction.
        /// </summary>
        /// <param name="document">The document to validate.</param>
        private void ValidationDuringTransaction(WarehouseDocument document)
        {
            if (!document.IsNew)
            {
                if (this.mapper.HasOutcomeDocumentAnyCommercialRelation(document.Id.Value) &&
                    (document.Lines.IsAnyChildNew() || document.Lines.IsAnyChildModified() || document.Lines.IsAnyChildDeleted()))
                    throw new ClientException(ClientExceptionId.UnableToEditOutcomeWarehouseDocument2);

                ICollection<Guid> allCorrections = mapper.GetWarehouseCorrectiveDocumentsId(document.Id.Value);

                if (allCorrections != null && allCorrections.Count != 0 && !document.CorrectedDocumentEditEnabled)
                    throw new ClientException(ClientExceptionId.UnableToEditDocumentBecauseOfCorrections);
            }

            this.ValidateShiftsToLinesRelations(document);

            if (document.IsNew && document.Source != null && document.Source.Attribute("type") != null &&
                document.Source.Attribute("type").Value == "multipleReservations")
            {
                string[] versions = document.Tag.Split(new char[] { ',' });

                foreach (string version in versions)
                {
                    this.mapper.CheckCommercialDocumentVersion(new Guid(version));
                }
            }
        }
    }
}

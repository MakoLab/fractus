using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.MethodInputParameters;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    /// <summary>
    /// Class that contains logic of income warehouse documents.
    /// </summary>
    internal class IncomeWarehouseDocumentLogic : WarehouseDocumentLogic
    {
        public IncomeWarehouseDocumentLogic(DocumentCoordinator coordinator)
            : base(coordinator)
        {
        }

        /// <summary>
        /// Corrects the document consistency that comes from client and can be incomplete.
        /// </summary>
        /// <param name="document">The document to correct.</param>
        private void CorrectDocumentConsistency(WarehouseDocument document)
        {
            DateTime documentIssueDate = document.IssueDate;

            if (!document.IsNew)
            {
                //if its editing process so we can change the issue date to the current date if
                //there is any new position
                DateTime currentIssueDate = SessionManager.VolatileElements.CurrentDateTime;

                if ((documentIssueDate.Year != currentIssueDate.Year ||
                        documentIssueDate.Month != currentIssueDate.Month ||
                        documentIssueDate.Day != currentIssueDate.Day) && document.Lines.IsAnyChildNew())
                {
                    document.IssueDate = currentIssueDate;
                    documentIssueDate = document.IssueDate;
                }
            }
            //FIX by ambro
            else
            {
                DateTime currentIssueDate = SessionManager.VolatileElements.CurrentDateTime;
                document.IssueDate = SessionManager.VolatileElements.CurrentDateTime;
                documentIssueDate = document.IssueDate;
            }
            //FIX by ambro

            Guid warehouseId = document.WarehouseId;

            foreach (WarehouseDocumentLine line in document.Lines.Children)
            {
                line.IncomeDate = documentIssueDate;
                line.WarehouseId = warehouseId;
            }

            this.DeliverySelectionCheck(document);

            this.GenerateAndUpdateCommercialWarehouseValuations(document);
        }

        /// <summary>
        /// Generates the and update commercial warehouse valuations.
        /// </summary>
        /// <param name="document">The document that contains lines to generate and update valuations.</param>
        private void GenerateAndUpdateCommercialWarehouseValuations(WarehouseDocument document)
        {
            if (document.SkipManualValuations) return;

            this.ValuateFromOutcome(document);

            foreach (WarehouseDocumentLine line in document.Lines.Children)
            {
				int cwvCount = line.CommercialWarehouseValuations.Children.Count;
				bool beforeSystemStartCorrectionLine = line.Direction < 0 && line.Quantity < 0; 

				if (line.Value == 0)
				{
                    continue;
					//line.CommercialWarehouseValuations.RemoveAll();
					//document.Value = 0;
				}
				else if (line.Value != 0 && cwvCount >= 0 && cwvCount <=1) //create new valuation or remove and create (update)
				{
					if (cwvCount == 1)
					{
						line.CommercialWarehouseValuations.RemoveAll();
					}
					CommercialWarehouseValuation valuation = line.CommercialWarehouseValuations.CreateNew();
					valuation.Quantity = line.Quantity;
					valuation.Price = line.Price;
					valuation.Value = line.Value;
					//Jeśli mamy do czynienia z korektą sprzed startu systemu wiąże wycenę z pozycją korekty sprzedażowej
					//na podstawie commercialWarehouseRelation, która jest prawidłowo powiązana
					//potrzebne to aby koszt na takiej fakturze był widoczny w zestawieniu
					if (beforeSystemStartCorrectionLine)
					{
						CommercialWarehouseRelation cwr = line.CommercialWarehouseRelations.FirstOrDefault();
						if (cwr != null && cwr.RelatedLine != null)
						{
							valuation.RelatedLine = cwr.RelatedLine;
							cwr.Value = valuation.Price;
							cwr.IsValuated = true;
						}
					}
				}
				else
					throw new InvalidOperationException("Critical and fatal exception: too many commercial warehouse valuations to update 'mon!");
            }
        }

        private void ValuateFromOutcome(WarehouseDocument document)
        {
            if (document.ValuateFromOutcomeDocumentId != null)
            {
                WarehouseDocument outcome = (WarehouseDocument)this.mapper.LoadBusinessObject(BusinessObjectType.WarehouseDocument, document.ValuateFromOutcomeDocumentId.Value);
                decimal totalValue = 0;

                foreach (var incLine in document.Lines)
                {
                    if (incLine.ValuateFromOutcomeDocumentLinesId == null) continue;

                    decimal value = outcome.Lines.Where(l => incLine.ValuateFromOutcomeDocumentLinesId.Contains(l.Id.Value)).Sum(ll => ll.Value);
                    totalValue += value;
                    incLine.Value = value;
                    incLine.Price = Decimal.Round(value / incLine.Quantity, 2, MidpointRounding.AwayFromZero);
                }

                document.Value = totalValue;
            }
        }

        /// <summary>
        /// Saves the business object.
        /// </summary>
        /// <param name="document"><see cref="WarehouseDocument"/> to save.</param>
        /// <returns>Xml containing result of oper</returns>
        public virtual XDocument SaveBusinessObject(WarehouseDocument document)
        {
            DictionaryMapper.Instance.CheckForChanges();

            //correct the document that comes from client
            this.CorrectDocumentConsistency(document);

            this.ExecuteDocumentOptions(document);

            //validate
            document.Validate();

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

                if (document.DocumentStatus == DocumentStatus.Canceled && ConfigurationMapper.Instance.IsWmsEnabled)
                    DependencyContainerManager.Container.Get<WarehouseMapper>().DeleteShiftsForDocument(document.Id.Value);

				if (document.DocumentType.WarehouseDocumentOptions.UpdateLastPurchasePrice)
				{
					UpdateLastPurchasePriceRequest updateLastPurchasePriceRequest = new UpdateLastPurchasePriceRequest(document);
					this.mapper.UpdateStock(updateLastPurchasePriceRequest);
				}

                DocumentLogicHelper.AssignNumber(document, this.mapper);

                //Make operations list
                XDocument operations = XDocument.Parse("<root/>");

                document.SaveChanges(operations);

                if (document.AlternateVersion != null)
                    document.AlternateVersion.SaveChanges(operations);

                if (operations.Root.HasElements)
                {
                    this.coordinator.UpdateStock(document);
                    //this.mapper.UpdateStockForCanceledDocument(document);

                    this.ValidationDuringTransaction(document);

                    this.mapper.ExecuteOperations(operations);

                    this.mapper.CreateCommunicationXml(document);
                    this.mapper.CreateCommunicationXmlForDocumentRelations(operations);
                    this.mapper.UpdateDictionaryIndex(document);
                }

                Coordinator.LogSaveBusinessObjectOperation();

                document.SaveRelatedObjects();

                operations = XDocument.Parse("<root/>");

                document.SaveRelations(operations);

                if (document.AlternateVersion != null)
                    ((Document)document.AlternateVersion).SaveRelations(operations);

                if (operations.Root.HasElements)
                {
                    this.mapper.ExecuteOperations(operations);
                    this.mapper.CreateCommunicationXmlForDocumentRelations(operations); //generowanie paczek dla relacji dokumentow
                }

                this.mapper.DeleteDocumentAccountingData(document);

                this.mapper.UpdateReservationAndOrderStock(document);

                WarehouseCoordinator.ProcessWarehouseManagamentSystem(document.ShiftTransaction);

                this.mapper.ValuateIncomeWarehouseDocument(document, false);

                if (document.DraftId != null)
                    this.mapper.DeleteDraft(document.DraftId.Value);

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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:70");
                Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:71");
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }

        /// <summary>
        /// Validations the document during transaction.
        /// </summary>
        /// <param name="document">The document to validate.</param>
        private void ValidationDuringTransaction(WarehouseDocument document)
        {
            if (!document.IsNew)
            {
                if (this.mapper.HasIncomeWarehouseDocumentAnyOutcomeRelation(document.Id.Value))
                {
                    //sprawdzamy czy jakies linie byly dodane nowe a jak byly to czy zmiana byla od wartosci zero do wiekszej od zera
                    foreach (WarehouseDocumentLine line in document.Lines.Children)
                    {
                        if (line.Status == BusinessObjectStatus.Modified)
                        {
                            WarehouseDocumentLine alternateLine = (WarehouseDocumentLine)line.AlternateVersion;

                            if (alternateLine.Value != 0 
                                || alternateLine.ItemId != line.ItemId 
                                || alternateLine.Quantity != line.Quantity
                                || alternateLine.Direction != line.Direction)
                                throw new ClientException(ClientExceptionId.UnableToEditIncomeWarehouseDocument);
                        }
                    }

                    if ((document.Lines.IsAnyChildNew() || document.Lines.IsAnyChildDeleted()))
                        throw new ClientException(ClientExceptionId.UnableToEditIncomeWarehouseDocument);
                }

                ICollection<Guid> allCorrections = mapper.GetWarehouseCorrectiveDocumentsId(document.Id.Value);

                if (allCorrections != null && allCorrections.Count != 0)
                    throw new ClientException(ClientExceptionId.UnableToEditDocumentBecauseOfCorrections);
            }
        }
    }
}

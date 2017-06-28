using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.Finances;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.MethodInputParameters;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    internal class FinancialReportLogic
    {
        private DocumentMapper mapper;
        private DocumentCoordinator coordinator;

        public FinancialReportLogic(DocumentCoordinator coordinator)
        {
            this.mapper = (DocumentMapper)coordinator.Mapper;
            this.coordinator = coordinator;
        }

        private void ExecuteLogic(FinancialReport document)
        {
            FinancialReport alternate = document.AlternateVersion as FinancialReport;

            if (alternate == null) //new report
            {
                document.CreatingUser = Contractor.CreateEmptyContractor(SessionManager.User.UserId);
                //document.CreationDate = SessionManager.VolatileElements.CurrentDateTime;
            }
            else
            {
                if (alternate.IsClosed == false && document.IsClosed == true)
                {
                    document.ClosingUser = Contractor.CreateEmptyContractor(SessionManager.User.UserId);
                    //document.ClosureDate = SessionManager.VolatileElements.CurrentDateTime;
                }
                else if (alternate.IsClosed == true && document.IsClosed == false)
                {
                    document.OpeningUser = Contractor.CreateEmptyContractor(SessionManager.User.UserId);
                    document.OpeningDate = SessionManager.VolatileElements.CurrentDateTime;
                }
            }
        }

        private void ValidateDuringTransaction(FinancialReport document)
        {
			FinancialReport alternate = document.AlternateVersion as FinancialReport;
			//Nie można ponownie otworzyć zaksięgowanego raportu finansowego
			if (alternate != null && alternate.IsClosed && !document.IsClosed)
			{
				string objectExportedStatus = this.mapper.GetFinancialReportStatusById(document.Id.Value);
				if ((objectExportedStatus ?? ExportToAccountingStatus.Unexported) != ExportToAccountingStatus.Unexported)
				{
					throw new ClientException(ClientExceptionId.BookedFinancialReportReopeningForbidden);
				}
			}

            Guid? openedReportId = this.mapper.GetOpenedFinancialReportId(document.FinancialRegisterId);

            if (openedReportId != null && !SessionManager.VolatileElements.SavedInThisTransaction(openedReportId.Value))
                throw new ClientException(ClientExceptionId.OpenedFinancialReportAlreadyExists);

            GetFinancialReportValidationDatesResponse response = this.mapper.GetFinancialReportValidationDates(document.FinancialRegisterId, document.CreationDate, document.Id.Value, document.IsNew);

            if (document.ClosureDate != null)
            {
                //sprawdzamy czy data zamkniecia jest < od daty otwarcia kolejnego raportu
                if (response.NextFinancialReportOpeningDate != null &&
                    document.ClosureDate.Value >= response.NextFinancialReportOpeningDate.Value)
                    throw new ClientException(ClientExceptionId.FinancialReportCloseError);

                if (response.GreatestIssueDateOnFinancialDocument != null &&
                    document.ClosureDate.Value < response.GreatestIssueDateOnFinancialDocument.Value)
                    throw new ClientException(ClientExceptionId.FinancialReportCloseError3);

                if (document.ClosureDate.Value <= document.CreationDate)
                    throw new ClientException(ClientExceptionId.FinancialReportCloseError4);
            }

            if (response.PreviousFinancialReportClosureDate != null &&
                document.IssueDate < response.PreviousFinancialReportClosureDate.Value)
                throw new ClientException(ClientExceptionId.FinancialReportCloseError2);
        }

		private Dictionary<Guid, string> ConsumeGetNextFinancialReportsIdResult(XDocument getNextFinancialReportsIdResult)
		{
			//mogą się powtarzać wyniki
			Dictionary<Guid, string> result = new Dictionary<Guid,string>();

			foreach (XElement id in getNextFinancialReportsIdResult.Root.Elements())
			{
				XAttribute objectExportedAttr = id.Attribute(XmlName.ObjectExported);
				Guid idGuid = new Guid(id.Value);
				if (!result.ContainsKey(idGuid))
				{
					result.Add(new Guid(id.Value), objectExportedAttr != null ? objectExportedAttr.Value : null);
				}
			}

			return result;
		}

        private void RecalculateFurtherReports(FinancialReport document)
        {
			XDocument getNextFinancialReportsIdResult = this.mapper.GetNextFinancialReportsId(document.Id.Value);

			Dictionary<Guid, string> nextReportsIdDict = this.ConsumeGetNextFinancialReportsIdResult(getNextFinancialReportsIdResult);

            FinancialReport previousReport = document;

            foreach (Guid id in nextReportsIdDict.Keys)
            {
                FinancialReport ptrReport = (FinancialReport)this.coordinator.LoadBusinessObject(BusinessObjectType.FinancialReport, id);

				decimal prvInitialBalance = ptrReport.InitialBalance;
                ptrReport.InitialBalance = previousReport.InitialBalance + previousReport.IncomeAmount.Value + previousReport.OutcomeAmount.Value;
				
				//Jeśli raport jest zaksięgowany a zmienił się jego bilans to rzucamy wyjątek
				if (prvInitialBalance != ptrReport.InitialBalance
					&& nextReportsIdDict.ContainsKey(ptrReport.Id.Value)
					&& nextReportsIdDict[ptrReport.Id.Value] != null
					&& nextReportsIdDict[ptrReport.Id.Value] != ExportToAccountingStatus.Unexported)
				{
					throw new ClientException(ClientExceptionId.BookedFinancialReportRecalculationForbidden);
				}

                ptrReport.SkipFurtherReportRecalculation = true;

                document.AddRelatedObject(ptrReport);
                previousReport = ptrReport;
            }
        }

        private void CalculateBalance(FinancialReport document)
        {
            if (document.ClosureDate != null)
            {
                CalculateReportBalanceResponse response = this.mapper.CalculateReportBalance(document.Id.Value);
                document.IncomeAmount = response.IncomeAmount;
                document.OutcomeAmount = response.OutcomeAmount;

                if (!document.SkipFurtherReportRecalculation)
                    this.RecalculateFurtherReports(document);
            }
            else if (document.IsNew)
            {
                //sprawdzamy czy to pierwszy raport czy juz jakeis byly
                bool exists = this.mapper.CheckReportExistence(document.FinancialRegisterId);

                if (exists)//policz raport otwarcia
                {
                    decimal initialBalance = this.mapper.CalculateReportInitialBalance(document.FinancialRegisterId);
                    document.InitialBalance = initialBalance;
                }//w przeciwnym przypadku wpisz to co wklepal uzytkownik
            }
        }

        public XDocument SaveBusinessObject(FinancialReport document)
        {
            DictionaryMapper.Instance.CheckForChanges();

            //validate
            document.Validate();

            //load alternate version
            if (!document.IsNew)
            {
                IBusinessObject alternateBusinessObject = this.mapper.LoadBusinessObject(document.BOType, document.Id.Value);
                document.SetAlternateVersion(alternateBusinessObject);
            }

            this.ExecuteLogic(document);

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

                this.ValidateDuringTransaction(document);
                this.CalculateBalance(document);

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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:67");
                Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:68");
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }
    }
}

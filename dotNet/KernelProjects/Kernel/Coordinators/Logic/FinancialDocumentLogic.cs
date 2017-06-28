using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Finances;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.ObjectFactories;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.MethodInputParameters;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    internal class FinancialDocumentLogic
    {
        private DocumentMapper mapper;
        private DocumentCoordinator coordinator;

        public FinancialDocumentLogic(DocumentCoordinator coordinator)
        {
            this.mapper = (DocumentMapper)coordinator.Mapper;
            this.coordinator = coordinator;
        }

        private void CorrectDocumentConsistency(FinancialDocument document)
        {
            foreach (Payment payment in document.Payments)
            {
				payment.ExchangeDate = document.ExchangeDate;
				payment.ExchangeRate = document.ExchangeRate;
				payment.ExchangeScale = document.ExchangeScale;
				
				if (!payment.IsNew)
                    continue;

                payment.PaymentCurrencyId = document.DocumentCurrencyId;
                payment.SystemCurrencyId = document.SystemCurrencyId;
                payment.Contractor = document.Contractor;
                payment.ContractorAddressId = document.ContractorAddressId;
                payment.Date = document.IssueDate;
                payment.DueDate = document.IssueDate;

                foreach (PaymentSettlement s in payment.Settlements.Children)
                {
                    s.Date = document.IssueDate;
                    s.Amount = payment.Amount;
                }
            }
        }

        public static void ReplaceAndValidatePayments(ICollection<Payment> allPayments, IEnumerable<Guid> paymentsToSettle, IEnumerable<PaymentSettlement> settlementsToReplace)
        {
            ICollection<Payment> relatedPayments = DependencyContainerManager.Container.Get<DocumentMapper>().GetPaymentsById(paymentsToSettle);

            foreach (var settlement in settlementsToReplace)
            {
				Payment parentPayment = (Payment)settlement.Parent;
                settlement.RelatedPayment = relatedPayments.Where(p => p.Id.Value == settlement.RelatedPayment.Id.Value).FirstOrDefault();
				if (settlement.RelatedPayment == null)
				{
					throw new ClientException(ClientExceptionId.AutomaticFinancialDocumentUpdateException);
				}

                //sprawdzamy czy suma rozliczen wyzej przylaczonej platnosci + biezacy settlement nie jest wieksza od platnosci
                decimal settledAmount = settlement.RelatedPayment.Settlements.Children.Where(ss => ss.Id.Value != settlement.Id.Value).Sum(s => s.Amount);
                decimal currentPaymentAmount = Math.Abs(parentPayment.Amount);
                decimal relatedPaymentAmount = Math.Abs(settlement.RelatedPayment.Amount);
                //dodajemy tutaj jeszcze sume rozliczen do tego rozliczenia ktora znajduje sie w biezacym dokumencie
                //bo moze byc sytuacja ze 2 pozycje z aktualnego dokumentu rozliczaja ten sam payment i wtedy dla
                //drugiej pozycji trzeba jeszcze posumowac fakt ze pierwsza juz rozlicza ten sam payment

                var settlementInCurrentDoc = (from pt in allPayments
                                              where pt.Settlements.Children.Count > 0
                                              from s in pt.Settlements.Children
                                              where s.RelatedPayment.Id.Value == settlement.RelatedPayment.Id.Value
                                              && s.Id.Value != settlement.Id.Value
                                              && s.IsNew
                                              select s.Amount).Sum();

                settledAmount += settlementInCurrentDoc;

                if (Math.Round(relatedPaymentAmount - settledAmount - settlement.Amount, 2, MidpointRounding.AwayFromZero) < 0)
                    throw new ClientException(ClientExceptionId.PaymentSettlementException, null,
                        "docNumber:" + settlement.RelatedPayment.DocumentFullNumber,
                        "amount:" + settlement.Amount.ToString(CultureInfo.InvariantCulture),
                        "currencySymbol:" + DictionaryMapper.Instance.GetCurrency(settlement.RelatedPayment.PaymentCurrencyId).Symbol);

                if (settlement.Amount > currentPaymentAmount)
                    throw new ClientException(ClientExceptionId.SettlementException);

				if (parentPayment.PaymentCurrencyId != settlement.RelatedPayment.PaymentCurrencyId)
					throw new ClientException(ClientExceptionId.SettlementPaymentsCurrencyMismatch);
            }
        }

        private void ExecuteLogicDuringTransaction(FinancialDocument document)
        {
            //doczytujemy wszystkie platnosci ktore mamy powiazac wraz z ich pozostalymi rozliczeniami
            var paymentsToSettle = (from pt in document.Payments.Children
                                    from s in pt.Settlements.Children
                                    where s.Status == BusinessObjectStatus.New ||
                                        s.Status == BusinessObjectStatus.Modified
                                    select s.RelatedPayment.Id.Value).Distinct();

			//kopiujemy to do listy bo jak linq w locie iteruje to man sie potem w locie zmieni wartosc
			List<Guid> paymentsToSettleList = paymentsToSettle.ToList();

            var settlementsToReplace = from pt in document.Payments.Children
                                       from s in pt.Settlements.Children
                                       where s.Status == BusinessObjectStatus.New ||
                                        s.Status == BusinessObjectStatus.Modified
                                       select s;

			//j.w.
			List<PaymentSettlement> settlementsToReplaceList = settlementsToReplace.ToList();

            FinancialDocumentLogic.ReplaceAndValidatePayments(document.Payments.Children, paymentsToSettleList, settlementsToReplaceList);
        }

        private void ValidateDuringTransaction(FinancialDocument document)
        {
			FinancialRegister financialRegister = DictionaryMapper.Instance.GetFinancialRegister(document.FinancialReport.FinancialRegisterId);
			//Sprawdzenie czy stanowisko ma uprawnienia do dodawania określonych płatności do raportu finansowego na wybranym rejestrze
			if (!financialRegister.IsAllowedByProfile())
			{
				throw new ClientException(ClientExceptionId.UnableToIssueFinancialDocument4);
			}

            Guid? openedReportId = this.mapper.GetOpenedFinancialReportId(document.FinancialReport.FinancialRegisterId);

            if (openedReportId == null)
                throw new ClientException(ClientExceptionId.OpenedFinancialReportDoesNotExist);
            else if(openedReportId.Value != document.FinancialReport.Id.Value)
                throw new ClientException(ClientExceptionId.UnableToIssueDocumentToClosedFinancialReport);

            XElement dates = this.mapper.GetFinancialReportsDate(document.FinancialReport.FinancialRegisterId);
            DateTime openedReportCreationDate = DateTime.Parse(dates.Element("openedReportCreationDate").Value, CultureInfo.InvariantCulture);
            DateTime? nextReportCreationDate = null;

            if (dates.Element("nextReportCreationDate") != null)
                nextReportCreationDate = DateTime.Parse(dates.Element("nextReportCreationDate").Value, CultureInfo.InvariantCulture);

            if (document.IssueDate < openedReportCreationDate)
                throw new ClientException(ClientExceptionId.UnableToIssueFinancialDocument);

            if (nextReportCreationDate != null && document.IssueDate >= nextReportCreationDate.Value)
                throw new ClientException(ClientExceptionId.UnableToIssueFinancialDocument2);
		}

		private void ValidateAfterSave(FinancialDocument document)
		{
			#region Blokada zejścia ze stanem finansowym poniżej 0
			FinancialRegister financialRegister = DictionaryMapper.Instance.GetFinancialRegister(document.FinancialReport.FinancialRegisterId);
			if (financialRegister.ValidateBalanceBelowZero)
			{
				if (this.mapper.GetFinancialReportBalance(document.FinancialReport.FinancialRegisterId) < 0)
				{
					throw new ClientException(ClientExceptionId.FinancialRegisterBalanceBelowZero);
				}
			}
			#endregion
		}

        private string AmountToStr(decimal amount)
        {
            return String.Format(" ({0})", amount.ToString(CultureInfo.InvariantCulture).Replace('.', ','));
        }

        private string MergeDescriptions(FinancialDocument document)
        {
            string mergedText = String.Empty;
            string previousText = null;

            foreach (var line in document.Payments)
            {
                if (line.Amount < 0 || line.Description == null) continue;

                //mergujemy text
                if (previousText == null)
                {
                    mergedText = line.Description;

                    if (line.IsNew)
                        mergedText += this.AmountToStr(line.Amount);
                }
                else
                {
                    string[] previous = previousText.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                    string[] current = line.Description.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);

                    int min = Math.Min(previous.Length, current.Length);

                    for (int i = 0; i < min; i++)
                    {
                        if (previous[i] != current[i])
                        {
                            mergedText += ", ";

                            for (int u = i; u < current.Length; u++)
                            {
                                mergedText += current[u];

                                if (u + 1 < current.Length)
                                    mergedText += " ";
                            }

                            break;
                        }
                    }

                    mergedText += this.AmountToStr(line.Amount);
                }

                previousText = line.Description;
            }

            return mergedText;
        }

        private void MergePayments(FinancialDocument document)
        {
            if (!ConfigurationMapper.Instance.OnePositionFinancialDocuments)
                return;

            string mergedText = this.MergeDescriptions(document);
            List<Payment> paymentsToDelete = new List<Payment>();
            Payment firstPayment = null;

            foreach (var line in document.Payments)
            {
                if (line.Amount < 0) continue;

                //a tutaj sumujemy wartosci i przepisujemy rozliczenia
                if (firstPayment == null)
                    firstPayment = line;
                else
                {
                    paymentsToDelete.Add(line);
                    firstPayment.Amount += line.Amount;

                    foreach (var settlement in line.Settlements)
                    {
                        var newSettlement = firstPayment.Settlements.CreateNew();
                        newSettlement.Amount = settlement.Amount;
                        newSettlement.RelatedPayment = new Payment(newSettlement) { Id = settlement.RelatedPayment.Id.Value };
                    }
                }
            }

            foreach (var pt in paymentsToDelete)
                document.Payments.Remove(pt);

			firstPayment.Description = mergedText;
		}

        private void ExecuteCustomLogic(FinancialDocument document)
        {
            List<Guid> salesOrders = new List<Guid>();
            foreach (var payment in document.Payments)
            {
                if (payment.SalesOrderId != null)
                {
                    var relation = document.Relations.CreateNew(BusinessObjectStatus.New);
                    relation.RelationType = DocumentRelationType.SalesOrderToOutcomeFinancialDocument;
                    relation.RelatedDocument = new CommercialDocument() { Id = payment.SalesOrderId.Value };
                    relation.DecimalValue = payment.Amount;

                    if (!salesOrders.Contains(payment.SalesOrderId.Value))
                    {
                        salesOrders.Add(payment.SalesOrderId.Value);
                        CommercialDocument salesOrder = (CommercialDocument)this.mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, payment.SalesOrderId.Value);

                        DuplicableAttributeFactory.DuplicateAttributes(salesOrder, document);
                    }
                }
            }

            this.MergePayments(document);
            this.CreateOrUpdateNegativePayment(document);
        }

        private void CreateOrUpdateNegativePayment(FinancialDocument document)
        {
            Guid? payerId = document.DocumentType.FinancialDocumentOptions.PayerId;

            if (payerId == null)
                return;

            Payment negativePayment = document.Payments.Where(p => p.Amount < 0).FirstOrDefault();

            if (negativePayment == null)
            {
                negativePayment = document.Payments.CreateNew(BusinessObjectStatus.New);
                ContractorMapper contractorMapper = DependencyContainerManager.Container.Get<ContractorMapper>();
                Contractor payer = (Contractor)contractorMapper.LoadBusinessObject(BusinessObjectType.Contractor, payerId.Value);
                negativePayment.Contractor = payer;
                var addr = payer.Addresses.GetDefaultAddress();

                if (addr != null)
                    negativePayment.ContractorAddressId = addr.Id.Value;

                negativePayment.Direction = document.Payments[0].Direction;
                negativePayment.PaymentCurrencyId = document.DocumentCurrencyId;
                negativePayment.SystemCurrencyId = document.SystemCurrencyId;
                negativePayment.ExchangeDate = document.ExchangeDate;
                negativePayment.ExchangeRate = document.ExchangeRate;
                negativePayment.ExchangeScale = document.ExchangeScale;
                negativePayment.Date = document.IssueDate;
                negativePayment.DueDate = document.IssueDate;
            }

            if (!ConfigurationMapper.Instance.OnePositionFinancialDocuments)
                negativePayment.Description = this.MergeDescriptions(document);
            else
                negativePayment.Description = document.Payments[0].Description;

            string beginning = "Za dokument: ";

            if (negativePayment.Description.StartsWith(beginning))
                negativePayment.Description = negativePayment.Description.Substring(beginning.Length);

            negativePayment.Amount = -document.Payments.Where(pp => pp.Amount > 0).Sum(a => a.Amount);
        }

        public XDocument SaveBusinessObject(FinancialDocument document)
        {
            DictionaryMapper.Instance.CheckForChanges();
            this.CorrectDocumentConsistency(document);

			//Bezwarunkowo skopiuj kontrahenta z dokumentu do płatności.
			document.Payments.CopyDocumentContractor();
			
			//load alternate version
            if (!document.IsNew)
            {
                IBusinessObject alternateBusinessObject = this.mapper.LoadBusinessObject(document.BOType, document.Id.Value);
                document.SetAlternateVersion(alternateBusinessObject);
            }

            //validate
            document.Validate();

            this.ExecuteCustomLogic(document);

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

                this.ExecuteLogicDuringTransaction(document);

                this.ValidateDuringTransaction(document);

                //Make operations list
                XDocument operations = XDocument.Parse("<root/>");

                document.SaveChanges(operations);

                if (document.AlternateVersion != null)
                    document.AlternateVersion.SaveChanges(operations);

                bool generateComPackage = false;

                if (operations.Root.HasElements)
                {
                    this.mapper.ExecuteOperations(operations);
                    this.mapper.UpdateDictionaryIndex(document);
                    generateComPackage = true;
                }

                Coordinator.LogSaveBusinessObjectOperation();

                document.SaveRelatedObjects();

                operations = XDocument.Parse("<root/>");

                document.SaveRelations(operations);

                if (document.AlternateVersion != null)
                    ((FinancialDocument)document.AlternateVersion).SaveRelations(operations);

                if (operations.Root.HasElements)
                {
                    this.mapper.ExecuteOperations(operations);
                    generateComPackage = true;
                }

				this.ValidateAfterSave(document);

                this.mapper.UpdateDocumentInfoOnPayments(document);

                this.mapper.DeleteDocumentAccountingData(document);

				if (generateComPackage)
				{
					this.mapper.CreateCommunicationXml(document);
					if (operations.Root.HasElements)
						this.mapper.CreateCommunicationXmlForDocumentRelations(operations); //generowanie paczek dla relacji dokumentow
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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:65");
                Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:66");
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }
    }
}

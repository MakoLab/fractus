using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Finances;
using Makolab.Fractus.Kernel.Coordinators.Logic;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.Coordinators;

namespace Makolab.Fractus.Kernel.ObjectFactories
{
    internal static class FinancialDocumentFactory
    {
        public static void CreateFinancialReportToFinancialRegister(XElement source, FinancialReport destination)
        {
            Guid registerId = new Guid(source.Element("financialRegisterId").Value);
            FinancialRegister register = DictionaryMapper.Instance.GetFinancialRegister(registerId);
            destination.Number.NumberSettingId = register.FinancialReportNumberSettingId;
            destination.FinancialRegisterId = registerId;

            DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
            bool exists = mapper.CheckReportExistence(registerId);

            if (!exists)
            {
                destination.IsFirstReport = true;
                destination.InitialBalance = 0;
            }
            else
                destination.InitialBalance = mapper.CalculateReportInitialBalance(registerId);
        }

        private static FinancialDirection GetFinancialDirectionForPayment(CommercialDocument document, Payment payment)
        {
            DocumentCategory category = document.DocumentType.DocumentCategory;

            if (category == DocumentCategory.Sales || category == DocumentCategory.SalesCorrection)
            {
                if (payment.Amount > 0)
                    return FinancialDirection.Income;
                else
                    return FinancialDirection.Outcome;
            }
            else if (category == DocumentCategory.Purchase || category == DocumentCategory.PurchaseCorrection)
            {
                if (payment.Amount > 0)
                    return FinancialDirection.Outcome;
                else
                    return FinancialDirection.Income;
            }

            throw new InvalidOperationException("Unknown financial direction to choose");
        }

        public static void UpdateFinancialDocumentsInCommercialDocument(CommercialDocument document)
        {
            if (document == null) return;

            DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();

            ICollection<Guid> financialIdCol = mapper.GetRelatedFinancialDocumentsId(document.Id.Value);

            //wczytujemy i laczymy dokumenty po paymentach
            foreach (Guid id in financialIdCol)
            {
                FinancialDocument fDoc = null;

                try
                {
                    fDoc = (FinancialDocument)mapper.LoadBusinessObject(BusinessObjectType.FinancialDocument, id);
                }
                catch (ClientException ex)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:126");
                    if (ex.Id == ClientExceptionId.ObjectNotFound)
                        continue;
                }

                document.AddRelatedObject(fDoc);

				//aktualizujemy dane kursu na dokumencie finansowym i na jego platnosciach
				fDoc.ExchangeDate = document.ExchangeDate;
				fDoc.ExchangeRate = document.ExchangeRate;
				fDoc.ExchangeScale = document.ExchangeScale;

				foreach (Payment payment in fDoc.Payments)
				{
					payment.ExchangeDate = document.ExchangeDate;
					payment.ExchangeRate = document.ExchangeRate;
					payment.ExchangeScale = document.ExchangeScale;
				}

                var settlements = from p in document.Payments.Children
                                  from s in p.Settlements.Children
                                  select s;

                foreach (PaymentSettlement settlement in settlements)
                {
                    Payment pt = fDoc.Payments.Children.Where(x => x.Id.Value == settlement.RelatedPayment.Id.Value).FirstOrDefault();

                    if (pt != null)
                    {
                        settlement.RelatedPayment = pt;

                        if (settlement.AlternateVersion != null)
                            ((PaymentSettlement)settlement.AlternateVersion).RelatedPayment = pt;
                    }
                }

                //replace deleted payments/settlements
                if(document.AlternateVersion != null)
                {
                    CommercialDocument alternateDocument = (CommercialDocument)document.AlternateVersion;
                    var deletedSettlements = from p in alternateDocument.Payments.Children
                                             from s in p.Settlements.Children
                                             where p.AlternateVersion == null
                                             select s;

                    foreach (PaymentSettlement settlement in deletedSettlements)
                    {
                        Payment pt = fDoc.Payments.Children.Where(x => x.Id.Value == settlement.RelatedPayment.Id.Value).FirstOrDefault();

                        if (pt != null)
                            settlement.RelatedPayment = pt;
                    }
                }
            }

            if (!FinancialDocumentFactory.IsFinancialToCommercialRelationOneToOne(document))
            {
                throw new ClientException(ClientExceptionId.AutomaticFinancialDocumentUpdateException);
            }

            //aktualizujemy
            foreach (Payment payment in document.Payments.Children.Where(p => p.Status == BusinessObjectStatus.Modified))
            {
                Payment alternatePayment = (Payment)payment.AlternateVersion;
                string cntId, altercntId;
                cntId = payment.Contractor != null ? payment.Contractor.Id.ToString() : "brak";
                altercntId = alternatePayment.Contractor != null ? alternatePayment.Contractor.Id.ToString() : "brak";

                //Jeśli zmienia się kontrhent to należy zmienić dowiązany dokument handlowy
                if (payment.PaymentMethodId.Value == alternatePayment.PaymentMethodId.Value 
                        && !(cntId != altercntId)) //zmienila sie wartosc
                {
                    PaymentSettlement settlement = payment.Settlements.Children.FirstOrDefault();
                    
                    if (settlement != null)
                    {
                        settlement.Amount = Math.Abs(payment.Amount);

                        decimal difference = Math.Abs(Math.Abs(payment.Amount) - Math.Abs(settlement.RelatedPayment.Amount));

                        if ((settlement.RelatedPayment.Amount + difference) * settlement.RelatedPayment.Direction == -payment.Amount * payment.Direction)
                            settlement.RelatedPayment.Amount += difference;
                        else
                            settlement.RelatedPayment.Amount -= difference;

                        ((FinancialDocument)settlement.RelatedPayment.Parent).Amount = settlement.RelatedPayment.Amount;
                        settlement.RelatedPayment.Amount = settlement.RelatedPayment.Amount;
                        settlement.RelatedPayment.Settlements.Where(s => s.Id.Value == settlement.Id.Value).First().Amount = settlement.RelatedPayment.Amount;
                    }
                }
                else //zmienila sie forma platnosci
                {
                    //anulujemy powiazany dokument finansowy jezeli:
                    //1) powiazanie jest na pelna sume
                    //2) dokument istnieje (nie rozliczamy nic z innego oddzialu
                    //3) powiazany dokument ma taki sam typ jaki jaki generowala stara forma platnosci
                    if (payment.Settlements.Children.Count > 0)
                    {
                        //1
                        if (payment.Settlements.Children.Count != 1)
                            throw new ClientException(ClientExceptionId.AutomaticFinancialDocumentUpdateException);

                        if (alternatePayment.Amount != payment.Settlements.Children.First().Amount)
                            throw new ClientException(ClientExceptionId.AutomaticFinancialDocumentUpdateException);

                        //2
                        FinancialDocument fDoc = (FinancialDocument)payment.Settlements.Children.First().RelatedPayment.Parent;

                        if (fDoc == null)
                            throw new ClientException(ClientExceptionId.AutomaticFinancialDocumentUpdateException);

                        //3
                        FinancialRegister reg = DictionaryMapper.Instance.GetFinancialRegisterForSpecifiedPaymentMethod(alternatePayment.PaymentMethodId.Value, SessionManager.User.BranchId, alternatePayment.PaymentCurrencyId);

                        if (reg == null || (reg.IncomeDocumentTypeId != fDoc.DocumentTypeId && reg.OutcomeDocumentTypeId != fDoc.DocumentTypeId))
                            throw new ClientException(ClientExceptionId.AutomaticFinancialDocumentUpdateException);
                        
                        //warunki spelnione, mozna anulowac
                        DocumentStatusChangeLogic.CancelFinancialDocument(fDoc);
                        payment.Settlements.RemoveAll();
                    }

                    FinancialDocumentFactory.GenerateFinancialDocumentToPayment(payment, document);
                }
            }
        }

        private static bool IsFinancialToCommercialRelationOneToOne(CommercialDocument document)
        {
            foreach (Payment pt in document.Payments.Children.Where(p => p.Status == BusinessObjectStatus.Modified))
            {
                Payment payment = (Payment)pt.AlternateVersion; //dla zmienionych paymentow sprawdzamy czy maja powiazania 1:1
                //ale dla ich pierwotnej postaci jaka jest w bazie

                if (DictionaryMapper.Instance.IsPaymentMethodSupportedByRegister(payment.PaymentMethodId.Value, SessionManager.User.BranchId))
                {
                    PaymentSettlement settlement = payment.Settlements.Children.FirstOrDefault();

                    //sprawdzamy czy ma powiazanie z finansowym
                    if (payment.Settlements.Children.Count != 1)
                        return false;

                    if (settlement.Amount != Math.Abs(payment.Amount))
                        return false;

                    if (Math.Abs(settlement.RelatedPayment.Amount) != Math.Abs(payment.Amount))
                        return false;

                    //if (settlement.RelatedPayment.Date != document.IssueDate)
                    if (!settlement.IsAutoGenerated)
                        return false;

                    int allPaymentsCount = 0;

                    if (settlement.RelatedPayment.Parent.BOType == BusinessObjectType.FinancialDocument)
                        allPaymentsCount = ((FinancialDocument)settlement.RelatedPayment.Parent).Payments.Children.Count;
                    else
                        return false;
                 // Daje komentarz bo wywala się zawsze dla karty rozliczanej na minus automatycznie. 
                 // Suma paymentów sie zgadza wiec pozostaje kwestia automatycznej aktualizacji 
                 //   if (allPaymentsCount != 1)
                 //       return false;
                }
                else //rejestry nieobslugiwane musza byc nierozliczone
                {
                    if (payment.Settlements.Children.Count != 0)
                        return false;
                }
            }

            return true;
        }

        private static void GenerateFinancialDocumentToPayment(Payment payment, CommercialDocument document)
        {
            DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
			using (DocumentCoordinator coordinator = new DocumentCoordinator(false, false))
			{
				PaymentMethod paymentMethod = DictionaryMapper.Instance.GetPaymentMethod(payment.PaymentMethodId.Value);

				Guid branchId = SessionManager.User.BranchId;

				if (DictionaryMapper.Instance.IsPaymentMethodSupportedByRegister(paymentMethod.Id.Value, branchId))
				{
					FinancialRegister register = DictionaryMapper.Instance.GetFinancialRegisterForSpecifiedPaymentMethod(paymentMethod.Id.Value, branchId, payment.PaymentCurrencyId);

					if (register == null)
						throw new ClientException(ClientExceptionId.UnableToIssueFinancialDocument3);

					FinancialDirection direction = FinancialDocumentFactory.GetFinancialDirectionForPayment(document, payment);

					Guid? reportId = mapper.GetOpenedFinancialReportId(register.Id.Value);

					if (reportId == null)
						throw new ClientException(ClientExceptionId.UnableToIssueDocumentToClosedFinancialReport);

					FinancialDocument financialDoc = new FinancialDocument();
					financialDoc.RelatedCommercialDocument = document;
					coordinator.TrySaveProfileIdAttribute(financialDoc);

					if (direction == FinancialDirection.Income)
					{
						financialDoc.DocumentTypeId = register.IncomeDocumentTypeId;
						financialDoc.Number.NumberSettingId = register.IncomeNumberSettingId;
					}
					else
					{
						financialDoc.DocumentTypeId = register.OutcomeDocumentTypeId;
						financialDoc.Number.NumberSettingId = register.OutcomeNumberSettingId;
					}

					financialDoc.Contractor = payment.Contractor;
					financialDoc.ContractorAddressId = payment.ContractorAddressId;
					FinancialReport report = new FinancialReport();
					report.Id = reportId;
					report.FinancialRegisterId = register.Id.Value;
					financialDoc.FinancialReport = report;
					financialDoc.DocumentStatus = DocumentStatus.Committed;
					DuplicableAttributeFactory.DuplicateAttributes(document, financialDoc);

					Payment pt = financialDoc.Payments.CreateNew();
					pt.Amount = Math.Abs(payment.Amount);
					pt.ExchangeRate = financialDoc.ExchangeRate = document.ExchangeRate;
					pt.ExchangeScale = financialDoc.ExchangeScale = document.ExchangeScale;
					pt.ExchangeDate = financialDoc.ExchangeDate = document.ExchangeDate;
					financialDoc.Amount = pt.Amount;
					financialDoc.DocumentCurrencyId = payment.PaymentCurrencyId;
					PaymentSettlement settlement = pt.Settlements.CreateNew();
					settlement.IsAutoGenerated = true;
					settlement.RelatedPayment = payment;
					settlement.Amount = pt.Amount;

					document.AddRelatedObject(financialDoc);
				}
			}
        }

        public static void GenerateFinancialDocumentToCommercialDocument(CommercialDocument document)
        {
            if (document == null) return;

            foreach (Payment payment in document.Payments.Children)
            {
                FinancialDocumentFactory.GenerateFinancialDocumentToPayment(payment, document);
            }
        }
    }
}

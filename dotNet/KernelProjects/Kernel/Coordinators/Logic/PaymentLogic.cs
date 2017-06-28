using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Finances;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    internal class PaymentLogic
    {
        private DocumentMapper mapper;
        private DocumentCoordinator coordinator;

        public PaymentLogic(DocumentCoordinator coordinator)
        {
            this.mapper = (DocumentMapper)coordinator.Mapper;
            this.coordinator = coordinator;
        }

        private void CorrectDocumentConsistency(Payment payment)
        {
            DateTime currentDateTime = SessionManager.VolatileElements.CurrentDateTime;

            foreach (PaymentSettlement s in payment.Settlements.Children)
            {
                if (s.IsNew)
                {
                    s.Date = currentDateTime;

                    if (s.Amount == 0)
                        s.Amount = Math.Abs(payment.Amount);
                }
            }
        }

        private void ExecuteLogicDuringTransaction(Payment payment)
        {
            //doczytujemy wszystkie platnosci ktore mamy powiazac wraz z ich pozostalymi rozliczeniami
            var paymentsToSettle = (from s in payment.Settlements.Children
                                    where s.Status == BusinessObjectStatus.New ||
                                     s.Status == BusinessObjectStatus.Modified
                                    select s.RelatedPayment.Id.Value).Distinct();

            var settlementsToReplace = from s in payment.Settlements.Children
                                       where s.Status == BusinessObjectStatus.New ||
                                        s.Status == BusinessObjectStatus.Modified
                                       select s;

            List<Payment> allPayments = new List<Payment>(1);
            allPayments.Add(payment);
            
            FinancialDocumentLogic.ReplaceAndValidatePayments(allPayments, paymentsToSettle, settlementsToReplace);
        }

        public XDocument SaveBusinessObject(Payment payment)
        {
            DictionaryMapper.Instance.CheckForChanges();
            this.CorrectDocumentConsistency(payment);

            //validate
            payment.Validate();

            //load alternate version
            if (!payment.IsNew)
            {
                IBusinessObject alternateBusinessObject = this.mapper.LoadBusinessObject(payment.BOType, payment.Id.Value);
                payment.SetAlternateVersion(alternateBusinessObject);
            }

            //update status
            payment.UpdateStatus(true);

            if (payment.AlternateVersion != null)
                payment.AlternateVersion.UpdateStatus(false);

            SqlConnectionManager.Instance.BeginTransaction();

            try
            {
                DictionaryMapper.Instance.CheckForChanges();
                this.mapper.CheckBusinessObjectVersion(payment);

                this.ExecuteLogicDuringTransaction(payment);

                //Make operations list
                XDocument operations = XDocument.Parse("<root/>");

                payment.SaveChanges(operations);

                if (payment.AlternateVersion != null)
                    payment.AlternateVersion.SaveChanges(operations);

                if (operations.Root.HasElements)
                {
                    this.mapper.ExecuteOperations(operations);

                    //to jest podporka do tego ze jak usuniemy samo rozliczenie to payment bedzie niezmodyfikowany i nie wygeneruje sie przez to paczka ;)
                    if (payment.Status == BusinessObjectStatus.Unchanged)
                        payment.Status = BusinessObjectStatus.Modified;

                    this.mapper.CreateCommunicationXml(payment);
                }

                Coordinator.LogSaveBusinessObjectOperation();

                XDocument returnXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture, "<root><id>{0}</id></root>", payment.Id.ToUpperString()));

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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:82");
                Coordinator.ProcessSqlException(sqle, payment.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:83");
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }
    }
}

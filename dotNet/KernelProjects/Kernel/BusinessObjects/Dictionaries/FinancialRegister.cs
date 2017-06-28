using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Dictionaries
{
    [XmlSerializable(XmlField = "financialRegister")]
    [DatabaseMapping(TableName = "financialRegister")]
    internal class FinancialRegister : BusinessObject, IVersionedBusinessObject, ILabeledDictionaryBusinessObject
    {
        public bool ForceSave { get; set; }
        public Guid? NewVersion { get; set; }

        [XmlSerializable(XmlField = "symbol")]
        [Comparable]
        [DatabaseMapping(ColumnName = "symbol")]
        public string Symbol { get; set; }

        [XmlSerializable(XmlField = "xmlLabels")]
        [Comparable]
        [DatabaseMapping(ColumnName = "xmlLabels")]
        public XElement Labels { get; set; }

        [XmlSerializable(XmlField = "currencyId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "currencyId")]
        public Guid CurrencyId { get; set; }

        [XmlSerializable(XmlField = "accountingAccount")]
        [Comparable]
        [DatabaseMapping(ColumnName = "accountingAccount")]
        public string AccountingAccount { get; set; }

        [XmlSerializable(XmlField = "bankContractorId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "bankContractorId")]
        public Guid? BankContractorId { get; set; }

        [XmlSerializable(XmlField = "bankAccountNumber")]
        [Comparable]
        [DatabaseMapping(ColumnName = "bankAccountNumber")]
        public string BankAccountNumber { get; set; }

        [XmlSerializable(XmlField = "xmlOptions")]
        [Comparable]
        [DatabaseMapping(ColumnName = "xmlOptions")]
        public XElement Options { get; set; }

        public Guid IncomeDocumentTypeId { get { return new Guid(this.Options.Element("register").Element("incomeDocument").Element("documentTypeId").Value); } }
        public Guid IncomeNumberSettingId { get { return new Guid(this.Options.Element("register").Element("incomeDocument").Element("numberSettingId").Value); } }
        public Guid OutcomeDocumentTypeId { get { return new Guid(this.Options.Element("register").Element("outcomeDocument").Element("documentTypeId").Value); } }
        public Guid OutcomeNumberSettingId { get { return new Guid(this.Options.Element("register").Element("outcomeDocument").Element("numberSettingId").Value); } }
        public Guid FinancialReportNumberSettingId { get { return new Guid(this.Options.Element("register").Element("financialReport").Element("numberSettingId").Value); } }

		public bool ValidateBalanceBelowZero 
		{ 
			get 
			{
				XAttribute attr = RegisterElement.Attribute("validateBalanceBelowZero");

				if (attr != null)
				{
					bool result = false;
					if (Boolean.TryParse(attr.Value, out result))
						return result;
				}

				return false;
			} 
		}

        public ICollection<Guid> PaymentMethods { get; private set; }

		private XElement RegisterElement { get { return this.Options.Element(XmlName.Register); } }

        [XmlSerializable(XmlField = "registerCategory")]
        [Comparable]
        [DatabaseMapping(ColumnName = "registerCategory")]
        public RegisterCategory RegisterCategory { get; set; }

        public FinancialRegister()
            : base(null, BusinessObjectType.FinancialRegister)
        {
        }

        public override void Deserialize(XElement element)
        {
            base.Deserialize(element);

            if (this.Options != null)
            {
                List<Guid> pmethodsId = new List<Guid>();

                foreach (XElement id in this.Options.Element("register").Element("paymentMethods").Elements())
                    pmethodsId.Add(new Guid(id.Value));

                this.PaymentMethods = pmethodsId;
            }
            else
                this.PaymentMethods = null;
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.CurrencyId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:currencyId");

            if (String.IsNullOrEmpty(this.Symbol))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:symbol");

            if (this.Labels == null || !this.Labels.HasElements)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:xmlLabels");

            if (String.IsNullOrEmpty(this.AccountingAccount))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:accountingAccount");

            if (this.Options == null || !this.Options.HasElements)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:xmlOptions");
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
            {
                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
            }
        }

		/// <summary>
		/// Sprawdzenie czy profil stanowiska ma uprawnienia do wystawiania płatności w tym rejestrze finansowym
		/// </summary>
		/// <returns></returns>
		public bool IsAllowedByProfile()
		{
			if (SessionManager.Profile != null && ConfigurationMapper.Instance.Profiles.ContainsKey(SessionManager.Profile)
				|| ConfigurationMapper.Instance.DefaultProfile != null)
			{
				XElement profile = ConfigurationMapper.Instance.DefaultProfile;

				if (SessionManager.Profile != null && ConfigurationMapper.Instance.Profiles.ContainsKey(SessionManager.Profile))
					profile = ConfigurationMapper.Instance.Profiles[SessionManager.Profile];

				XElement symbolElement = profile.Element(XmlName.FinancialRegisters).Elements().Where(e => e.Value == this.Symbol).FirstOrDefault();
				return symbolElement != null;
			}
			else
			{
				return true;
			}
		}
    }
}

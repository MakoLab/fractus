using System;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects.Finances
{
    /// <summary>
    /// A payment class that acts as a object that is connected with documents, payment methods and money amount.
    /// </summary>
    [XmlSerializable(XmlField = "payment")]
    [DatabaseMapping(TableName = "payment",
		GetData = StoredProcedure.finance_p_getPaymentData, GetDataParamName = "paymentId")]
    internal class Payment : BusinessObject, IOrderable, IVersionedBusinessObject
    {
        /// <summary>
        /// Object order in the database and in xml node list.
        /// </summary>
        [XmlSerializable(XmlField = "ordinalNumber")]
        [Comparable]
        [DatabaseMapping(ColumnName = "ordinalNumber")]
        public int Order { get; set; }

        /// <summary>
        /// Gets or sets payment's date.
        /// </summary>
        [XmlSerializable(XmlField = "date")]
        [Comparable]
        [DatabaseMapping(ColumnName = "date")]
        public DateTime Date { get; set; }

        /// <summary>
        /// Gets or sets payment's due date.
        /// </summary>
        [XmlSerializable(XmlField = "dueDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "dueDate")]
        public DateTime DueDate { get; set; }

		/// <summary>
		/// Gets or sets payment's due days. Can be null.
		/// </summary>
		[XmlSerializable(XmlField = "dueDays")]
		public int? DueDays { get; set; }

        [XmlSerializable(XmlField = "contractor", RelatedObjectType = BusinessObjectType.Contractor)]
        [Comparable]
        [DatabaseMapping(ColumnName = "contractorId", OnlyId = true)]
        public Contractor Contractor { get; set; }

        /// <summary>
        /// Gets or sets selected contractor's <see cref="ContractorAddress"/> id.
        /// </summary>
        [XmlSerializable(XmlField = "addressId", EncapsulatingXmlField = "contractor", ProcessLast = true)]
        [Comparable]
        [DatabaseMapping(ColumnName = "contractorAddressId")]
        public Guid? ContractorAddressId { get; set; }

        private Guid? paymentMethodId;

        /// <summary>
        /// Gets or sets <see cref="PaymentMethod"/>'s id.
        /// </summary>
        [XmlSerializable(XmlField = "paymentMethodId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "paymentMethodId")]
        public Guid? PaymentMethodId
        {
            get { return this.paymentMethodId; }
            set
            {
                this.paymentMethodId = value;

                if (this.paymentMethodId != null)
                {
                    //Fragment odpowiedzialny za wyłączenie RequireSettlement jeśli tak wynika z typu płatności
                    PaymentMethod pm = DictionaryMapper.Instance.GetPaymentMethod(this.paymentMethodId.Value);
                    if (this.RequireSettlement == null || this.RequireSettlement)
                    this.RequireSettlement = pm.IsRequireSettlement;
                }
            }
        }

        /// <summary>
        /// Gets or sets payment amount.
        /// </summary>
        [XmlSerializable(XmlField = "amount")]
        [Comparable]
        [DatabaseMapping(ColumnName = "amount")]
        public decimal Amount { get; set; }

        [XmlSerializable(XmlField = "description")]
        [Comparable]
        [DatabaseMapping(ColumnName = "description")]
        public string Description { get; set; }

        /// <summary>
        /// Gets or sets payment currency id.
        /// </summary>
        [XmlSerializable(XmlField = "paymentCurrencyId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "paymentCurrencyId")]
        public Guid PaymentCurrencyId { get; set; }

        /// <summary>
        /// Gets or sets system currency id.
        /// </summary>
        [XmlSerializable(XmlField = "systemCurrencyId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "systemCurrencyId")]
        public Guid SystemCurrencyId { get; set; }

        /// <summary>
        /// Gets or sets exchange date.
        /// </summary>
        [XmlSerializable(XmlField = "exchangeDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "exchangeDate")]
        public DateTime ExchangeDate { get; set; }

        /// <summary>
        /// Gets or sets exchange scale.
        /// </summary>
        [XmlSerializable(XmlField = "exchangeScale")]
        [Comparable]
        [DatabaseMapping(ColumnName = "exchangeScale")]
        public int ExchangeScale { get; set; }

        /// <summary>
        /// Gets or sets exchange rate.
        /// </summary>
        [XmlSerializable(XmlField = "exchangeRate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "exchangeRate")]
        public decimal ExchangeRate { get; set; }

        /// <summary>
        /// Gets or sets the value indicating whether the <see cref="Payment"/> has been settled.
        /// </summary>
        [XmlSerializable(XmlField = "isSettled")]
        [Comparable]
        [DatabaseMapping(ColumnName = "isSettled")]
        public bool IsSettled { get; set; }

        [XmlSerializable(XmlField = "documentInfo")]
        [Comparable]
        [DatabaseMapping(ColumnName = "documentInfo")]
        public string DocumentInfo { get; set; }

        public string DocumentFullNumber
        {
            get
            {
                if (this.DocumentInfo == null)
                    return null;
                else
                    return this.DocumentInfo.Split(new char[] { ';' })[1];
            }
        }

        [XmlSerializable(XmlField = "settlements")]
        public PaymentSettlements Settlements { get; private set; }

        [XmlSerializable(XmlField = "financialDocumentHeaderId")]
        [DatabaseMapping(ColumnName = "financialDocumentHeaderId")]
        public Guid? FinancialDocumentHeaderId { get; set; }

        [XmlSerializable(XmlField = "commercialDocumentHeaderId")]
        [DatabaseMapping(ColumnName = "commercialDocumentHeaderId")]
        public Guid? CommercialDocumentHeaderId { get; set; }

        [XmlSerializable(XmlField = "direction")]
        [Comparable]
        [DatabaseMapping(ColumnName = "direction")]
        public int Direction { get; set; }

        [XmlSerializable(XmlField = "salesOrderId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "salesOrderId")]
        public Guid? SalesOrderId { get; set; }



        [XmlSerializable(XmlField = "requireSettlement")]
        [Comparable]
        [DatabaseMapping(ColumnName = "requireSettlement")]
        public bool RequireSettlement
        { get; set; }

        [XmlSerializable(XmlField = "unsettledAmount")]
        [Comparable]
        [DatabaseMapping(ColumnName = "unsettledAmount", LoadOnly = true)]
        public decimal UnsettledAmount { get; set; }

        public bool ForceSave { get; set; }

        public Guid? NewVersion { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="Payment"/> class with a specified xml root element and default settings.
        /// </summary>
        /// <param name="parent">Parent <see cref="BusinessObject"/>.</param>
        public Payment(BusinessObject parent)
            : base(parent, BusinessObjectType.Payment)
        {
            var currentDateTime = SessionManager.VolatileElements.CurrentDateTime.Date;
            this.Settlements = new PaymentSettlements(this);
            this.Date = currentDateTime;
            this.SystemCurrencyId = ConfigurationMapper.Instance.SystemCurrencyId;
            this.ExchangeDate = currentDateTime;
            this.ExchangeRate = 1;
            this.ExchangeScale = 1;
            this.RequireSettlement = true;
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.PaymentCurrencyId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:paymentCurrencyId");

            if (this.SystemCurrencyId == Guid.Empty || this.SystemCurrencyId != ConfigurationMapper.Instance.SystemCurrencyId)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:systemCurrencyId");

            bool allowZero = false;

            CommercialDocument comParent = this.Parent as CommercialDocument;

			if (comParent != null)
			{
				if (comParent.Relations.Where(r => r.RelationType == DocumentRelationType.SalesOrderToInvoice).FirstOrDefault() != null)
				{
					allowZero = true; //przepuscmy teraz ten payment, a i tak logika zapisu faktury go wywali
				}
				var attrWithProtocole = comParent.Attributes[DocumentFieldName.Attribute_IsSimulateSettlementInvoiceWithProtocole];
				if (attrWithProtocole != null && attrWithProtocole.Value != null && attrWithProtocole.Value.Value == "1")
				{
					allowZero = true;
				}
			}
            if (this.Amount == 0 && !allowZero)
                throw new ClientException(ClientExceptionId.PaymentAmountEqualToZero);
        }
        
        public override void Validate()
        {
            if (this.DueDate.Date < this.Date.Date)
                throw new ClientException(ClientExceptionId.NegativePaymentDueDate);

            if (this.Settlements != null)
            {
                this.Settlements.Validate();

                decimal settlementsAmount = this.Settlements.Children.Sum(s => s.Amount);

                if (Math.Abs(this.Amount) < settlementsAmount)
                    throw new ClientException(ClientExceptionId.SettlementException);
            }

            base.Validate();
        }

        /// <summary>
        /// Checks if the object has changed against <see cref="BusinessObject.AlternateVersion"/> and updates its own <see cref="BusinessObject.Status"/>.
        /// </summary>
        /// <param name="isNew">Value indicating whether the <see cref="BusinessObject"/> should be considered as the new one or the old one.</param>
        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            if (this.Settlements != null)
                this.Settlements.UpdateStatus(isNew);
        }

        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            if (this.Settlements != null)
                this.Settlements.SetAlternateVersion(((Payment)alternate).Settlements);
        }

        public void LoadPaymentMethodDefaults()
        {
            if (this.PaymentMethodId != null)
            {
                PaymentMethod pm = DictionaryMapper.Instance.GetPaymentMethod(this.PaymentMethodId.Value);
                this.DueDate = this.Date.AddDays(pm.DueDays);

                ICurrencyDocument currencyParent = this.Parent as ICurrencyDocument;

                if (currencyParent != null)
                {
                    this.PaymentCurrencyId = currencyParent.DocumentCurrencyId;
                    this.ExchangeDate = currencyParent.ExchangeDate;
                    this.ExchangeRate = currencyParent.ExchangeRate;
                    this.ExchangeScale = currencyParent.ExchangeScale;
                }
            }
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
                if (this.Parent != null)
                {
                    if (this.Parent.BOType == BusinessObjectType.CommercialDocument)
                    {
                        this.CommercialDocumentHeaderId = this.Parent.Id.Value;
                        this.FinancialDocumentHeaderId = null;
                    }
                    else if (this.Parent.BOType == BusinessObjectType.FinancialDocument)
                    {
                        this.CommercialDocumentHeaderId = null;
                        this.FinancialDocumentHeaderId = this.Parent.Id.Value;
                    }
                    else
                        throw new InvalidOperationException("Type of Parent is not supported");
                }

                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
            }

            if (this.Settlements != null)
                this.Settlements.SaveChanges(document);
        }

		/// <summary>
		/// Calculate DueDays.
		/// DueDays = DueDate - subtrahend
		/// </summary>
		/// <param name="subtrahend">a substrahend in calculation</param>
		public void CalculateDueDays(DateTime subtrahend)
		{
			this.DueDays = this.DueDate.Subtract(subtrahend).Days;
		}

		/// <summary>
		/// Makes a copy of contractor from document containg payment
		/// </summary>
		/// <param name="document">Document containing payment</param>
		public void CopyDocumentContractor(IContractorContainingDocument document)
		{
			this.Contractor = document.Contractor;
			this.ContractorAddressId = document.ContractorAddressId;
		}
    }
}

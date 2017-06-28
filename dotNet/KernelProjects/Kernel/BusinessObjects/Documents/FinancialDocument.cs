using System;
using System.Collections.Generic;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Finances;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    [XmlSerializable(XmlField = "financialDocument")]
    [DatabaseMapping(TableName = "financialDocumentHeader",
		GetData = StoredProcedure.document_p_getFinancialDocumentData, GetDataParamName = "financialDocumentHeaderId", List = StoredProcedure.document_p_getFinancialDocuments)]
    internal class FinancialDocument : Document, ICurrencyDocument, IPaymentsContainingDocument, IContractorContainingDocument
    {
        /// <summary>
        /// Gets or sets the document contractor.
        /// </summary>
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

        /// <summary>
        /// Gets or sets the issuing person.
        /// </summary>
        [XmlSerializable(XmlField = "issuingPerson", RelatedObjectType = BusinessObjectType.Contractor)]
        [Comparable]
        [DatabaseMapping(ColumnName = "issuingPersonContractorId", OnlyId = true)]
        public Contractor IssuingPerson { get; set; }

        [XmlSerializable(XmlField = "financialReport", RelatedObjectType = BusinessObjectType.FinancialReport)]
        [Comparable]
        [DatabaseMapping(ColumnName = "financialReportId", OnlyId = true)]
        public FinancialReport FinancialReport { get; set; }

        [XmlSerializable(XmlField = "amount")]
        [Comparable]
        [DatabaseMapping(ColumnName = "amount")]
        public decimal Amount { get; set; }

        [XmlSerializable(XmlField = "payments", ProcessLast = true)]
        public Payments Payments { get; private set; }

        [XmlSerializable(XmlField = "exchangeDate")]
        [Comparable]
        public DateTime ExchangeDate { get; set; }

        [XmlSerializable(XmlField = "exchangeScale")]
        [Comparable]
        public int ExchangeScale { get; set; }

        [XmlSerializable(XmlField = "exchangeRate")]
        [Comparable]
        public decimal ExchangeRate { get; set; }

        private FinancialDirection? direction;

        public FinancialDirection FinancialDirection
        {
            get
            {
                if (this.direction == null)
                    this.direction = this.DocumentType.FinancialDocumentOptions.FinancialDirection;

                return this.direction.Value;
            }
        }

        public CommercialDocument RelatedCommercialDocument { get; set; }

		public override string ParentIdColumnName
		{
			get
			{
				return "financialDocumentHeaderId";
			}
		}

        public FinancialDocument()
            : base(BusinessObjectType.FinancialDocument)
        {
            this.Payments = new Payments(this);

            DateTime currentDateTime = SessionManager.VolatileElements.CurrentDateTime;

            //document defaults
            this.IssueDate = currentDateTime;
            this.ExchangeDate = currentDateTime.PreviousWorkDay();
            this.ExchangeScale = 1;
            this.ExchangeRate = 1;

            Contractor issuingPerson = (Contractor)DependencyContainerManager.Container.Get<ContractorMapper>().LoadBusinessObject(BusinessObjectType.Contractor, SessionManager.User.UserId);
            this.IssuingPerson = issuingPerson;
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.FinancialReport == null)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:report");
        }

        /// <summary>
        /// Validates the <see cref="BusinessObject"/>.
        /// </summary>
        public override void Validate()
        {
            base.Validate();

            if (!this.IsNew && this.FinancialReport.Id.Value != ((FinancialDocument)this.AlternateVersion).FinancialReport.Id.Value)
                throw new ClientException(ClientExceptionId.FinancialDocumentException3);

            FinancialRegister register = DictionaryMapper.Instance.GetFinancialRegister(this.FinancialReport.FinancialRegisterId);

            if (this.IsNew && ((this.FinancialDirection == FinancialDirection.Income && register.IncomeNumberSettingId != this.Number.NumberSettingId) ||
                (this.FinancialDirection == FinancialDirection.Outcome && register.OutcomeNumberSettingId != this.Number.NumberSettingId)))
                throw new ClientException(ClientExceptionId.FinancialDocumentException1);

            if ((this.FinancialDirection == FinancialDirection.Income && register.IncomeDocumentTypeId != this.DocumentTypeId) ||
                (this.FinancialDirection == FinancialDirection.Outcome && register.OutcomeDocumentTypeId != this.DocumentTypeId))
                throw new ClientException(ClientExceptionId.FinancialDocumentException2);

			//Nie można edytować KW powiązanego z ZSP
			if (!this.IsNew && this.FinancialDirection == FinancialDirection.Outcome &&
				this.DocumentType.FinancialDocumentOptions.RegisterCategoryAsEnum == RegisterCategory.CashRegister
				&& this.Relations.HasRelations(DocumentRelationType.SalesOrderToOutcomeFinancialDocument))
			{
				throw new ClientException(ClientExceptionId.UnableToEditFinancialOutcomeDocumentRelatedWithSalesOrder);
			}

			#region Currency must match financial register currency

			if (this.DocumentCurrencyId != DictionaryMapper.Instance.GetFinancialRegister(this.FinancialReport.FinancialRegisterId).CurrencyId)
			{
				throw new ClientException(ClientExceptionId.IncompatibleDocumentAndFinancialRegisterCurrencies);
			}

			#endregion

			if (this.Payments.Children.Count == 0)
                throw new ClientException(ClientExceptionId.NoLines);

            if (this.Payments != null)
                this.Payments.Validate();
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            //save changes of child elements first
            if (this.Attributes != null)
                this.Attributes.SaveChanges(document);

            if (this.Payments != null)
                this.Payments.SaveChanges(document);

            //if the document has been changed or some of his children have been changed
            if ((this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
                || this.ForceSave)
            {
                if (this.AlternateVersion == null || ((this.AlternateVersion.Status == BusinessObjectStatus.Unchanged ||
                    this.AlternateVersion.Status == BusinessObjectStatus.Unknown) && ((IVersionedBusinessObject)this.AlternateVersion).ForceSave == false))
                {
                    this.SystemStartEditValidation();
                    Dictionary<string, object> forcedToSave = new Dictionary<string, object>();

                    forcedToSave.Add("xmlConstantData", this.GetConstantData());
                    forcedToSave.Add("modificationDate", SessionManager.VolatileElements.CurrentDateTime.ToIsoString());
                    forcedToSave.Add("modificationApplicationUserId", SessionManager.User.UserId.ToUpperString());

                    BusinessObjectHelper.SaveBusinessObjectChanges(this, document, forcedToSave, null);

                    this.Number.SaveChanges(document);
                }
            }
        }

        /// <summary>
        /// Gets the constant data that should be saved in present version to a separate column.
        /// </summary>
        /// <returns><see cref="XElement"/> containing constant data.</returns>
        private XElement GetConstantData()
        {
            XElement constant = new XElement("constant");

            if (this.Contractor != null)
            {
                XElement el = CommercialDocument.GetContractorConstantData(this.Contractor, "contractor");

                if (el != null)
                    constant.Add(el);
            }

            if (this.IssuingPerson != null)
            {
                XElement el = CommercialDocument.GetContractorConstantData(this.IssuingPerson, "issuingPerson");

                if (el != null)
                    constant.Add(el);
            }

            return constant;
        }

        /// <summary>
        /// Checks if the object has changed against <see cref="BusinessObject.AlternateVersion"/> and updates its own <see cref="BusinessObject.Status"/> as well as AlternateVersion BO's status.
        /// </summary>
        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            if (this.Payments != null)
            {
                this.Payments.UpdateStatus(isNew);

                if (this.Payments.IsAnyChildDeleted() && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
                    this.AlternateVersion.Status = BusinessObjectStatus.Modified;
            }
        }

        /// <summary>
        /// Sets the alternate version of the <see cref="BusinessObject"/>.
        /// </summary>
        /// <param name="alternate"><see cref="BusinessObject"/> that is to be considered as the alternate one.</param>
        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            FinancialDocument alternateDocument = (FinancialDocument)alternate;

            if (this.Payments != null)
                this.Payments.SetAlternateVersion(alternateDocument.Payments);
        }
    }
}

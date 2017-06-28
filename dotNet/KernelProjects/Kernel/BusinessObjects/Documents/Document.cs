using System;
using System.Collections.Generic;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.BusinessObjects.Documents.Options;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    /// <summary>
    /// Class that represents any document.
    /// </summary>
    internal abstract class Document : SimpleDocument
    {
        /// <summary>
        /// Gets or sets document type.
        /// </summary>
        [XmlSerializable(XmlField = "documentTypeId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "documentTypeId")]
        public Guid DocumentTypeId { get; set; }

        /// <summary>
        /// Gets the type of the document.
        /// </summary>
        public DocumentType DocumentType { get { return DictionaryMapper.Instance.GetDocumentType(this.DocumentTypeId); } }

        /// <summary>
        /// Gets document symbol.
        /// </summary>
        public override string Symbol { get { return DictionaryMapper.Instance.GetDocumentType(this.DocumentTypeId).Symbol; } }

        public override XDocument FullXml
        {
            get
            {
                XDocument xdoc = base.FullXml;
                xdoc.Root.Add(DocumentOptionsManager.GetOptionsForDocument(this));

                return xdoc;
            }
        }

        /// <summary>
        /// Gets or sets issue date.
        /// </summary>
        [XmlSerializable(XmlField = "issueDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "issueDate")]
        public override DateTime IssueDate { get; set; }

        [XmlSerializable(XmlField = "status")]
        [Comparable]
        [DatabaseMapping(ColumnName = "status")]
        public DocumentStatus DocumentStatus { get; set; }

        /// <summary>
        /// Gets or sets system currency id.
        /// </summary>
        [XmlSerializable(XmlField = "systemCurrencyId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "systemCurrencyId")]
        public Guid SystemCurrencyId { get; set; }

        public bool IsBeforeSystemStart
        {
            get
            {
                if (ConfigurationMapper.Instance.SystemStartDate != null &&
                    this.IssueDate.Date < ConfigurationMapper.Instance.SystemStartDate.Value.Date)
                    return true;
                else
                    return false;
            }
        }

		public bool DoesRealizeOrder
		{
			get
			{
				bool result = false;
				if (this.DocumentOptions.Count > 0)
				{
					foreach (IDocumentOption option in this.DocumentOptions)
					{
						if (option as RealizeOrderOption != null)
						{
							result = true;
						}
					}
				}
				return result;
			}
		}

        /// <summary>
        /// Gets or sets document currency id.
        /// </summary>
        [XmlSerializable(XmlField = "documentCurrencyId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "documentCurrencyId")]
        public Guid DocumentCurrencyId { get; set; }

		public bool HasSystemCurrency
		{
			get
			{
				return this.SystemCurrencyId == this.DocumentCurrencyId;
			}
		}

        [XmlSerializable(XmlField = "tag", UseAttribute = true)]
        public string Tag { get; set; }

        /// <summary>
        /// Gets or sets the <see cref="DocumentAttrValues"/> object that manages <see cref="Document"/>'s attributes.
        /// </summary>
        [XmlSerializable(XmlField = "attributes", ProcessLast = true)]
        public DocumentAttrValues Attributes { get; private set; }

        [XmlSerializable(XmlField = "relations", ProcessLast = true)]
        public DocumentRelations Relations { get; private set; }

        public ICollection<IDocumentOption> DocumentOptions { get; private set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="Document"/> class with a specified xml root element and default settings.
        /// </summary>
        /// <param name="parent">Parent <see cref="BusinessObject"/>.</param>
        /// <param name="boType">Type of <see cref="Document"/>.</param>
        public Document(BusinessObjectType boType)
            : base(boType)
        {
            this.DocumentOptions = new List<IDocumentOption>();
            this.Attributes = new DocumentAttrValues(this);
            this.Relations = new DocumentRelations(this);

            //defaults
            this.SystemCurrencyId = ConfigurationMapper.Instance.SystemCurrencyId;
			this.DocumentCurrencyId = ConfigurationMapper.Instance.SystemCurrencyId;
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.DocumentTypeId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:documentTypeId");

            if (this.DocumentCurrencyId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:documentCurrencyId");

            if (this.SystemCurrencyId == Guid.Empty || this.SystemCurrencyId != ConfigurationMapper.Instance.SystemCurrencyId)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:systemCurrencyId");
        }

        /// <summary>
        /// Validates the <see cref="BusinessObject"/>.
        /// </summary>
        public override void Validate()
        {
            base.Validate();

			if (this.AlternateVersion != null)
			{
				Document alternateVersionOfDocument = (Document)this.AlternateVersion;
				if (alternateVersionOfDocument != null && alternateVersionOfDocument.DocumentCurrencyId != this.DocumentCurrencyId)
					throw new ClientException(ClientExceptionId.DocumentCurrencyChangeForbidden);
			}

            if (this.Attributes != null)
                this.Attributes.Validate();

            if (this.Relations != null)
                this.Relations.Validate();
        }

        protected void SystemStartEditValidation()
        {
            if (ConfigurationMapper.Instance.SystemStartDate != null && this.DocumentType != null)
            {
                DocumentCategory dc = this.DocumentType.DocumentCategory;

                if ((dc == DocumentCategory.Sales || dc == DocumentCategory.Purchase || dc == DocumentCategory.Financial) &&
                    !this.IsNew && this.IsBeforeSystemStart && this.OriginId.HasValue &&
                    (this.Status == BusinessObjectStatus.Modified || this.ForceSave))
                {
                    throw new ClientException(ClientExceptionId.EditDocumentBeforeSystemStartForbidden);
                }
            }
        }

        public virtual void SaveRelations(XDocument document)
        {
            if (this.Relations != null)
                this.Relations.SaveChanges(document);
        }

        /// <summary>
        /// Checks if the object has changed against <see cref="BusinessObject.AlternateVersion"/> and updates its own <see cref="BusinessObject.Status"/> as well as AlternateVersion BO's status.
        /// </summary>
        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            if (this.Attributes != null)
            {
                this.Attributes.UpdateStatus(isNew);

                if (this.Attributes.IsAnyChildDeleted() && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
                    this.AlternateVersion.Status = BusinessObjectStatus.Modified;
            }

            if (this.Relations != null)
            {
                this.Relations.UpdateStatus(isNew);

                if (this.Relations.IsAnyChildDeleted() && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
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

            Document alternateDocument = (Document)alternate;

            if (this.Attributes != null)
                this.Attributes.SetAlternateVersion(alternateDocument.Attributes);

            if (this.Relations != null)
                this.Relations.SetAlternateVersion(alternateDocument.Relations);
        }

		/// <summary>
		/// Deserialize document and sets custom values
		/// </summary>
		/// <param name="element"></param>
		public override void Deserialize(XElement element)
		{
			base.Deserialize(element);
			//Enable manual number setting for documents before system Start
			if (this.IsBeforeSystemStart)
			{
				XElement numberElement = element.Element("number");
				XElement numberSettingId = numberElement != null ? numberElement.Element("numberSettingId") : null;
				if (numberSettingId == null || String.IsNullOrEmpty(numberSettingId.Value))
				{
					this.Number.SkipAutonumbering = true;
				}
			}
		}

		public bool DocumentOptionsContains(Type type, string method)
		{
			bool isGenerateDocumentOptionType = type == typeof(GenerateDocumentOption);
			foreach (IDocumentOption option in this.DocumentOptions)
			{
				if (option.GetType() == type)
				{
					GenerateDocumentOption castedOption = (GenerateDocumentOption)option;
					if (isGenerateDocumentOptionType)
					{
						if (method != null && castedOption.Method != null && castedOption.Method == method)
						{
							return true;
						}
					}
					else
					{
						return true;
					}
				}
			}
			return false;
		}

		internal DateTime GetCalculateDueDaysOnPaymentSubtrahend()
		{
			DateTime subtrahend = this.IssueDate;
			//Sprawdzenie czy faktura zakupu
			if (this.DocumentType.DocumentCategory == DocumentCategory.Purchase)
			{
				DocumentAttrValue supplierDocumentDate = this.Attributes[DocumentFieldName.Attribute_SupplierDocumentDate];
				if (supplierDocumentDate != null)
				{
					subtrahend = Convert.ToDateTime(supplierDocumentDate.Value.Value);
				}
			}
			return subtrahend.Trunc(DateTimeAccuracy.Day);
		}
    }
}

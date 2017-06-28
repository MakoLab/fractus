using System;
using System.Collections.Generic;
using System.Xml.Linq;
using System.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.HelperObjects;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    /// <summary>
    /// Class that represents any document.
    /// </summary>
    internal abstract class SimpleDocument : BusinessObject, IVersionedBusinessObject
    {
        [XmlSerializable(XmlField = "companyId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "companyId")]
        public Guid? CompanyId { get; set; }

        [XmlSerializable(XmlField = "branchId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "branchId")]
        public Guid BranchId { get; set; }

        [XmlSerializable(XmlField = "source", UseAttribute = true)]
        public XElement Source { get; set; }

        [XmlSerializable(XmlField = "draftId", UseAttribute = true)]
        public Guid? DraftId { get; set; }

        /// <summary>
        /// Gets or sets document's number.
        /// </summary>
        [XmlSerializable()]
        public DocumentNumber Number { get; set; }

        public abstract string Symbol { get; }
        public abstract DateTime IssueDate { get; set; }

        /// <summary>
        /// Gets or sets a flag that forces the <see cref="BusinessObject"/> to save changes even if no changes has been made.
        /// </summary>
        public bool ForceSave { get; set; }

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s new version number.
        /// </summary>
        public Guid? NewVersion { get; set; }

        public void AddRelatedObject(IBusinessObject businessObject)
        {
            if (!this.RelatedObjects.Contains(businessObject))
                this.RelatedObjects.Add(businessObject);
        }

		public void AddRelatedObjectsAsFirst(List<IBusinessObject> objects)
		{
			List<IBusinessObject> newList = new List<IBusinessObject>(objects);
			newList.AddRange(this.RelatedObjects);
			this.RelatedObjects = newList;
		}

        public ICollection<IBusinessObject> RelatedObjects { get; private set; }

        private string disableDocumentChange = String.Empty;

        [XmlSerializable(XmlField = "disableDocumentChange", UseAttribute = true)]
        public string DisableDocumentChange
        {
            get
            {
                if (String.IsNullOrEmpty(this.disableDocumentChange)) return null;
                else return this.disableDocumentChange;
            }
            set
            {
                if (value != null && !this.disableDocumentChange.Contains(value))
                {
                    if (this.disableDocumentChange.Length > 0)
                        this.disableDocumentChange += ",";

                    this.disableDocumentChange += value;
                }
            }
        }

        private string disableContractorChange = String.Empty;

        [XmlSerializable(XmlField = "disableContractorChange", UseAttribute = true)]
        public string DisableContractorChange
        {
            get
            {
                if (String.IsNullOrEmpty(this.disableContractorChange)) return null;
                else return this.disableContractorChange;
            }
            set
            {
                if (value != null && !this.disableContractorChange.Contains(value))
                {
                    if (this.disableContractorChange.Length > 0)
                        this.disableContractorChange += ",";

                    this.disableContractorChange += value;
                }
            }
        }

        private string disableLinesChange = String.Empty;

        [XmlSerializable(XmlField = "disableLinesChange", UseAttribute = true)]
        public string DisableLinesChange
        {
            get
            {
                if (String.IsNullOrEmpty(this.disableLinesChange)) return null;
                else return this.disableLinesChange;
            }
            set
            {
                if (value != null && !this.disableLinesChange.Contains(value))
                {
                    if (this.disableLinesChange.Length > 0)
                        this.disableLinesChange += ",";

                    this.disableLinesChange += value;
                }
            }
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="Document"/> class with a specified xml root element and default settings.
        /// </summary>
        /// <param name="parent">Parent <see cref="BusinessObject"/>.</param>
        /// <param name="boType">Type of <see cref="Document"/>.</param>
        public SimpleDocument(BusinessObjectType boType)
            : base(null, boType)
        {
            this.RelatedObjects = new List<IBusinessObject>();

            //defaults
            this.Number = new DocumentNumber(this);
			var defaultNumberSettingIdConf
				= ConfigurationMapper.Instance.GetSingleConfigurationEntry("document.defaults.numberSettingId");
			if (defaultNumberSettingIdConf == null)
				throw new InvalidOperationException("Missing configuration setting: 'document.defaults.numberSettingId'");
			this.Number.NumberSettingId = new Guid(defaultNumberSettingIdConf.Value.Value);
            this.IssueDate = SessionManager.VolatileElements.CurrentDateTime;

            User user = SessionManager.User;
            this.BranchId = user.BranchId;
            this.CompanyId = user.CompanyId;
        }

        public void ClearDisableLinesChangeReason()
        {
            this.disableLinesChange = String.Empty;
        }

        /// <summary>
        /// Gets the contractor constant data.
        /// </summary>
        /// <param name="contractor">The contractor.</param>
        /// <param name="elementName">Name of the <see cref="XElement"/> that will be returned.</param>
        /// <returns><see cref="XElement"/> with contractor's contant data or <c>null</c> if the contractor is null.</returns>
        protected static XElement GetContractorConstantData(Contractor contractor, string elementName)
        {
            if (contractor != null)
            {
                XElement element = new XElement(elementName);

                element.Add(new XElement("shortName", contractor.ShortName));
                element.Add(new XElement("fullName", contractor.FullName));
				if (contractor.Version.HasValue)
					element.Add(new XElement("version", contractor.Version.ToUpperString()));

                if (!String.IsNullOrEmpty(contractor.Nip))
                {
                    element.Add(new XElement("nip", contractor.Nip));
                    IBusinessObject bo = DictionaryMapper.Instance.GetCountry(contractor.NipPrefixCountryId);
                    element.Add(new XElement("nipPrefixCountrySymbol", ((Makolab.Fractus.Kernel.BusinessObjects.Dictionaries.Country)bo).Symbol));
                }

                element.Add(contractor.Addresses.Serialize("addresses")); //auto-cloning

				//accounts
				if (contractor.Accounts.Children.Count > 0)
				{
					element.Add(contractor.Accounts.Serialize(XmlName.Accounts));
				}
				//some attributes
				List<ContractorAttrValue> attributesToSerialize = new List<ContractorAttrValue>();
				attributesToSerialize.Add(contractor.Attributes[ContractorFieldName.Attribute_DedicatedAccountNumber]);
				attributesToSerialize.Add(contractor.Attributes[ContractorFieldName.Contact_Phone]);
				attributesToSerialize.Add(contractor.Attributes[ContractorFieldName.Contact_Email]);

				var filteredAttributesToSerialize = attributesToSerialize.Where(a => a != null);
				if (filteredAttributesToSerialize.Count() > 0)
				{
					XElement attributesElement = new XElement(XmlName.Attributes);
					element.Add(attributesElement);
					foreach (var attr in attributesToSerialize.Where(a => a != null))
					{
						attributesElement.Add(attr.Serialize());
					}
				}

                return element;
            }
            else
                return null;
        }

        /// <summary>
        /// Validates the <see cref="BusinessObject"/>.
        /// </summary>
        public override void Validate()
        {
            base.Validate();

            this.Number.Validate();

            User user = SessionManager.User;

            if ((this.CompanyId != null && user.CompanyId != this.CompanyId) || user.BranchId != this.BranchId)
                throw new ClientException(ClientExceptionId.DocumentCompanyOrBranchError, null, 
                    "this.CompanyId:" + (this.CompanyId != null ? this.CompanyId.ToUpperString() : "null"),
                    "user.CompanyId:" + user.CompanyId.ToUpperString(), 
                    "this.BranchId:" + this.BranchId.ToUpperString(),
                    "user.BranchId:" + user.BranchId.ToUpperString());
        }

        public void SaveRelatedObjects()
        {
            foreach (IBusinessObject businessObject in this.RelatedObjects)
            {
                using (Coordinator c = Coordinator.GetCoordinatorForSpecifiedType(businessObject.BOType, false, false))
                {
                    c.SaveBusinessObject(businessObject);
                }
            }
        }

        /// <summary>
        /// Checks if the object has changed against <see cref="BusinessObject.AlternateVersion"/> and updates its own <see cref="BusinessObject.Status"/> as well as AlternateVersion BO's status.
        /// </summary>
        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            this.Number.UpdateStatus(isNew);
        }

        /// <summary>
        /// Sets the alternate version of the <see cref="BusinessObject"/>.
        /// </summary>
        /// <param name="alternate"><see cref="BusinessObject"/> that is to be considered as the alternate one.</param>
        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            SimpleDocument alternateDocument = (SimpleDocument)alternate;

            this.Number.SetAlternateVersion(alternateDocument.Number);
        }

        /// <summary>
        /// Recursively creates new children (BusinessObjects) and attaches them to proper xml elements.
        /// </summary>
        /// <param name="element">Xml element to attach.</param>
        public override void Deserialize(XElement element)
        {
            base.Deserialize(element);

            this.Number.Deserialize(element.Element("number"));
        }

		/// <summary>
		/// Compare source type name with specified name
		/// </summary>
		/// <param name="sourceName">Name of a source type to compare</param>
		/// <returns>true if type names of sources are equal, false otherwise</returns>
		public bool CheckSourceType(string sourceTypeName)
		{
			return this.Source != null && this.Source.CheckType(sourceTypeName);
		}
    }
}

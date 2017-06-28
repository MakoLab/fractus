using System;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Contractors
{
    /// <summary>
    /// Class representing a contractor.
    /// </summary>
    [XmlSerializable(XmlField = "contractor")]
    [DatabaseMapping(TableName = "contractor")]
    public class Contractor : BusinessObject, IVersionedBusinessObject
    {
        /// <summary>
        /// Gets or sets a flag that forces the <see cref="BusinessObject"/> to save changes even if no changes has been made.
        /// </summary>
        public bool ForceSave { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Contractor"/>'s Code.
        /// </summary>
        [XmlSerializable(XmlField = "code")]
        [Comparable]
        [DatabaseMapping(TableName = "contractor", ColumnName = "code")]
        public string Code { get; set; }

        /// <summary>
        /// Gets or sets the value indicating whether the <see cref="Contractor"/> is a supplier.
        /// </summary>
        [XmlSerializable(XmlField = "isSupplier")]
        [Comparable]
        [DatabaseMapping(TableName = "contractor", ColumnName = "isSupplier")]
        public bool IsSupplier { get; set; }

        /// <summary>
        /// Gets or sets the value indicating whether the <see cref="Contractor"/> is a receiver.
        /// </summary>
        [XmlSerializable(XmlField = "isReceiver")]
        [Comparable]
        [DatabaseMapping(TableName = "contractor", ColumnName = "isReceiver")]
        public bool IsReceiver { get; set; }

        /// <summary>
        /// Gets or sets the value indicating whether the <see cref="Contractor"/> is a business entity.
        /// </summary>
        [XmlSerializable(XmlField = "isBusinessEntity")]
        [Comparable]
        [DatabaseMapping(TableName = "contractor", ColumnName = "isBusinessEntity")]
        public bool IsBusinessEntity { get; set; }

        /// <summary>
        /// Gets or sets the value indicating whether the <see cref="Contractor"/> is a <see cref="Bank"/>.
        /// </summary>
        [XmlSerializable(XmlField = "isBank")]
        [Comparable]
        [DatabaseMapping(TableName = "contractor", ColumnName = "isBank")]
        public bool IsBank { get; set; }

        /// <summary>
        /// Gets or sets the value indicating whether the <see cref="Contractor"/> is an <see cref="Employee"/>.
        /// </summary>
        [XmlSerializable(XmlField = "isEmployee")]
        [Comparable]
        [DatabaseMapping(TableName = "contractor", ColumnName = "isEmployee")]
        public bool IsEmployee { get; set; }

        /// <summary>
        /// Gets or sets the value indicating whether the <see cref="Contractor"/> is own company.
        /// </summary>
        [XmlSerializable(XmlField = "isOwnCompany")]
        [Comparable]
        [DatabaseMapping(TableName = "contractor", ColumnName = "isOwnCompany")]
        public bool IsOwnCompany { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Contractor"/>'s full name. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "fullName")]
        [Comparable]
        [DatabaseMapping(TableName = "contractor", ColumnName = "fullName")]
        public string FullName { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Contractor"/>'s short name. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "shortName")]
        [Comparable]
        [DatabaseMapping(TableName = "contractor", ColumnName = "shortName")]
        public string ShortName { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Contractor"/>'s NIP.
        /// </summary>
        [XmlSerializable(XmlField = "nip")]
        [Comparable]
        [DatabaseMapping(TableName = "contractor", ColumnName = "nip")]
        public string Nip { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Contractor"/>'s NIP prefix.
        /// </summary>
        [XmlSerializable(XmlField = "nipPrefixCountryId")]
        [Comparable]
        [DatabaseMapping(TableName = "contractor", ColumnName = "nipPrefixCountryId")]
        public Guid NipPrefixCountryId { get; set; }

		/// <summary>
		/// Gets or sets <see cref="Contractor"/>'s Creation Date
		/// </summary>
		[XmlSerializable(XmlField = "creationDate")]
		[DatabaseMapping(TableName = "contractor", ColumnName = "creationDate", LoadOnly = true)]
		public DateTime? CreationDate { get; set; }

		/// <summary>
		/// Gets or sets <see cref="Contractor"/>'s Modification Date
		/// </summary>
		[XmlSerializable(XmlField = "modificationDate")]
		[DatabaseMapping(TableName = "contractor", ColumnName = "modificationDate", LoadOnly = true)]
		public DateTime? ModificationDate { get; set; }

		/// <summary>
		/// Gets or sets <see cref="Contractor"/>'s Modification User Id
		/// </summary>
		[XmlSerializable(XmlField = "modificationUserId")]
		[DatabaseMapping(TableName = "contractor", ColumnName = "modificationUserId", LoadOnly = true)]
		public Guid? ModificationUserId { get; set; }

		/// <summary>
		/// Gets or sets Modification User Name
		/// </summary>
		[XmlSerializable(XmlField = "modificationUser")]
		public string ModificationUser { get; set; }

		/// <summary>
		/// Gets or sets <see cref="Contractor"/>'s Creation User Id
		/// </summary>
		[XmlSerializable(XmlField = "creationUserId")]
		[DatabaseMapping(TableName = "contractor", ColumnName = "creationUserId", LoadOnly = true)]
		public Guid? CreationUserId { get; set; }

		/// <summary>
		/// Gets or sets Modification User Name
		/// </summary>
		[XmlSerializable(XmlField = "creationUser")]
		public string CreationUser { get; set; }

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s new version number.
        /// </summary>
        public Guid? NewVersion { get; set; }

        /// <summary>
        /// Gets or sets the <see cref="ContractorAddresses"/> object that manages <see cref="Contractor"/>'s addresses.
        /// </summary>
        [XmlSerializable(XmlField = "addresses")]
        public ContractorAddresses Addresses { get; private set; }

        /// <summary>
        /// Gets or sets the <see cref="ContractorRelations"/> object that manages <see cref="Contractor"/>'s relations.
        /// </summary>
        [XmlSerializable(XmlField = "relations")]
        public ContractorRelations Relations { get; private set; }

        /// <summary>
        /// Gets or sets the <see cref="ContractorAccounts"/> object that manages <see cref="Contractor"/>'s accounts.
        /// </summary>
        [XmlSerializable(XmlField = "accounts")]
        public ContractorAccounts Accounts { get; private set; }

        /// <summary>
        /// Gets or sets the <see cref="ContractorAttrValues"/> object that manages <see cref="Contractor"/>'s attributes.
        /// </summary>
        [XmlSerializable(XmlField = "attributes")]
        public ContractorAttrValues Attributes { get; private set; }

        /// <summary>
        /// Gets or sets the <see cref="ContractorGroupMemberships"/> object that manages <see cref="Contractor"/>'s group memberships.
        /// </summary>
        [XmlSerializable(XmlField = "groupMemberships")]
        public ContractorGroupMemberships GroupMemberships { get; private set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="Contractor"/> class with a specified xml root element and default settings.
        /// </summary>
        /// <param name="parent">Parent <see cref="BusinessObject"/>.</param>
        /// <param name="boType">Type of <see cref="Contractor"/>.</param>
        public Contractor(BusinessObject parent, BusinessObjectType boType)
            : base(parent, boType)
        {
            this.Accounts = new ContractorAccounts(this);
            this.Addresses = new ContractorAddresses(this);
            this.Attributes = new ContractorAttrValues(this);
            this.Relations = new ContractorRelations(this);
            this.GroupMemberships = new ContractorGroupMemberships(this);

            this.NipPrefixCountryId = DictionaryMapper.Instance.GetCountry("PL").Id.Value;
        }

        public static Contractor CreateEmptyContractor(Guid id)
        {
            Contractor c = new Contractor(null, BusinessObjectType.Contractor);
            c.Id = id;
            return c;
        }

        /// <summary>
        /// Sets the alternate version of the <see cref="BusinessObject"/>.
        /// </summary>
        /// <param name="alternate"><see cref="BusinessObject"/> that is to be considered as the alternate one.</param>
        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            Contractor alternateContractor = (Contractor)alternate;

            if (this.Accounts != null)
                this.Accounts.SetAlternateVersion(alternateContractor.Accounts); 

            if (this.Addresses != null)
                this.Addresses.SetAlternateVersion(alternateContractor.Addresses); 

            if (this.Attributes != null)
                this.Attributes.SetAlternateVersion(alternateContractor.Attributes); 

            if (this.GroupMemberships != null)
                this.GroupMemberships.SetAlternateVersion(alternateContractor.GroupMemberships); 

            if (this.Relations != null)
                this.Relations.SetAlternateVersion(alternateContractor.Relations);
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (String.IsNullOrEmpty(this.FullName))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:fullName");

            if (String.IsNullOrEmpty(this.ShortName))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:shortName");

            //zakomentowane zgodnie z zaleceniami Kuby
            //if (String.IsNullOrEmpty(this.Nip) && this.IsBusinessEntity)
            //    throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:nip");

            if (this.NipPrefixCountryId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:nipPrefixCountryId");
        }

        /// <summary>
        /// Validates the <see cref="BusinessObject"/>.
        /// </summary>
        public override void Validate()
        {
            if (this.Status == BusinessObjectStatus.New)
            {
                int catalogueLimit = ConfigurationMapper.Instance.CatalogueLimit;

                if (catalogueLimit > 0)
                {
                    ContractorMapper mapper = DependencyContainerManager.Container.Get<ContractorMapper>();
                    int count = mapper.GetContractorsCount();

                    if (count >= catalogueLimit)
                        throw new ClientException(ClientExceptionId.CatalogueLimitError, null, "catalogueLimit:" + catalogueLimit.ToString(CultureInfo.InvariantCulture));
                }
            }

            Configuration.Configuration conf = ConfigurationMapper.Instance.GetConfiguration(SessionManager.User, "contractors.allowOneGroupMembership").FirstOrDefault();

            if (conf != null && conf.Value.Value.ToUpperInvariant() == "TRUE" &&
                this.GroupMemberships != null && this.GroupMemberships.Children.Count > 1)
                throw new ClientException(ClientExceptionId.ContractorOneGroupMembershipEnforcement);

            conf = ConfigurationMapper.Instance.GetConfiguration(SessionManager.User, "contractors.enforceGroupMembership").FirstOrDefault();

            if (conf != null && conf.Value.Value.ToUpperInvariant() == "TRUE" &&
                this.GroupMemberships != null && this.GroupMemberships.Children.Count == 0)
                throw new ClientException(ClientExceptionId.ContractorGroupMembershipEnforcement);

            base.Validate();

            if (this.AlternateVersion != null)
            {
                Contractor alt = (Contractor)this.AlternateVersion;

                if (this.IsBank != alt.IsBank ||
                    this.IsEmployee != alt.IsEmployee)
                    throw new ClientException(ClientExceptionId.ContractorTypeChangeError);
            }

            if (this.Accounts != null)
                this.Accounts.Validate();

            if (this.Addresses != null)
                this.Addresses.Validate();

            if (this.Attributes != null)
                this.Attributes.Validate();

            if (this.GroupMemberships != null)
                this.GroupMemberships.Validate();

            if (this.Relations != null)
                this.Relations.Validate();
        }

        /// <summary>
        /// Checks if the object has changed against <see cref="BusinessObject.AlternateVersion"/> and updates its own <see cref="BusinessObject.Status"/> as well as AlternateVersion BO's status.
        /// </summary>
        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            if (this.Accounts != null)
            {
                this.Accounts.UpdateStatus(isNew);

                if (this.Accounts.IsAnyChildDeleted() && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
                    this.AlternateVersion.Status = BusinessObjectStatus.Modified;
            }

            if (this.Addresses != null)
            {
                this.Addresses.UpdateStatus(isNew);

                if (this.Addresses.IsAnyChildDeleted() && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
                    this.AlternateVersion.Status = BusinessObjectStatus.Modified;
            }

            if (this.Attributes != null)
            {
                this.Attributes.UpdateStatus(isNew);

                if (this.Attributes.IsAnyChildDeleted() && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
                    this.AlternateVersion.Status = BusinessObjectStatus.Modified;
            }

            if (this.GroupMemberships != null)
            {
                this.GroupMemberships.UpdateStatus(isNew);

                if (this.GroupMemberships.IsAnyChildDeleted() && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
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
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            //save changes of child elements first

            if (this.Accounts != null)
                this.Accounts.SaveChanges(document);

            if (this.Addresses != null)
                this.Addresses.SaveChanges(document);

            if (this.Attributes != null)
                this.Attributes.SaveChanges(document);

            //if the contractor has been changed or some of his children have been changed
            if ((this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
                || this.ForceSave)
            {
                if (this.AlternateVersion == null || ((this.AlternateVersion.Status == BusinessObjectStatus.Unchanged ||
                    this.AlternateVersion.Status == BusinessObjectStatus.Unknown) && ((IVersionedBusinessObject)this.AlternateVersion).ForceSave == false))
                {
                    //BusinessObjectHelper.SaveMainObjectChanges(this, document, "contractor", new string[] { "id", 
                    //"code", "isSupplier", "isReceiver", "isBusinessEntity", "isBank", "isEmployee", 
                    //"isTemplate", "isOwnCompany", "fullName", "shortName", "nip", "nipPrefixCountryId", "version" }, null);

                    BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
                }
            }

            //relations have to be saved at the end
            if (this.GroupMemberships != null)
                this.GroupMemberships.SaveChanges(document);

            if (this.Relations != null)
                this.Relations.SaveChanges(document);
        }
    }
}

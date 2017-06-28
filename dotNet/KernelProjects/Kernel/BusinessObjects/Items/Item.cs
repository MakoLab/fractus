using System;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using System.Collections.Generic;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Items
{
    /// <summary>
    /// Class representing an item.
    /// </summary>
    [XmlSerializable(XmlField = "item")]
	[DatabaseMapping(TableName = "item", Insert = StoredProcedure.item_p_insertItem, Update = StoredProcedure.item_p_updateItem)]
    public class Item : BusinessObject, IVersionedBusinessObject
    {
        /// <summary>
        /// Gets or sets a flag that forces the <see cref="BusinessObject"/> to save changes even if no changes has been made.
        /// </summary>
        public bool ForceSave { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Item"/>'s code. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "code")]
        [Comparable]
        [DatabaseMapping(ColumnName = "code")]
        public string Code { get; set; }

        /// <summary>
        /// Gets or sets <see cref="ItemType"/>'s id.
        /// </summary>
        [XmlSerializable(XmlField = "itemTypeId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "itemTypeId")]
        public Guid ItemTypeId { get; set; }

        /// <summary>
        /// Gets <see cref="Item"/>'s name. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "name")]
        [Comparable]
        [DatabaseMapping(ColumnName = "name")]
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Item"/>'s default price.
        /// </summary>
        [XmlSerializable(XmlField = "defaultPrice")]
        [Comparable]
        [DatabaseMapping(ColumnName = "defaultPrice")]
        public decimal DefaultPrice { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Unit"/>'s id.
        /// </summary>
        [XmlSerializable(XmlField = "unitId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "unitId")]
        public Guid UnitId { get; set; }

        [XmlSerializable(XmlField = "vatRateId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "vatRateId")]
        public Guid VatRateId { get; set; }

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s new version number.
        /// </summary>
        public Guid? NewVersion { get; set; }

        /// <summary>
        /// Gets or sets the <see cref="ItemAttrValues"/> class that manages <see cref="ItemAttrValue"/>'s collection.
        /// </summary>
        [XmlSerializable(XmlField = "attributes")]
        public ItemAttrValues Attributes { get; private set; }

        /// <summary>
        /// Gets or sets the <see cref="ItemRelations"/> class that manages <see cref="ItemRelation"/>'s collection.
        /// </summary>
        [XmlSerializable(XmlField = "relations")]
        public ItemRelations Relations { get; private set; }

        /// <summary>
        /// Gets or sets the <see cref="ItemUnitRelations"/> class that manages <see cref="ItemUnitRelation"/>'s collection.
        /// </summary>
        [XmlSerializable(XmlField = "unitRelations")]
        public ItemUnitRelations UnitRelations { get; private set; }

        /// <summary>
        /// Gets or sets the <see cref="ItemGroupMemberships"/> object that manages <see cref="Item"/>'s group memberships.
        /// </summary>
        [XmlSerializable(XmlField = "groupMemberships")]
        public ItemGroupMemberships GroupMemberships { get; private set; }

        /// <summary>
        /// Gets or sets <see cref="Item"/>'s Creation Date
        /// </summary>
        [XmlSerializable(XmlField = "creationDate")]
        [DatabaseMapping(TableName = "item", ColumnName = "creationDate", LoadOnly = true)]
        public DateTime? CreationDate { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Item"/>'s Modification Date
        /// </summary>
        [XmlSerializable(XmlField = "modificationDate")]
        [DatabaseMapping(TableName = "item", ColumnName = "modificationDate", LoadOnly = true)]
        public DateTime? ModificationDate { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Item"/>'s Modification User Id
        /// </summary>
        [XmlSerializable(XmlField = "modificationUserId")]
        [DatabaseMapping(TableName = "item", ColumnName = "modificationUserId", LoadOnly = true)]
        public Guid? ModificationUserId { get; set; }

        /// <summary>
        /// Gets or sets Modification User Name
        /// </summary>
        [XmlSerializable(XmlField = "modificationUser")]
        public string ModificationUser { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Item"/>'s Creation User Id
        /// </summary>
        [XmlSerializable(XmlField = "creationUserId")]
        [DatabaseMapping(TableName = "item", ColumnName = "creationUserId", LoadOnly = true)]
        public Guid? CreationUserId { get; set; }

        /// <summary>
        /// Gets or sets Modification User Name
        /// </summary>
        [XmlSerializable(XmlField = "creationUser")]
        public string CreationUser { get; set; }

        /// <summary>
        /// Gets or sets Modification User Name
        /// </summary>
        [XmlSerializable(XmlField = "visible")]
        public bool Visible { get; set; }

		/// <summary>
		/// Serialize all barcode into xml element
		/// </summary>
		public XElement BarcodesXml
		{
			get
			{
				XElement result = XElement.Parse(String.Format(@"<item id=""{0}""/>", this.Id.Value.ToUpperString()));
				foreach(ItemAttrValue barcode in this.Attributes.Where(a => a.ItemFieldName == ItemFieldName.Attribute_Barcode))
				{
					result.Add(XElement.Parse(String.Format(@"<barcode>{0}</barcode>", barcode.Value.Value)));
				}
				return result;
			}
		}

        /// <summary>
        /// Initializes a new instance of the <see cref="Item"/> class with a specified xml root element and default settings.
        /// </summary>
        /// <param name="parent">Parent <see cref="BusinessObject"/>.</param>
        public Item(BusinessObject parent)
            : this(parent, BusinessObjectType.Item)
        {
        }

		/// <summary>
		/// Initializes a new instance of the <see cref="Item"/> class with a specified xml root element and default settings.
		/// </summary>
		/// <param name="parent">Parent <see cref="BusinessObject"/>.</param>
		/// <param name="boType">Type of <see cref="BusinessObject"/>.</param>
		public Item(BusinessObject parent, BusinessObjectType boType)
			: base(parent, boType)
		{
			this.Attributes = new ItemAttrValues(this);
			this.Relations = new ItemRelations(this);
			this.UnitRelations = new ItemUnitRelations(this);
			this.GroupMemberships = new ItemGroupMemberships(this);
		}

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if(String.IsNullOrEmpty(this.Code))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:code");

            if(this.ItemTypeId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:itemTypeId");

            if (String.IsNullOrEmpty(this.Name))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:name");

            if (this.UnitId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:unitId");

            if (this.VatRateId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:vatRateId");
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
                    ItemMapper mapper = DependencyContainerManager.Container.Get<ItemMapper>();
                    int count = mapper.GetItemsCount();

                    if (count >= catalogueLimit)
                        throw new ClientException(ClientExceptionId.CatalogueLimitError, null, "catalogueLimit:" + catalogueLimit.ToString(CultureInfo.InvariantCulture));
                }
            }
            
            if (ConfigurationMapper.Instance.MinimalProfitMarginValidation)
            {
                var modified = this.GroupMemberships.Where(g => g.Status != BusinessObjectStatus.Unchanged).FirstOrDefault();

                if (modified != null)
                    throw new ClientException(ClientExceptionId.ItemsGroupChangeError);

                Item alternateItem = (Item)this.AlternateVersion;

                if (alternateItem != null)
                {
                    modified = alternateItem.GroupMemberships.Where(g => g.Status == BusinessObjectStatus.Deleted).FirstOrDefault();

                    if (modified != null)
                        throw new ClientException(ClientExceptionId.ItemsGroupChangeError);
                }
            }

            Configuration.Configuration conf = ConfigurationMapper.Instance.GetConfiguration(SessionManager.User, "items.allowOneGroupMembership").FirstOrDefault();

            if (conf != null && conf.Value.Value.ToUpperInvariant() == "TRUE" &&
                this.GroupMemberships != null && this.GroupMemberships.Children.Count > 1)
                throw new ClientException(ClientExceptionId.ItemOneGroupMembershipEnforcement
					, null, "code:"+this.Code);

            conf = ConfigurationMapper.Instance.GetConfiguration(SessionManager.User, "items.enforceGroupMembership").FirstOrDefault();

            if (conf != null && conf.Value.Value.ToUpperInvariant() == "TRUE" &&
                this.GroupMemberships != null && this.GroupMemberships.Children.Count == 0)
                throw new ClientException(ClientExceptionId.ItemGroupMembershipEnforcement
					, null, "code:"+this.Code);

            base.Validate();
        }

        /// <summary>
        /// Sets the alternate version of the <see cref="BusinessObject"/>.
        /// </summary>
        /// <param name="alternate"><see cref="BusinessObject"/> that is to be considered as the alternate one.</param>
        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            Item alternateItem = (Item)alternate;

            if (this.Attributes != null)
                this.Attributes.SetAlternateVersion(alternateItem.Attributes);

            if (this.Relations != null)
                this.Relations.SetAlternateVersion(alternateItem.Relations);

            if (this.UnitRelations != null)
                this.UnitRelations.SetAlternateVersion(alternateItem.UnitRelations);

            if (this.GroupMemberships != null)
                this.GroupMemberships.SetAlternateVersion(alternateItem.GroupMemberships);
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

            if (this.UnitRelations != null)
            {
                this.UnitRelations.UpdateStatus(isNew);

                if (this.UnitRelations.IsAnyChildDeleted() && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
                    this.AlternateVersion.Status = BusinessObjectStatus.Modified;
            }

            if (this.GroupMemberships != null)
            {
                this.GroupMemberships.UpdateStatus(isNew);

                if (this.GroupMemberships.IsAnyChildDeleted() && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
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
            if (this.Attributes != null)
                this.Attributes.SaveChanges(document);

            //if the contractor has been changed or some of his children have been changed
            if ((this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
                || this.ForceSave)
            {
                if (this.AlternateVersion == null || ((this.AlternateVersion.Status == BusinessObjectStatus.Unchanged ||
                    this.AlternateVersion.Status == BusinessObjectStatus.Unknown) && ((IVersionedBusinessObject)this.AlternateVersion).ForceSave == false))
                {
                    BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
                }
            }

            //relations have to be saved at the end
            if (this.Relations != null)
                this.Relations.SaveChanges(document);

            if (this.UnitRelations != null)
                this.UnitRelations.SaveChanges(document);

            if (this.GroupMemberships != null)
                this.GroupMemberships.SaveChanges(document);
        }

		public void AppendGroupMemberships(List<Guid> itemGroupIds)
		{
			if (itemGroupIds == null)
				return;

			bool allowOneGroupMembership = ConfigurationMapper.Instance.ItemsAllowOneGroupMembership;

			List<Guid> itemGroupIdsToInsert = allowOneGroupMembership ? new List<Guid> () : new List<Guid> (itemGroupIds);
			if (allowOneGroupMembership && itemGroupIds.Count > 0)
			{
				itemGroupIdsToInsert.Add(itemGroupIds.First());
				if (!this.GroupMemberships.Any(gm => gm.ItemGroupId == itemGroupIdsToInsert.First()))
					this.GroupMemberships.Children.Clear();
			}

			foreach (Guid itemGroupId in itemGroupIds)
			{
				if (!this.GroupMemberships.Any(gm => gm.ItemGroupId == itemGroupId))
				{
					var groupMembership = GroupMemberships.CreateNew();
					groupMembership.ItemGroupId = itemGroupId;
				}
			}
		}
    }
}

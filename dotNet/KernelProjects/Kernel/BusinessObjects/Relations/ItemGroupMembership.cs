using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Items;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    /// <summary>
    /// Class representing <see cref="Item"/>'s group membership.
    /// </summary>
    [XmlSerializable(XmlField = "groupMembership")]
    [DatabaseMapping(TableName = "itemGroupMembership")]
    public class ItemGroupMembership : BusinessObject, IBusinessObjectDictionaryRelation
    {
        /// <summary>
        /// Gets or sets a flag indicating whether to upgrade version of the main <see cref="BusinessObject"/>.
        /// </summary>
        /// <value></value>
        public bool UpgradeMainObjectVersion { get; set; }

        /// <summary>
        /// Gets or sets related dictionary object's id.
        /// </summary>
        public Guid RelatedDictionaryObjectId
        {
            get { return this.ItemGroupId; }
            set { this.ItemGroupId = value; }
        }

        /// <summary>
        /// Gets or sets a flag that forces the <see cref="BusinessObject"/> to save changes even if no changes has been made.
        /// </summary>
        /// <value></value>
        public bool ForceSave { get; set; }

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s new version number.
        /// </summary>
        /// <value></value>
        public Guid? NewVersion { get; set; }

        /// <summary>
        /// Gets or sets item's group Id.
        /// </summary>
        [XmlSerializable(XmlField = "itemGroupId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "itemGroupId")]
        public Guid ItemGroupId { get; set; }

        [DatabaseMapping(ColumnName = "itemId")]
        public Guid ItemId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        /// <summary>
        /// Initializes a new instance of the <see cref="ItemGroupMembership"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="Item"/>.</param>
        public ItemGroupMembership(Item parent)
            : base(parent, BusinessObjectType.ItemGroupMembership)
        {
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.ItemGroupId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:itemGroupId");
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
                BusinessObjectHelper.SaveDictionaryRelationChanges(this, document);
            }
        }
    }
}

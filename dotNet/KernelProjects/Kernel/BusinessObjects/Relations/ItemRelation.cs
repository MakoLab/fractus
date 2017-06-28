using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Items;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    /// <summary>
    /// Class representing relation between an item and an unit.
    /// </summary>
    [XmlSerializable(XmlField = "relation")]
    [DatabaseMapping(TableName = "itemRelation")]
    public class ItemRelation : BusinessObject, IBusinessObjectRelation, IOrderable
    {
        /// <summary>
        /// Object order in the database and in xml node list.
        /// </summary>
        [XmlSerializable(XmlField = "order")]
        [Comparable]
        [DatabaseMapping(ColumnName = "order")]
        public int Order { get; set; }

        /// <summary>
        /// Gets or sets a flag that forces the <see cref="BusinessObject"/> to save changes even if no changes has been made.
        /// </summary>
        public bool ForceSave { get; set; }

        /// <summary>
        /// Gets or sets related object.
        /// </summary>
        [XmlSerializable(XmlField = "relatedObject", AutoDeserialization = false)]
        [Comparable]
        [DatabaseMapping(ColumnName = "relatedObjectId", OnlyId = true)]
        public IBusinessObject RelatedObject { get; set; }

        /// <summary>
        /// Gets item relation type's id.
        /// </summary>
        [XmlSerializable(XmlField = "itemRelationTypeId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "itemRelationTypeId", ForceSaveOnDelete = true)]
        public Guid ItemRelationTypeId { get; set; }

        /// <summary>
        /// Relation's type name.
        /// </summary>
        private ItemRelationTypeName itemRelationTypeName;

        /// <summary>
        /// Gets or sets the relation's type
        /// </summary>
        public ItemRelationTypeName ItemRelationTypeName
        {
            get { return this.itemRelationTypeName; }
            set
            {
                if (value != ItemRelationTypeName.Unknown)
                {
                    this.ItemRelationTypeId = DictionaryMapper.Instance.GetItemRelationType(value).Id.Value;
                }

                this.itemRelationTypeName = value;
            }
        }

        [DatabaseMapping(ColumnName = "itemId")]
        public Guid ItemId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s new version number.
        /// </summary>
        public Guid? NewVersion { get; set; }

        /// <summary>
        /// Gets or sets the <see cref="ItemRelationAttrValues"/> class that manages <see cref="ItemRelationAttrValue"/>'s collection.
        /// </summary>
        [XmlSerializable(XmlField = "relationAttributes")]
        public ItemRelationAttrValues Attributes { get; private set; }

        /// <summary>
        /// Gets or sets a flag indicating whether to upgrade version of the main <see cref="BusinessObject"/>.
        /// </summary>
        public bool UpgradeMainObjectVersion { get; set; }

        /// <summary>
        /// Gets or sets a flag indicating whether to upgrade version of the related <see cref="BusinessObject"/>.
        /// </summary>
        public bool UpgradeRelatedObjectVersion { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="ItemRelation"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="Item"/>.</param>
        public ItemRelation(Item parent)
            : base(parent, BusinessObjectType.ItemRelation)
        {
            this.Attributes = new ItemRelationAttrValues(this);
        }

        /// <summary>
        /// Recursively creates new children (BusinessObjects) and attaches them to proper xml elements.
        /// </summary>
        /// <param name="element">Xml element to attach.</param>
        public override void Deserialize(XElement element)
        {
            base.Deserialize(element);

            ItemRelationType relType = DictionaryMapper.Instance.GetItemRelationType(this.ItemRelationTypeId);
            string relatedObjectType = relType.Metadata.Element("relatedObjectType").Value;
            
            //update the relation type name
            this.itemRelationTypeName = relType.TypeName;

            IBusinessObject obj = BusinessObjectHelper.CreateRelatedBusinessObjectFromXmlElement((XElement)element.Element("relatedObject").FirstNode,
                relatedObjectType);

            this.RelatedObject = obj;
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.RelatedObject == null)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:relatedObject");

            if (this.ItemRelationTypeId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:itemRelationTypeId");
        }

        /// <summary>
        /// Checks if the object has changed against <see cref="BusinessObject.AlternateVersion"/> and updates its own <see cref="BusinessObject.Status"/> as well as AlternateVersion BO's status.
        /// </summary>
        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            if (this.Attributes != null)
                this.Attributes.UpdateStatus(isNew);
        }

        /// <summary>
        /// Sets the alternate version of the <see cref="BusinessObject"/>.
        /// </summary>
        /// <param name="alternate"><see cref="BusinessObject"/> that is to be considered as the alternate one.</param>
        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            ItemRelation alternateItemRelation = (ItemRelation)alternate;

            if (this.Attributes != null)
                this.Attributes.SetAlternateVersion(alternateItemRelation.Attributes);
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if (this.Attributes != null)
                this.Attributes.SaveChanges(document);

            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
            {
                BusinessObjectHelper.SaveRelationChanges(this, document);
            }
        }
    }
}

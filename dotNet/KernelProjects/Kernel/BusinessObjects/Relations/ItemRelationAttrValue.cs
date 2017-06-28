using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    /// <summary>
    /// Class representing <see cref="ItemRelationAttrValue"/>'s attribute.
    /// </summary>
    [XmlSerializable(XmlField = "relationAttribute")]
	[DatabaseMapping(TableName = "itemRelationAttrValue", Insert = StoredProcedure.item_p_insertItemRelationAttrValue, Update = StoredProcedure.item_p_updateItemRelationAttrValue)]
    public class ItemRelationAttrValue : BusinessObject, IOrderable
    {
        /// <summary>
        /// Object order in the database and in xml node list.
        /// </summary>
        [XmlSerializable(XmlField = "order")]
        [Comparable]
        [DatabaseMapping(ColumnName = "order")]
        public int Order { get; set; }

        /// <summary>
        /// Gets the item relation attr value type's id
        /// </summary>
        [XmlSerializable(XmlField = "itemRAVTypeId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "itemRAVTypeId")]
        public Guid ItemRelationAttrValueTypeId { get; set; }

        /// <summary>
        /// Field's name
        /// </summary>
        private ItemRelationAttrValueTypeName itemRelationAttrValueTypeName;

        /// <summary>
        /// Gets or sets the field's name
        /// </summary>
        public ItemRelationAttrValueTypeName ItemRelationAttrValueTypeName
        {
            get { return this.itemRelationAttrValueTypeName; }
            set
            {
                if (value != ItemRelationAttrValueTypeName.Unknown)
                {
                    this.ItemRelationAttrValueTypeId = DictionaryMapper.Instance.GetItemRelationAttrValueType(value).Id.Value;
                }

                this.itemRelationAttrValueTypeName = value;
            }
        }

        /// <summary>
        /// Gets or sets attribute value. Cannot be null.
        /// </summary>
        [XmlSerializable(XmlField = "value")]
        [Comparable]
        [DatabaseMapping(ColumnName = "value", VariableColumnName = true)]
        public XElement Value { get; set; }

        [DatabaseMapping(ColumnName = "itemRelationId")]
        public Guid ItemRelationId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        /// <summary>
        /// Initializes a new instance of the <see cref="ItemRelationAttrValue"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="ItemRelation"/>.</param>
        public ItemRelationAttrValue(ItemRelation parent)
            : base(parent)
        {
            this.Value = new XElement("value");
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if(this.ItemRelationId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:itemRelationId");

            if (this.ItemRelationAttrValueTypeId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:itemRAVTypeId");

            if (this.Value == null || this.Value.Value.Length == 0 && this.Value.HasElements == false)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:value");
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
                ItemRelationAttrValueType field = DictionaryMapper.Instance.GetItemRelationAttrValueType(this.ItemRelationAttrValueTypeId);
                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, field.Metadata.Element("dataType").Value);
            }
        }
    }
}

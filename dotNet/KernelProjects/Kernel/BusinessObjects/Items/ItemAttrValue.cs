using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects.Items
{
    /// <summary>
    /// Class representing <see cref="Item"/>'s attribute.
    /// </summary>
    [XmlSerializable(XmlField = "attribute")]
	[DatabaseMapping(TableName = "itemAttrValue", Insert = StoredProcedure.item_p_insertItemAttrValue, Update = StoredProcedure.item_p_updateItemAttrValue)]
    public class ItemAttrValue : BusinessObject, IOrderable
    {
        /// <summary>
        /// Object order in the database and in xml node list.
        /// </summary>
        [XmlSerializable(XmlField = "order")]
        [Comparable]
        [DatabaseMapping(ColumnName = "order")]
        public int Order { get; set; }

        /// <summary>
        /// Gets the attribute's description id.
        /// </summary>
        [XmlSerializable(XmlField = "itemFieldId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "itemFieldId")]
        public Guid ItemFieldId { get; set; }

        /// <summary>
        /// Field's name
        /// </summary>
        private ItemFieldName itemFieldName;

        /// <summary>
        /// Gets or sets the field's name
        /// </summary>
        public ItemFieldName ItemFieldName
        {
            get { return this.itemFieldName; }
            set
            {
                if (value != ItemFieldName.Unknown)
                {
                    this.ItemFieldId = DictionaryMapper.Instance.GetItemField(value).Id.Value;
                }

                this.itemFieldName = value;
            }
        }

        /// <summary>
        /// Gets or sets attribute value. Cannot be null.
        /// </summary>
        [XmlSerializable(XmlField = "value")]
        [Comparable]
        [DatabaseMapping(ColumnName = "value", VariableColumnName = true)]
        public XElement Value { get; set; }

        [DatabaseMapping(ColumnName = "itemId")]
        public Guid ItemId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        /// <summary>
        /// Initializes a new instance of the <see cref="ItemAttrValue"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="Item"/>.</param>
        public ItemAttrValue(Item parent)
            : base(parent)
        {
            this.Value = new XElement("value");
        }

        /// <summary>
        /// Recursively creates new children (BusinessObjects) and attaches them to proper xml elements.
        /// </summary>
        /// <param name="element">Xml element to attach.</param>
        public override void Deserialize(XElement element)
        {
            base.Deserialize(element);

            //update the field name
            this.itemFieldName = DictionaryMapper.Instance.GetItemField(this.ItemFieldId).TypeName;
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.ItemFieldId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:itemFieldId");

            if (this.Value == null || this.Value.Value.Length == 0 && this.Value.HasElements == false)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:value");
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
            {
                if (this.Id == null)
                    this.GenerateId();

                ItemField field = DictionaryMapper.Instance.GetItemField(this.ItemFieldId);
                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, field.Metadata.Element("dataType").Value);
            }
        }
    }
}

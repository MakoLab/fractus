using System.Linq;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Mappers;
using System;
using System.Globalization;

namespace Makolab.Fractus.Kernel.BusinessObjects.Items
{
    /// <summary>
    /// Class that manages <see cref="Item"/>'s attributes.
    /// </summary>
    public class ItemAttrValues : BusinessObjectsContainer<ItemAttrValue>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ItemAttrValues"/> class with a specified <see cref="Item"/> to attach to.
        /// </summary>
        /// <param name="parent"><see cref="Item"/> to attach to.</param>
        public ItemAttrValues(Item parent)
            : base(parent, "attribute")
        {
        }

        /// <summary>
        /// Creates new <see cref="ItemAttrValue"/> according to the Item's defaults and attaches it to the parent <see cref="Item"/>.
        /// </summary>
        /// <returns>A new <see cref="ItemAttrValue"/>.</returns>
        public override ItemAttrValue CreateNew()
        {
            //create new ItemAttrValue object and attach it to the element
            ItemAttrValue attribute = new ItemAttrValue((Item)this.Parent);

            attribute.Order = this.Children.Count + 1;

            //add the ItemAttrValue to the ItemAttrValue's collection
            this.Children.Add(attribute);

            return attribute;
        }

		public ItemAttrValue CreateNew(ItemFieldName fieldName)
		{
			ItemAttrValue itemAttr = this.CreateNew();
			itemAttr.ItemFieldName = fieldName;
			return itemAttr;
		}

		public ItemAttrValue GetOrCreateNew(ItemFieldName fieldName)
		{
			ItemAttrValue itemAttr = this[fieldName];
			if (itemAttr == null)
			{
				itemAttr = this.CreateNew();
				itemAttr.ItemFieldName = fieldName;
			}
			return itemAttr;
		}

		public ItemAttrValue this[ItemFieldName fieldName]
		{
			get { return this.Children.Where(c => c.ItemFieldName == fieldName).FirstOrDefault(); }
		}

		public decimal? GetDecimalValue(ItemFieldName fieldName)
		{
			decimal? result = null;
			ItemAttrValue attr = this[fieldName];

			if (attr != null)
			{
				result = Convert.ToDecimal(attr.Value.Value, CultureInfo.InvariantCulture);
			}

			return result;
		}

        public override void Validate()
        {
            base.Validate();

            foreach (var attr in this.Children)
            {
                var count = this.Children.Where(c => c.ItemFieldId == attr.ItemFieldId && c != attr).Count();

                if (count > 0)
                {
                    var field = DictionaryMapper.Instance.GetItemField(attr.ItemFieldId);

                    if (field.Metadata.Element("allowMultiple") == null)
                        throw new ClientException(ClientExceptionId.SingleAttributeMultipled, null, "name:" + BusinessObjectHelper.GetBusinessObjectLabelInUserLanguage(field).Value);
                }
            }
        }
    }
}

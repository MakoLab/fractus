using Makolab.Fractus.Kernel.BusinessObjects.Items;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    /// <summary>
    /// Class that manages <see cref="Item"/>'s relations.
    /// </summary>
    public class ItemRelationAttrValues : BusinessObjectsContainer<ItemRelationAttrValue>
    {
        /// <summary>
        /// Initializes a new instance of <see cref="ItemRelationAttrValue"/> class with a specified <see cref="ItemRelation"/> to attach to.
        /// </summary>
        /// <param name="parent"><see cref="Item"/> to attach to.</param>
        public ItemRelationAttrValues(ItemRelation parent)
            : base(parent, "relationAttribute")
        {
        }

        /// <summary>
        /// Creates new <see cref="ItemRelationAttrValue"/> of the <see cref="ItemRelationAttrValueTypeName.Unknown"/> type according to the Item's defaults and attaches it to the parent <see cref="ItemRelation"/>.
        /// </summary>
        /// <returns>A new <see cref="ItemRelationAttrValue"/>.</returns>
        public override ItemRelationAttrValue CreateNew()
        {
            //create new ItemRelationAttrValue object and attach it to the element
            ItemRelationAttrValue relation = new ItemRelationAttrValue((ItemRelation)this.Parent);

            relation.Order = this.Children.Count + 1;

            //add the ItemRelationAttrValue to the ItemRelationAttrValue's collection
            this.Children.Add(relation);

            return relation;
        }
    }
}

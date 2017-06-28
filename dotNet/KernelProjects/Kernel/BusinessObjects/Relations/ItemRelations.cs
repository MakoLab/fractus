using Makolab.Fractus.Kernel.BusinessObjects.Items;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    /// <summary>
    /// Class that manages <see cref="Item"/>'s relations.
    /// </summary>
    public class ItemRelations : BusinessObjectsContainer<ItemRelation>
    {
        /// <summary>
        /// Initializes a new instance of <see cref="ItemRelations"/> class with a specified <see cref="Item"/> to attach to.
        /// </summary>
        /// <param name="parent"><see cref="Item"/> to attach to.</param>
        public ItemRelations(Item parent)
            : base(parent, "relation")
        {
        }

        /// <summary>
        /// Creates new <see cref="ItemRelation"/> of the <see cref="ItemRelationTypeName.Unknown"/> type according to the Item's defaults and attaches it to the parent <see cref="Item"/>.
        /// </summary>
        /// <returns>A new <see cref="ItemRelation"/>.</returns>
        public override ItemRelation CreateNew()
        {
            //create new ItemRelation object and attach it to the element
            ItemRelation relation = new ItemRelation((Item)this.Parent);

            relation.Order = this.Children.Count + 1;

            //add the ItemRelation to the ItemRelation's collection
            this.Children.Add(relation);

            return relation;
        }
    }
}

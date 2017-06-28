using Makolab.Fractus.Kernel.BusinessObjects.Relations;

namespace Makolab.Fractus.Kernel.BusinessObjects.Items
{
    /// <summary>
    /// Class that manages <see cref="Item"/>'s unit relations.
    /// </summary>
    public class ItemUnitRelations : BusinessObjectsContainer<ItemUnitRelation>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ItemUnitRelations"/> class with a specified <see cref="Item"/> to attach to.
        /// </summary>
        /// <param name="parent"><see cref="Item"/> to attach to.</param>
        public ItemUnitRelations(Item parent)
            : base(parent, "unitRelation")
        {
        }

        /// <summary>
        /// Creates new <see cref="ItemUnitRelation"/> according to the Item's defaults and attaches it to the parent <see cref="Item"/>.
        /// </summary>
        /// <returns>A new <see cref="ItemUnitRelation"/>.</returns>
        public override ItemUnitRelation CreateNew()
        {
            //create new ItemUnitRelation object and attach it to the element
            ItemUnitRelation attribute = new ItemUnitRelation((Item)this.Parent);

            //add the ItemUnitRelation to the ItemUnitRelation's collection
            this.Children.Add(attribute);

            return attribute;
        }
    }
}

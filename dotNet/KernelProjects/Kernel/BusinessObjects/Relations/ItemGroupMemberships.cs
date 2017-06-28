using Makolab.Fractus.Kernel.BusinessObjects.Items;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    /// <summary>
    /// Class that manages <see cref="Item"/>'s group memberships.
    /// </summary>
    public class ItemGroupMemberships : BusinessObjectsContainer<ItemGroupMembership>
    {
        /// <summary>
        /// Initializes a new instance of <see cref="ItemGroupMemberships"/> class with a specified <see cref="Item"/> to attach to.
        /// </summary>
        /// <param name="parent"><see cref="Item"/> to attach to.</param>
        public ItemGroupMemberships(Item parent)
            : base(parent, "groupMembership")
        {
        }

        /// <summary>
        /// Creates new <see cref="ItemGroupMembership"/> according to the item's defaults and attaches it to the parent <see cref="Item"/>.
        /// </summary>
        /// <returns>A new <see cref="ItemGroupMembership"/>.</returns>
        public override ItemGroupMembership CreateNew()
        {
            //create new ItemGroupMembership object and attach it to the element
            ItemGroupMembership group = new ItemGroupMembership((Item)this.Parent);

            //add the group to the groups collection
            this.Children.Add(group);

            return group;
        }
    }
}

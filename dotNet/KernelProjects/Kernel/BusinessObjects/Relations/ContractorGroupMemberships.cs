using Makolab.Fractus.Kernel.BusinessObjects.Contractors;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    /// <summary>
    /// Class that manages <see cref="Contractor"/>'s group memberships.
    /// </summary>
    public class ContractorGroupMemberships : BusinessObjectsContainer<ContractorGroupMembership>
    {
        /// <summary>
        /// Initializes a new instance of <see cref="ContractorGroupMemberships"/> class with a specified <see cref="Contractor"/> to attach to.
        /// </summary>
        /// <param name="parent"><see cref="Contractor"/> to attach to.</param>
        public ContractorGroupMemberships(Contractor parent)
            : base(parent, "groupMembership")
        {
        }

        /// <summary>
        /// Creates new <see cref="ContractorGroupMembership"/> according to the contractor's defaults and attaches it to the parent <see cref="Contractor"/>.
        /// </summary>
        /// <returns>A new <see cref="ContractorGroupMembership"/>.</returns>
        public override ContractorGroupMembership CreateNew()
        {
            //create new ContractorGroupMembership object and attach it to the element
            ContractorGroupMembership group = new ContractorGroupMembership((Contractor)this.Parent);

            //add the group to the groups collection
            this.Children.Add(group);

            return group;
        }
    }
}

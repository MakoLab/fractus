using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    /// <summary>
    /// Class that manages <see cref="Contractor"/>'s relations.
    /// </summary>
    public class ContractorRelations : BusinessObjectsContainer<ContractorRelation>
    {
        /// <summary>
        /// Initializes a new instance of <see cref="ContractorRelations"/> class with a specified <see cref="Contractor"/> to attach to.
        /// </summary>
        /// <param name="parent"><see cref="Contractor"/> to attach to.</param>
        public ContractorRelations(Contractor parent)
            : base(parent, "relation")
        {
        }

        /// <summary>
        /// Creates new <see cref="ContractorRelation"/> of the <see cref="ContractorRelationTypeName.Unknown"/> type according to the contractor's defaults and attaches it to the parent <see cref="Contractor"/>.
        /// </summary>
        /// <returns>A new <see cref="ContractorRelation"/>.</returns>
        public override ContractorRelation CreateNew()
        {
             //create new ContractorRelation object and attach it to the element
            ContractorRelation relation = new ContractorRelation((Contractor)this.Parent);

            relation.Order = this.Children.Count + 1;

            //add the ContractorRelation to the ContractorRelation's collection
            this.Children.Add(relation);

            return relation;
        }
    }
}

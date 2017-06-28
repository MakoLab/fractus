using System;
using System.Collections.Generic;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    /// <summary>
    /// Class that manages <see cref="IncomeOutcomeRelation"/>'s relations.
    /// </summary>
    internal class IncomeOutcomeRelations : BusinessObjectsContainer<IncomeOutcomeRelation>
    {
        /// <summary>
        /// Initializes a new instance of <see cref="IncomeOutcomeRelations"/> class with a specified <see cref="WarehouseDocumentLine"/> to attach to.
        /// </summary>
        /// <param name="parent"><see cref="WarehouseDocumentLine"/> to attach to.</param>
        public IncomeOutcomeRelations(BusinessObject parent)
            : base(parent, "incomeOutcomeRelation")
        {
        }

        /// <summary>
        /// Creates new <see cref="IncomeOutcomeRelation"/> and attaches it to the parent <see cref="WarehouseDocumentLine"/>.
        /// </summary>
        /// <param name="status">The status that has to be set to the newly created <see cref="BusinessObject"/>.</param>
        /// <param name="direction">The relation's direction.</param>
        /// <returns>A new <see cref="IncomeOutcomeRelation"/>.</returns>
        public IncomeOutcomeRelation CreateNew(BusinessObjectStatus status, WarehouseDirection direction)
        {
            IncomeOutcomeRelation relation = this.CreateNew(status);
            relation.Direction = direction;
            return relation;
        }

        public override void Validate()
        {
            base.Validate();

            List<IncomeOutcomeRelation> children = (List<IncomeOutcomeRelation>)this.Children;

            for (int i = 0; i < children.Count; i++)
            {
                for (int u = i + 1; u < children.Count; u++)
                {
                    if (children[i].RelatedLine.Id.Value == children[u].RelatedLine.Id.Value)
                        throw new InvalidOperationException("Duplicated incomeOutcomeRelations!");
                }
            }
        }

        /// <summary>
        /// Creates new <see cref="IncomeOutcomeRelation"/> and attaches it to the parent <see cref="WarehouseDocumentLine"/>.
        /// </summary>
        /// <returns>A new <see cref="IncomeOutcomeRelation"/>.</returns>
        public override IncomeOutcomeRelation CreateNew()
        {
            //create new IncomeOutcomeRelation object and attach it to the element
            IncomeOutcomeRelation relation = new IncomeOutcomeRelation(this.Parent, WarehouseDirection.Outcome);

            //add the IncomeOutcomeRelation to the IncomeOutcomeRelation's collection
            this.Children.Add(relation);

            return relation;
        }
    }
}

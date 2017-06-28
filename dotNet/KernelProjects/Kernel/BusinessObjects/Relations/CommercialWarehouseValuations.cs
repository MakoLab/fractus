using Makolab.Fractus.Kernel.BusinessObjects.Documents;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    /// <summary>
    /// Class that manages <see cref="CommercialWarehouseValuation"/>'s relations.
    /// </summary>
    internal class CommercialWarehouseValuations : BusinessObjectsContainer<CommercialWarehouseValuation>
    {
        /// <summary>
        /// Initializes a new instance of <see cref="CommercialWarehouseValuations"/> class with a specified <see cref="WarehouseDocumentLine"/> or <see cref="CommercialDocumentLine"/> to attach to.
        /// </summary>
        /// <param name="parent"><see cref="WarehouseDocumentLine"/> or <see cref="CommercialDocumentLine"/> to attach to.</param>
        public CommercialWarehouseValuations(BusinessObject parent)
            : base(parent, "commercialWarehouseValuation")
        {
        }

        /// <summary>
        /// Creates new <see cref="CommercialWarehouseValuation"/> and attaches it to the parent <see cref="WarehouseDocumentLine"/> or <see cref="CommercialDocumentLine"/>.
        /// </summary>
        /// <returns>A new <see cref="CommercialWarehouseValuation"/>.</returns>
        public override CommercialWarehouseValuation CreateNew()
        {
            //create new CommercialWarehouseValuation object and attach it to the element
            CommercialWarehouseValuation relation = new CommercialWarehouseValuation(this.Parent);

            //add the CommercialWarehouseValuation to the CommercialWarehouseValuation's collection
            this.Children.Add(relation);

            return relation;
        }
    }
}

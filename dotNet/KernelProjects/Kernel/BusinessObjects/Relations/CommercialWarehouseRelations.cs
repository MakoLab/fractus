using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    /// <summary>
    /// Class that manages <see cref="CommercialWarehouseRelation"/>s.
    /// </summary>
    internal class CommercialWarehouseRelations : BusinessObjectsContainer<CommercialWarehouseRelation>
    {
        /// <summary>
        /// Initializes a new instance of <see cref="CommercialWarehouseRelations"/> class with a specified <see cref="WarehouseDocumentLine"/> or <see cref="CommercialDocumentLine"/> to attach to.
        /// </summary>
        /// <param name="parent"><see cref="WarehouseDocumentLine"/> or <see cref="CommercialDocumentLine"/> to attach to.</param>
        public CommercialWarehouseRelations(BusinessObject parent)
            : base(parent, "commercialWarehouseRelation")
        {
        }

        /// <summary>
        /// Creates new <see cref="CommercialWarehouseRelation"/> and attaches it to the parent <see cref="WarehouseDocumentLine"/> or <see cref="CommercialDocumentLine"/>.
        /// </summary>
        /// <returns>A new <see cref="CommercialWarehouseRelation"/>.</returns>
        public override CommercialWarehouseRelation CreateNew()
        {
            //create new CommercialWarehouseRelation object and attach it to the element
            CommercialWarehouseRelation relation = new CommercialWarehouseRelation(this.Parent);

            CommercialDocument parent = this.Parent as CommercialDocument;
            
            if (parent != null)
            {
                DocumentCategory dc = parent.DocumentType.DocumentCategory;

                if (dc == DocumentCategory.Sales || dc == DocumentCategory.SalesCorrection || dc == DocumentCategory.Purchase
                    || dc == DocumentCategory.PurchaseCorrection)
                    relation.IsCommercialRelation = true;
                if (dc == DocumentCategory.Reservation || dc == DocumentCategory.Order)
                    relation.IsOrderRelation = true;
                if (dc == DocumentCategory.Service)
                    relation.IsServiceRelation = true;
            }

            //add the CommercialWarehouseRelation to the CommercialWarehouseRelation's collection
            this.Children.Add(relation);

            return relation;
        }
    }
}

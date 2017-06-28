
namespace Makolab.Fractus.Kernel.Enums
{
    /// <summary>
    /// Specifies allowed types of document categories.
    /// </summary>
    public enum DocumentCategory
    {
        Unknown = -1,

        /// <summary>
        /// Sales document.
        /// </summary>
        Sales = 0,
        /// <summary>
        /// Warehouse document.
        /// </summary>
        Warehouse = 1,

        Purchase = 2,

        Reservation = 3,

        Order = 4,

        SalesCorrection = 5,
        PurchaseCorrection = 6,
        OutcomeWarehouseCorrection = 7,
        IncomeWarehouseCorrection = 8,
        Financial = 9,
        Service = 10,
        Complaint = 11,
        Inventory = 12,
        SalesOrder = 13,
        Technology = 14,
        ProductionOrder = 15,
		Offer = 16
    }
}

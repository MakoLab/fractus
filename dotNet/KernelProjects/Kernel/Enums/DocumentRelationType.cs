
namespace Makolab.Fractus.Kernel.Enums
{
    public enum DocumentRelationType
    {
        Unknown = 0,
        InvoiceToBill = 1,
        ServiceToOutcomeShift = 2,
        ServiceToInvoice = 3,
        ServiceToInternalOutcome = 4,
        ComplaintToInternalOutcome = 5,
        ComplaintToInternalIncome = 6,
        InventoryToWarehouse = 7,
        SalesDocumentToSimulatedInvoice = 8,
        SalesOrderToInvoice = 9,
        SalesOrderToWarehouseDocument = 10,
        Unused = 11,
        SalesOrderToCorrectiveCommercialDocument = 12,
        SalesOrderToOutcomeFinancialDocument = 13,
        ProductionOrderToOutcome = 14,
        ProductionOrderToIncome = 15,
		SalesOrderToSimulatedInvoice = 16
    }
}

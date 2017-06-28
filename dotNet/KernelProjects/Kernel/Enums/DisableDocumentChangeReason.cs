
namespace Makolab.Fractus.Kernel.Enums
{
    internal static class DisableDocumentChangeReason
    {
        public static readonly string LINES_RELATED_WAREHOUSE_DOCUMENT = "documents.messages.disableLinesChange.relatedWarehouseDocument";
        public static readonly string LINES_SETTLEMENT_INVOICE = "documents.messages.disableLinesChange.settlementInvoice";
        public static readonly string LINES_RELATED_OUTCOMES = "documents.messages.disableLinesChange.relatedOutcomes";
        public static readonly string LINES_RELATED_COMMERCIAL_DOCUMENT = "documents.messages.disableLinesChange.relatedCommercialDocument";
        public static readonly string LINES_CLOSED_SERVICE_DOCUMENT = "documents.messages.disableLinesChange.closedServiceDocument";
        public static readonly string LINES_INVOICE_FROM_BILL = "documents.messages.disableLinesChange.invoiceFromBill";
        public static readonly string DOCUMENT_BILL_HAS_INVOICE = "documents.messages.disableDocumentChange.billHasInvoice";
        public static readonly string DOCUMENT_RELATED_CORRECTIVE_DOCUMENTS = "documents.messages.disableDocumentChange.relatedCorrectiveDocuments";
        public static readonly string DOCUMENT_LATER_PREPAYMENTS = "documents.messages.disableDocumentChange.documentHasLaterPrepayments";
        public static readonly string CONTRACTOR_PARTIALLY_REALIZED_ORDER = "documents.messages.disableContractorChange.partiallyRealizedOrder";
        public static readonly string DOCUMENT_HAS_INVOICE = "documents.messages.documentHasInvoice";
        public static readonly string INSUFFICIENT_PREPAIDS_AMOUNT = "documents.messages.insufficientPrepaidsAmount";
    }
}

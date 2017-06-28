
namespace Makolab.Fractus.Kernel.Enums
{
    /// <summary>
    /// Specifies document field's name.
    /// </summary>
    public enum DocumentFieldName
    {
        /// <summary>
        /// Unknown field.
        /// </summary>
        Unknown,
        ShiftDocumentAttribute_OppositeDocumentId,
        ShiftDocumentAttribute_OppositeWarehouseId,
        ShiftDocumentAttribute_OppositeDocumentStatus,
        Attribute_ResponsiblePerson,
        Attribute_FiscalPrintDate,
        Attribute_DescriptiveCorrectionAfter,
        Attribute_DescriptiveCorrectionBefore,
        Attribute_SupplierDocumentNumber,
        Attribute_SupplierDocumentDate,
        Attribute_RemoteOrderNumber,
        Attribute_CustomerOrderNumber,
        Attribute_Remarks,
        Attribute_ProcessState,
		Attribute_ProcessStateChangeDate,
		Attribute_ProcessType,
        Attribute_ProcessObject,
        LineAttribute_GenerateDocumentOption,
        LineAttribute_ServiceRealized,
        Attribute_OppositeDocumentId,
        Attribute_OrderNumber,
        Attribute_OrderIssueDate,
        Attribute_TargetBranchId,
        Attribute_OrderStatus,
        Attribute_SalesOrderXml,
        Attribute_SettlementDate,
        LineAttribute_SalesOrderGenerateDocumentOption,
        Attribute_FiscalPrepayment,
        Attribute_IsSettlementDocument,
        LineAttribute_ProductionItemType,
        Attribute_ProductionTechnologyName,
        LineAttribute_ProductionTechnologyName,
        Attribute_SalesmanId,
        Attribute_IncomeShiftOrderId,
		LineAttribute_RealizedSalesOrderLineId,
		Attribute_DocumentIssueProfileId,
		Attribute_SalesOrderSalesType,
		Attribute_DocumentSourceType,
		Attribute_ProductionOrderNumber,
		Attribute_IsSimulateSettlementInvoiceWithProtocole
    }
}


namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Specifies communication package type.
    /// </summary>
    public enum CommunicationPackageType
    {
        /// <summary>
        /// Package type is unknown.
        /// </summary>
        Unknown,

        ComplaintDocumentSnapshot,

        /// <summary>
        /// Package is a configuraion entry
        /// </summary>
        Configuration,

        /// <summary>
        /// Package is a contractor snapshot.
        /// </summary>
        ContractorSnapshot,

        /// <summary>
        /// Package is a contractor relations.
        /// </summary>
        ContractorRelations,

        /// <summary>
        /// Package is a contractor group membership.
        /// </summary>
        ContractorGroupMembership,

        /// <summary>
        /// Package contains a dictionary snapshot.
        /// </summary>
        DictionaryPackage,

        /// <summary>
        /// Package commercial-commercial relations
        /// </summary>
        DocumentRelation,

        FinancialDocumentSnapshot,

        FinancialReport,

        FileDescriptor,

        InventoryDocumentSnapshot,

        /// <summary>
        /// Package is a item snapshot.
        /// </summary>
        ItemSnapshot,

        /// <summary>
        /// Package is a item relations.
        /// </summary>
        ItemRelation,

        /// <summary>
        /// Package is a item unit relation.
        /// </summary>
        ItemUnitRelation,

        /// <summary>
        /// Package is a item group membership.
        /// </summary>
        ItemGroupMembership,

        /// <summary>
        /// Package is a commercial document snapshot.
        /// </summary>
        CommercialDocumentSnapshot,

        /// <summary>
        /// Package is an extended commercial document snapshot.
        /// Extended packate has some additional logic for example forwarding rules
        /// </summary>
        CommercialDocumentSnapshotEx,

        /// <summary>
        /// Package is a Series snapshot.
        /// </summary>
        Series,

        /// <summary>
        /// Package is a payment snapshot
        /// </summary>
        Payment,

        ///// <summary>
        ///// Package is a payment settlement snapshot
        ///// </summary>
        //PaymentSettlementSnapshot,

        /// <summary>
        /// Warehouse document
        /// </summary>
        WarehouseDocumentSnapshot,

        /// <summary>
        /// Relation between income and outcome
        /// </summary>
        IncomeOutcomeRelation,

        /// <summary>
        /// Value relations between warehouse documents.
        /// </summary>
        WarehouseDocumentValuation, 

        /// <summary>
        /// Relation between commercial and warehouse documents
        /// </summary>
        CommercialWarehouseRelation,

        /// <summary>
        ///  Value relations between warehouse and commercial documents.
        /// </summary>
        CommercialWarehouseValuation,

        /// <summary>
        /// Deletes relations between commercial and warehouse document
        /// </summary>
        UnrelateCommercialDocument,

        /// <summary>
        /// Deletes outcome warehouse document relations
        /// </summary>
        UnrelateWarehouseDocumentForOutcome,

        /// <summary>
        /// Deletes income warehouse document relations
        /// </summary>
        UnrelateWarehouseDocumentForIncome,

        /// <summary>
        /// Item stock on warehouse.
        /// </summary>
        WarehouseStock,

        /// <summary>
        /// Sets opposite shift document status
        /// </summary>
        ShiftDocumentStatus,

        /// <summary>
        /// Pricing rules
        /// </summary>
        PriceRule,

        /// <summary>
        /// List of pricing rules
        /// </summary>
        PriceRuleList,

        /// <summary>
        /// Custom package
        /// </summary>
        Custom,

        /// <summary>
        /// Package has other type.
        /// </summary>
        Other
    }
}

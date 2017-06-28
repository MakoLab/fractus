
namespace Makolab.Fractus.Commons
{
    /// <summary>
    /// Specifies the list of stored procedures allowed to execute.
    /// </summary>
    public enum StoredProcedure
    {
        Unknown = 0,

        #region Communication procedures
        communication_p_createPaymentPackage,
        communication_p_createFinancialReportPackage,
        communication_p_createFinancialDocumentPackage,
        communication_p_createFileDescriptorPackage,
        communication_p_createDocumentRelationPackage,
        communication_p_createInventoryDocumentPackage,
        communication_p_createComplaintDocumentPackage,
        /// <summary>
        /// Creates WarehouseDocumentSnapshot communication package. Params:
        /// * xmlVar - xml containing input data.
        /// </summary>
        communication_p_createWarehouseDocumentPackage,

        /// <summary>
        /// Creates IncomeOutcomeRelation communication package. Params:
        /// * xmlVar - xml containing input data.
        /// </summary>
        communication_p_createIncomeOutcomeRelationPackage,

        /// <summary>
        /// Creates CommercialWarehouseRelation communication package. Params:
        /// * xmlVar - xml containing input data.
        /// </summary>
        communication_p_createCommercialWarehouseRelationPackage,

        /// <summary>
        /// Creates CommercialWarehouseRelation communication package. Params:
        /// * xmlVar - xml containing input data.
        /// </summary>
        communication_p_createCommercialWarehouseValuationPackage,

        /// <summary>
        /// Creates UnrelateWarehouseDocumentForIncome or UnrelateWarehouseDocumentForOutcome communication package. Params:
        /// * xmlVar - xml containing input data.
        /// </summary>
        communication_p_createUnrelateDocumentPackage,

        /// <summary>
        /// Creates contractor relation communication package. Params:
        /// * xmlVar - xml containing input data.
        /// </summary>
        communication_p_createContractorRelationPackage,

        /// <summary>
        /// Creates contractor communication package. Params:
        /// * xmlVar - xml containing such parameters as businessObjectId, previousVersion, localTransactionId, deferredTransactionId
        /// </summary>
        communication_p_createContractorPackage,

        /// <summary>
        /// Creates commercial document communication package. Params:
        /// * xmlVar - xml containing such parameters as businessObjectId, previousVersion, localTransactionId, deferredTransactionId
        /// </summary>
        communication_p_createCommercialDocumentPackage,

        /// <summary>
        /// Creates contractor group membership communication package. Params:
        /// * xmlVar - xml containing such parameters as businessObjectId, previousVersion, localTransactionId, deferredTransactionId
        /// </summary>
        communication_p_createContractorGroupMembershipPackage,

        /// <summary>
        /// Creates item group membership communication package. Params:
        /// * xmlVar - xml containing such parameters as businessObjectId, previousVersion, localTransactionId, deferredTransactionId
        /// </summary>
        communication_p_createItemGroupMembershipPackage,

        /// <summary>
        /// Creates item communication package. Params:
        /// * xmlVar - xml containing such parameters as businessObjectId, previousVersion, localTransactionId, deferredTransactionId
        /// </summary>
        communication_p_createItemPackage,

        /// <summary>
        /// Creates item relation communication package. Params:
        /// * xmlVar - xml containing input data.
        /// </summary>
        communication_p_createItemRelationPackage,

        /// <summary>
        /// Creates item unit relation communication package. Params:
        /// * xmlVar - xml containing input data.
        /// </summary>
        communication_p_createItemUnitRelationPackage,

        /// <summary>
        /// Creates warehouse stock communication package. Params:
        /// * xmlVar - xml containing input data.
        /// </summary>
        communication_p_createWarehouseStockPackage,

        /// <summary>
        /// Gets item group membership communication package. Params:
        /// * id - group membership id.
        /// </summary>
        communication_p_getItemGroupMembershipPackage,

        /// <summary>
        /// Gets new packages that must be send. Params:
        /// * maxTransactionCount - defies maximum number of local transactions that are returned.
        /// </summary>
        communication_p_getOutgoingQueue,

        /// <summary>
        /// Gets new packages that must be executed. Params:
        /// * maxTransactionCount - defies maximum number of local transactions that are returned.
        /// </summary>
        communication_p_getIncomingQueue,

        /// <summary>
        /// Gets contractor communication snapshot. Params:
        /// * contractorId - contractor id.
        /// </summary>
        communication_p_getContractorPackage,

        /// <summary>
        /// Gets contractor relation communication package. Params:
        /// * id - relation id.
        /// </summary>
        communication_p_getContractorRelationPackage,

        /// <summary>
        /// Gets contractor group membership communication package. Params:
        /// * id - group membership id.
        /// </summary>
        communication_p_getContractorGroupMembershipPackage,

        /// <summary>
        /// Gets inventory communication snapshot. Params:
        /// * id - inventory id.
        /// </summary>
        communication_p_getInventoryDocumentPackage,

        /// <summary>
        /// Gets item communication snapshot. Params:
        /// * id - item id.
        /// </summary>
        communication_p_getItemPackage,

        /// <summary>
        /// Gets item relation communication package. Params:
        /// * id - item relation id.
        /// </summary>
        communication_p_getItemRelationPackage,

        /// <summary>
        /// Gets item unit relation communication package. Params:
        /// * id - item unit relation id.
        /// </summary>
        communication_p_getItemUnitRelationPackage,

        /// <summary>
        /// Gets commercial document communication snapshot. Params:
        /// * id - commercial document id.
        /// </summary>
        communication_p_getCommercialDocumentPackage,

        /// <summary>
        /// Gets commercial document communication snapshot. Params:
        /// * id - commercial document id.
        /// </summary>
        communication_p_getWarehouseDocumentPackage,

        /// <summary>
        /// Gets warehouse document communication snapshot. Params:
        /// * id - warehouse document id.
        /// </summary>
        communication_p_getIncomeOutcomeRelationPackage,

        /// <summary>
        /// Gets commercial-warehouse valuation communication package. Params:
        /// * id - commercial-warehouse valuation id.
        /// </summary>
        communication_p_getCommercialWarehouseValuationPackage,

        /// <summary>
        /// Gets commercial-warehouse relation communication package. Params:
        /// * id - commercial-warehouse relation id.
        /// </summary>
        communication_p_getCommercialWarehouseRelationPackage,

        /// <summary>
        /// Gets warehouse document communication snapshot. Params:
        /// * id - warehouse document id.
        /// </summary>
        communication_p_getDocumentRelationPackage,

        /// <summary>
        /// Gets warehouse document valuation communication package. Params:
        /// * id - warehouse document valuation id.
        /// </summary>
        communication_p_getWarehouseDocumentValuationPackage,

        /// <summary>
        /// Gets document series snapshot. Params:
        /// * id - document series id.
        /// </summary>
        communication_p_getSeriesPackage,

        /// <summary>
        /// Gets amount of packages waiting for execution.
        /// </summary>
        communication_p_getUnprocessedPackagesQuantity,

        /// <summary>
        /// Gets payment communication snapshot. Params:
        /// * id - payment id.
        /// </summary>
        communication_p_getPaymentPackage,

        /// <summary>
        /// Gets payment settlement communication snapshot. Params:
        /// * id - payment settlement id.
        /// </summary>      
        communication_p_getPaymentSettlementPackage,

        /// <summary>
        /// Gets amount of packages waiting to be send.
        /// </summary>
        communication_p_getUndeliveredPackagesQuantity,

        communication_p_getFinancialDocumentPackage,

        communication_p_getFinancialReportPackage,

        communication_p_getFileDescriptorPackage,

        communication_p_getLastIncompleteTransactionByDatabase,

        communication_p_getComplaintDocumentPackage,

        /// <summary>
        /// Save communication package by putting it in the execution/incoming queue. Params:
        /// * xmlVar - xml containing single or multiple communication packages with required identifiers.
        /// </summary>
        communication_p_insertIncomingPackage,

        /// <summary>
        /// Inserts a new communication outgoing package. Params:
        /// * xmlVar - xml containing single or multiple communication packages with required identifiers.
        /// </summary>
        communication_p_insertOutgoingPackage,

        /// <summary>
        /// Marks communication package as send. Params:
        /// * id - package id.
        /// </summary>
        communication_p_setPackageSent,

        /// <summary>
        /// Marks communication package as executed. Params:
        /// * id - package id.
        /// </summary>
        communication_p_setPackageExecuted,

        /// <summary>
        /// Sets isCompleted flag to true on all packages from given local transaction. Params:
        /// * localTransactionId - local transaction id.
        /// </summary>
        /// <remarks>
        /// Only packages with isCompleted flag set to true can be executed.
        /// </remarks>
        communication_p_setIncomingTransactionCompleted,

        /// <summary>
        /// Updates communication statistics of one or many departments. Params:
        /// * xmlVar - xml containing statistics of one or many departments.
        /// </summary>
        communication_p_updateStatistics,

        /// <summary>
        /// Creates communication package with all data from specified table. Params:
        /// * xmlVar - contains the name of the table.
        /// </summary>
        communication_p_createTablePackage,

        /// <summary>
        /// Creates Configuration communication package. Params:
        /// * xmlVar - xml containing input data.
        /// </summary>
        communication_p_createConfigurationPackage,

        /// <summary>
        /// Gets detailed communication statistics for specified branch
        /// * branchId - branch id
        /// </summary>
        communication_p_getStatisticsDetails,

        /// <summary>
        /// Gets basic communication statistics for all branches
        /// </summary>
        communication_p_getStatisticsList,
        #endregion

        #region Contractor procedures
        /// <summary>
        /// Gets random keywords from the contractor dictionary. Params:
        /// * xmlVar - xml containing amount attribute.
        /// </summary>
        contractor_p_getRandomKeywords,
        contractor_p_deleteContractor,
        contractor_p_insertApplicationUser,
        contractor_p_updateApplicationUser,

        /// <summary>
        /// Gets full data about all own companies. Params:
        /// * xmlVar - ignored.
        /// </summary>
        contractor_p_getOwnCompanies,

        /// <summary>
        /// Gets the number of contractor group memberships. Params:
        /// * contractorGroupId - id of the contractor group to count.
        /// </summary>
        contractor_p_getContractorGroupMembershipsCount,

        /// <summary>
        /// Sets a new version of the contractor. Params:
        /// * oldVersion - old contractor's version
        /// * newVersion - new contractor's version
        /// </summary>
        contractor_p_setContractorVersion,

        /// <summary>
        /// Updates contractor dictionary index. Params:
        /// * xmlVar - xml containing 'businessObjectId' and 'mode' attributes.
        /// </summary>
        contractor_p_updateContractorDictionary,

        /// <summary>
        /// Check if the contractor version is the same as specified (expected) and throws 50012 error if it doesn't. Params:
        /// * version - expected contractor version
        /// </summary>
        contractor_p_checkContractorVersion,

        /// <summary>
        /// Deletes contractor accounts. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        contractor_p_deleteContractorAccount,

        /// <summary>
        /// Deletes contractor addresses. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        contractor_p_deleteContractorAddress,

        /// <summary>
        /// Deletes contractor attribute values. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        contractor_p_deleteContractorAttrValue,

        /// <summary>
        /// Deletes contractor relations. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        contractor_p_deleteContractorRelation,

        /// <summary>
        /// Gets contractors list. Params:
        /// * xmlVar - xml containing configuration options.
        /// </summary>
        contractor_p_getContractors,

        /// <summary>
        /// Gets full contractor data. Params:
        /// * contractorId - contractor's id to load.
        /// </summary>
        contractor_p_getContractorData,

        /// <summary>
        /// Deletes contractor group membership. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        contractor_p_deleteContractorGroupMembership,

        /// <summary>
        /// Updates contractor group membership. Params:
        /// * xmlVar - xml containing contractor group membership entries.
        /// </summary>
        contractor_p_updateContractorGroupMembership,

        /// <summary>
        /// Inserts a new contractor group membership. Params:
        /// * xmlVar - xml containing contractor group membership entries.
        /// </summary>
        contractor_p_insertContractorGroupMembership,

        /// <summary>
        /// Updates contractor address. Params:
        /// * xmlVar - xml containing contractor address entries.
        /// </summary>
        contractor_p_updateContractorAddress,

        /// <summary>
        /// Inserts a new contractor address. Params:
        /// * xmlVar - xml containing contractor address entries.
        /// </summary>
        contractor_p_insertContractorAddress,

        /// <summary>
        /// Inserts a new contractor relation. Params:
        /// * xmlVar - xml containing contractor relation entries.
        /// </summary>
        contractor_p_insertContractorRelation,

        /// <summary>
        /// Updates contractor relation. Params:
        /// * xmlVar - xml containing contractor relation entries.
        /// </summary>
        contractor_p_updateContractorRelation,

        /// <summary>
        /// Inserts a new contractor attribute value. Params:
        /// * xmlVar - xml containing contractor attribute value entries.
        /// </summary>
        contractor_p_insertContractorAttrValue,

        /// <summary>
        /// Updates contractor attribute value. Params:
        /// * xmlVar - xml containing contractor attribute value entries.
        /// </summary>
        contractor_p_updateContractorAttrValue,

        /// <summary>
        /// Updates contractor. Params:
        /// * xmlVar - xml containing contractor entries.
        /// </summary>
        contractor_p_updateContractor,

        /// <summary>
        /// Inserts a new contractor. Params:
        /// * xmlVar - xml containing contractor entries.
        /// </summary>
        contractor_p_insertContractor,

        /// <summary>
        /// Updates bank. Params:
        /// * xmlVar - xml containing bank entries.
        /// </summary>
        contractor_p_updateBank,

        /// <summary>
        /// Inserts a new bank. Params:
        /// * xmlVar - xml containing bank entries.
        /// </summary>
        contractor_p_insertBank,

        /// <summary>
        /// Updates employee. Params:
        /// * xmlVar - xml containing employee entries.
        /// </summary>
        contractor_p_updateEmployee,

        /// <summary>
        /// Inserts a new employee. Params:
        /// * xmlVar - xml containing employee entries.
        /// </summary>
        contractor_p_insertEmployee,

        /// <summary>
        /// Updates contractor account. Params:
        /// * xmlVar - xml containing contractor account entries.
        /// </summary>
        contractor_p_updateContractorAccount,

        /// <summary>
        /// Inserts a new contractor account. Params:
        /// * xmlVar - xml containing contractor account entries.
        /// </summary>
        contractor_p_insertContractorAccount,

        /// <summary>
        /// Gets one specific application user by login. Params:
        /// * login - specifies user to load by his login.
        /// </summary>
        contractor_p_getApplicationUser,

        /// <summary>
        /// Creates snapshot for the specified contractor. Params:
        /// * xmlVar - xml containing options for generating contractor snapshot.
        /// </summary>
        contractor_p_createSnapshot,

        /// <summary>
        /// Gets a list of random contractor's id. Params:
        /// * xmlVar - xml containing amount attribute in root-tag.
        /// </summary>
        contractor_p_getRandomContractors,

        /// <summary>
        /// Gets contractors quantity. Params:
        /// * xmlVar - not used xml param
        /// </summary>
        contractor_p_getContractorsCount,
        contractor_p_checkContractorCodeExistence,
        contractor_p_getContractorByFullNameAndPostCode,
        contractor_p_getContractorByNip,
        #endregion

        #region Document procedures
        document_p_getPrepaymentDocuments,
        document_p_deleteDraft,
        document_p_getSalesOrderSettledAmount,
        document_p_getPrepaidDocumentsNumber,
        document_p_getCommercialDocumentByOppositeDocumentId,
        document_p_getCommercialDocumentDataByLineId,
        document_p_checkInventoryDocumentVersion,
        document_p_checkInventorySheetVersion,
        document_p_getRelatedFinancialDocumentsId,
        document_p_cancelWarehouseDocument,
        document_p_getRelatedWarehouseDocumentsId,
        document_p_insertDocumentRelation,
        document_p_updateDocumentRelation,
        document_p_deleteDocumentRelation,
        document_p_insertInventoryDocumentHeader,
        document_p_updateInventoryDocumentHeader,
        document_p_insertInventorySheet,
        document_p_updateInventorySheet,
        document_p_insertInventorySheetLine,
        document_p_updateInventorySheetLine,
        document_p_deleteInventorySheetLine,
        document_p_getInventoryDocumentData,
        document_p_getInventorySheetData,
        document_p_getTechnologiesNames,
        document_p_getProductionItems,
        /// <summary>
        /// Checks existence of technology name
        /// * xmlVar - <root><name>test</name></root>
        /// </summary>
        document_p_checkTechnologyNameExistence,
        /// <summary>
        /// Gets full financial document data. Params:
        /// * financialDocumentHeaderId - id of the document to load.
        /// </summary>
        document_p_getFinancialDocumentData,

        /// <summary>
        /// Inserts a new financial document header. Params:
        /// * xmlVar - xml containing financial document header entries.
        /// </summary>
        document_p_insertFinancialDocumentHeader,

        /// <summary>
        /// Updates financial document header. Params:
        /// * xmlVar - xml containing financial document header entries.
        /// </summary>
        document_p_updateFinancialDocumentHeader,

        /// <summary>
        /// Gets contractor dealing. Params:
        /// * xmlVar - xml with contractor id and date
        /// </summary>
        document_p_getContractorDealing,

        document_p_checkIncomeValuation,

        /// <summary>
        /// Valuates income warehouse document. Params:
        /// *warehouseDocumentHeaderId - id of valuated document
        /// *localTransactionId
        /// *deferredTransactionId
        /// *databaseId
        /// </summary>
        document_p_valuateIncome,

        /// <summary>
        /// Valuates invoice. Params:
        /// *commercialDocumentHeaderId - id of valuated document
        /// *localTransactionId
        /// *deferredTransactionId
        /// *databaseId
        /// </summary>
        document_xp_valuateInvoice,

        /// <summary>
        /// Deletes relations between specified warehouse document and warehouse documents. Params:
        /// *commercialDocumentHeaderId - id of commercial document to unrelate.
        /// </summary>
        document_p_unrelateCommercialDocumentFromWarehouseDocuments,

        /// <summary>
        /// Deletes all relations of outcome warehouse document. Params:
        /// *warehouseDocumentHeaderId
        /// </summary>
        document_p_deleteWarehouseDocumentRelationsForOutcome,

        /// <summary>
        /// Deletes all relations of income warehouse document. Params:
        /// *warehouseDocumentHeaderId
        /// </summary>
        document_p_deleteWarehouseDocumentRelationsForIncome,

        /// <summary>
        /// Updates order stock. Params:
        /// @xmlVar - input xml containing specified item, warehouse and ordered quantity
        /// </summary>
        document_p_updateOrderStock,

        /// <summary>
        /// Updates order stock. Params:
        /// @xmlVar - input xml containing specified item, warehouse and reserved quantity
        /// </summary>
        document_p_updateReservationStock,

        /// <summary>
        /// Updates warehouse stock - avaliable, reserved and ordered quatntity using absolute value. Params:
        /// @xmlVar - input xml containing a row from document.WarehouseStock table
        /// </summary>
        document_p_updateWarehouseStock,

        /// <summary>
        /// Deletes income-outcome relations of specified warehouse document. Params:
        /// *warehouseDocumentHeaderId - specified document id
        /// </summary>
        document_p_deleteIncomeOutcomeRelations,

        /// <summary>
        /// Gets all corrective documents for specified commercial document. Params:
        /// *commercialDocumentHeaderId - specified document id
        /// </summary>
        document_p_getCommercialCorrectiveDocuments,

        /// <summary>
        /// Gets previous corrective documents for specified commercial corrective document. Params:
        /// *commercialDocumentHeaderId - commercial document id
        /// </summary>
        document_p_getPreviousCommercialCorrectiveDocuments,

        /// <summary>
        /// Gets all corrective documents for specified warehouse document. Params:
        /// *warehouseDocumentHeaderId - warehouse document id
        /// </summary>
        document_p_getWarehouseCorrectiveDocuments,

        /// <summary>
        /// Gets previous corrective documents for specified warehouse corrective document. Params:
        /// *warehouseDocumentHeaderId - warehouse document id
        /// </summary>
        document_p_getPreviousWarehouseCorrectiveDocuments,

        /// <summary>
        /// When specified outcome line has associated corrective document it is returned as corrected line; otherwise, empty xml is returned. Params:
        /// *warehouseDocumentLineId - warehouse document line id
        /// </summary>
        document_p_getOutcomeLineAfterCorrection,

        document_p_getIncomeLineAfterCorrection,

        /// <summary>
        /// Inserts a new series entries to the database. Params:
        /// * xmlVar - xml containing series entries
        /// </summary>
        document_p_insertSeries,

        /// <summary>
        /// Updates stock for the specified item and warehouse. Params:
        /// * xmlVar - xml containing item collection.
        /// </summary>
        document_p_updateStock,

        /// <summary>
        /// Updates last purchase price in warehouseStock for the specified item and warehouse. Params:
        /// * xmlVar - xml containing item collection.
        /// </summary>
        document_p_updateLastPurchasePrice,

        /// <summary>
        /// Gets the current date from database.
        /// </summary>
        document_p_getDate,

        /// <summary>
        /// Gets deliveries for the specifies items. Params:
        /// * xmlVar - input xml.
        /// </summary>
        document_p_getDeliveries,

        /// <summary>
        /// Check if the document version is the same as specified (expected) and throws 50012 error if it doesn't. Params:
        /// * version - expected document version
        /// </summary>
        document_p_checkCommercialDocumentVersion,

        /// <summary>
        /// Check if the document version is the same as specified (expected) and throws 50012 error if it doesn't. Params:
        /// * version - expected document version
        /// </summary>
        document_p_checkFinancialDocumentVersion,

        /// <summary>
        /// Check if the document version is the same as specified (expected) and throws 50012 error if it doesn't. Params:
        /// * version - expected document version
        /// </summary>
        document_p_checkFinancialReportVersion,

        /// <summary>
        /// Check if the document version is the same as specified (expected) and throws 50012 error if it doesn't. Params:
        /// * version - expected document version
        /// </summary>
        document_p_checkWarehouseDocumentVersion,

        /// <summary>
        /// Indexes commercial document during insert action. Params:
        /// * xmlVar - xml containing full xml of the commercial document.
        /// </summary>
        document_p_insertCommercialDocumentDictionary,

        /// <summary>
        /// Inserts a new commercial document header. Params:
        /// * xmlVar - xml containing commercial document header entries.
        /// </summary>
        document_p_insertCommercialDocumentHeader,

        /// <summary>
        /// Inserts a new warehouse document header. Params:
        /// * xmlVar - xml containing warehouse document header entries.
        /// </summary>
        document_p_insertWarehouseDocumentHeader,

        /// <summary>
        /// Updates commercial document header. Params:
        /// * xmlVar - xml containing commercial document header entries.
        /// </summary>
        document_p_updateCommercialDocumentHeader,

        /// <summary>
        /// Updates warehouse document header. Params:
        /// * xmlVar - xml containing warehouse document header entries.
        /// </summary>
        document_p_updateWarehouseDocumentHeader,

        /// <summary>
        /// Inserts a new commercial document line. Params:
        /// * xmlVar - xml containing commercial document line entries.
        /// </summary>
        document_p_insertCommercialDocumentLine,

        /// <summary>
        /// Inserts a new warehouse document line. Params:
        /// * xmlVar - xml containing warehouse document line entries.
        /// </summary>
        document_p_insertWarehouseDocumentLine,

        /// <summary>
        /// Updates commercial document line. Params:
        /// * xmlVar - xml containing commercial document line entries.
        /// </summary>
        document_p_updateCommercialDocumentLine,

        /// <summary>
        /// Updates warehouse document line. Params:
        /// * xmlVar - xml containing warehouse document line entries.
        /// </summary>
        document_p_updateWarehouseDocumentLine,

        /// <summary>
        /// Deletes an commercial document line. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        document_p_deleteCommercialDocumentLine,

        /// <summary>
        /// Deletes an warehouse document line. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        document_p_deleteWarehouseDocumentLine,

        /// <summary>
        /// Inserts new commercial warehouse valuation entries. Params:
        /// * xmlVar - xml containing commercial warehouse valuation entries.
        /// </summary>
        document_p_insertCommercialWarehouseValuation,

        /// <summary>
        /// Updates commercial warehouse valuation entries. Params:
        /// * xmlVar - xml containing commercial warehouse valuation entries.
        /// </summary>
        document_p_updateCommercialWarehouseValuation,

        /// <summary>
        /// Deletes commercial warehouse valuation entries. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        document_p_deleteCommercialWarehouseValuation,

        /// <summary>
        /// Inserts new commercial warehouse relation entries. Params:
        /// * xmlVar - xml containing commercial warehouse relation entries.
        /// </summary>
        document_p_insertCommercialWarehouseRelation,

        /// <summary>
        /// Updates commercial warehouse relation entries. Params:
        /// * xmlVar - xml containing commercial warehouse relation entries.
        /// </summary>
        document_p_updateCommercialWarehouseRelation,

        /// <summary>
        /// Deletes commercial warehouse relation entries. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        document_p_deleteCommercialWarehouseRelation,

        /// <summary>
        /// Inserts a new commercial document vat table. Params:
        /// * xmlVar - xml containing commercial document vat table entries.
        /// </summary>
        document_p_insertCommercialDocumentVatTable,

        /// <summary>
        /// Valuates an outcome warehouse document. Params:
        /// * warehouseDocumentHeaderId
        /// </summary>
        document_xp_valuateOutcome,

        /// <summary>
        /// Updates cost on outcome warehouse document.
        /// </summary>
        document_p_updateWarehouseDocumentCost,

        /// <summary>
        /// Updates commercial document vat table. Params:
        /// * xmlVar - xml containing commercial document vat table entries.
        /// </summary>
        document_p_updateCommercialDocumentVatTable,

        /// <summary>
        /// Deletes an commercial document vat table. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        document_p_deleteCommercialDocumentVatTable,

        /// <summary>
        /// Inserts a new document's attribute. Params:
        /// * xmlVar - xml containing document's attribute entries.
        /// </summary>
        document_p_insertDocumentAttrValue,

        /// <summary>
        /// Updates document's attribute. Params:
        /// * xmlVar - xml containing document's attribute entries.
        /// </summary>
        document_p_updateDocumentAttrValue,

        /// <summary>
        /// Deletes an document's attribute. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        document_p_deleteDocumentAttrValue,

        document_p_insertDocumentLineAttrValue,

        document_p_updateDocumentLineAttrValue,

        document_p_deleteDocumentLineAttrValue,

        /// <summary>
        /// Gets full commercial document data. Params:
        /// * commercialDocumentHeaderId - id of the document to load.
        /// </summary>
        document_p_getCommercialDocumentData,

        document_p_getFinancialDocuments,

        /// <summary>
        /// Gets full warehouse document data. Params:
        /// * warehouseDocumentHeaderId - id of the document to load.
        /// </summary>
        document_p_getWarehouseDocumentData,

        /// <summary>
        /// Gets documents list. Params:
        /// * xmlVar - xml containing configuration options.
        /// </summary>
        document_p_getCommercialDocuments,

        /// <summary>
        /// Checks whether a number is free to get. Params:
        /// * xmlVar - xml containing seriesValue, number.
        /// Returns <root>true</root> or <root>false</root>.
        /// </summary>
        document_p_checkNumberExistence,

        /// <summary>
        /// Gets the last used number for the specified series. Params:
        /// * xmlVar - xml containing numberSettingId, seriesValue.
        /// </summary>
        document_p_getLastNumberForSeries,

        /// <summary>
        /// Inserts a new income outcome relation row. Params:
        /// * xmlVar - xml income outcome relation entries.
        /// </summary>
        document_p_insertIncomeOutcomeRelation,

        /// <summary>
        /// Updates income outcome relation row. Params:
        /// * xmlVar - xml income outcome relation entries.
        /// </summary>
        document_p_updateIncomeOutcomeRelation,

        document_p_insertWarehouseDocumentValuation,
        document_p_updateWarehouseDocumentValuation,
        document_p_deleteWarehouseDocumentValuation,

        /// <summary>
        /// Deletes an income outcome relation row. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        document_p_deleteIncomeOutcomeRelation,

        /// <summary>
        /// Checks whether income warehouse document has any outcomes. Params:
        /// * id - id of the document to check for having outcomes.
        /// </summary>
        document_p_hasIncomeAnyOutcome,

        /// <summary>
        /// Check whether any outcome warehouse document has relation with commercial document. Params:
        /// * id - if of the outcome warehouse document to check.
        /// </summary>
        document_p_hasOutcomeAnyCommercialRelation,

        /// <summary>
        /// Gets warehouse documents list. Params:
        /// * xmlVar - xml containing configuration options.
        /// </summary>
        document_p_getWarehouseDocuments,

        document_p_getInventoryDocuments,

        /// <summary>
        /// Gets income shift document. Params:
        /// @outcomeShiftId - id of outcome shift document paired with returned outcome shift document.
        /// </summary>
        document_p_getIncomeShiftByOutcomeId,

        /// <summary>
        /// Creates outcome quantity correction. Params:
        /// * xmlVar - xml containing outcome document correction data.
        /// </summary>
        document_p_createOutcomeQuantityCorrection,

        /// <summary>
        /// Gets headers' id for lines specified by collection of nodes containing line id.
        /// * xmlVar - xml containing collection of lines' id.
        /// </summary>
        document_p_getHeaderIdForWarehouseLines,

        /// <summary>
        /// Gets all warehouse corrective lines for the specified warehouse document header id
        /// * warehouseDocumentHeaderId
        /// </summary>
        document_p_getAllWarehouseCorrectiveLines,

        /// <summary>
        /// Gets all lines in <see cref="CommercialDocument"/>s which realize sales order (contain attributeLineAttribute_RealizedSalesOrderLineId)
        /// </summary>
        document_p_getRealizedSalesOrderLines,

        /// <summary>
        /// Creates income quantity correction. Params:
        /// * xmlVar - xml containing income document correction data.
        /// </summary>
        document_p_createIncomeQuantityCorrection,

        document_p_checkForLaterCorrectionsExistence,
        document_p_getCommercialDocumentLines,
        document_p_getDocumentContractorFullName,
        document_p_isWarehouseDocumentValuated,
        document_p_getDocumentCost,
        document_p_getLineMappingForDocument,

        #endregion

        #region Finance procedures
        finance_p_getFinancialReportsDate,
        finance_p_getOpenedFinancialReportId,
        finance_p_getFinancialReports,
        finance_p_getFinancialReportValidationDates,
        finance_p_getFinancialReportStatusById,
        finance_p_calculateReportBalance,
        finance_p_calculateReportInitialBalance,
        finance_p_checkReportExistence,
        finance_p_getPaymentsById,
        finance_p_getNextFinancialReportsId,
        finance_p_updateDocumentInfoOnPayments,
        finance_p_checkPaymentVersion,
        /// <summary>
        /// Inserts a new financial report. Params:
        /// * xmlVar - xml containing financial report entries.
        /// </summary>
        finance_p_insertFinancialReport,

        /// <summary>
        /// Updates financial report. Params:
        /// * xmlVar - xml containing financial report entries.
        /// </summary>
        finance_p_updateFinancialReport,

        /// <summary>
        /// Inserts a new payment settlement. Params:
        /// * xmlVar - xml containing payment settlement entries.
        /// </summary>
        finance_p_insertPaymentSettlement,

        /// <summary>
        /// Updates payment settlement. Params:
        /// * xmlVar - xml containing payment settlement entries.
        /// </summary>
        finance_p_updatePaymentSettlement,

        /// <summary>
        /// Deletes payment settlement. Params:
        /// * xmlVar - xml containing payment settlement id.
        /// </summary>
        finance_p_deletePaymentSettlement,

        /// <summary>
        /// Deletes payment. Params:
        /// * xmlVar - xml containing payment id.
        /// </summary>
        finance_p_deletePayment,

        /// <summary>
        /// Gets full financial report data. Params:
        /// * financialReportId - id of the document to load.
        /// </summary>
        finance_p_getFinancialReportData,

        /// <summary>
        /// Inserts a new payment. Params:
        /// * xmlVar - xml containing payment entries.
        /// </summary>
        finance_p_insertPayment,

        /// <summary>
        /// Updates payment. Params:
        /// * xmlVar - xml containing payment entries.
        /// </summary>
        finance_p_updatePayment,
        finance_p_getPaymentData,
        finance_p_getRegistersOpenReports,
        #endregion

        #region Dictionary procedures

        /// <summary>
        /// Gets all financial registers.
        /// </summary>
        dictionary_p_getFinancialRegisters,

        /// <summary>
        /// Gets all vat registers.
        /// </summary>
        dictionary_p_getVatRegisters,

        /// <summary>
        /// Gets all accounting journals.
        /// </summary>
        dictionary_p_getAccountingJournals,

        /// <summary>
        /// Gets all accounting rules.
        /// </summary>
        dictionary_p_getAccountingRules,
        /// <summary>
        /// Gets list of avaliable status for documents (all data from dictionary.DocumentStatus table)
        /// </summary>
        dictionary_p_getDocumentStatuses,

        /// <summary>
        /// Gets list of offer statuses
        /// </summary>
        dictionary_p_getOfferStatuses,

        /// <summary>
        /// Gets all countries.
        /// </summary>
        dictionary_p_getCountries,

        /// <summary>
        /// Gets all companies.
        /// </summary>
        dictionary_p_getCompanies,

        /// <summary>
        /// Gets all branches.
        /// </summary>
        dictionary_p_getBranches,

        /// <summary>
        /// Gets all warehouses.
        /// </summary>
        dictionary_p_getWarehouses,

        /// <summary>
        /// Gets all job positions.
        /// </summary>
        dictionary_p_getJobPositions,

        /// <summary>
        /// Gets the whole table DictionaryVersion.
        /// </summary>
        dictionary_p_getDictionariesVersions,

        /// <summary>
        /// Gets all contractor relation types.
        /// </summary>
        dictionary_p_getContractorRelationTypes,

        /// <summary>
        /// Gets all contractor fields.
        /// </summary>
        dictionary_p_getContractorFields,

        /// <summary>
        /// Gets all item fields.
        /// </summary>
        dictionary_p_getItemFields,

        /// <summary>
        /// Gets all item relation attr value types.
        /// </summary>
        dictionary_p_getItemRelationAttrValueTypes,

        /// <summary>
        /// Gets all item relation types.
        /// </summary>
        dictionary_p_getItemRelationTypes,

        /// <summary>
        /// Gets all item types.
        /// </summary>
        dictionary_p_getItemTypes,

        /// <summary>
        /// Gets all units.
        /// </summary>
        dictionary_p_getUnits,

        /// <summary>
        /// Gets all unit types.
        /// </summary>
        dictionary_p_getUnitTypes,

        /// <summary>
        /// Gets all mime types.
        /// </summary>
        dictionary_p_getMimeTypes,

        /// <summary>
        /// Gets all repositories.
        /// </summary>
        dictionary_p_getRepositories,

        /// <summary>
        /// Gets all vat rates.
        /// </summary>
        dictionary_p_getVatRates,

        /// <summary>
        /// Gets all document fields.
        /// </summary>
        dictionary_p_getDocumentFields,

        /// <summary>
        /// Gets all currencies.
        /// </summary>
        dictionary_p_getCurrencies,

        /// <summary>
        /// Gets all issue places.
        /// </summary>
        dictionary_p_getIssuePlaces,

        /// <summary>
        /// Gets all payment methods.
        /// </summary>
        dictionary_p_getPaymentMethods,

        /// <summary>
        /// Gets all documenttypes.
        /// </summary>
        dictionary_p_getDocumentTypes,

        /// <summary>
        /// Gets all document field relations.
        /// </summary>
        dictionary_p_getDocumentFieldRelations,

        /// <summary>
        /// Gets all configuration keys.
        /// </summary>
        dictionary_p_getConfigurationKeys,

        /// <summary>
        /// Inserts a new configurationKey. Params:
        /// * xmlVar - xml containing configurationKey entries.
        /// </summary>
        dictionary_p_insertConfigurationKey,

        /// <summary>
        /// Updates configurationKey. Params:
        /// * xmlVar - xml containing configurationKey entries.
        /// </summary>
        dictionary_p_updateConfigurationKey,

        /// <summary>
        /// Inserts a new contractorField. Params:
        /// * xmlVar - xml containing contractorField entries.
        /// </summary>
        dictionary_p_insertContractorField,

        /// <summary>
        /// Updates contractorField. Params:
        /// * xmlVar - xml containing contractorField entries.
        /// </summary>
        dictionary_p_updateContractorField,

        /// <summary>
        /// Inserts a new contractorRelationType. Params:
        /// * xmlVar - xml containing contractorRelationType entries.
        /// </summary>
        dictionary_p_insertContractorRelationType,

        /// <summary>
        /// Updates contractorRelationType. Params:
        /// * xmlVar - xml containing contractorRelationType entries.
        /// </summary>
        dictionary_p_updateContractorRelationType,

        /// <summary>
        /// Inserts a new country. Params:
        /// * xmlVar - xml containing country entries.
        /// </summary>
        dictionary_p_insertCountry,

        /// <summary>
        /// Updates country. Params:
        /// * xmlVar - xml containing country entries.
        /// </summary>
        dictionary_p_updateCountry,

        /// <summary>
        /// Inserts a new currency. Params:
        /// * xmlVar - xml containing currency entries.
        /// </summary>
        dictionary_p_insertCurrency,

        /// <summary>
        /// Updates currency. Params:
        /// * xmlVar - xml containing currency entries.
        /// </summary>
        dictionary_p_updateCurrency,

        /// <summary>
        /// Inserts a new documentField. Params:
        /// * xmlVar - xml containing documentField entries.
        /// </summary>
        dictionary_p_insertDocumentField,

        /// <summary>
        /// Updates documentField. Params:
        /// * xmlVar - xml containing documentField entries.
        /// </summary>
        dictionary_p_updateDocumentField,

        /// <summary>
        /// Inserts a new documentFieldRelation. Params:
        /// * xmlVar - xml containing documentFieldRelation entries.
        /// </summary>
        dictionary_p_insertDocumentFieldRelation,

        /// <summary>
        /// Updates documentFieldRelation. Params:
        /// * xmlVar - xml containing documentFieldRelation entries.
        /// </summary>
        dictionary_p_updateDocumentFieldRelation,

        /// <summary>
        /// Inserts a new documentType. Params:
        /// * xmlVar - xml containing documentType entries.
        /// </summary>
        dictionary_p_insertDocumentType,

        /// <summary>
        /// Updates documentType. Params:
        /// * xmlVar - xml containing documentType entries.
        /// </summary>
        dictionary_p_updateDocumentType,

        /// <summary>
        /// Inserts a new issuePlace. Params:
        /// * xmlVar - xml containing issuePlace entries.
        /// </summary>
        dictionary_p_insertIssuePlace,

        /// <summary>
        /// Updates issuePlace. Params:
        /// * xmlVar - xml containing issuePlace entries.
        /// </summary>
        dictionary_p_updateIssuePlace,

        /// <summary>
        /// Inserts a new itemField. Params:
        /// * xmlVar - xml containing itemField entries.
        /// </summary>
        dictionary_p_insertItemField,

        /// <summary>
        /// Updates itemField. Params:
        /// * xmlVar - xml containing itemField entries.
        /// </summary>
        dictionary_p_updateItemField,

        /// <summary>
        /// Inserts a new itemRelationAttrValueType. Params:
        /// * xmlVar - xml containing itemRelationAttrValueType entries.
        /// </summary>
        dictionary_p_insertItemRelationAttrValueType,

        /// <summary>
        /// Updates itemRelationAttrValueType. Params:
        /// * xmlVar - xml containing itemRelationAttrValueType entries.
        /// </summary>
        dictionary_p_updateItemRelationAttrValueType,

        /// <summary>
        /// Inserts a new itemRelationType. Params:
        /// * xmlVar - xml containing itemRelationType entries.
        /// </summary>
        dictionary_p_insertItemRelationType,

        /// <summary>
        /// Updates itemRelationType. Params:
        /// * xmlVar - xml containing itemRelationType entries.
        /// </summary>
        dictionary_p_updateItemRelationType,

        /// <summary>
        /// Inserts a new itemType. Params:
        /// * xmlVar - xml containing itemType entries.
        /// </summary>
        dictionary_p_insertItemType,

        /// <summary>
        /// Updates itemType. Params:
        /// * xmlVar - xml containing itemType entries.
        /// </summary>
        dictionary_p_updateItemType,

        /// <summary>
        /// Inserts a new jobPosition. Params:
        /// * xmlVar - xml containing jobPosition entries.
        /// </summary>
        dictionary_p_insertJobPosition,

        /// <summary>
        /// Updates jobPosition. Params:
        /// * xmlVar - xml containing jobPosition entries.
        /// </summary>
        dictionary_p_updateJobPosition,

        /// <summary>
        /// Inserts a new mimeType. Params:
        /// * xmlVar - xml containing mimeType entries.
        /// </summary>
        dictionary_p_insertMimeType,

        /// <summary>
        /// Updates mimeType. Params:
        /// * xmlVar - xml containing mimeType entries.
        /// </summary>
        dictionary_p_updateMimeType,

        /// <summary>
        /// Inserts a new paymentMethod. Params:
        /// * xmlVar - xml containing paymentMethod entries.
        /// </summary>
        dictionary_p_insertPaymentMethod,

        /// <summary>
        /// Updates paymentMethod. Params:
        /// * xmlVar - xml containing paymentMethod entries.
        /// </summary>
        dictionary_p_updatePaymentMethod,

        /// <summary>
        /// Inserts a new repository. Params:
        /// * xmlVar - xml containing repository entries.
        /// </summary>
        dictionary_p_insertRepository,

        /// <summary>
        /// Updates repository. Params:
        /// * xmlVar - xml containing repository entries.
        /// </summary>
        dictionary_p_updateRepository,

        /// <summary>
        /// Inserts a new unit. Params:
        /// * xmlVar - xml containing unit entries.
        /// </summary>
        dictionary_p_insertUnit,

        /// <summary>
        /// Updates unit. Params:
        /// * xmlVar - xml containing unit entries.
        /// </summary>
        dictionary_p_updateUnit,

        /// <summary>
        /// Inserts a new unitType. Params:
        /// * xmlVar - xml containing unitType entries.
        /// </summary>
        dictionary_p_insertUnitType,

        /// <summary>
        /// Updates unitType. Params:
        /// * xmlVar - xml containing unitType entries.
        /// </summary>
        dictionary_p_updateUnitType,

        /// <summary>
        /// Inserts a new vatRate. Params:
        /// * xmlVar - xml containing vatRate entries.
        /// </summary>
        dictionary_p_insertVatRate,

        /// <summary>
        /// Updates vatRate. Params:
        /// * xmlVar - xml containing vatRate entries.
        /// </summary>
        dictionary_p_updateVatRate,

        /// <summary>
        /// Inserts a new documentNumberComponent. Params:
        /// * xmlVar - xml containing documentNumberComponent entries.
        /// </summary>
        dictionary_p_insertDocumentNumberComponent,

        /// <summary>
        /// Updates documentNumberComponent. Params:
        /// * xmlVar - xml containing documentNumberComponent entries.
        /// </summary>
        dictionary_p_updateDocumentNumberComponent,

        /// <summary>
        /// Gets all document number components.
        /// </summary>
        dictionary_p_getDocumentNumberComponents,

        /// <summary>
        /// Gets all number settings.
        /// </summary>
        dictionary_p_getNumberSettings,

        /// <summary>
        /// Inserts a new numberSetting. Params:
        /// * xmlVar - xml containing numberSetting entries.
        /// </summary>
        dictionary_p_insertNumberSetting,

        /// <summary>
        /// Updates numberSetting. Params:
        /// * xmlVar - xml containing numberSetting entries.
        /// </summary>
        dictionary_p_updateNumberSetting,

        /// <summary>
        /// Determines whether specified warehoues are local
        /// * xmlVar - xml containing lists of warehouses that are checked.
        /// </summary>
        dictionary_p_isLocalWarehouse,
        dictionary_p_getContainerTypes,
        dictionary_p_checkBranchVersion,
        dictionary_p_checkCompanyVersion,
        dictionary_p_checkContainerTypeVersion,
        dictionary_p_checkContractorFieldVersion,
        dictionary_p_checkContractorRelationTypeVersion,
        dictionary_p_checkCountryVersion,
        dictionary_p_checkCurrencyVersion,
        dictionary_p_checkDocumentFieldRelationVersion,
        dictionary_p_checkDocumentFieldVersion,
        dictionary_p_checkDocumentTypeVersion,
        dictionary_p_checkIssuePlaceVersion,
        dictionary_p_checkItemFieldVersion,
        dictionary_p_checkItemRelationAttrValueTypeVersion,
        dictionary_p_checkItemRelationTypeVersion,
        dictionary_p_checkItemTypeVersion,
        dictionary_p_checkJobPositionVersion,
        dictionary_p_checkMimeTypeVersion,
        dictionary_p_checkPaymentMethodVersion,
        dictionary_p_checkRepositoryVersion,
        dictionary_p_checkUnitTypeVersion,
        dictionary_p_checkUnitVersion,
        dictionary_p_checkVatRateVersion,
        dictionary_p_checkWarehouseVersion,
        dictionary_p_checkNumberSettingVersion,
        dictionary_p_checkVatRegisterVersion,
        dictionary_p_getShiftFields,
        dictionary_p_checkShiftFieldVersion,
        dictionary_p_insertShiftField,
        dictionary_p_updateShiftField,
        dictionary_p_insertServicePlace,
        dictionary_p_updateServicePlace,
        dictionary_p_getServicePlaces,
        dictionary_p_checkServicePlaceVersion,
        #endregion

        #region Item procedures
        item_p_blockItem,
        item_p_unblockItems,
        item_p_checkItemExistenceInDocuments,
        item_p_checkItemsExistenceByCode,
        item_p_getFiscalNames,
        item_p_checkItemCodeExistence,
        item_p_getItemsDetailsForDocument,
        item_p_getItemsManufacturerAndCode,
        item_p_getItemsByManufacturerAndCode,
        item_p_getItemsByBarcode,
        item_p_getItemsDetailsForDocumentByItemCode,
        item_p_getItemsGroups,

        /// <summary>
        /// Creates (update or insert) price rules
        /// </summary>
        item_p_createPriceRule,

        /// <summary>
        /// Saves list of price rules
        /// </summary>
        item_p_savePriceRuleList,

        /// <summary>
        /// Gets items quantity. Params:
        /// * xmlVar - not used xml param
        /// </summary>
        item_p_getItemsCount,


        /// <summary>
        /// Gets amount of items belonging to specified group. Params: 
        /// * itemGroupId - item group id.
        /// </summary>
        item_p_getItemGroupMembershipsCount,

        /// <summary>
        /// Gets random keywords from the item dictionary. Params:
        /// * xmlVar - xml containing amount attribute.
        /// </summary>
        item_p_getRandomKeywords,

        /// <summary>
        /// Gets the name of the specified item. Params:
        /// @id - item id.
        /// </summary>
        item_p_getItemName,

        /// <summary>
        /// Gets full item data. Params:
        /// * itemId - contractor's id to load.
        /// </summary>
        item_p_getItemData,

        /// <summary>
        /// Gets a list of random lines. Params:
        /// * xmlVar - xml containing amount attribute in root-tag.
        /// </summary>
        item_p_getRandomLines,

        /// <summary>
        /// Gets items list. Params:
        /// * xmlVar - xml containing configuration options.
        /// </summary>
        item_p_getItems,

        /// <summary>
        /// Check if the item version is the same as specified (expected) and throws 50012 error if it doesn't. Params:
        /// * version - expected item version
        /// </summary>
        item_p_checkItemVersion,

        /// <summary>
        /// Updates an item. Params:
        /// * xmlVar - xml containing item entries.
        /// </summary>
        item_p_updateItem,

        /// <summary>
        /// Inserts a new item. Params:
        /// * xmlVar - xml containing item entries.
        /// </summary>
        item_p_insertItem,

        /// <summary>
        /// Inserts a new item group membership. Params:
        /// * xmlVar - xml containing item group membership entries.
        /// </summary>
        item_p_insertItemGroupMembership,

        /// <summary>
        /// Updates an item group membership. Params:
        /// * xmlVar - xml containing item group membership entries.
        /// </summary>
        item_p_updateItemGroupMembership,

        /// <summary>
        /// Deletes an item group membership. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        item_p_deleteItemGroupMembership,

        /// <summary>
        /// Inserts a new item unit relation. Params:
        /// * xmlVar - xml containing item unit relation entries.
        /// </summary>
        item_p_insertItemUnitRelation,

        /// <summary>
        /// Updates an item unit relation. Params:
        /// * xmlVar - xml containing item unit relation entries.
        /// </summary>
        item_p_updateItemUnitRelation,

        /// <summary>
        /// Deletes an item unit relation. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        item_p_deleteItemUnitRelation,

        /// <summary>
        /// Inserts a new item relation. Params:
        /// * xmlVar - xml containing item relation entries.
        /// </summary>
        item_p_insertItemRelation,

        /// <summary>
        /// Updates an item relation. Params:
        /// * xmlVar - xml containing item relation entries.
        /// </summary>
        item_p_updateItemRelation,

        /// <summary>
        /// Deletes an item relation. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        item_p_deleteItemRelation,

        /// <summary>
        /// Inserts a new item relation attr value. Params:
        /// * xmlVar - xml containing item relation attr value entries.
        /// </summary>
        item_p_insertItemRelationAttrValue,

        /// <summary>
        /// Updates an item relation attr value. Params:
        /// * xmlVar - xml containing item relation attr value entries.
        /// </summary>
        item_p_updateItemRelationAttrValue,

        /// <summary>
        /// Deletes an item relation attr value. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        item_p_deleteItemRelationAttrValue,

        /// <summary>
        /// Inserts a new item attr value. Params:
        /// * xmlVar - xml containing item attr value entries.
        /// </summary>
        item_p_insertItemAttrValue,

        /// <summary>
        /// Updates an item attr value. Params:
        /// * xmlVar - xml containing item attr value entries.
        /// </summary>
        item_p_updateItemAttrValue,

        /// <summary>
        /// Deletes an item attr value. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        item_p_deleteItemAttrValue,

        /// <summary>
        /// Updates item dictionary index. Params:
        /// * xmlVar - xml containing 'businessObjectId' and 'mode' attributes.
        /// </summary>
        item_p_updateItemDictionary,

        /// <summary>
        /// Sets a new version of the item. Params:
        /// * oldVersion - old item's version
        /// * newVersion - new item's version
        /// </summary>
        item_p_setItemVersion,

        /// <summary>
        /// Gets a collection of equivalent items. Params:
        /// * itemId - id of the item for which we want to get equivalents
        /// * groupId - id of the equivalent group
        /// </summary>
        item_p_getItemEquivalents,

        /// <summary>
        /// Gets a list of items with its parameters neccessary for adding the items to the document's line. Params:
        /// * xmlVar - xml list containing id of items to get.
        /// </summary>
        item_p_getItemsForDocument,

        /// <summary>
        /// Gets item types for specified items. Params:
        /// * xmlVar - xml list containing id of items
        /// </summary>
        item_p_getItemsTypes,

        item_p_deleteItem,
        #endregion

        #region Configuration procedures
        /// <summary>
        /// Gets the configuration elements. Params:
        /// * xmlVar - xml containing entries with configuration key names.
        /// </summary>
        configuration_p_getConfiguration,
        configuration_p_deleteConfiguration,
        configuration_p_deleteConfigurationById,
        /// <summary>
        /// Updates version of configuration table.
        /// </summary>
        configuration_p_updateConfigurationVersion,

        /// <summary>
        /// Inserts a new configuration entry. Params:
        /// * xmlVar - xml containing configuration entries.
        /// </summary>
        configuration_p_insertConfiguration,

        /// <summary>
        /// Updates configuration entry. Params:
        /// * xmlVar - xml containing configuration entries.
        /// </summary>
        configuration_p_updateConfiguration,

        /// <summary>
        /// Gets the specified configuration element. Params:
        /// * id - id of the configuration to load.
        /// </summary>
        configuration_p_getConfigurationById,

        /// <summary>
        /// Gets all configuration entries that has exactly the same key. Params:
        /// * xmlVar - xml containing key entry.
        /// </summary>
        configuration_p_getConfigurationSet,
        configuration_p_getCurrentBranchId,
        configuration_p_getConfigurationKeys,
        #endregion

        #region Repository procedures
        /// <summary>
        /// Updates file descriptor. Params:
        /// * xmlVar - xml containing fileDescriptor entries.
        /// </summary>
        repository_p_insertFileDescriptor,

        /// <summary>
        /// Gets a file descriptor. Params:
        /// * id - file descriptor's id to load.
        /// </summary>
        repository_p_getFileDescriptor,

        /// <summary>
        /// Deletes file descriptor. Params:
        /// * xmlVar - xml containing object's id to delete.
        /// </summary>
        repository_p_deleteFileDescriptor,

        /// <summary>
        /// Updates file descriptor. Params:
        /// * xmlVar - xml containing file descriptor entries.
        /// </summary>
        repository_p_updateFileDescriptor,

        /// <summary>
        /// Check if the FileDescriptor version is the same as specified (expected) and throws 50012 error if it doesn't. Params:
        /// * version - expected item version
        /// </summary>
        repository_p_checkFileDescriptorVersion,

        /// <summary>
        /// Gets the list of all file descriptors.
        /// </summary>
        repository_p_getFileDescriptors,
        #endregion

        #region Journal procedures
        /// <summary>
        /// Insers new row to the Journal table. Params:
        /// * applicationUserId - GUID (NOT NULL)
        /// * journalActionId - GUID (NOT NULL)
        /// * firstObjectId - GUID (NULL)
        /// * secondObjectId - GUID (NULL)
        /// * xmlParams - xml (NULL)
        /// * kernelVersion - varchar (NOT NULL)
        /// </summary>
        journal_p_insertJournalEntry,

        /// <summary>
        /// Gets all journal actions from the JournalAction table.
        /// </summary>
        journal_p_getJournalActions,
        #endregion

        #region Accounting procedures
        accounting_p_getContractorData,
        accounting_p_setObjectMapping,
        accounting_p_getWarehouseDocument,
        accounting_p_getCommercialDocument,
        accounting_p_getFinancialReport,
        accounting_p_createAccountingEntries,
        accounting_p_deleteAccountingDocumentData,
        accounting_p_updatePayments,
        #endregion

        #region Warehouse procedures
        warehouse_p_insertShiftTransaction,
        warehouse_p_updateShiftTransaction,
        warehouse_p_insertShift,
        warehouse_p_updateShift,
        warehouse_p_deleteShift,
        warehouse_p_insertContainer,
        warehouse_p_updateContainer,
        warehouse_p_insertContainerShift,
        warehouse_p_updateContainerShift,
        warehouse_p_getShiftTransactionData,
        warehouse_p_createShiftTransaction,
        warehouse_p_editShiftTransaction,
        warehouse_p_getContainer,
        warehouse_p_getShiftForWarehouseDocument,
        warehouse_p_getContainers,
        warehouse_p_checkContainerContent,
        warehouse_p_getShiftsForIncomeWarehouseLines,
        warehouse_p_getContainerSymbolByShiftId,
        warehouse_p_deleteShiftsForDocument,
        warehouse_p_getShiftsById,
        warehouse_p_createIncomeShiftCorrection,
        warehouse_p_insertShiftAttrValue,
        warehouse_p_updateShiftAttrValue,
        warehouse_p_deleteShiftAttrValue,
        warehouse_p_getShiftTransactionByShiftId,
        warehouse_p_duplicateShiftAttributes,
        warehouse_p_getAvailableLots,
        #endregion

        #region Service
        service_p_insertServiceHeader,
        service_p_updateServiceHeader,
        service_p_insertServiceHeaderServicedObjects,
        service_p_updateServiceHeaderServicedObjects,
        service_p_deleteServiceHeaderServicedObjects,
        service_p_insertServiceHeaderServicePlace,
        service_p_updateServiceHeaderServicePlace,
        service_p_deleteServiceHeaderServicePlace,
        service_p_insertServiceHeaderEmployees,
        service_p_updateServiceHeaderEmployees,
        service_p_deleteServiceHeaderEmployees,
        service_p_insertServicedObject,
        service_p_updateServicedObject,
        service_p_checkServicedObjectVersion,
        service_p_checkServiceVersion,
        service_p_getServicedObjectData,
        service_p_getServiceData,
        #endregion

        #region Complaint
        complaint_p_checkComplaintDocumentVersion,
        complaint_p_insertComplaintDocumentHeader,
        complaint_p_updateComplaintDocumentHeader,
        complaint_p_insertComplaintDocumentLine,
        complaint_p_updateComplaintDocumentLine,
        complaint_p_deleteComplaintDocumentLine,
        complaint_p_insertComplaintDecision,
        complaint_p_updateComplaintDecision,
        complaint_p_deleteComplaintDecision,
        complaint_p_getComplaintDocumentData,
        complaint_p_getComplaintDocuments,
        #endregion

        #region Custom
        custom_p_getPortaCompleteItemDetails,
        custom_p_executeCustomPackage,
        custom_p_getMakolabCompleteItemDetails,
        custom_p_checkItemsExistenceByCode,
        custom_p_importPrices,
        #endregion

        #region Tests.dbo
        dbo_p_insertTestStep,
        #endregion

        #region Configuration Related

        dbo_p_getConfigurationDocumentation,
        dbo_p_insertConfigurationDocumentation,
        dbo_p_updateConfigurationDocumentation,
        dbo_p_getConfigurationChanges,
        dbo_p_insertConfigurationChange,
        item_p_getItemsByItemCode,
        contractor_p_getContractorByFullName

        #endregion
    }
}

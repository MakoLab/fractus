
namespace Makolab.Fractus.Kernel.Enums
{
    /// <summary>
    /// Specifies exception messages id for the <see cref="Makolab.Fractus.Kernel.Exceptions.ClientException"/> class.
    /// </summary>
	public enum ClientExceptionId
	{
		/// <summary>
		/// No session id supplied.
		/// </summary>
		NoSessionId = 1,

		/// <summary>
		/// Session has expired.
		/// </summary>
		SessionExpired = 2,

		/// <summary>
		/// Unknown document type. Params: objType.
		/// </summary>
		UnknownBusinessObjectType = 3,

		/// <summary>
		/// During executing business logic a dictionary has changed.
		/// </summary>
		DictionaryChanged = 4,

		/// <summary>
		/// Single element in BusinessObject is invalid. Params: fieldName.
		/// </summary>
		FieldValidationError = 5,

		/// <summary>
		/// Object version is different. Params: objType.
		/// </summary>
		VersionMismatch = 6,

		/// <summary>
		/// Specified language version is invalid.
		/// </summary>
		InvalidLanguageVersion = 7,

		/// <summary>
		/// Logon failed because of incorrect username or password.
		/// </summary>
		AuthenticationError = 8,

		/// <summary>
		/// <see cref="Makolab.Fractus.Kernel.Managers.SqlConnectionManager.InitializeConnection"/> has timed out.
		/// </summary>
		InitializeConnectionTimeout = 9,

		/// <summary>
		/// Specified object was not found.
		/// </summary>
		ObjectNotFound = 10,

		/// <summary>
		/// Currently processed object already exists in the database.
		/// </summary>
		ObjectAlreadyExists = 11,

		/// <summary>
		/// An item is already in other item equivalent group and cannot be bound to another. Params: itemName.
		/// </summary>
		ItemEquivalentGroupException = 12,

		/// <summary>
		/// Cannot delete contractors group definition, because contractors are already attached to it. Params: count
		/// </summary>
		ContractorsGroupDeleteException = 13,

		/// <summary>
		/// SqlException, Timeout expired has occured.
		/// </summary>
		SqlTimeout = 14,

		/// <summary>
		/// Cannot change document number because of logic.
		/// </summary>
		DocumentNumberChangeException = 15,

		/// <summary>
		/// Deadlock occured.
		/// </summary>
		Deadlock = 16,

		/// <summary>
		/// ReceivingPerson cannot be set if the contractor is null.
		/// </summary>
		ReceivingPersonWithoutContractor = 17,

		/// <summary>
		/// Document doesn't contain any lines.
		/// </summary>
		NoLines = 18,

		/// <summary>
		/// Document can contains only one document line.
		/// </summary>
		OnlyOneDocumentLineAllowed = 19,

		/// <summary>
		/// Document have to contain a contractor.
		/// </summary>
		ContractorIsMandatory = 20,

		/// <summary>
		/// Document cannot contain a contractor.
		/// </summary>
		ContractorIsForbidden = 21,

		/// <summary>
		/// Document can only be issued in system currency.
		/// </summary>
		DocumentCurrencyException = 22,

		/// <summary>
		/// The document cannot use specified payment method. Params: paymentMethodName.
		/// </summary>
		PaymentMethodForbidden = 23,

		/// <summary>
		/// The document cannot have specified document feature. Params: documentFeatureName.
		/// </summary>
		DocumentFeatureForbidden = 24,

		/// <summary>
		/// Not enough item in stock. Params: itemName, warehouseName.
		/// </summary>
		NoItemInStock = 25,

		/// <summary>
		/// Cant edit income warehouse document because it already has outcomes.
		/// </summary>
		UnableToEditIncomeWarehouseDocument = 26,

		/// <summary>
		/// Cant edit outcome warehouse document because it has date other than current date.
		/// </summary>
		UnableToEditOutcomeWarehouseDocument = 27,

		/// <summary>
		/// Cant edit outcome warehouse document because it already has relations with commercial documents.
		/// </summary>
		UnableToEditOutcomeWarehouseDocument2 = 28,

		/// <summary>
		/// Cant edit commercial document because it already has relation with warehouse document.
		/// </summary>
		UnableToEditCommercialDocument = 29,

		UnableToRelateDocuments = 30,

		/// <summary>
		/// Cannot use this bussines object type with this feature.
		/// </summary>
		UnsupportedBusinessObjectType = 31,

		NonStorableItemOnWarehouseDocument = 32,

		UnableToRealizeOrder = 33,

		UnableToRealizeOrder2 = 34,

		IncorrectIssueDateOnSalesDocument = 35,
		QuantityBelowOrEqualZero = 36,
		ItemsGroupDeleteException = 37,
		ContractorTypeChangeError = 38,
		CreateNewDocumentFromCanceledDocument = 39,
		UnableToEditOutcomeWarehouseDocument3 = 40,
		DocumentCompanyOrBranchError = 41,
		CatalogueLimitError = 42,
		WarehouseCorrectionError = 43,
		WarehouseCorrectionError2 = 44,
		WarehouseCorrectionError3 = 45,
		WarehouseCorrectionError4 = 46,
		FullyCorrectedCorrectionError = 47,
		UnableToEditDocumentBecauseOfCorrections = 48,
		NonCorrectiveCorrection = 49,
		DifferentPaymentsAndDocumentValue = 50,
		OpenedFinancialReportDoesNotExist = 51,
		OpenedFinancialReportAlreadyExists = 52,
		UnableToIssueDocumentToClosedFinancialReport = 53,
		UnableToIssueFinancialDocument = 54,
		UnableToIssueFinancialDocument2 = 55,
		FinancialReportCloseError = 56,
		FinancialReportCloseError2 = 57,
		FinancialReportCloseError3 = 58,
		FinancialReportCloseError4 = 59,
		PaymentAmountEqualToZero = 60,
		PaymentSettlementException = 61,
		FinancialDocumentException1 = 62,
		FinancialDocumentException2 = 63,
		FinancialDocumentException3 = 64,
		SettlementException = 65,
		AutomaticFinancialDocumentUpdateException = 66,
		ZeroPaymentSettlementException = 67,
		CancelWarehouseDocumentError1 = 68,
		CancelWarehouseDocumentError2 = 69,
		CancelWarehouseDocumentError3 = 70,
		ItemUnitIdChangeError = 71,
		QuantityOnCorrectionAboveZero = 72,
		ContractorGroupMembershipEnforcement = 73,
		ItemGroupMembershipEnforcement = 74,
		ItemOneGroupMembershipEnforcement = 75,
		ContractorOneGroupMembershipEnforcement = 76,
		PartiallyRealizedOrderContractorChange = 77,
		CalculationTypeChangeError = 78,
		CorrectedCorrectionCancellationError = 79,
		InsufficientQuantityOnContainer = 80,
		NotEnoughDeliveriesSelected = 81,
		NotEmptyContainerRemoval = 82,
		WarehouseChangeError = 83,
		TotalShiftQuantityError = 84,
		TotalShiftQuantityError2 = 85,
		DeliveriesInNonDeliverySelectedWarehouseError = 86,
		ContainerUnrelatedQuantityExceeded = 87,
		ContainerRelatedQuantityExceeded = 88,
		ItemVatRateIdChangeError = 89,
		LinePriceBelowOrEqualZero = 90,
		LinePriceBelowZero = 91,
		UnableToCancelCorrectedDocument = 92,
		NegativePaymentDueDate = 93,
		IncorrectDocumentTypesToRelate = 94,
		UnableToUnrelate = 95,
		IncorrectEventDateSales = 96,
		IncorrectEventDatePurchase = 97,
		ItemCodeAlreadyExists = 98,
		ContractorCodeAlreadyExists = 99,
		SingleAttributeMultipled = 100,
		SourceAndDestinationContainersAreTheSame = 101,
		ContainerUnassignedQuantityExceeded = 102,
		EarlierIssueDateOnCorrectiveDocument = 103,
		SourceQuantityExceeded = 104,
		NoContainerIdOnShift = 105,
		ZeroQuantityOnShift = 106,
		ManufacturerAndCodeLineException = 107,
		RemoteOrderSendingException1 = 108,
		MissingAttribute = 109,
		UnableToRelateDocumentBecauseOfStatus = 110,
		InvaluatedOutcomesProhibited = 111,
		SettlePaymentsError = 112,
		BillCorrectionError = 113,
		InconsistentPaymentMethodOnInvoiceAndBill = 114,
		InconsistentCalculationTypeOnInvoiceAndBill = 115,
		MissingLineAttribute = 116,
		GenerateDocumentOptionAttriuteChangeError = 117,
		QuantityBelowServiceRealized = 118,
		ServiceRealizedLineRemoval = 119,
		ComplaintDecisionQuantityError = 120,
		RealizedComplaintDecisionRemoval = 121,
		RealizedComplaintDecisionQuantityEdition = 122,
		SelectLots = 123,
		ClosedInventorySheetEdition = 124,
		ClosedInventoryDocumentEdition = 125,
		DuplicatedItemInInventorySheet = 126,
		InsufficientLineDetails = 127,
		SqlConnectionError = 128,
		InvoiceToClosedServiceDocument = 129,
		AlreadyClosedServiceDocument = 130,
		CancelWarehouseDocumentError4 = 131,
		ServiceDocumentCloseError1 = 132,
		BookedOutcomeError = 133,
		BookedOutcomeError2 = 134,
		ComplaintDocumentCloseError = 135,
		ItemBlockError = 136,
		BlockedItemError = 137,
		NoWarehouseIdOnInventorySheet = 138,
		NoUserQuantityOnInventorySheetLine = 139,
		ComplaintDecisionTypeChangeError = 140,
		NoSpecifiedVatRate = 141,
		NoSpecifiedPaymentMethod = 142,
		NoSpecifiedCurrency = 143,
		ServiceProcessConfigurationError = 144,
		ItemRemovalError = 145,
		ContractorRemovalError = 146,
		SalesPriceBelowPurchaseError = 147,
		SalesPriceBelowPurchaseWarning = 148,
		InvaluatedOutcomesError = 149,
		InvaluatedOutcomesWarning = 150,
		SalesOrderPrepaidsNumberMismatch = 151,
		SalesOrderSettlementOverpaidError = 152,
		SalesOrderSettlementUnderpaidError = 153,
		PrepaidInvoiceLinesError = 154,
		UnableToRealizeSalesOrder = 155,
		UnableToRealizeSalesOrder3 = 156,
		UnableToCreateInvoiceToSalesOrder = 157,
		UnableToCreateInvoiceToWarehouseDocument = 158,
		UnableToCreatePrepaymentDocument = 159,
		UnableToCreateSettlementDocument = 160,
		DifferentCalculationTypes = 161,
		ErrorClosingSalesOrder = 162,
		UnableToCreatePrepaymentDocument2 = 163,
		UnableToCreateSettlementDocument2 = 164,
		UnableToCreateSettlementDocument3 = 165,
		UnableToIssueFinancialDocument3 = 166,
		MissingTechnologyNameOnTechnology = 167,
		MissingProductionItemType = 168,
		MissingProductionTechnologyName = 169,
		MissingMainProductOnTechnology = 170,
		InvalidItemType = 171,
		MissingMaterialOnTechnology = 172,
		MinimalMarginValidationError = 173,
		ProductionOrderQuantityError = 174,
		MissingSalesman = 175,
		ItemsGroupChangeError = 176,
		EditDocumentBeforeSystemStartForbidden = 177,
		ReservationsFromMultipleWarehousesError = 178,
		DocumentCorrectionBeforeSystemStartError = 179,
		NoTargetBranchSelected = 180,
		IncorrectWarehouseOnShiftOrder = 181,
		OnDocumentCommitValidationError = 182,
		EmptyDocumentNumberError = 183,
		OnlyLineValuesCanBeEdited = 184,
		ExistingTechnologyName = 185,
		SalesOrderMoreThanOneServiceLineError = 186,
		ExcessiveSalesOrderRealizationByCommercialDocument = 187,
		GenerateOutcomeFromSalesOptionMissing = 188,
		UnableToIssueFinancialDocument4 = 189,
		DocumentEditForbiddenRelatedSalesOrderClosed = 190,
		IncorrectNumberOfPayments = 191,
		IncorrectNumberOfPayments2 = 192,
		IncorrectNumberOfPayments3 = 193,
		WarehouseNotLocal = 194,
		CommercialDocumentLineWarehouseNotSelected = 195,
		UnableToEditFinancialOutcomeDocumentRelatedWithSalesOrder = 196,
		LineQuantityEditForbiddenRelatedSalesOrder = 197,
		UnsupportedVatRate = 198,
		LineQuantityChangeForbiddenDuringRelazationOfSalesOrder = 199,
		MissingBeforeSystemStartWhCorrectionTemplate = 200,
		MaximalDiscountValidationError = 201,
		SalesDocumentFromSimulatedInvoiceRelatedWithSalesOrderForbidden = 202,
		FinancialRegisterBalanceBelowZero = 203,
		VatRateNotAllowedForSelectedSaleDate = 204,
		SourceDocumentInvalidFormat = 205,
		InsertMissingItems = 206,
		IncompleteRelation = 207,
		ForwardError = 208,
		BookedFinancialReportRecalculationForbidden = 209,
		BookedFinancialReportReopeningForbidden = 210,
		InvalidConfigurationEntry = 211,
		ContractorNotFound = 212,
		MissingCurrentBranchId = 213,
		MissingDefaultOrBillingAddress = 214,
		ForbiddenUnits = 215,
		NotEnoughQuantityContainerSlot = 216,
		SettlementPaymentsCurrencyMismatch = 217,
		DocumentCurrencyChangeForbidden = 218,
		IncompatibleDocumentAndFinancialRegisterCurrencies = 219,
		IncompatibleDocumentAndCorrectionCurrencies = 220,
		UnableToEstablishConnectionWithBranch = 221,
		UnableToEdtiConfigurationAtBranch = 222,
        NoSourceContainerForAutomaticShift = 223
	}
}

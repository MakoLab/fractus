/*
name=[warehouse].[p_handheld_GetDeliveryHistory]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
/P8YJduwX36PfIQufX+q7A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_handheld_GetDeliveryHistory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_handheld_GetDeliveryHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_handheld_GetDeliveryHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_handheld_GetDeliveryHistory]
@deliveryId UNIQUEIDENTIFIER
AS
BEGIN
	SELECT
		DT.symbol documentSymbol,
		H.fullNumber documentNumber,
		H.issueDate documentDate,
		L.incomeDate incomeDate,
		'''' incomeUser, --U.fullName incomeUser,
		CAST(L.quantity as float) incomeQuantity,
		'''' attributes,
		L.price purchasePrice,
		I.code itemCode,
		I.[name] itemName,
		''PLN'' currency
	FROM
		document.WarehouseDocumentLine L
		JOIN document.WarehouseDocumentHeader H ON H.id = L.warehouseDocumentHeaderId
		JOIN dictionary.DocumentType DT ON DT.id = H.documentTypeId
		--JOIN contractor.Contractor U ON U.id = ST.applicationUserId
		JOIN item.Item I ON I.id = L.itemId
	WHERE
		L.id = @deliveryId

	SELECT
		ST2.issueDate date,
		CAST(S2.quantity as float) quantity,
		C1.[name] [from],
		C2.[name] [to],
		ISNULL((SELECT TOP 1 CAST(CAST(decimalValue AS float) as varchar(10))
			FROM warehouse.ShiftAttrValue V
			JOIN dictionary.ShiftField F ON F.id = V.shiftFieldId
			WHERE shiftId = S2.id AND F.name = ''Attribute_Voltage''
		) + ''V '', '''') +
		ISNULL((SELECT TOP 1 CAST(CAST(decimalValue AS float) as varchar(10))
			FROM warehouse.ShiftAttrValue V
			JOIN dictionary.ShiftField F ON F.id = V.shiftFieldId
			WHERE shiftId = S2.id AND F.name = ''Attribute_Current''
		) + ''A '', '''') +
		ISNULL((SELECT TOP 1 CONVERT(char(10), dateValue, 21)
			FROM warehouse.ShiftAttrValue V
			JOIN dictionary.ShiftField F ON F.id = V.shiftFieldId
			WHERE shiftId = S2.id AND F.name = ''Attribute_MeasureTime''
		), '''') +
		ISNULL('' ('' + (SELECT TOP 1 textValue
			FROM warehouse.ShiftAttrValue V
			JOIN dictionary.ShiftField F ON F.id = V.shiftFieldId
			WHERE shiftId = S2.id AND F.name = ''Attribute_Other''
		) + '')'', '''')
		AS attributes,
		U.fullName [user]
	FROM
		warehouse.Shift S2
		JOIN warehouse.ShiftTransaction ST2 ON ST2.id = S2.shiftTransactionId
		JOIN warehouse.Container C2 ON C2.id = S2.containerId
		LEFT JOIN warehouse.Shift S1 ON S1.id = S2.sourceShiftId AND S1.status >= 40
		LEFT JOIN warehouse.Container C1 ON C1.id = S1.containerId
		JOIN contractor.Contractor U ON U.id = ST2.applicationUserId
	WHERE
		S2.incomeWarehouseDocumentLineId = @deliveryId AND S2.status >= 40
	ORDER BY ST2.number ASC, S2.ordinalNumber ASC

	-- warehouse.p_handheld_GetDeliveryHistory ''A855F0D9-B568-4B35-8735-57CA162355AD''

END
' 
END
GO

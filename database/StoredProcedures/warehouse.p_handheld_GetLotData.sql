/*
name=[warehouse].[p_handheld_GetLotData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
8kZKxejom0bU4Et8W/OqWw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_handheld_GetLotData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_handheld_GetLotData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_handheld_GetLotData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_handheld_GetLotData]
@lotId UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @lots TABLE (id uniqueidentifier)

	INSERT INTO @lots (id) VALUES (@lotId)

	WHILE @@rowcount <> 0  --EXISTS (SELECT id FROM warehouse.Shift WHERE id NOT IN (SELECT id FROM @lots) AND sourceShiftId IN (SELECT id FROM @lots))
		INSERT INTO @lots (id)
		SELECT id FROM warehouse.Shift WHERE status > 40 AND id NOT IN (SELECT id FROM @lots) AND sourceShiftId IN (SELECT id FROM @lots)

	SELECT
		I.code as itemCode,
		I.name as itemName,
		L.incomeDate as incomeDate,
		H.issueDate as documentDate,
		(DT.symbol + '' '' +	H.fullNumber) as documentNumber,
		CAST(S.quantity as float) as initialQuantity,
		U.fullName as [user],
		L.price as purchasePrice,
		CUR.symbol as currency,
				ISNULL((SELECT TOP 1 CAST(CAST(decimalValue AS float) as varchar(10))
			FROM warehouse.ShiftAttrValue V
			JOIN dictionary.ShiftField F ON F.id = V.shiftFieldId
			WHERE shiftId = S.id AND F.name = ''Attribute_Voltage''
		) + ''V '', '''') +
		ISNULL((SELECT TOP 1 CAST(CAST(decimalValue AS float) as varchar(10))
			FROM warehouse.ShiftAttrValue V
			JOIN dictionary.ShiftField F ON F.id = V.shiftFieldId
			WHERE shiftId = S.id AND F.name = ''Attribute_Current''
		) + ''A '', '''') +
		ISNULL((SELECT TOP 1 CONVERT(char(10), dateValue, 21)
			FROM warehouse.ShiftAttrValue V
			JOIN dictionary.ShiftField F ON F.id = V.shiftFieldId
			WHERE shiftId = S.id AND F.name = ''Attribute_MeasureTime''
		), '''') +
		ISNULL('' ('' + (SELECT TOP 1 textValue
			FROM warehouse.ShiftAttrValue V
			JOIN dictionary.ShiftField F ON F.id = V.shiftFieldId
			WHERE shiftId = S.id AND F.name = ''Attribute_Other''
		) + '')'', '''')
		AS attributes,
		L.id as deliveryId
	FROM
		warehouse.Shift S
		JOIN warehouse.ShiftTransaction ST ON ST.id = S.shiftTransactionId
		JOIN document.WarehouseDocumentLine L ON L.id = S.incomeWarehouseDocumentLineId
		JOIN document.WarehouseDocumentHeader H ON H.id = L.warehouseDocumentHeaderId
		JOIN dictionary.DocumentType DT ON DT.id = H.documentTypeId
		JOIN item.Item I ON I.id = L.itemId
		LEFT JOIN contractor.Contractor U ON U.id = ST.applicationUserId
		JOIN dictionary.Currency CUR ON CUR.id = H.documentCurrencyId
	WHERE
		S.id = @lotId

	SELECT
		S.id as shiftId,
		CAST(S.quantity - ISNULL(R.remaining, 0) as float) as quantity,
		C.name,
				ISNULL((SELECT TOP 1 CAST(CAST(decimalValue AS float) as varchar(10))
			FROM warehouse.ShiftAttrValue V
			JOIN dictionary.ShiftField F ON F.id = V.shiftFieldId
			WHERE shiftId = S.id AND F.name = ''Attribute_Voltage''
		) + ''V '', '''') +
		ISNULL((SELECT TOP 1 CAST(CAST(decimalValue AS float) as varchar(10))
			FROM warehouse.ShiftAttrValue V
			JOIN dictionary.ShiftField F ON F.id = V.shiftFieldId
			WHERE shiftId = S.id AND F.name = ''Attribute_Current''
		) + ''A '', '''') +
		ISNULL((SELECT TOP 1 CONVERT(char(10), dateValue, 21)
			FROM warehouse.ShiftAttrValue V
			JOIN dictionary.ShiftField F ON F.id = V.shiftFieldId
			WHERE shiftId = S.id AND F.name = ''Attribute_MeasureTime''
		), '''') +
		ISNULL('' ('' + (SELECT TOP 1 textValue
			FROM warehouse.ShiftAttrValue V
			JOIN dictionary.ShiftField F ON F.id = V.shiftFieldId
			WHERE shiftId = S.id AND F.name = ''Attribute_Other''
		) + '')'', '''')
		AS attributes,
		U.fullName as [user]
	FROM
		warehouse.Shift S
		JOIN warehouse.ShiftTransaction ST ON ST.id = S.shiftTransactionId
		LEFT JOIN (SELECT SUM(sx.quantity) as remaining, sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.status > 40 GROUP BY sx.sourceShiftId) R ON R.sourceShiftId = S.id
		JOIN warehouse.Container C ON C.id = S.containerId
		JOIN contractor.Contractor U ON U.id = ST.applicationUserId
	WHERE S.status > 0 AND S.id IN (SELECT id FROM @lots) AND (S.quantity - ISNULL(R.remaining, 0)) > 0

	-- warehouse.p_handheld_GetLotData ''7A3CB5C5-8F44-470B-9C15-154DD5CD4C8F''
END
' 
END
GO

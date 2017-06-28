/*
name=[warehouse].[p_handheld_GetDataForContainer]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
60mnRVKktPxigEDi/aE38w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_handheld_GetDataForContainer]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_handheld_GetDataForContainer]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_handheld_GetDataForContainer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_handheld_GetDataForContainer]
@containerId UNIQUEIDENTIFIER
AS
BEGIN
	SELECT
		C.xmlLabels.query(''/ * /label[1]'').value(''.'',''varchar(20)'') as containerLabel,
		I.code itemCode,
		I.name itemName,
		CAST(s.quantity - ISNULL(x.q,0) as float) quantity,
		l.incomeDate incomeDate,
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
		DT.symbol + '' '' + h.fullNumber documentNumber,
		CAST(l.quantity as float) deliveryQuantity,
		IU.fullName issuingUser,
		SU.fullName shiftingUser,
		L.price purchasePrice,
		CUR.symbol currency,
		L.id deliveryId,
		s.id shiftId
	FROM  warehouse.Shift s
		LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.status >= 40 GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
		LEFT JOIN document.WarehouseDocumentLine l ON s.incomeWarehouseDocumentLineId = l.id
		LEFT JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id
		LEFT JOIN dictionary.DocumentType DT ON DT.id = H.documentTypeId
		JOIN item.Item i ON l.itemId = i.id
		JOIN warehouse.ShiftTransaction st ON s.shiftTransactionId = st.id
		JOIN warehouse.Container C ON C.id = S.containerId
		LEFT JOIN contractor.Contractor IU ON IU.id = h.modificationApplicationUserId
		LEFT JOIN contractor.Contractor SU ON SU.id = ST.applicationUserId
		LEFT JOIN dictionary.Currency CUR ON CUR.id = H.documentCurrencyId
	WHERE (s.quantity - ISNULL(x.q,0)) > 0 AND s.containerId = @containerId AND s.status >= 40
	ORDER BY st.number
	--IF @@rowcount = 0
	--	SELECT 	*
	--	FROM warehouse.Container 
	--	WHERE id = @containerId
	
	
	-- warehouse.p_handheld_GetDataForContainer ''A770635E-CbCA-4DE9-83F0-DF519AD25217''
END
' 
END
GO

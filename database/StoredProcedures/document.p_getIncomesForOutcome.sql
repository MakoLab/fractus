/*
name=[document].[p_getIncomesForOutcome]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
T0TUsdvcJ5E3pctEoBFxJg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getIncomesForOutcome]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getIncomesForOutcome]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getIncomesForOutcome]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getIncomesForOutcome]
@xmlVar XML
AS
BEGIN
DECLARE @lineId UNIQUEIDENTIFIER

	SELECT @lineId = @xmlVar.query(''params/outcomeId'').value(''.'',''char(36)'')
	SELECT (
		SELECT distinct direction AS ''@direction'', ir.quantity AS ''@quantity'' , l.id AS ''@id'' , fullNumber AS ''@fullNumber'', ordinalNumber AS ''@ordinalNumber'', 
		cv.incomePrice AS ''@price'', cv.incomeValue AS ''@value'', issuedate AS ''@date'', h.id AS ''@documentId'', ISNULL(cv.quantity, ir.quantity) AS ''@relationQuantity''
		FROM document.IncomeOutcomeRelation ir 
			LEFT JOIN document.WarehouseDocumentValuation cv ON ir.outcomeWarehouseDocumentLineId = cv.outcomeWarehouseDocumentLineId 
				AND ir.incomeWarehouseDocumentLineId = cv.incomeWarehouseDocumentLineId
			JOIN document.WarehouseDocumentLine l ON ir.incomeWarehouseDocumentLineId = l.id
			JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id
		WHERE ir.outcomeWarehouseDocumentLineId = @lineId
		FOR XML PATH(''line'') , TYPE 
	) FOR XML PATH(''relatedIncomes''), TYPE

END
' 
END
GO

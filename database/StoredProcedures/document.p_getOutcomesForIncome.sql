/*
name=[document].[p_getOutcomesForIncome]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
YWD3hXYYW2mGn0mTe7dIiw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getOutcomesForIncome]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getOutcomesForIncome]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getOutcomesForIncome]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getOutcomesForIncome]
@xmlVar XML
AS
BEGIN
DECLARE @lineId UNIQUEIDENTIFIER

	SELECT @lineId = @xmlVar.query(''params/incomeId'').value(''.'',''char(36)'')

	SELECT (
		SELECT	direction AS ''@direction'', l.quantity AS ''@quantity'' , l.id AS ''@id'' , fullNumber AS ''@fullNumber'', 
				ordinalNumber AS ''@ordinalNumber'', price AS ''@price'', l.value AS ''@value'', issuedate AS ''@date'', 
				h.id AS ''@documentId'', ir.quantity AS ''@relationQuantity''
		FROM document.IncomeOutcomeRelation ir 
			JOIN document.WarehouseDocumentLine l ON ir.outcomeWarehouseDocumentLineId = l.id
			JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id
		WHERE ir.incomeWarehouseDocumentLineId = @lineId
		FOR XML PATH(''line''), TYPE 
	) FOR XML PATH(''relatedOutcomes''), TYPE

END
' 
END
GO

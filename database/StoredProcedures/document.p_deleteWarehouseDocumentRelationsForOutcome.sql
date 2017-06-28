/*
name=[document].[p_deleteWarehouseDocumentRelationsForOutcome]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
W6Gm7LatJfFHC10EyX1zJg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteWarehouseDocumentRelationsForOutcome]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_deleteWarehouseDocumentRelationsForOutcome]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteWarehouseDocumentRelationsForOutcome]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_deleteWarehouseDocumentRelationsForOutcome] 
@warehouseDocumentHeaderId UNIQUEIDENTIFIER
AS
BEGIN

UPDATE document.WarehouseDocumentLine
SET outcomeDate = NULL
WHERE id IN (
	SELECT incomeWarehouseDocumentLineId FROM document.IncomeOutcomeRelation
	WHERE IncomeOutcomeRelation.outcomeWarehouseDocumentLineId IN ( 
			SELECT id FROM document.WarehouseDocumentLine WHERE WarehouseDocumentHeaderId = @warehouseDocumentHeaderId
						)
			)


DELETE FROM document.CommercialWarehouseValuation
WHERE CommercialWarehouseValuation.warehouseDocumentLineId IN ( 
		SELECT id FROM document.WarehouseDocumentLine WHERE WarehouseDocumentHeaderId = @warehouseDocumentHeaderId
		)

DELETE FROM document.CommercialWarehouseRelation
WHERE CommercialWarehouseRelation.warehouseDocumentLineId IN ( 
		SELECT id FROM document.WarehouseDocumentLine WHERE WarehouseDocumentHeaderId = @warehouseDocumentHeaderId
			)

DELETE FROM document.IncomeOutcomeRelation
WHERE IncomeOutcomeRelation.outcomeWarehouseDocumentLineId IN ( 
		SELECT id FROM document.WarehouseDocumentLine WHERE WarehouseDocumentHeaderId = @warehouseDocumentHeaderId
		)

DELETE FROM document.WarehouseDocumentValuation
WHERE WarehouseDocumentValuation.outcomeWarehouseDocumentLineId IN ( 
		SELECT id FROM document.WarehouseDocumentLine WHERE WarehouseDocumentHeaderId = @warehouseDocumentHeaderId
			)
END
' 
END
GO

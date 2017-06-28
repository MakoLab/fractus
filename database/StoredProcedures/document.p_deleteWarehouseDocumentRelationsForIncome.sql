/*
name=[document].[p_deleteWarehouseDocumentRelationsForIncome]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
85gZmXP7D7g/Lxg3xos4rg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteWarehouseDocumentRelationsForIncome]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_deleteWarehouseDocumentRelationsForIncome]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteWarehouseDocumentRelationsForIncome]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_deleteWarehouseDocumentRelationsForIncome] 
@warehouseDocumentHeaderId UNIQUEIDENTIFIER
AS
BEGIN

DELETE FROM document.CommercialWarehouseValuation
WHERE CommercialWarehouseValuation.warehouseDocumentLineId IN ( 
		SELECT id FROM document.WarehouseDocumentLine WHERE WarehouseDocumentHeaderId = @warehouseDocumentHeaderId
		)

DELETE FROM document.CommercialWarehouseRelation
WHERE CommercialWarehouseRelation.warehouseDocumentLineId IN ( 
		SELECT id FROM document.WarehouseDocumentLine WHERE WarehouseDocumentHeaderId = @warehouseDocumentHeaderId
			)


DELETE FROM document.IncomeOutcomeRelation
WHERE IncomeOutcomeRelation.incomeWarehouseDocumentLineId IN ( 
		SELECT id FROM document.WarehouseDocumentLine WHERE WarehouseDocumentHeaderId = @warehouseDocumentHeaderId
		)

DELETE FROM document.WarehouseDocumentValuation
WHERE WarehouseDocumentValuation.incomeWarehouseDocumentLineId IN ( 
		SELECT id FROM document.WarehouseDocumentLine WHERE WarehouseDocumentHeaderId = @warehouseDocumentHeaderId
			)

END
' 
END
GO

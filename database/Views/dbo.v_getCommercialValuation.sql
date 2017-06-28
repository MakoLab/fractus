/*
name=[dbo].[v_getCommercialValuation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
d2koohYD6TgO0010m3WpNQ==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_getCommercialValuation]'))
DROP VIEW [dbo].[v_getCommercialValuation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_getCommercialValuation]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[v_getCommercialValuation]
AS
	SELECT * 
	FROM (
	SELECT cv.id, cv.warehouseDocumentLineId, (sum(cv.quantity) - sum(ISNULL(wv.quantity ,0)) ) quantity , ir.incomeDate, ir.outcomeWarehouseDocumentLineId, cv.price
	FROM document.IncomeOutcomeRelation ir 
		JOIN  document.CommercialWarehouseValuation cv  ON cv.warehouseDocumentLineId = ir.incomeWarehouseDocumentLineId
		LEFT JOIN document.WarehouseDocumentValuation wv ON wv.valuationId = cv.id
	
	GROUP BY cv.id, cv.warehouseDocumentLineId, ir.incomeDate, ir.outcomeWarehouseDocumentLineId,  cv.price
		) x 
	WHERE x.quantity > 0
' 
GO

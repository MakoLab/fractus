/*
name=[document].[v_getAvailableDeliveries]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Db2Xdb5OlDyjeIS5VV6wxQ==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[document].[v_getAvailableDeliveries]'))
DROP VIEW [document].[v_getAvailableDeliveries]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[document].[v_getAvailableDeliveries]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [document].[v_getAvailableDeliveries]
AS
SELECT     id, quantity, price, value, itemId, warehouseId, incomeDate, warehouseDocumentHeaderId, ordinalNumber
FROM         (SELECT     id, warehouseDocumentHeaderId, ISNULL(quantity * direction, 0) - ISNULL
                                                  ((SELECT     SUM(quantity) AS Expr1
                                                      FROM         [document].IncomeOutcomeRelation AS r
                                                      WHERE     (incomeWarehouseDocumentLineId = l.id)), 0) AS quantity, price, value, itemId, warehouseId, incomeDate, ordinalNumber
                       FROM          [document].WarehouseDocumentLine AS l
                       WHERE      (outcomeDate IS NULL)) AS x
WHERE     (quantity > 0)
' 
GO

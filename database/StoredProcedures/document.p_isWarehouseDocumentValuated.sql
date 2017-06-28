/*
name=[document].[p_isWarehouseDocumentValuated]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
bF9ozrxrkg+48wTUxyHliA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_isWarehouseDocumentValuated]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_isWarehouseDocumentValuated]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_isWarehouseDocumentValuated]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_isWarehouseDocumentValuated] 
@warehouseDocumentHeaderId UNIQUEIDENTIFIER
AS
BEGIN

IF EXISTS ( SELECT * FROM document.WarehouseDocumentLine WHERE warehouseDocumentHeaderId = @warehouseDocumentHeaderId AND correctedWarehouseDocumentLineId IS NOT NULL )
	BEGIN
	SELECT CASE WHEN SUM(qty) = 0 THEN CAST(''<root>true</root>'' AS XML) ELSE CAST(''<root>false</root>'' AS XML) END
	FROM (
		SELECT ISNULL(SUM(ABS(wl.quantity)) - SUM( ISNULL( ISNULL(y.qty,z.qty),0)),0) qty
		FROM document.WarehouseDocumentLine wl
				LEFT JOIN (	
						SELECT SUM(ABS(wv.quantity)) qty, wv.warehouseDocumentLineId  
						FROM document.CommercialWarehouseValuation wv 
						GROUP BY wv.warehouseDocumentLineId 
						) y ON y.warehouseDocumentLineId = wl.id 
				LEFT JOIN (	
						SELECT SUM(ABS(wv.quantity)) qty, wv.outcomeWarehouseDocumentLineId  
						FROM document.WarehouseDocumentValuation wv 
						GROUP BY wv.outcomeWarehouseDocumentLineId 
						) z ON z.outcomeWarehouseDocumentLineId = wl.id	
		WHERE wl.warehouseDocumentHeaderId = @warehouseDocumentHeaderId
		) x
	END
ELSE	
	BEGIN
	SELECT CASE WHEN SUM(qty) = 0 THEN CAST(''<root>true</root>'' AS XML) ELSE CAST(''<root>false</root>'' AS XML) END
	FROM (
		SELECT  ISNULL((SUM(ABS(wl.quantity)) -  SUM(ISNULL(xx.qty ,0))),0 )  qty
		FROM document.WarehouseDocumentLine wl
			LEFT JOIN (	
						SELECT SUM(ABS(wv.quantity)) qty, wv.outcomeWarehouseDocumentLineId  
						FROM document.WarehouseDocumentValuation wv 
						GROUP BY wv.outcomeWarehouseDocumentLineId 
						) xx ON xx.outcomeWarehouseDocumentLineId = wl.id
		WHERE wl.warehouseDocumentHeaderId = @warehouseDocumentHeaderId
		) x
		
	END	
END
' 
END
GO

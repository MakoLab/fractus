/*
name=[tools].[p_mergeItemUnit]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fMPjn+xTGCCTVY6e/KrCUw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_mergeItemUnit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_mergeItemUnit]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_mergeItemUnit]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE tools.p_mergeItemUnit @itemId uniqueidentifier
AS
BEGIN

DECLARE @dbId UNIQUEIDENTIFIER, @unitId UNIQUEIDENTIFIER, @warehouseId UNIQUEIDENTIFIER,  @xml XML
DECLARE @tmp TABLE (id uniqueidentifier)
SELECT @dbId = textValue FROM configuration.Configuration WHERE [key] like ''communication.DatabaseId''

BEGIN TRAN

SELECT @unitId = unitId FROM item.Item WHERE id = @itemId

SELECT TOP 1  @warehouseId = warehouseId
FROM  document.WarehouseStock WHERE itemId = @itemId AND unitId <> @unitId

UPDATE x 
set x.unitId = i.unitId
FROM document.CommercialDocumentLine x 
	JOIN item.Item i ON x.itemId = i.id
WHERE x.unitId <> i.unitId

UPDATE x 
set x.unitId = i.unitId
FROM document.WarehouseDocumentLine x 
	JOIN item.Item i ON x.itemId = i.id
WHERE x.unitId <> i.unitId

DELETE FROM document.WarehouseStock WHERE itemId = @itemId AND unitId <> @unitId

	IF @@rowcount > 0 
	BEGIN

		UPDATE document.WarehouseStock 
		SET quantity = ISNULL(wl.quantity,0)
		FROM document.WarehouseStock ws
			LEFT JOIN (
				SELECT SUM (l.direction * l.quantity) quantity, l.itemId, l.warehouseId
				FROM document.WarehouseDocumentHeader h 
				JOIN document.WarehouseDocumentLine l on h.id = l.warehouseDocumentHeaderId
				WHERE h.[status] >= 40
				GROUP BY l.itemId, l.warehouseId
				)wl ON ws.itemId = wl.itemId AND ws.warehouseId = wl.warehouseId
		WHERE ws.warehouseId in (SELECT id FROM dictionary.Warehouse where branchId in (SELECT id FROM dictionary.Branch WHERE databaseId = @dbId)) 
			AND ISNULL(ws.quantity,0) <> ISNULL(wl.quantity ,0)
			AND ws.itemId = @itemId
		SELECT @xml =  ''<root localTransactionId="'' + CAST(newid() as varchar(50))+ ''" deferredTransactionId="'' + CAST(newid() as varchar(50))+ ''" databaseId="'' + CAST(@dbId as varchar(50))+ ''"> 
		<entry><itemId>'' + CAST(@itemId as varchar(50))+ ''</itemId><warehouseId>'' + CAST(@warehouseId as varchar(50))+ ''</warehouseId></entry></root>''
		EXEC [communication].[p_createWarehouseStockPackage] @xml

	END

COMMIT TRAN
END
' 
END
GO

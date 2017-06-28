/*
name=[item].[p_blockItem]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
mCxuY6g+fLqcbH9PqKVbpA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_blockItem]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_blockItem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_blockItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_blockItem] 
@xmlVar XML
AS

DECLARE @idoc int,
	@rowcount int,
	@inventoryDocumentHeaderId UNIQUEIDENTIFIER
	

DECLARE @tmp TABLE ( itemId UNIQUEIDENTIFIER, warehouseId UNIQUEIDENTIFIER )

	SELECT @inventoryDocumentHeaderId = NULLIF(@xmlVar.value(''(root/@inventoryDocumentHeaderId)[1]'',''char(36)''),'''')

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

	INSERT INTO @tmp ( itemId, warehouseId )
	SELECT itemId, warehouseId
	FROM OPENXML(@idoc, ''/root/entry'')
		WITH (
				itemId char(36) ''@itemId'',
				warehouseId char(36) ''@warehouseId''
			)

	EXEC sp_xml_removedocument @idoc

IF EXISTS(	SELECT ws.id 
			FROM @tmp t
				JOIN document.WarehouseStock ws ON ws.itemId = t.itemId AND ws.warehouseId = t.warehouseId
			WHERE ws.isBlocked = 1)
   OR EXISTS (	SELECT * 
				FROM document.InventorySheetLine l
					JOIN document.InventorySheet s ON l.inventorySheetId = s.id AND s.status >= 20
					LEFT JOIN @tmp t ON  l.itemId = t.itemId AND s.warehouseId = t.warehouseId
				WHERE l.inventorySheetId <> @inventoryDocumentHeaderId ) 
	BEGIN
	SELECT (
		SELECT  ws.itemId as ''@itemId'', ws.warehouseId as ''@warehouseId'' , 1 as ''@alreadyBlocked''
		FROM @tmp t
			JOIN document.WarehouseStock ws ON ws.itemId = t.itemId AND ws.warehouseId = t.warehouseId
		WHERE ws.isBlocked = 1
		FOR XML PATH(''entry''),TYPE
	) FOR XML PATH(''root''),TYPE
	END
ELSE			
	BEGIN
	UPDATE document.WarehouseStock
		SET isBlocked = 1
	FROM document.WarehouseStock ws
		JOIN @tmp t ON ws.itemId = t.itemId AND ws.warehouseId = t.warehouseId
		
	SELECT (
		SELECT  ws.itemId as ''@itemId'', ws.warehouseId as ''@warehouseId'' , ws.quantity as ''@quantity''
		FROM @tmp t
			JOIN document.WarehouseStock ws ON ws.itemId = t.itemId AND ws.warehouseId = t.warehouseId
		WHERE ws.isBlocked = 1
		FOR XML PATH(''entry''),TYPE
	) FOR XML PATH(''root''),TYPE
		
	END
' 
END
GO

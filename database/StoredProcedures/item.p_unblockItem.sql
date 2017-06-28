/*
name=[item].[p_unblockItem]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
/PjxFV7rmWsy/5cusc0Ujg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_unblockItem]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_unblockItem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_unblockItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_unblockItem] 
@xmlVar XML
AS
BEGIN

	DECLARE @idoc int,
		@rowcount int

	DECLARE @tmp TABLE ( itemId UNIQUEIDENTIFIER, warehouseId UNIQUEIDENTIFIER )


	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

	INSERT INTO @tmp ( itemId, warehouseId )
	SELECT itemId, warehouseId
	FROM OPENXML(@idoc, ''/root/entry'')
		WITH (
				itemId char(36) ''@itemId'',
				warehouseId char(36) ''@warehouseId''
			)

	EXEC sp_xml_removedocument @idoc

	UPDATE document.WarehouseStock
		SET isBlocked = NULL
	FROM document.WarehouseStock ws
		JOIN @tmp t ON ws.itemId = t.itemId AND ws.warehouseId = t.warehouseId
		
END
' 
END
GO

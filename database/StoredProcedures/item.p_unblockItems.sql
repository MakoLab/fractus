/*
name=[item].[p_unblockItems]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
NkaIxdqDk+YFLyQr0n97Dg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_unblockItems]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_unblockItems]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_unblockItems]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_unblockItems]
AS
BEGIN

/*Procedura odblokowuje wpisy towary jeśli nie znajdują się na inwentaryzacjach*/
UPDATE ws
SET isBlocked = null
FROM document.WarehouseStock ws
	LEFT JOIN (  SELECT isl.itemId, ish.warehouseId
			FROM document.InventorySheet ish
				JOIN document.InventorySheetLine isl ON ish.id = isl.inventorySheetId
			WHERE isl.direction <> 0 AND ( ish.status > 0 AND ish.status < 40)
		) x ON ws.itemId = x.itemId AND ws.warehouseId = x.warehouseId
WHERE ws.isBlocked = 1 AND x.itemId IS NULL

END
' 
END
GO

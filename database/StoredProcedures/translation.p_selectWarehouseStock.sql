/*
name=[translation].[p_selectWarehouseStock]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
8VV90mqps4gjlBQq2+fg5Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_selectWarehouseStock]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_selectWarehouseStock]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_selectWarehouseStock]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_selectWarehouseStock]
@warehouseId UNIQUEIDENTIFIER,
@itemId UNIQUEIDENTIFIER
AS
BEGIN
	SELECT id, unitId, quantity, reservedQuantity, orderedQuantity  FROM document.warehouseStock 
		WHERE 
			warehouseId = @warehouseId 
			AND
			itemId = @itemId
END
' 
END
GO

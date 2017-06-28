/*
name=[document].[p_getWarehouseStock]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
xyBT9/FN2LM154DjU/n50w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getWarehouseStock]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getWarehouseStock]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getWarehouseStock]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE procedure [document].[p_getWarehouseStock] @xmlVar xml = null
as
begin
	DECLARE @warehouseId uniqueidentifier
	DECLARE @tmp TABLE (id uniqueidentifier)

	SELECT @warehouseId = @xmlVar.value(''(root/warehouseId)[1]'',''char(36)'')
	
	INSERT INTO @tmp 
	SELECT x.value(''(itemId)[1]'',''char(36)'')
	FROM @xmlVar.nodes(''root/collection/line'') as a(x)

	SELECT (
		SELECT t.id itemId, @warehouseId warehouseId, ISNULL(ws.lastPurchaseNetPrice ,0) lastPurchaseNetPrice
		FROM @tmp t  
			LEFT JOIN document.WarehouseStock ws WITH(NOLOCK)  ON ws.itemId = t.id AND ws.warehouseId = @warehouseId
		FOR XML PATH(''line''),TYPE
	)FOR XML PATH(''root''),TYPE

end
' 
END
GO

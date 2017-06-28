/*
name=[document].[p_getItemStock]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ND3YeGSwyZ22se9wxE8t7Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getItemStock]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getItemStock]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getItemStock]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_getItemStock]
@xmlVar XML
AS
BEGIN
	DECLARE @itemId UNIQUEIDENTIFIER

	SELECT @itemId = @xmlVar.query(''params/itemId'').value(''.'',''char(36)'')

	SELECT (
	SELECT warehouseId AS ''@warehouseId'' , quantity AS ''@quantity'', reservedQuantity AS ''@reservedQuantity'', orderedQuantity AS ''@orderedQuantity'', lastPurchaseNetPrice AS ''@lastPurchaseNetPrice'',
	 ROUND(100 * (  i.defaultPrice -  ISNULL(ws.lastPurchaseNetPrice,0) ) / NULLIF(i.defaultPrice,0) ,2) AS ''@profitMargin''
	FROM document.WarehouseStock ws WITH(NOLOCK)
	JOIN dictionary.Warehouse dw  WITH(NOLOCK) on dw.id = ws.WarehouseId
	JOIN item.Item i  WITH(NOLOCK) ON ws.itemId = i.id
	WHERE itemId = @itemId
	ORDER BY [order]
	FOR XML PATH(''warehouse''), TYPE
	) FOR XML PATH(''itemStock''), TYPE
END
' 
END
GO

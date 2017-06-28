/*
name=[document].[p_getInventoryDocumentSheetLines]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
lu1NBrxWtyj3P1ptF2D/Lg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getInventoryDocumentSheetLines]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getInventoryDocumentSheetLines]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getInventoryDocumentSheetLines]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_getInventoryDocumentSheetLines] --''<inventoryDocumentHeaderId>5D03273C-AF15-42FE-95D4-44A9036610A5</inventoryDocumentHeaderId>''
@xmlVar XML
AS
BEGIN
DECLARE @inventoryDocumentHeaderId UNIQUEIDENTIFIER

SELECT @inventoryDocumentHeaderId = @xmlVar.query(''//inventoryDocumentHeaderId'').value(''.'',''char(36)'')

SELECT (
	SELECT ( 
							SELECT    s.*, i.name itemName, ise.ordinalNumber inventorySheetOrdinalNumber ,ise.id inventorySheetId ,ih.fullNumber, ise.warehouseId, w.symbol
							,CASE WHEN ih.status < 40 AND  s.userQuantity > s.systemQuantity  THEN (s.userQuantity - s.systemQuantity) *
							( SELECT ISNULL(ww.lastPurchaseNetPrice,0) FROM document.WarehouseStock ww WHERE ww.itemId = s.itemId AND ise.warehouseId = ww.warehouseId ) -- (SELECT top 1 cl.netPrice FROM document.CommercialDocumentLine cl WHERE cl.itemId = s.itemId AND cl.quantity > 0)  
							 ELSE ISNULL( r.value, 0) END value

							FROM      document.InventorySheetLine  s 
								JOIN document.InventorySheet ise ON ise.id = s.inventorySheetId
								JOIN document.InventoryDocumentHeader ih ON ise.inventoryDocumentHeaderId = ih.id
								JOIN item.Item i ON s.itemId = i.id
								JOIN dictionary.Warehouse w ON ise.warehouseId = w.id
								LEFT JOIN (	SELECT  itemId , warehouseId , SUM(value) value, ISNULL(dr.firstInventoryDocumentHeaderId, dr.secondInventoryDocumentHeaderId)  inventoryDocumentHeaderId
											FROM document.WarehouseDocumentLine l
												JOIN document.DocumentRelation dr ON l.warehouseDocumentHeaderId IN (dr.firstWarehouseDocumentHeaderId, dr.secondWarehouseDocumentHeaderId)
											WHERE dr.firstInventoryDocumentHeaderId IS NOT NULL OR dr.secondInventoryDocumentHeaderId IS NOT NULL
											GROUP BY   itemId , warehouseId ,  dr.firstInventoryDocumentHeaderId, dr.secondInventoryDocumentHeaderId
											) r on s.itemId = r.itemId  AND ih.id = r.inventoryDocumentHeaderId  AND ise.warehouseId = r.warehouseId
							WHERE     ih.id = @inventoryDocumentHeaderId
							ORDER BY  ise.ordinalNumber ,  s.ordinalNumber
							FOR XML PATH(''line''), TYPE
						   )
	FOR XML PATH(''root''),TYPE 
) AS returnsXML

END
' 
END
GO

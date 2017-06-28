/*
name=[document].[p_getInventorySheetData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
trE7dhCzXil/F6DRHsmWvA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getInventorySheetData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getInventorySheetData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getInventorySheetData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_getInventorySheetData] 
@inventorySheetId uniqueidentifier
AS
BEGIN
SELECT (
	SELECT    ( SELECT    ( 
							SELECT    s.*, h.fullNumber inventoryDocumentFullNumber
							

							FROM      document.InventorySheet  s 
								JOIN document.InventoryDocumentHeader h ON  s.inventoryDocumentHeaderId =  h.id
								
							WHERE     s.id = @inventorySheetId
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''inventorySheet''), TYPE
			   ),(SELECT   (
							SELECT    e.*, i.name itemName
								, ISNULL( r.value, 0)  value
							FROM      document.InventorySheetLine  e
								JOIN document.InventorySheet  s ON s.id = e.inventorySheetId 
								JOIN document.InventoryDocumentHeader h ON  s.inventoryDocumentHeaderId =  h.id
								JOIN item.Item i ON e.itemId = i.id
								LEFT JOIN (	SELECT  itemId , warehouseId , SUM(value) value, ISNULL(dr.firstInventoryDocumentHeaderId, dr.secondInventoryDocumentHeaderId)  inventoryDocumentHeaderId
											FROM document.WarehouseDocumentLine l
												JOIN document.DocumentRelation dr ON l.warehouseDocumentHeaderId IN (dr.firstWarehouseDocumentHeaderId, dr.secondWarehouseDocumentHeaderId)
											WHERE dr.firstInventoryDocumentHeaderId IS NOT NULL OR dr.secondInventoryDocumentHeaderId IS NOT NULL
											GROUP BY   itemId , warehouseId ,  dr.firstInventoryDocumentHeaderId, dr.secondInventoryDocumentHeaderId
											) r on e.itemId = r.itemId  AND  h.id = r.inventoryDocumentHeaderId  AND h.warehouseId = r.warehouseId
							WHERE     e.inventorySheetId = @inventorySheetId
							ORDER BY ordinalNumber
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''inventorySheetLine''), TYPE
			   )
	FOR XML PATH(''root''),TYPE 
) AS returnsXML

END
' 
END
GO

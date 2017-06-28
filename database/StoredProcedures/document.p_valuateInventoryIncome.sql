/*
name=[document].[p_valuateInventoryIncome]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ff1KclasSkedcHIwgcb1qQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_valuateInventoryIncome]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_valuateInventoryIncome]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_valuateInventoryIncome]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [document].[p_valuateInventoryIncome] @warehouseDocumentHeaderId uniqueidentifier
AS
/*Procedura wyceniająca Inventory Income*/
BEGIN
	DECLARE @inventoryIncomeTemplateName varchar(50),@inventoryIncomeDocumentType  uniqueidentifier

	/*Pobranie nazwy templejta dla przychodowej różnicy inwentaryzyacyjnej*/

		SELECT @inventoryIncomeTemplateName = xmlOptions.value(''(root/inventoryDocument/@incomeDifferentialDocumentTemplate)[1]'',''varchar(50)'') 
		FROM dictionary.DocumentType 
		WHERE documentCategory = 12

	/*Pobranie typu dokumentu (INW+)*/

		SELECT @inventoryIncomeDocumentType = xmlValue.value(''(root/warehouseDocument/documentTypeId)[1]'',''varchar(50)'') 
		FROM configuration.Configuration 
		WHERE [key] = ''templates.WarehouseDocument.'' + @inventoryIncomeTemplateName

		UPDATE l 
			SET l.price = ISNULL((SELECT top 1 x.lastPurchaseNetPrice FROM document.WarehouseStock x WHERE x.itemId = l.itemId  AND x.warehouseId = l.warehouseId) ,0)
				,l.value = l.quantity * ISNULL((SELECT top 1 x.lastPurchaseNetPrice FROM document.WarehouseStock x WHERE x.itemId = l.itemId  AND x.warehouseId = l.warehouseId) ,0)
	
		--SET l.price = ISNULL((SELECT top 1 x.price FROM document.WarehouseDocumentLine x WHERE x.itemId = l.itemId AND x.direction * x.quantity > 0 AND x.price > 0 AND x.warehouseId = l.warehouseId) ,0)
		--,l.value = l.quantity * ISNULL((SELECT top 1 x.price FROM document.WarehouseDocumentLine x WHERE x.itemId = l.itemId AND x.direction * x.quantity > 0 AND x.price > 0 AND x.warehouseId = l.warehouseId) ,0)
		FROM document.WarehouseDocumentLine l 
			JOIN document.WarehouseDocumentHeader h  ON h.id = l.warehouseDocumentHeaderId
		WHERE  h.documentTypeId = @inventoryIncomeDocumentType 
			AND h.id = @warehouseDocumentHeaderId
			AND l.value = 0.0

		UPDATE h
		SET h.value = ISNULL(x.value,0)
		FROM document.WarehouseDocumentHeader h
			JOIN (	SELECT sum(value) value, warehouseDocumentHeaderId 
					FROM document.WarehouseDocumentLine  
					GROUP BY warehouseDocumentHeaderId 
					) x ON h.id = x.warehouseDocumentHeaderId
		WHERE h.id = @warehouseDocumentHeaderId

END
' 
END
GO

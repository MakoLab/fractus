/*
name=[print].[p_getInventoryDocumentSheetLines]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
nT7QNF50EmmSHRUyHZJsIw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[print].[p_getInventoryDocumentSheetLines]') AND type in (N'P', N'PC'))
DROP PROCEDURE [print].[p_getInventoryDocumentSheetLines]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[print].[p_getInventoryDocumentSheetLines]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [print].[p_getInventoryDocumentSheetLines] @documentHeaderId UNIQUEIDENTIFIER
AS
BEGIN
DECLARE @inventoryDocumentHeaderId UNIQUEIDENTIFIER

SELECT @inventoryDocumentHeaderId = @documentHeaderId
SELECT (
	SELECT (
		SELECT war.symbol as ''@warehouse'', 
				( 	
				SELECT    s.*, i.name itemName, i.code itemCode, 
					CASE WHEN ih.status < 40 AND  s.userQuantity > s.systemQuantity  
					THEN (s.userQuantity - s.systemQuantity) * ( SELECT ISNULL(ww.lastPurchaseNetPrice,0) FROM document.WarehouseStock ww WHERE ww.itemId = s.itemId AND ise.warehouseId = ww.warehouseId )
						
						  ELSE ISNULL( w.value, 0) END value,
					CASE WHEN s.systemQuantity < s.userQuantity 
			
						THEN 
								ISNULL( 
									ISNULL((SELECT sum(l.value * l.direction) FROM document.WarehouseDocumentLine l JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id WHERE l.itemId = i.id AND l.warehouseId = ise.warehouseId AND h.issueDate <= ih.issueDate ),0) 
									+  (s.userQuantity - s.systemQuantity ) * ( SELECT ISNULL(ww.lastPurchaseNetPrice,0) FROM document.WarehouseStock ww WHERE ww.itemId = s.itemId AND ise.warehouseId = ww.warehouseId ),0)
						ELSE 
							CASE WHEN s.userQuantity = 0 THEN 0 ELSE 1 END 
								* ((ISNULL((SELECT sum(l.value * l.direction) FROM document.WarehouseDocumentLine l JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id WHERE l.itemId = i.id AND l.warehouseId = ise.warehouseId AND h.issueDate <= ih.issueDate ),0)) /NULLIF(s.systemQuantity ,0)) *  s.userQuantity END itemValue,

						u.xmlLabels.value(''(labels/label[@lang = "pl"]/@symbol)[1]'', ''varchar(50)'') unitSymbol,
						ise.ordinalNumber inventorySheetOrdinalNumberto 
						
				FROM document.InventorySheetLine  s 
					JOIN document.InventorySheet ise ON ise.id = s.inventorySheetId
					JOIN document.InventoryDocumentHeader ih ON ise.inventoryDocumentHeaderId = ih.id
					LEFT JOIN (	SELECT  itemId , warehouseId , SUM(value) value, ISNULL(dr.firstInventoryDocumentHeaderId, dr.secondInventoryDocumentHeaderId)  inventoryDocumentHeaderId
								FROM document.WarehouseDocumentLine l
									JOIN document.DocumentRelation dr ON l.warehouseDocumentHeaderId IN (dr.firstWarehouseDocumentHeaderId, dr.secondWarehouseDocumentHeaderId)
								WHERE dr.firstInventoryDocumentHeaderId IS NOT NULL OR dr.secondInventoryDocumentHeaderId IS NOT NULL
								GROUP BY   itemId , warehouseId ,  dr.firstInventoryDocumentHeaderId, dr.secondInventoryDocumentHeaderId
								) W on s.itemId = w.itemId  AND ih.id = w.inventoryDocumentHeaderId 
					JOIN item.Item i ON s.itemId = i.id
					JOIN dictionary.Unit u ON s.unitId = u.id
				WHERE ih.id = @inventoryDocumentHeaderId AND ise.warehouseId = ist.warehouseId AND s.direction <> 0
				ORDER BY  ise.ordinalNumber, s.ordinalNumber, i.name
				FOR XML PATH(''line''), TYPE )
		FROM document.InventoryDocumentHeader  dh
			JOIN document.InventorySheet ist ON ist.inventoryDocumentHeaderId = dh.id
			JOIN dictionary.Warehouse war ON ist.warehouseId = war.id
		WHERE dh.id = @inventoryDocumentHeaderId 	
		GROUP BY war.symbol,  ist.warehouseId
		ORDER BY MIN(ist.ordinalNumber)
		FOR XML PATH(''warehouse''), TYPE ),
		(SELECT c.fullName, c.shortName, c.nip, ca.city, ca.postCode, ca.postOffice, ca.Address
		FROM contractor.Contractor c
			JOIN contractor.ContractorAddress ca ON c.id = ca.contractorId
			JOIN dictionary.ContractorField cf ON cf.name = ''Address_Default'' AND ca.contractorFieldId = cf.id
		WHERE isOwnCompany = 1
		FOR XML PATH(''ownCompany''), TYPE),
		(SELECT fullNumber,[type], issueDate, closureDate, header, footer,
		(SELECT textValue FROM [configuration].[Configuration] WHERE [key] = ''document.defaults.systemCurrencyId'') systemCurrencyId
		FROM document.InventoryDocumentHeader
		WHERE id = @inventoryDocumentHeaderId
		FOR XML PATH(''inventory''), TYPE)
				
	FOR XML PATH(''root''),TYPE 
) AS returnsXML
END
' 
END
GO

/*
name=[tools].[p_naprawStany]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
oxB7eQUC2HERyMnunF3iHA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_naprawStany]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_naprawStany]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_naprawStany]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N' 
CREATE PROCEDURE [tools].[p_naprawStany]
AS

DECLARE @dbId UNIQUEIDENTIFIER


SELECT @dbId = textValue FROM configuration.Configuration WHERE [key] like ''communication.DatabaseId''


--Wstawienie do document.WarehouseStock brakujących towarów na magazynach na podstawie document.CommercialDocumentLine

INSERT INTO  document.WarehouseStock (id,warehouseId, itemId, unitId,quantity, reservedQuantity, orderedQuantity )
SELECT newid(), l.warehouseId, l.itemId, l.unitId, 0,null,NULL
FROM document.WarehouseDocumentLine l
	LEFT JOIN document.WarehouseStock  ws ON l.warehouseId = ws.warehouseId AND l.itemId = ws.itemId
WHERE   ws.id IS NULL	
group by  l.warehouseId, l.itemId, l.unitId	 

UPDATE document.WarehouseStock 
SET quantity = ISNULL(wl.quantity,0)
FROM document.WarehouseStock ws
	LEFT JOIN (
		SELECT SUM (l.direction * l.quantity) quantity, l.itemId, l.warehouseId
		FROM document.WarehouseDocumentHeader h 
		JOIN document.WarehouseDocumentLine l on h.id = l.warehouseDocumentHeaderId
		WHERE h.[status] >= 40
		GROUP BY l.itemId, l.warehouseId
		)wl ON ws.itemId = wl.itemId AND ws.warehouseId = wl.warehouseId
WHERE ws.warehouseId in (SELECT id FROM dictionary.Warehouse where branchId in (SELECT id FROM dictionary.Branch WHERE databaseId = @dbId)) 
	AND ISNULL(ws.quantity,0) <> ISNULL(wl.quantity ,0)


--Usuwanie daty rozchodu z pozycji dokumentów magazynowych, jeśli nie zostały całkowicie rozchodowane (na podstawie document.IncomeOutcomeRelation)

UPDATE document.WarehouseDocumentLine
SET outcomeDate = NULL
WHERE id IN (
	SELECT l.id 
	FROM document.WarehouseDocumentHeader h 
		JOIN document.WarehouseDocumentLine l ON h.id = l.warehouseDocumentHeaderId
		JOIN dictionary.DocumentType dt ON h.documentTypeId = dt.id --AND dt.symbol = ''PZ''
		LEFT JOIN (	SELECT SUM(quantity) q, incomeWarehouseDocumentLineId 
					FROM document.IncomeOutcomeRelation 
					GROUP BY incomeWarehouseDocumentLineId ) ir ON l.id = ir.incomeWarehouseDocumentLineId
		JOIN  item.Item i ON l.itemId = i.id
	WHERE h.[status] >= 40
		AND ABS(l.quantity * l.direction)  < ir.q 
		AND l.outcomeDate IS NOT NULL 
		AND l.warehouseId in (SELECT id FROM dictionary.Warehouse where branchId in (SELECT id FROM dictionary.Branch WHERE databaseId = @dbId)) 
)


--Aktualizacja ilości zamówionej (od dostawcy) na kartotekach w document.WarehouseStock.
--Ilość zamówiona to ilość niezrealizowanych z Zamówień do klienta obliczana jako: (ilość z ZAM) - (ilość z powiazanych dokumentów PZ)

UPDATE document.WarehouseStock 
SET orderedQuantity =  ISNULL(orderLines.quantity,0)
FROM document.WarehouseStock ws 
	LEFT JOIN ( 
		SELECT SUM(isnull(l.quantity,0) - isnull(cr.quantity,0)) quantity, l.itemId, l.warehouseId  
		FROM document.CommercialDocumentHeader h 
			JOIN document.CommercialDocumentLine l ON h.id = l.CommercialDocumentHeaderId AND h.[status] >= 40
			LEFT JOIN (select commercialDocumentLineId, sum(isnull(quantity,0)) quantity from document.CommercialWarehouseRelation
						where isOrderRelation = 1
						group by commercialDocumentLineId) cr ON l.id = cr.commercialDocumentLineId
		WHERE l.orderDirection = 1
		GROUP BY l.itemId, l.warehouseId ) orderLines ON  ws.itemId = orderLines.itemId AND ws.warehouseId = orderLines.warehouseId 
	JOIN item.Item i ON ws.itemId = i.id
WHERE ISNULL(orderLines.quantity,0) <> ISNULL(ws.orderedQuantity,0) AND ws.warehouseId in (SELECT id FROM dictionary.Warehouse where branchId in (SELECT id FROM dictionary.Branch WHERE databaseId = @dbId))


--Aktualizuje ilości zarezerwowane na odstawie powiązań linii dokumentów z document.CommercialDocumentLine
--które są rezerwacjami oraz ich powiązań z pozycjami dok. magazynowych w document.CommercialWarehouseRelation

UPDATE ws
SET reservedQuantity = ISNULL(orderLines.quantity,0)
FROM document.WarehouseStock ws 
	LEFT JOIN ( 
SELECT sum(isnull(l.quantity,0)) - isnull(sum(isnull(cr.quantity,0)),0) quantity, l.itemId, l.warehouseId  
FROM document.CommercialDocumentHeader h 
JOIN document.CommercialDocumentLine l ON h.id = l.CommercialDocumentHeaderId AND h.[status] >= 20
LEFT JOIN (SELECT SUM(isnull(quantity,0)) quantity, commercialDocumentLineId
			FROM document.CommercialWarehouseRelation
			where isOrderRelation = 1
			GROUP BY commercialDocumentLineId) cr
ON l.id = cr.commercialDocumentLineId
WHERE l.orderDirection = -1
GROUP BY l.itemId, l.warehouseId
			 ) orderLines ON  ws.itemId = orderLines.itemId AND ws.warehouseId = orderLines.warehouseId 
	JOIN item.Item i ON ws.itemId = i.id
WHERE ISNULL(orderLines.quantity,0) <> ISNULL(ws.reservedQuantity,0) AND ws.warehouseId IN (SELECT id FROM dictionary.Warehouse where branchId in (SELECT id FROM dictionary.Branch WHERE databaseId = @dbId))


--UPDATE ws
--SET reservedQuantity = ISNULL(orderLines.quantity,0)
--FROM document.WarehouseStock ws 
--	LEFT JOIN ( 
--		SELECT SUM(l.quantity - cr.quantity) quantity, l.itemId, l.warehouseId  
--		FROM document.CommercialDocumentLine l 
--			LEFT JOIN document.CommercialWarehouseRelation cr ON l.id = cr.commercialDocumentLineId AND cr.isOrderRelation = 1
--		WHERE l.orderDirection = -1
--		GROUP BY l.itemId, l.warehouseId
--			 ) orderLines ON  ws.itemId = orderLines.itemId AND ws.warehouseId = orderLines.warehouseId 
--	JOIN item.Item i ON ws.itemId = i.id
--WHERE ISNULL(orderLines.quantity,0) <> ISNULL(ws.orderedQuantity,0) AND ws.warehouseId IN (SELECT id FROM dictionary.Warehouse where branchId in (SELECT id FROM dictionary.Branch WHERE databaseId = @dbId))



--SELECT l.id ,ws.reservedQuantity ,l.quantity ,cr.quantity ,l.itemId, l.warehouseId  
--FROM document.CommercialDocumentLine l 
--	JOIN document.WarehouseStock ws  ON  ws.itemId = l.itemId AND ws.warehouseId = l.warehouseId 
--	LEFT JOIN document.CommercialWarehouseRelation cr ON l.id = cr.commercialDocumentLineId 
--		AND cr.isOrderRelation = 1
--WHERE l.orderDirection = -1 
--	AND l.warehouseId = ''30d11e41-5969-4640-bd38-0ae0e7e22a71'' 
--	AND l.itemId = ''9efaceb2-6414-4506-b0d4-06bea8784fdd''



--SELECT  reservedQuantity , orderLines.quantity, ws.itemId , ws.warehouseId
--FROM document.WarehouseStock ws 
--	LEFT JOIN ( 
--		SELECT SUM(l.quantity - cr.quantity) quantity, l.itemId, l.warehouseId  
--		FROM document.CommercialDocumentLine l 
--			LEFT JOIN document.CommercialWarehouseRelation cr ON l.id = cr.commercialDocumentLineId AND cr.isOrderRelation = 1
--		WHERE l.orderDirection = -1
--		GROUP BY l.itemId, l.warehouseId
--			 ) orderLines ON  ws.itemId = orderLines.itemId AND ws.warehouseId = orderLines.warehouseId 
--	JOIN item.Item i ON ws.itemId = i.id
--WHERE orderLines.quantity <> ws.reservedQuantity


----UPDATE document.WarehouseStock 
----SET reservedQuantity = (ISNULL(orderLines.quantity, 0 ) - ISNULL(relationLines.quantity, 0))
----FROM document.WarehouseStock ws 
----	LEFT JOIN ( 
----		SELECT SUM(l.quantity) quantity, l.itemId, l.warehouseId  
----		FROM document.CommercialDocumentLine l 
----		WHERE l.orderDirection = -1
----		GROUP BY l.itemId, l.warehouseId ) orderLines ON  ws.itemId = orderLines.itemId AND ws.warehouseId = orderLines.warehouseId 
----	LEFT JOIN 
----	(	SELECT SUM(cr.quantity) quantity, l.itemId, l.warehouseId 
----		FROM document.CommercialDocumentLine l 
----			LEFT JOIN document.CommercialWarehouseRelation cr ON l.id = cr.commercialDocumentLineId AND cr.isOrderRelation = 1
----		WHERE l.orderDirection = -1
----		GROUP BY l.itemId, l.warehouseId
----	) relationLines ON  ws.itemId = relationLines.itemId AND ws.warehouseId = relationLines.warehouseId
----	JOIN item.Item i ON ws.itemId = i.id
----WHERE (ISNULL(orderLines.quantity, 0 ) - ISNULL(relationLines.quantity, 0)) <> ws.reservedQuantity
' 
END
GO

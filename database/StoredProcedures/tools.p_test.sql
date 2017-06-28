/*
name=[tools].[p_test]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Zd/f+Za9oUTbQd4Otnpcag==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_test]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_test]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_test]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tools].[p_test]
AS

SELECT ''outcomeDate na nie rozchodowanych PZ'' [rodzaj bledu], i.name [nazwa towaru]--, l.quantity AS [ilosc na pozycji], ir.q [ilosc na rozchodach]
	FROM document.WarehouseDocumentHeader h 
		JOIN document.WarehouseDocumentLine l ON h.id = l.warehouseDocumentHeaderId
		JOIN dictionary.DocumentType dt ON h.documentTypeId = dt.id AND dt.symbol = ''PZ''
		LEFT JOIN (	SELECT SUM(quantity) q, incomeWarehouseDocumentLineId 
					FROM document.IncomeOutcomeRelation 
					GROUP BY incomeWarehouseDocumentLineId ) ir ON l.id = ir.incomeWarehouseDocumentLineId
		JOIN  item.Item i ON l.itemId = i.id
	WHERE l.quantity  <> ir.q AND l.outcomeDate IS NOT NULL AND h.status >= 40

UNION
SELECT ''niezgodny stan w WarehouseStock'' [rodzaj bledu], i.name [nazwa towaru]
FROM document.WarehouseStock ws
	LEFT JOIN (
		SELECT SUM (direction * quantity) quantity, itemId, warehouseId
		FROM document.WarehouseDocumentLine
		GROUP BY itemId, warehouseId
		)wl ON ws.itemId = wl.itemId AND ws.warehouseId = wl.warehouseId
	JOIN  item.Item i ON ws.itemId = i.id
WHERE ws.quantity <> wl.quantity
UNION
SELECT ''niezgodny stan rezerwacji w WarehouseStock'' [rodzaj bledu], i.name [nazwa towaru]
FROM document.WarehouseStock ws 
	LEFT JOIN ( 
		SELECT SUM(l.quantity) quantity, l.itemId, l.warehouseId  
		FROM document.CommercialDocumentLine l 
		WHERE l.orderDirection = -1
		GROUP BY l.itemId, l.warehouseId ) orderLines ON  ws.itemId = orderLines.itemId AND ws.warehouseId = orderLines.warehouseId 
	LEFT JOIN 
	(	SELECT SUM(cr.quantity) quantity, l.itemId, l.warehouseId 
		FROM document.CommercialDocumentLine l 
			LEFT JOIN document.CommercialWarehouseRelation cr ON l.id = cr.commercialDocumentLineId AND cr.isOrderRelation = 1
		WHERE l.orderDirection = -1
		GROUP BY l.itemId, l.warehouseId
	) relationLines ON  ws.itemId = relationLines.itemId AND ws.warehouseId = relationLines.warehouseId
	JOIN item.Item i ON ws.itemId = i.id
	JOIN ( SELECT id FROM dictionary.Warehouse WHERE branchId in ( SELECT id FROM dictionary.Branch where databaseId = (SELECT textValue FROM configuration.Configuration where [key] like ''communication.databaseId'')) or symbol = ''CE'' ) ww ON ws.warehouseId = ww.id
WHERE (ISNULL(orderLines.quantity, 0 ) - ISNULL(relationLines.quantity, 0)) <> ws.reservedQuantity
UNION
SELECT ''niezgodny stan zamowien w WarehouseStock'' [rodzaj bledu], i.name [nazwa towaru]
FROM document.WarehouseStock ws 
	LEFT JOIN ( 
		SELECT SUM(l.quantity) quantity, l.itemId, l.warehouseId  
		FROM document.CommercialDocumentLine l 
		WHERE l.orderDirection = 1
		GROUP BY l.itemId, l.warehouseId ) orderLines ON  ws.itemId = orderLines.itemId AND ws.warehouseId = orderLines.warehouseId 
	LEFT JOIN 
	(	SELECT SUM(cr.quantity) quantity, l.itemId, l.warehouseId 
		FROM document.CommercialDocumentLine l 
			LEFT JOIN document.CommercialWarehouseRelation cr ON l.id = cr.commercialDocumentLineId AND cr.isOrderRelation = 1
		WHERE l.orderDirection = -1
		GROUP BY l.itemId, l.warehouseId
	) relationLines ON  ws.itemId = relationLines.itemId AND ws.warehouseId = relationLines.warehouseId
	JOIN item.Item i ON ws.itemId = i.id
WHERE (ISNULL(orderLines.quantity, 0 ) - ISNULL(relationLines.quantity, 0)) <> ws.orderedQuantity
UNION
SELECT ''za bardzo rozchodowany PZ'' [rodzaj bledu], i.name [nazwa towaru]
	FROM document.WarehouseDocumentHeader h 
		JOIN document.WarehouseDocumentLine l ON h.id = l.warehouseDocumentHeaderId
		LEFT JOIN (	SELECT SUM(quantity) q, incomeWarehouseDocumentLineId 
					FROM document.IncomeOutcomeRelation 
					GROUP BY incomeWarehouseDocumentLineId ) ir ON l.id = ir.incomeWarehouseDocumentLineId
		JOIN  item.Item i ON l.itemId = i.id
	WHERE (l.quantity * l.direction)  < ir.q AND h.status >= 40
UNION
SELECT ''za bardzo przychodowany WZ'' [rodzaj bledu], i.name [nazwa towaru]
	FROM document.WarehouseDocumentHeader h 
		JOIN document.WarehouseDocumentLine l ON h.id = l.warehouseDocumentHeaderId
		LEFT JOIN (	SELECT SUM(quantity) q, outcomeWarehouseDocumentLineId 
					FROM document.IncomeOutcomeRelation 
					GROUP BY outcomeWarehouseDocumentLineId ) ir ON l.id = ir.outcomeWarehouseDocumentLineId
		JOIN  item.Item i ON l.itemId = i.id
	WHERE (l.quantity * l.direction)  < -ir.q
	
UNION
select ''Nie powiązany z przychodem rozchód'' ,  i.name [nazwa towaru]
from  [document].WarehouseDocumentLine  l 
	LEFT JOIN [document].IncomeOutcomeRelation ir ON l.id = ir.outcomeWarehouseDocumentLineId
	JOIN item.Item i ON l.itemId = i.id
WHERE  (l.quantity * l.direction) <0
group by l.id,l.quantity , l.direction, i.name
HAVING ABS(l.quantity * l.direction) <> ABS(sum(ISNULL(ir.quantity,0)) )
UNION
SELECT ''niezgodna suma ilości na powiązaniach ilościowych i wartościowych'' [rodzaj bledu], i.name [nazwa towaru]
	FROM document.WarehouseDocumentHeader h 
		JOIN document.WarehouseDocumentLine l ON h.id = l.warehouseDocumentHeaderId
		LEFT JOIN (	SELECT SUM(quantity) q, outcomeWarehouseDocumentLineId 
					FROM document.IncomeOutcomeRelation 
					GROUP BY outcomeWarehouseDocumentLineId ) ir ON l.id = ir.outcomeWarehouseDocumentLineId
		LEFT JOIN (	SELECT SUM(quantity) q2, outcomeWarehouseDocumentLineId 
					FROM document.WarehouseDocumentValuation 
					GROUP BY outcomeWarehouseDocumentLineId ) wv ON l.id = wv.outcomeWarehouseDocumentLineId
		JOIN  item.Item i ON l.itemId = i.id
	WHERE wv.q2  > ir.q
UNION
SELECT  ''tabela vat ma źle policzoną kwotę vat'' [rodzaj bledu], dt.symbol + '' '' + h.fullNumber + ''z dnia:'' + CONVERT(varchar(10),h.issueDate ,120) + '' vat_policzony:'' + CAST(vatVal_licz as varchar(50)) + '' vat_aktualny:'' + CAST(vatVal as varchar(50))
FROM (
	select CAST( (round(grossValue * (v.rate/(v.rate + 100.00)) ,2) ) as float) vatVal_licz, (vatValue) vatVal, commercialDocumentHeaderId
		FROM document.CommercialDocumentVatTable
			JOIN dictionary.vatRate v ON CommercialDocumentVatTable.vatRateId = v.id
		where round(grossValue * (v.rate/(v.rate + 100.00)) ,2)<> vatValue  
			AND ABS(ABS(round(grossValue * (v.rate/(v.rate + 100.00)) ,2)) - ABS(vatValue)) > 0.01
	) x 
	JOIN document.CommercialDocumentHeader 	h ON x.commercialDocumentHeaderId = h.id
	JOIN dictionary.DocumentType dt ON h.documentTypeId = dt.id
where x.vatVal <> 0
UNION
SELECT  ''źle podsumowany nagłówek'' [rodzaj bledu], dt.symbol + '' '' + h.fullNumber + ''z dnia:'' + CONVERT(varchar(10),h.issueDate ,120) + '' suma z pozycji:'' + CAST(poz as varchar(50)) + '' nagłówek:'' + CAST(nag as varchar(50))
FROM (
		SELECT SUM(ISNULL(l.grossValue,0) + ISNULL(l.netValue,0))  poz, (ISNULL(h.netValue,0) + ISNULL(h.grossValue,0)) nag, commercialDocumentHeaderId
		FROM document.CommercialDocumentHeader h
			JOIN document.CommercialDocumentLine l ON h.id = l.commercialDOcumentHeaderId
			JOIN dictionary.DocumentType t ON h.documentTypeId = t.id
		WHERE l.commercialDirection <> 0 and t.symbol not like ''FZ%''
		GROUP BY commercialDocumentHeaderId, ISNULL(h.netValue,0) , ISNULL(h.grossValue,0)
		HAVING ABS(SUM(ISNULL(l.grossValue,0) + ISNULL(l.netValue,0))  - (ISNULL(h.netValue,0) + ISNULL(h.grossValue,0)) ) > 0.5
		
	) x 
	JOIN document.CommercialDocumentHeader 	h ON x.commercialDocumentHeaderId = h.id
	JOIN dictionary.DocumentType dt ON h.documentTypeId = dt.id
where x.poz <> x.nag
' 
END
GO

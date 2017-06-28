/*
name=[tools].[p_aktualizujOCZ]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dr0x4Rh4sg7TsnbdEXVp2g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_aktualizujOCZ]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_aktualizujOCZ]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_aktualizujOCZ]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tools].[p_aktualizujOCZ]
AS
 
--Pobranie identyfikatora bazy oddziału, w którym wykonywane jest zapytanie
DECLARE @dbId UNIQUEIDENTIFIER
SELECT @dbId = textValue FROM configuration.Configuration WHERE [KEY] LIKE ''communication.DatabaseId''
 
UPDATE ws 
SET ws.lastPurchaseNetPrice = y.price ,ws.lastPurchaseIssueDate = y.incomeDate
FROM document.WarehouseStock ws
	JOIN (
--KROK 4. Jeśli istnieje wiele dokumentów o identycznych datach przychodu, wystawienia i numerze pozycji z daną kartoteka, wybieramy z nich najwyższą cenę
	SELECT y.itemId, y.warehouseId, max(z.price) AS price, y.incomeDate, z.issueDate, y.ordinalNumber
	FROM (
--KROK 3. Jeśli na jednym dokumencie dany towar występuje wielokrotnie, wybieramy ostatnią pozycję
		SELECT d.itemId, d.warehouseId, d.incomeDate, d.issueDate, MAX(ordinalNumber) ordinalNumber
		FROM(		
--KROK 2. Wybieramy najnowszy dokument spośród tych o jednakowej dacie przychodu (dzięki temu bierzemy cene z PZK zamiast z PZ)
			SELECT b.itemId, b.warehouseId, b.incomeDate, MAX(c.issueDate) issueDate
			FROM(
--KROK 1. Wybieramy ostatni przychód towaru na magazynie
				SELECT itemId, warehouseId, MAX(incomeDate) incomeDate
				FROM(
					SELECT itemId, warehouseId, incomeDate
					FROM document.WarehouseDocumentLine 
--Wybieramy tylko przychody
					WHERE (direction * quantity) > 0 
--Tylko niezerowe wartości (value = ilość * cena)
					AND value > 0 
--Wybieramy tylko te dokumenty magazynowe, których typy mają ustawioną wartość atrybutu updateLastPurchasePrice na true
					AND warehouseDocumentHeaderId IN (
						SELECT id 
						FROM document.WarehouseDocumentHeader
						WHERE documentTypeId IN (
							SELECT id
							FROM dictionary.DocumentType
							WHERE xmlOptions.value(''(root/warehouseDocument[@updateLastPurchasePrice="true"])[1]'',''varchar(10)'') IS NOT NULL
							)
						)
					UNION
--Oprócz dokumentów magazynowych OCZ mogą modyfikować FZ i FKZ
					SELECT itemId, l.warehouseId, h.issueDate AS incomeDate
					FROM document.CommercialDocumentLine l
					JOIN document.CommercialDocumentHeader h ON l.commercialDocumentHeaderId = h.id
					WHERE h.documentTypeId IN (
						SELECT id
						FROM dictionary.DocumentType
						WHERE symbol IN (''FZ'', ''FKZ'')
						)
					AND l.netValue > 0 
					AND (commercialDirection * quantity) > 0
					) a
				GROUP BY itemId, warehouseId 
				) b
			JOIN(
				SELECT l.itemId, l.warehouseId, l.incomeDate, h.issueDate
				FROM document.WarehouseDocumentHeader h
				JOIN document.WarehouseDocumentLine l ON h.id = l.warehouseDocumentHeaderId
				WHERE (l.direction * l.quantity) > 0 
				AND l.value > 0 
				AND h.documentTypeId IN (
					SELECT id
					FROM dictionary.DocumentType
					WHERE xmlOptions.value(''(root/warehouseDocument[@updateLastPurchasePrice="true"])[1]'',''varchar(10)'') IS NOT NULL
					)
				UNION
				SELECT l.itemId, l.warehouseId, h.issueDate AS incomeDate, h.issueDate 
				FROM document.CommercialDocumentHeader h
				JOIN document.CommercialDocumentLine l ON h.id = l.commercialDocumentHeaderId
				WHERE h.documentTypeId IN (
					SELECT id
					FROM dictionary.DocumentType
					WHERE symbol IN (''FZ'', ''FKZ'')
					)
				AND l.netValue > 0 
				AND (l.commercialDirection * l.quantity) > 0
				) c ON b.itemId = c.itemId AND b.warehouseId = c.warehouseId AND b.incomeDate = c.incomeDate
			GROUP BY b.itemId, b.warehouseId, b.incomeDate
			) d	
 
		JOIN (
			SELECT l.itemId, l.warehouseId, l.incomeDate, h.issueDate, l.ordinalNumber
			FROM document.WarehouseDocumentHeader h
			JOIN document.WarehouseDocumentLine l ON h.id = l.warehouseDocumentHeaderId
			WHERE (l.direction * l.quantity) > 0 
			AND l.value > 0 
			AND h.documentTypeId IN (
				SELECT id
				FROM dictionary.DocumentType
				WHERE xmlOptions.value(''(root/warehouseDocument[@updateLastPurchasePrice="true"])[1]'',''varchar(10)'') IS NOT NULL
				)
			UNION
			SELECT l.itemId, l.warehouseId, h.issueDate AS incomeDate, h.issueDate, l.ordinalNumber
			FROM document.CommercialDocumentHeader h
			JOIN document.CommercialDocumentLine l ON h.id = l.commercialDocumentHeaderId
			WHERE h.documentTypeId IN (
				SELECT id
				FROM dictionary.DocumentType
				WHERE symbol IN (''FZ'', ''FKZ'')
				)
			AND l.netValue > 0 
			AND (l.commercialDirection * l.quantity) > 0
			) x ON x.itemId = d.itemId AND x.warehouseId = d.warehouseId AND x.incomeDate = d.incomeDate AND x.issueDate = d.issueDate
		GROUP BY d.itemId, d.warehouseId, d.incomeDate, d.issueDate
		) y
	JOIN (
			SELECT l.itemId, l.warehouseId, l.price, l.incomeDate, h.issueDate, l.ordinalNumber
			FROM document.WarehouseDocumentLine l
			JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id
			WHERE (l.direction * l.quantity) > 0 
			AND l.value > 0 
			AND h.documentTypeId IN (
				SELECT id
				FROM dictionary.DocumentType
				WHERE xmlOptions.value(''(root/warehouseDocument[@updateLastPurchasePrice="true"])[1]'',''varchar(10)'') IS NOT NULL
				)
			UNION
			SELECT l.itemId, l.warehouseId, l.netPrice AS price, h.issueDate AS incomeDate, h.issueDate, l.ordinalNumber
			FROM document.CommercialDocumentHeader h
			JOIN document.CommercialDocumentLine l ON h.id = l.commercialDocumentHeaderId
			WHERE h.documentTypeId IN (
				SELECT id
				FROM dictionary.DocumentType
				WHERE symbol IN (''FZ'', ''FKZ'')
				)
			AND l.netValue > 0 
			AND (l.commercialDirection * l.quantity) > 0
		) z ON z.itemId = y.itemId AND  z.warehouseId = y.warehouseId AND z.incomeDate = y.incomeDate AND z.issueDate = y.issueDate AND z.ordinalNumber = y.ordinalNumber
	GROUP BY y.itemId, y.warehouseId, y.incomeDate, z.issueDate, y.ordinalNumber
	) y ON  y.itemId = ws.itemId AND  y.warehouseId = ws.warehouseId
--Poprawiamy tylko te pozycje, które mają niepoprawne OCZ
WHERE isnull(ws.lastPurchaseNetPrice,0) <> y.price
--Identyfikacja oddziału na podstawie identyfikatora bazy i wybór magazynów tylko z danego oddziału (żeby nie aktualizować przez przypadek obcych OCZ)
AND ws.warehouseId IN (SELECT id FROM dictionary.Warehouse WHERE branchId IN (SELECT id FROM dictionary.Branch WHERE databaseId = @dbId))
' 
END
GO

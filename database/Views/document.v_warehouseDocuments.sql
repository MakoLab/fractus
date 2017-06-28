/*
name=[document].[v_warehouseDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
SJsiHzA8Ld20GsdvXWT21g==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[document].[v_warehouseDocuments]'))
DROP VIEW [document].[v_warehouseDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[document].[v_warehouseDocuments]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [document].[v_warehouseDocuments] 
AS

	SELECT
		h.id,ig.itemGroupId ,   g.label test,
		b.symbol [Oddział], h.number [Numer dokumentu], h.fullNumber [Numer Pełny Dokumentu], 
		CONVERT(CHAR(10), h.issueDate,120) [Data Wystawienia], 
		MONTH( h.issueDate) [Miesiąc Wystawienia],
		YEAR(h.issueDate) [Rok],
		h.value [Wartość Dokumentu],
		s.seriesValue [Seria Dokumentu],
		dt.symbol [Typ Dokumentu], 
		c.code [Kod Kontrahenta], c.fullName [Nazwa Pełna Kontrahenta], 
		cu.symbol [Symbol Waluty],
		l.ordinalNumber [Pozycja Dokumentu], i.name [Nazwa Towaru], i.code [Kod Towaru],
		u.symbol [Jednostka], w.symbol [Magazyn], l.quantity * l.direction [Ilość], 
		l.price [Cena], l.value [Wartość]
	FROM document.WarehouseDocumentHeader h WITH(NOLOCK) 
		JOIN document.WarehouseDocumentLine l WITH(NOLOCK) ON h.id = l.warehouseDocumentHeaderId 
		JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id
		LEFT JOIN contractor.Contractor c WITH(NOLOCK) ON h.contractorId = c.id
		JOIN dictionary.Currency cu WITH(NOLOCK) ON h.documentCurrencyId = cu.id
		JOIN document.Series s WITH(NOLOCK) ON h.seriesId = s.id
		JOIN (  SELECT xmlLabels.value(''(labels/label[@lang = "pl"]/@symbol)[1]'',''varchar(50)'') symbol, id
				FROM  dictionary.Unit WITH(NOLOCK)
			 ) u ON l.unitId = u.id 
		JOIN item.Item i WITH(NOLOCK) ON l.itemId = i.id
		JOIN dictionary.Warehouse w WITH(NOLOCK) ON l.warehouseId = w.id 
		JOIN dictionary.Branch b WITH(NOLOCK) ON b.id = h.branchId
		JOIN item.ItemGroupMembership ig ON i.id = ig.itemId
		JOIN item.ItemGroup g ON ig.itemGroupId = g.id
	WHERE dt.documentCategory = 1 
' 
GO

/*
name=[dataWarehouse].[v_salesOrders]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
eYJEWFfCgaH5I/aj5SPUrA==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dataWarehouse].[v_salesOrders]'))
DROP VIEW [dataWarehouse].[v_salesOrders]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dataWarehouse].[v_salesOrders]'))
EXEC dbo.sp_executesql @statement = N'CREATE view [dataWarehouse].v_salesOrders
AS

select o.id,o.fullNumber [Numer pełny], o.status [Status],o.issueDate [Data], o.shortIssueDate [Krótka data], o.[year] [Rok],o.fullName [Kontrahent] ,o.code [Kod kontrahenta]
	,o.symbol [Oddział], o.grossValue [Brutto zamówienia], o.netValue [Netto zamówienia], o.salesType [Typ sprzedaży],o.settlementDate [Data rozliczenia], 
	ISNULL(NULLIF(ISNULL(o.settled,''nieroliczone''),''settled''),''roliczone'') czyRozliczone,o.salesmanName [Sprzedawca], o.salesmanCode [Kod sprzedawcy],
	ISNULL(CONVERT(varchar(10),o.relatedOutcome ,21) ,''brak'') [Data wydania],r.id [id dokumentu],r.documentType [Typ dokumentu], r.category [Kategoria],r.fullNumber [Numer pełny pow.],
	r.issueDate [Data dokumentu pow.],r.[warehouseValue] [Magazyn],r.netValue [Zam. netto], r.grossValue [Zam. brutto], r.[z_netValue] [Zal. netto], r.[z_grossValue] [Zal. brutto],
	r.[r_netValue] [Rozl. netto], r.[z_grossValue] [Rozl. brutto], r.[m_grossValue] [Wydanie]
	 
from [dataWarehouse].[salesOrders] o 
LEFT JOIN [dataWarehouse].[salesOrdersRelated] r ON o.id = r.[firstCommercialDocumentHeaderId]
' 
GO

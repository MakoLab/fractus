/*
name=[document].[v_salesDocumentsPL]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
1JmoY4NtoBlKnecpNnNlLw==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[document].[v_salesDocumentsPL]'))
DROP VIEW [document].[v_salesDocumentsPL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[document].[v_salesDocumentsPL]'))
EXEC dbo.sp_executesql @statement = N'


CREATE view [document].[v_salesDocumentsPl] 
AS
SELECT
		h.id, h.exchangeDate [Data kursu], h.exchangeRate [Kurs] , h.number [Numer Dokumentu], h.fullNumber [Numer Pełny], h.issueDate [Data Dokumentu], 
		h.eventDate [Data Sprzedaży], MONTH(h.eventDate) [Miesiąc Sprzedaży],YEAR(h.eventDate) [Rok Sprzedaży], DAY(h.eventDate) [Dzień  Sprzedaży],
		h.netValue [Netto Dokumentu], h.grossValue [Brutto Dokumentu], h.vatValue [Vat Dokumentu], h.creationDate [Data utworzenia],
		s.seriesValue [Wartość Serii],
		dt.symbol [Typ Dokumentu], 
		c.code [Kod Kontrahenta], c.fullName [Nazwa Kontrahenta], 
		ca.city [Miasto Kontrahenta],ca.postCode [Kod Pocztowy Kontrahenta],ca.address [Adres Kontrahenta],ca.addressNumber [Numer Adres Kontrahenta], co_ca.symbol [Kod Kraju],
		c_rp.code [Kod Odbierającego], c_rp.fullName [Nazwa Odbierającego], 
		c_ip.code [Kod Sprzedawcy], c_ip.fullName [Nazwa Sprzedawcy], 
		c_i.code [Kod Sprzedającego], c_i.fullName [Nazwa Sprzedającego], 
		ca_i.city [Miasto Sprzedającego],ca_i.postCode [Kod Pocztowy Sprzedającego],ca_i.address [Adres Sprzedającego],ca_i.addressNumber [Numer Adresu Sprzedajacego],
		co_i.symbol [Kraj Sprzedającego],		
		cu.symbol [Document currency symbol],
		l.ordinalNumber [Pozycja Dokumentu], i.name [Nazwa Produktu], i.code [Kod Produktu],
		u.symbol [Jednostka Miary], w.symbol [Symbol Magazynu], l.quantity [Ilość], 
		l.netPrice [Cena Netto], l.grossPrice [Cena Brutto], l.initialGrossPrice [Cena Brutto Przed Rabatem], 
		l.discountRate [Rabat], l.netValue [Wartość Netto Pozycji], l.grossValue [Wartość Brutto Pozycji], 
		l.vatValue [Vartość Vat Pozycji], v.symbol [Stawka Vat], cg.label [Grupa Kontrahentów]
		, ig.label [Grupa Towarów]
	FROM document.CommercialDocumentHeader h WITH(NOLOCK) 
		JOIN document.CommercialDocumentLine l WITH(NOLOCK) ON h.id = l.CommercialDocumentHeaderId 
		JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id
		LEFT JOIN contractor.Contractor c WITH(NOLOCK) ON h.contractorId = c.id
			LEFT JOIN contractor.ContractorAddress ca WITH(NOLOCK) ON h.contractorAddressId = ca.id
			LEFT JOIN dictionary.Country co_ca WITH(NOLOCK) ON ca.countryId = co_ca.id
		LEFT JOIN contractor.Contractor c_rp WITH(NOLOCK) ON h.receivingPersonContractorId = c_rp.id
		LEFT JOIN contractor.Contractor c_ip WITH(NOLOCK) ON h.issuingPersonContractorId = c_ip.id
		LEFT JOIN contractor.Contractor c_i WITH(NOLOCK) ON h.issuerContractorId = c_i.id
			LEFT JOIN contractor.ContractorAddress ca_i WITH(NOLOCK) ON h.contractorAddressId = ca_i.id
			LEFT JOIN dictionary.Country co_i WITH(NOLOCK) ON ca.countryId = co_i.id		
		JOIN dictionary.Currency cu WITH(NOLOCK) ON h.documentCurrencyId = cu.id
		JOIN document.Series s WITH(NOLOCK) ON h.seriesId = s.id
		JOIN (  SELECT xmlLabels.value(''(labels/label[@lang = "pl"]/@symbol)[1]'',''varchar(50)'') symbol, id
				FROM  dictionary.Unit WITH(NOLOCK)
			 ) u ON l.unitId = u.id 
		JOIN item.Item i WITH(NOLOCK) ON l.itemId = i.id
		JOIN dictionary.Warehouse w WITH(NOLOCK) ON l.warehouseId = w.id 
		JOIN dictionary.VatRate v WITH(NOLOCK) ON l.vatRateId = v.id
		LEFT JOIN contractor.ContractorGroupMembership cgm WITH(NOLOCK) ON c.id = cgm.contractorId
		LEFT JOIN contractor.ContractorGroup cg WITH(NOLOCK) ON cgm.contractorGroupId = cg.id
		LEFT JOIN item.ItemGroupMembership CGM2 WITH(NOLOCK) ON i.id = CGM2.itemId
		LEFT JOIN  item.ItemGroup ig WITH(NOLOCK) ON CGM2.itemGroupId = ig.id
	WHERE dt.documentCategory = 0
' 
GO

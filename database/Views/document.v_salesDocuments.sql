/*
name=[document].[v_salesDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4tSZer7MSbZSKgnm7yhy9Q==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[document].[v_salesDocuments]'))
DROP VIEW [document].[v_salesDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[document].[v_salesDocuments]'))
EXEC dbo.sp_executesql @statement = N'


CREATE view [document].[v_salesDocuments] 
AS
SELECT
		h.id, h.exchangeDate [Exchange date], h.exchangeRate [Exchange rate] , h.number [Number], h.fullNumber [Full number], h.issueDate [IssueDate], 
		h.eventDate [Event date], MONTH(h.eventDate) [Event month],YEAR(h.eventDate) [Event year], DAY(h.eventDate) [Event day],
		h.netValue [Document net value], h.grossValue [Document gross value], h.vatValue [Document vat value], h.creationDate [Document creation date],
		s.seriesValue [Document series value],
		dt.symbol [Document type], 
		c.code [Contractor code], c.fullName [Contractor full name], 
		ca.city [Contractor address city],ca.postCode [Contractor address post code],ca.city [Contractor address post office],ca.city [Contractor address], co_ca.symbol [Contractor address country symbol],
		c_rp.code [Receiving person code], c_rp.fullName [Receiving person full name], 
		c_ip.code [Issuing person code], c_ip.fullName [Issuing person full name], 
		c_i.code [Issuer code], c_i.fullName [Issuer full name], 
		ca_i.city [Issuer address city],ca_i.postCode [Issuer address post code],ca_i.city [Issuer address post office],ca_i.city [Issuer address], co_i.symbol [Issuer address country symbol],		
		cu.symbol [Document currency symbol],
		l.ordinalNumber [Document line ordinal number], i.name [Item name], i.code [Item code],
		u.symbol [Item unit symbol], w.symbol [Document line warehouse symbol], l.quantity [Document line quantity], 
		l.netPrice [Document line net price], l.grossPrice [Document line gross price], l.initialGrossPrice [Document line initial gross price], 
		l.discountRate [Document line discont rate], l.netValue [Document line net value], l.grossValue [Document line gross value], 
		l.vatValue [Document line vat value], v.symbol [Document line vat rate symbol], cg.label [Contractor group]
		, ig.label [Item group]
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

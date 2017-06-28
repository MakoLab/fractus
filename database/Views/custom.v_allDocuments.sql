/*
name=[custom].[v_allDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
yclA6onQUXtnziBo11qyWw==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[custom].[v_allDocuments]'))
DROP VIEW [custom].[v_allDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[custom].[v_allDocuments]'))
EXEC dbo.sp_executesql @statement = N'

CREATE view [custom].[v_allDocuments] as
select 
	CASE dt.documentCategory WHEN 0 THEN ''Sprzedażowy'' WHEN 1 THEN ''Magazynowy'' WHEN 2 THEN ''Zakupowy''
	WHEN 3 THEN ''Rezerwacja'' WHEN 4 THEN ''Zamówienie'' WHEN 5 THEN ''Korekta sprzedaży''
	WHEN 6 THEN ''Korekta zakupu'' WHEN 7 THEN ''Korekta rozchodu'' WHEN 8 THEN ''Korekta przychodu''
	WHEN 9 THEN ''Finansowy'' WHEN 10 THEN ''Serwis'' WHEN 11 THEN ''Reklamacja''
	WHEN 12 THEN ''Inwentaryzacja'' WHEN 13 THEN ''Zamówienie sprzedażowe'' WHEN 14 THEN ''Technologia''
	WHEN 15 THEN ''Zlecenie produkcyjne'' WHEN 16 THEN ''Oferta'' ELSE '''' END as [Kategoria dokumentu],
	dt.symbol as [Typ dokumentu],
	dt.xmlLabels.value(''(/labels/label[@lang="pl"])[1]'',''VARCHAR(MAX)'') as [Typ dokumentu nazwa],
	b.symbol as [Numer oddziału],
	b.xmlLabels.value(''(/labels/label[@lang="pl"])[1]'',''VARCHAR(MAX)'') as [Nazwa oddziału],
	h.fullNumber as [Numer dokumentu],
	CONVERT(varchar(10), h.issueDate, 21) as [Data wystawienia],
	CONVERT(varchar(4), h.issueDate, 21) as [+Rok],
	CONVERT(varchar(7), h.issueDate, 21) as [Rok-Miesiąc],
	DATEPART(dd, h.issueDate) as [Dzień miesiaca],
	DATEPART(dw, h.issueDate) as [Dzień tygodnia],
	CAST(DATEPART(hh, h.issueDate) AS VARCHAR(2)) + '':'' + RIGHT(''0'' + CAST(DATEPART(mi, h.issueDate) AS VARCHAR(2)),2) as [Godzina:Minuta],
	CAST(DATEPART(hh, h.issueDate) AS VARCHAR(2)) as [Godzina],
	h.netValue as [Wartość netto],
	h.vatValue as [Wartość VAT],
	h.grossValue as [Wartość brutto],
	CASE WHEN dt.documentCategory = 0 OR dt.documentCategory = 5 THEN cvs.value ELSE NULL END as [Koszt dokumentu],
	CASE WHEN dt.documentCategory = 0 OR dt.documentCategory = 5 THEN (h.netValue * h.exchangeRate)/h.exchangeScale - cvs.value ELSE NULL END as [Marża netto dokumentu],
	CASE WHEN dt.documentCategory = 0 OR dt.documentCategory = 5 THEN (h.grossValue * h.exchangeRate)/h.exchangeScale - cvs.value ELSE NULL END as [Marża brutto dokumentu],
	CASE WHEN h.netValue = 0 THEN 0 WHEN dt.documentCategory = 0 OR dt.documentCategory = 5 THEN ((h.netValue * h.exchangeRate)/h.exchangeScale - cvs.value)/h.netValue*100 ELSE NULL END as [Marża % dokumentu],
	h.issueDate as [Data i godzina],
	c.code as [Kod kontrahenta],
	c.shortName as [Nazwa kontrahenta],
	c.nip as [NIP],
	isnull(h.xmlConstantData.value(''(/constant/contractor/addresses/address/city)[1]'',''VARCHAR(MAX)'') + '', '','''') + isnull(h.xmlConstantData.value(''(/constant/contractor/addresses/address/postCode)[1]'',''VARCHAR(MAX)''),'''') + '' '' + isnull(h.xmlConstantData.value(''(/constant/contractor/addresses/address/address)[1]'',''VARCHAR(MAX)''),'''') as [Adres],
	isnull(phone.phone,'''') as [Telefon/y],
	dbo.f_getGroupLabel_mod(cgm.contractorGroupId,(SELECT xmlValue FROM configuration.Configuration WHERE [key] = ''contractors.group'')) as [Grupa kontrahenta],
	it.xmlLabels.value(''(/labels/label[@lang="pl"])[1]'',''VARCHAR(MAX)'') as [Typ towaru],
	dbo.f_getGroupLabel_tree(igm.itemGroupId,(SELECT xmlValue FROM configuration.Configuration WHERE [key] = ''items.group'')) as [Grupa towarowa],
	ia.textValue as [Producent],
	i.name as [Nazwa Towaru],
	l.quantity as [Ilość],
	l.netValue as [Wartość netto pozycji],
	l.grossValue as [Wartość brutto pozycji],
	CASE WHEN dt.documentCategory = 0 OR dt.documentCategory = 5 THEN ABS(ISNULL(cv.value,0)) * SIGN(l.quantity) ELSE NULL END as [Koszt pozycji],
	CASE WHEN dt.documentCategory = 0 OR dt.documentCategory = 5 THEN (l.netValue * h.exchangeRate)/h.exchangeScale - ABS(ISNULL(cv.value,0)) * SIGN(l.quantity) ELSE NULL END as [Marża netto pozycji],
	CASE WHEN dt.documentCategory = 0 OR dt.documentCategory = 5 THEN (l.grossValue * h.exchangeRate)/h.exchangeScale - ABS(ISNULL(cv.value,0)) * SIGN(l.quantity) ELSE NULL END as [Marża brutto pozycji],
	CASE WHEN l.netValue = 0 THEN 0 WHEN dt.documentCategory = 0 OR dt.documentCategory = 5 THEN ((l.netValue * h.exchangeRate)/h.exchangeScale - ABS(ISNULL(cv.value,0)) * SIGN(l.quantity))/l.netValue*100 ELSE NULL END as [Marża % pozycji],
	ISNULL(ISNULL(max_kred.decimalValue, cast(dbo.f_getContractorGroupAttribute(cgm.contractorGroupId, ''SalesLockAttribute_MaxDebtAmount'') as int)), maxdebt.textValue) as [Maksymalna wartość kredytu],
	ISNULL(ISNULL(max_dok.decimalValue, cast(dbo.f_getContractorGroupAttribute(cgm.contractorGroupId, ''SalesLockAttribute_MaxDocumentDebtAmount'') as int)), maxdoc.textValue) as [Maksymalna wartość dokumentu kredytowanego],
	ISNULL(ISNULL(max_przet.decimalValue, cast(dbo.f_getContractorGroupAttribute(cgm.contractorGroupId, ''SalesLockAttribute_MaxOverdueDays'') as int)), maxdays.textValue) as [Maksymalna ilość przeterminowanych dni],
	ISNULL(ISNULL(got.textValue, dbo.f_getContractorGroupAttribute(cgm.contractorGroupId, ''SalesLockAttribute_AllowCashPayment'')), replace(replace(cash.textValue,''true'',''1''),''false'',''0'')) as [Zawsze zezwalaj na płacenie gotówką],
	pay.[Forma Płatności],
	pay.[Termin płatności data],
	pay.[Termin płatności dnI],
	pay.[Rozliczone],
	pay.[Pozostało do rozliczenia],
	pay.[Dni po terminie],
	CASE WHEN pay.[Dni po terminie] > 0 AND pay.[Rozliczone] = ''NIE'' THEN ''TAK'' ELSE ''NIE'' END as [Przeterminowane]
from document.CommercialDocumentHeader h WITH(NOLOCK)
join dictionary.DocumentType dt WITH(NOLOCK) on dt.id = h.documentTypeId
join dictionary.Branch b WITH(NOLOCK) on b.id = h.branchId
left join contractor.Contractor c WITH(NOLOCK) on c.id = h.contractorId
left join contractor.ContractorGroupMembership cgm WITH(NOLOCK) on c.id = cgm.contractorId
left join contractor.ContractorAttrValue max_kred WITH(NOLOCK) on c.id = max_kred.contractorId and max_kred.contractorFieldId = ''BF58ECF1-D35B-400C-AFE8-D787CA8E6849''
left join contractor.ContractorAttrValue max_dok WITH(NOLOCK) on c.id = max_dok.contractorId and max_dok.contractorFieldId = ''00C6BE9B-97A3-464C-B599-7C6E4220639E''
left join contractor.ContractorAttrValue max_przet WITH(NOLOCK) on c.id = max_przet.contractorId and max_przet.contractorFieldId = ''974243A2-8895-4026-BD0E-6D979E858FF7''
left join contractor.ContractorAttrValue got WITH(NOLOCK) on c.id = got.contractorId and got.contractorFieldId = ''FDF5FDF6-3598-4194-B60F-BBD1EE2D9CAE''
left join (select  contractorId, dbo.[Concatenate](isnull(textValue,'''')) phone
			from contractor.ContractorAttrValue WITH(NOLOCK) 
			where contractorFieldId = ''D950E01D-5221-4711-96F2-A84F20435581''			
			group by contractorId) phone on c.id = phone.contractorId
left join document.CommercialDocumentLine l WITH(NOLOCK) on h.id = l.commercialDocumentHeaderId
left join item.item i WITH(NOLOCK) on l.itemId = i.id
left join dictionary.ItemType it WITH(NOLOCK) on i.itemTypeId = it.id
left join item.ItemGroupMembership igm WITH(NOLOCK) on i.id = igm.itemId
left join item.ItemAttrValue ia WITH(NOLOCK) on i.id = ia.itemId and ia.itemFieldId = ''9499C778-8324-49B3-A0AD-0810028283AC''
LEFT JOIN (SELECT SUM(ISNULL(ll.value,0)) value, v.commercialDocumentLineId 
			FROM document.CommercialWarehouseRelation v WITH(NOLOCK) 
			JOIN document.WarehouseDocumentLine ll WITH(NOLOCK) ON v.warehouseDocumentLineId = ll.id 
			Group by  v.commercialDocumentLineId ) cv ON l.id = cv.commercialDocumentLineId 
LEFT JOIN (SELECT SUM(ABS(ISNULL(cv.value,0)) * SIGN(ISNULL(cl.quantity,1))) value, cl.commercialDocumentHeaderId 
			FROM (SELECT SUM(ISNULL(ll.value,0)) value, v.commercialDocumentLineId 
			FROM document.CommercialWarehouseRelation v WITH(NOLOCK) 
			JOIN document.WarehouseDocumentLine ll WITH(NOLOCK) ON v.warehouseDocumentLineId = ll.id 
			Group by  v.commercialDocumentLineId ) cv 
			join document.CommercialDocumentLine cl WITH(NOLOCK) ON cv.commercialDocumentLineId = cl.id
			Group by cl.commercialDocumentHeaderId) cvs ON h.id = cvs.commercialDocumentHeaderId
left join (select dbo.[Concatenate](cast(pm.xmlLabels.value(''(/labels/label[@lang="pl"])[1]'',''varchar(100)'') as varchar(255))) as [Forma Płatności], 
			max(dueDate) as [Termin płatności data], 
			datediff(dd,max([date]),max(dueDate)) as [Termin płatności dni],
			case when sum(unsettledAmount) > 0 and sum(cast(isnull(requireSettlement,1) as int)) <> 0 then ''NIE'' else ''TAK'' END as [Rozliczone],
			sum(unsettledAmount) as [Pozostało do rozliczenia], 
			case when sum(unsettledAmount) > 0 then datediff(dd,max(dueDate),getdate()) else NULL END [Dni po terminie], 
			h.id
			from document.CommercialDocumentHeader h WITH(NOLOCK)
			join finance.Payment p WITH(NOLOCK) on h.id = p.commercialDocumentHeaderId
			join dictionary.PaymentMethod pm WITH(NOLOCK) on p.paymentMethodId = pm.id
			group by h.id) pay on h.id = pay.id	
left join (select textValue from configuration.Configuration where [key] = ''salesLock.maxDebtAmount'') maxdebt on 1 = 1	
left join (select textValue from configuration.Configuration where [key] = ''salesLock.maxDocumentDebtAmount'') maxdoc on 1 = 1	
left join (select textValue from configuration.Configuration where [key] = ''salesLock.maxOverdueDays'') maxdays on 1 = 1	
left join (select textValue from configuration.Configuration where [key] = ''salesLock.allowCashPayment'') cash on 1 = 1				
where h.status >= 40
union
select
	CASE dt.documentCategory WHEN 0 THEN ''Sprzedażowy'' WHEN 1 THEN ''Magazynowy'' WHEN 2 THEN ''Zakupowy''
	WHEN 3 THEN ''Rezerwacja'' WHEN 4 THEN ''Zamówienie'' WHEN 5 THEN ''Korekta sprzedaży''
	WHEN 6 THEN ''Korekta zakupu'' WHEN 7 THEN ''Korekta rozchodu'' WHEN 8 THEN ''Korekta przychodu''
	WHEN 9 THEN ''Finansowy'' WHEN 10 THEN ''Serwis'' WHEN 11 THEN ''Reklamacja''
	WHEN 12 THEN ''Inwentaryzacja'' WHEN 13 THEN ''Zamówienie sprzedażowe'' WHEN 14 THEN ''Technologia''
	WHEN 15 THEN ''Zlecenie produkcyjne'' WHEN 16 THEN ''Oferta'' ELSE '''' END as [Kategoria dokumentu],
	dt.symbol as [Typ dokumentu],
	dt.xmlLabels.value(''(/labels/label[@lang="pl"])[1]'',''VARCHAR(MAX)'') as [Typ dokumentu nazwa],
	b.symbol as [Numer oddziału],
	b.xmlLabels.value(''(/labels/label[@lang="pl"])[1]'',''VARCHAR(MAX)'') as [Nazwa oddziału],
	h.fullNumber as [Numer dokumentu],
	CONVERT(varchar(10), h.issueDate, 21) as [Data wystawienia],
	CONVERT(varchar(4), h.issueDate, 21) as [+Rok],
	CONVERT(varchar(7), h.issueDate, 21) as [Rok-Miesiąc],
	DATEPART(dd, h.issueDate) as [Dzień miesiaca],
	DATEPART(dw, h.issueDate) as [Dzień tygodnia],
	CAST(DATEPART(hh, h.issueDate) AS VARCHAR(2)) + '':'' + RIGHT(''0'' + CAST(DATEPART(mi, h.issueDate) AS VARCHAR(2)),2) as [Godzina:Minuta],
	CAST(DATEPART(hh, h.issueDate) AS VARCHAR(2)) as [Godzina],
	h.value as [Wartość netto],
	NULL as [Wartość VAT],
	NULL as [Wartość brutto],
	NULL as [Koszt dokumentu],
	NULL as [Marża netto dokumentu],
	NULL as [Marża brutto dokumentu],
	NULL as [Marża % dokumentu],
	h.issueDate as [Data i godzina],
	c.code as [Kod kontrahenta],
	c.shortName as [Nazwa kontrahenta],
	c.nip as [NIP],
	NULL as [Adres],
	isnull(phone.phone,'''') as [Telefon/y],
	dbo.f_getGroupLabel_mod(cgm.contractorGroupId,(SELECT xmlValue FROM configuration.Configuration WHERE [key] like ''contractors.group'')) as [Grupa kontrahenta],
	it.xmlLabels.value(''(/labels/label[@lang="pl"])[1]'',''VARCHAR(MAX)'') as [Typ towaru],
	dbo.f_getGroupLabel_tree(igm.itemGroupId,(SELECT xmlValue FROM configuration.Configuration WHERE [key] = ''items.group'')) as [Grupa towarowa],
	ia.textValue as [Producent],
	i.name as [Nazwa Towaru],
	l.quantity as [Ilość],
	l.value as [Wartość netto pozycji],
	NULL as [Wartość brutto pozycji],
	NULL as [Koszt pozycji],
	NULL as [Marża netto pozycji],
	NULL as [Marża brutto pozycji],
	NULL as [Marża % pozycji],
	ISNULL(ISNULL(max_kred.decimalValue, cast(dbo.f_getContractorGroupAttribute(cgm.contractorGroupId, ''SalesLockAttribute_MaxDebtAmount'') as int)), maxdebt.textValue) as [Maksymalna wartość kredytu],
	ISNULL(ISNULL(max_dok.decimalValue, cast(dbo.f_getContractorGroupAttribute(cgm.contractorGroupId, ''SalesLockAttribute_MaxDocumentDebtAmount'') as int)), maxdoc.textValue) as [Maksymalna wartość dokumentu kredytowanego],
	ISNULL(ISNULL(max_przet.decimalValue, cast(dbo.f_getContractorGroupAttribute(cgm.contractorGroupId, ''SalesLockAttribute_MaxOverdueDays'') as int)), maxdays.textValue) as [Maksymalna ilość przeterminowanych dni],
	ISNULL(ISNULL(got.textValue, dbo.f_getContractorGroupAttribute(cgm.contractorGroupId, ''SalesLockAttribute_AllowCashPayment'')), replace(replace(cash.textValue,''true'',''1''),''false'',''0'')) as [Zawsze zezwalaj na płacenie gotówką],
	NULL as [Forma Płatności],
	NULL as [Termin płatności data],
	NULL as [Termin płatności dnI],
	NULL as [Rozliczone],
	NULL as [Pozostało do rozliczenia],
	NULL as [Dni po terminie],
	NULL as [Przeterminowane]
from document.WarehouseDocumentHeader h WITH(NOLOCK)
join dictionary.DocumentType dt WITH(NOLOCK) on dt.id = h.documentTypeId
join dictionary.Branch b WITH(NOLOCK) on b.id = h.branchId
left join contractor.Contractor c WITH(NOLOCK) on c.id = h.contractorId
left join contractor.ContractorGroupMembership cgm WITH(NOLOCK) on c.id = cgm.contractorId
left join contractor.ContractorAttrValue max_kred WITH(NOLOCK) on c.id = max_kred.contractorId and max_kred.contractorFieldId = ''BF58ECF1-D35B-400C-AFE8-D787CA8E6849''
left join contractor.ContractorAttrValue max_dok WITH(NOLOCK) on c.id = max_dok.contractorId and max_dok.contractorFieldId = ''00C6BE9B-97A3-464C-B599-7C6E4220639E''
left join contractor.ContractorAttrValue max_przet WITH(NOLOCK) on c.id = max_przet.contractorId and max_przet.contractorFieldId = ''974243A2-8895-4026-BD0E-6D979E858FF7''
left join contractor.ContractorAttrValue got WITH(NOLOCK) on c.id = got.contractorId and got.contractorFieldId = ''FDF5FDF6-3598-4194-B60F-BBD1EE2D9CAE''
left join (select  contractorId, dbo.[Concatenate](isnull(textValue,'''')) phone
			from contractor.ContractorAttrValue WITH(NOLOCK) 
			where contractorFieldId = ''D950E01D-5221-4711-96F2-A84F20435581''			
			group by contractorId) phone on c.id = phone.contractorId
left join document.WarehouseDocumentLine l WITH(NOLOCK) on h.id = l.warehouseDocumentHeaderId
left join item.item i WITH(NOLOCK) on l.itemId = i.id
left join dictionary.ItemType it WITH(NOLOCK) on i.itemTypeId = it.id
left join item.ItemGroupMembership igm WITH(NOLOCK) on i.id = igm.itemId
left join item.ItemAttrValue ia WITH(NOLOCK) on i.id = ia.itemId and ia.itemFieldId = ''9499C778-8324-49B3-A0AD-0810028283AC''
left join (select textValue from configuration.Configuration where [key] = ''salesLock.maxDebtAmount'') maxdebt on 1 = 1	
left join (select textValue from configuration.Configuration where [key] = ''salesLock.maxDocumentDebtAmount'') maxdoc on 1 = 1	
left join (select textValue from configuration.Configuration where [key] = ''salesLock.maxOverdueDays'') maxdays on 1 = 1	
left join (select textValue from configuration.Configuration where [key] = ''salesLock.allowCashPayment'') cash on 1 = 1	
where h.status >= 40
union
select
	CASE dt.documentCategory WHEN 0 THEN ''Sprzedażowy'' WHEN 1 THEN ''Magazynowy'' WHEN 2 THEN ''Zakupowy''
	WHEN 3 THEN ''Rezerwacja'' WHEN 4 THEN ''Zamówienie'' WHEN 5 THEN ''Korekta sprzedaży''
	WHEN 6 THEN ''Korekta zakupu'' WHEN 7 THEN ''Korekta rozchodu'' WHEN 8 THEN ''Korekta przychodu''
	WHEN 9 THEN ''Finansowy'' WHEN 10 THEN ''Serwis'' WHEN 11 THEN ''Reklamacja''
	WHEN 12 THEN ''Inwentaryzacja'' WHEN 13 THEN ''Zamówienie sprzedażowe'' WHEN 14 THEN ''Technologia''
	WHEN 15 THEN ''Zlecenie produkcyjne'' WHEN 16 THEN ''Oferta'' ELSE '''' END as [Kategoria dokumentu],
	dt.symbol as [Typ dokumentu],
	dt.xmlLabels.value(''(/labels/label[@lang="pl"])[1]'',''VARCHAR(MAX)'') as [Typ dokumentu nazwa],
	b.symbol as [Numer oddziału],
	b.xmlLabels.value(''(/labels/label[@lang="pl"])[1]'',''VARCHAR(MAX)'') as [Nazwa oddziału],
	h.fullNumber as [Numer dokumentu],
	CONVERT(varchar(10), h.issueDate, 21) as [Data wystawienia],
	CONVERT(varchar(4), h.issueDate, 21) as [+Rok],
	CONVERT(varchar(7), h.issueDate, 21) as [Rok-Miesiąc],
	DATEPART(dd, h.issueDate) as [Dzień miesiaca],
	DATEPART(dw, h.issueDate) as [Dzień tygodnia],
	CAST(DATEPART(hh, h.issueDate) AS VARCHAR(2)) + '':'' + RIGHT(''0'' + CAST(DATEPART(mi, h.issueDate) AS VARCHAR(2)),2) as [Godzina:Minuta],
	CAST(DATEPART(hh, h.issueDate) AS VARCHAR(2)) as [Godzina],
	NULL as [Wartość netto],
	NULL as [Wartość VAT],
	h.amount as [Wartość brutto],
	NULL as [Koszt dokumentu],
	NULL as [Marża netto dokumentu],
	NULL as [Marża brutto dokumentu],
	NULL as [Marża % dokumentu],
	h.issueDate as [Data i godzina],
	c.code as [Kod kontrahenta],
	c.shortName as [Nazwa kontrahenta],
	c.nip as [NIP],
	isnull(ca.city + '', '','''') + isnull(ca.postCode,'''') + '' '' + isnull(ca.[address],'''') + '' '' + isnull(ca.addressNumber,'''') + '' '' + isnull(ca.flatNumber,'''') as [Adres],
	isnull(phone.phone,'''') as [Telefon/y],
	dbo.f_getGroupLabel_mod(cgm.contractorGroupId,(SELECT xmlValue FROM configuration.Configuration WHERE [key] like ''contractors.group'')) as [Grupa kontrahenta],
	NULL as [Typ towaru],
	NULL as [Grupa towarowa],
	NULL as [Producent],
	NULL as [Nazwa Towaru],
	NULL as [Ilość],
	NULL as [Wartość netto pozycji],
	NULL as [Wartość brutto pozycji],
	NULL as [Koszt pozycji],
	NULL as [Marża netto pozycji],
	NULL as [Marża brutto pozycji],
	NULL as [Marża % pozycji],
	ISNULL(ISNULL(max_kred.decimalValue, cast(dbo.f_getContractorGroupAttribute(cgm.contractorGroupId, ''SalesLockAttribute_MaxDebtAmount'') as int)), maxdebt.textValue) as [Maksymalna wartość kredytu],
	ISNULL(ISNULL(max_dok.decimalValue, cast(dbo.f_getContractorGroupAttribute(cgm.contractorGroupId, ''SalesLockAttribute_MaxDocumentDebtAmount'') as int)), maxdoc.textValue) as [Maksymalna wartość dokumentu kredytowanego],
	ISNULL(ISNULL(max_przet.decimalValue, cast(dbo.f_getContractorGroupAttribute(cgm.contractorGroupId, ''SalesLockAttribute_MaxOverdueDays'') as int)), maxdays.textValue) as [Maksymalna ilość przeterminowanych dni],
	ISNULL(ISNULL(got.textValue, dbo.f_getContractorGroupAttribute(cgm.contractorGroupId, ''SalesLockAttribute_AllowCashPayment'')), replace(replace(cash.textValue,''true'',''1''),''false'',''0'')) as [Zawsze zezwalaj na płacenie gotówką],
	pay.[Forma Płatności],
	pay.[Termin płatności data],
	pay.[Termin płatności dnI],
	pay.[Rozliczone],
	pay.[Pozostało do rozliczenia],
	NULL as [Dni po terminie],
	NULL as [Przeterminowane]
from document.FinancialDocumentHeader h WITH(NOLOCK)
join dictionary.DocumentType dt WITH(NOLOCK) on dt.id = h.documentTypeId
join dictionary.Branch b WITH(NOLOCK) on b.id = h.branchId
left join contractor.Contractor c WITH(NOLOCK) on c.id = h.contractorId
left join contractor.ContractorGroupMembership cgm WITH(NOLOCK) on c.id = cgm.contractorId
left join contractor.ContractorAttrValue max_kred WITH(NOLOCK) on c.id = max_kred.contractorId and max_kred.contractorFieldId = ''BF58ECF1-D35B-400C-AFE8-D787CA8E6849''
left join contractor.ContractorAttrValue max_dok WITH(NOLOCK) on c.id = max_dok.contractorId and max_dok.contractorFieldId = ''00C6BE9B-97A3-464C-B599-7C6E4220639E''
left join contractor.ContractorAttrValue max_przet WITH(NOLOCK) on c.id = max_przet.contractorId and max_przet.contractorFieldId = ''974243A2-8895-4026-BD0E-6D979E858FF7''
left join contractor.ContractorAttrValue got WITH(NOLOCK) on c.id = got.contractorId and got.contractorFieldId = ''FDF5FDF6-3598-4194-B60F-BBD1EE2D9CAE''
left join (select  contractorId, dbo.[Concatenate](isnull(textValue,'''')) phone
			from contractor.ContractorAttrValue WITH(NOLOCK) 
			where contractorFieldId = ''D950E01D-5221-4711-96F2-A84F20435581''			
			group by contractorId) phone on c.id = phone.contractorId
left join contractor.ContractorAddress ca WITH(NOLOCK) on c.id = ca.contractorId
left join (select dbo.[Concatenate](cast(pm.xmlLabels.value(''(/labels/label[@lang="pl"])[1]'',''varchar(100)'') as varchar(255))) as [Forma Płatności], 
			max(dueDate) as [Termin płatności data], 
			datediff(dd,max([date]),max(dueDate)) as [Termin płatności dni],
			case when sum(unsettledAmount) > 0 and sum(cast(isnull(requireSettlement,1) as int)) <> 0 then ''NIE'' else ''TAK'' END as [Rozliczone],
			sum(unsettledAmount) as [Pozostało do rozliczenia], 
			case when sum(unsettledAmount) > 0 then datediff(dd,max(dueDate),getdate()) else NULL END [Dni po terminie], 
			h.id
			from document.FinancialDocumentHeader h WITH(NOLOCK)
			join finance.Payment p WITH(NOLOCK) on h.id = p.financialDocumentHeaderId
			join dictionary.PaymentMethod pm WITH(NOLOCK) on p.paymentMethodId = pm.id
			group by h.id) pay on h.id = pay.id
left join (select textValue from configuration.Configuration where [key] = ''salesLock.maxDebtAmount'') maxdebt on 1 = 1	
left join (select textValue from configuration.Configuration where [key] = ''salesLock.maxDocumentDebtAmount'') maxdoc on 1 = 1	
left join (select textValue from configuration.Configuration where [key] = ''salesLock.maxOverdueDays'') maxdays on 1 = 1	
left join (select textValue from configuration.Configuration where [key] = ''salesLock.allowCashPayment'') cash on 1 = 1	
where h.status >= 40
' 
GO

/*
name=[translation].[p_translateF1Dictionaries]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
c10uMMrku7kcEerkh4vouA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_translateF1Dictionaries]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_translateF1Dictionaries]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_translateF1Dictionaries]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_translateF1Dictionaries] @serverName VARCHAR(50), @dbName VARCHAR(50), @translationServer VARCHAR(50), @dbTranslation VARCHAR(50) AS
BEGIN
	DECLARE @databaseId varchar(50), 
			@documentCurrencyId varchar(50), 
			@countryId varchar(50),
			@issuePlaceId varchar(50),
			@unitId varchar(50),
			@vatRateId varchar(50),
			@sql nvarchar(1500)
	
	delete from journal.Journal
	--delete from journal.JournalAction
	delete from finance.PaymentSettlement
	delete from finance.Payment
	delete from document.CommercialDocumentVatTable
	delete from document.FinancialDocumentHeader
	delete from finance.FinancialReport
	delete from contractor.Employee
	delete from contractor.ContractorAddress where contractorId not in (select top 1 contractorId from dictionary.Company) and id NOT IN (select top 1 contractorId from contractor.ApplicationUser where login = ''xxx'')
	delete from contractor.ContractorRelation
	delete from contractor.ContractorAccount
	delete from contractor.ContractorAttrValue
	delete from contractor.ContractorDictionaryRelation
	delete from contractor.ContractorDictionary
	delete from contractor.ContractorGroupMembership
	delete from contractor.Bank
	delete from contractor.ApplicationUser where login <> ''xxx''
	delete from contractor.Contractor where id NOT IN (select top 1 contractorId from dictionary.Company) and id NOT IN (select top 1 contractorId from contractor.ApplicationUser where login = ''xxx'')
	delete from dbo.ContractorImportRelation
	delete from dictionary.FinancialRegister
	delete from item.ItemUnitRelation
	delete from item.ItemDictionaryRelation
	delete from item.ItemDictionary
	delete from item.ItemGroupMembership
	delete from item.ItemRelationAttrValue
	delete from item.ItemRelation
	delete from item.ItemAttrValue
	delete from item.Item
	delete from dbo.ItemImportRelation
	delete from dictionary.Warehouse
	delete from dictionary.IssuePlace
	delete from translation.Kontrahent
	delete from translation.Towary
	delete from translation.Adres
	delete from translation.Punkty
	delete from translation.BranchAttributes
	delete from dictionary.ItemType WHERE [name] NOT IN (''Good'',''Service'')

	exec [translation].[p_insertCountry] @serverName,@dbName,@translationServer,@dbTranslation 
	exec [translation].[p_insertCurrency] @serverName,@dbName
	exec [translation].[p_insertPaymentMethod] @serverName,@dbName
	exec [translation].[p_insertUnit] @serverName,@dbName
	exec [translation].[p_insertVatRate] @serverName,@dbName
	exec [translation].[p_insertCompany] @serverName,@dbName /* tylko update dla dictionary.Company */
	exec [translation].[p_insertBranch] @serverName,@dbName
	exec [translation].[p_insertIssuePlace] @serverName,@dbName
	exec [translation].[p_insertWarehouse] @serverName,@dbName
	exec [translation].[p_insertGroup] @serverName,@dbName,@translationServer,@dbTranslation 
	exec [translation].[p_insertItemType] @serverName,@dbName
	
	exec [translation].[p_insertContractorField] ''Attribute_Code'',''Kod'',''Code''
	exec [translation].[p_insertContractorField] ''Attribute_Blocked'',''Zablokowany'',''Blocked''
	--exec [translation].[p_insertContractorField] ''Attribute_REGON'',''REGON'',''REGON''
	
	exec [translation].[p_insertItemField] ''Attribute_VAT'',''VAT'',''VAT''
	exec [translation].[p_insertItemField] ''Attribute_Package'',''Opakowanie'',''Package''
	exec [translation].[p_insertItemField] ''Attribute_FCode'',''fKod'',''fCode''

	UPDATE configuration.Configuration SET textValue = (SELECT TOP 1 contractorId FROM dictionary.Company) WHERE [key] = ''document.defaults.issuerId''
	UPDATE configuration.Configuration SET textValue = (SELECT TOP 1 id FROM dictionary.IssuePlace) WHERE [key] = ''document.defaults.issuePlaceId''
	UPDATE configuration.Configuration SET textValue = (SELECT id FROM dictionary.Currency WHERE symbol = ''PLN'') WHERE [key] = ''document.defaults.systemCurrencyId''
	UPDATE configuration.Configuration SET textValue = ''true'' WHERE [key] = ''system.isHeadquarter''
	UPDATE configuration.Configuration SET textValue = ''false'' WHERE [key] = ''warehouse.isWMSenabled''
	UPDATE configuration.Configuration SET textValue = ''true'' WHERE [key] = ''document.validation.blockInvaluatedOutcomes''

	SELECT @sql = ''UPDATE contractor.Contractor SET 
	fullName = (SELECT nazwa FROM [''+@serverName+''].''+@dbName+''.dbo.Dane_Firmy),
	shortName = (SELECT nazwaPelna FROM [''+@serverName+''].''+@dbName+''.dbo.Dane_Firmy),
	nip = (SELECT nip FROM [''+@serverName+''].''+@dbName+''.dbo.Dane_Firmy),
	strippedNip = REPLACE(REPLACE(NULLIF((SELECT nip FROM [''+@serverName+''].''+@dbName+''.dbo.Dane_Firmy),''''''''), ''''-'''', ''''''''), '''' '''', '''''''')
	WHERE id in (select top 1 contractorId from dictionary.Company)''
	EXEC sp_executesql @sql

	SELECT @sql = ''UPDATE contractor.ContractorAddress SET 
	city = (SELECT miasto FROM [''+@serverName+''].''+@dbName+''.dbo.Dane_Firmy),
	postCode = (SELECT kod_pocztowy FROM [''+@serverName+''].''+@dbName+''.dbo.Dane_Firmy),
	address = (SELECT ulica + '''' '''' + nr_domu FROM [''+@serverName+''].''+@dbName+''.dbo.Dane_Firmy)
	WHERE contractorId in (select top 1 contractorId from dictionary.Company)''	
	EXEC sp_executesql @sql

	SELECT @databaseId = databaseId FROM dictionary.Branch WHERE [order] = 0
	SELECT @documentCurrencyId = id FROM dictionary.Currency WHERE symbol = ''PLN''
	SELECT @countryId = id FROM dictionary.Country WHERE xmlLabels.value(''(//labels/label)[1]'', ''nvarchar(max)'') = ''Polska''
	SELECT @issuePlaceId = textValue FROM configuration.Configuration WHERE [key] = ''document.defaults.issuePlaceId''
	SELECT @unitId = id FROM dictionary.Unit WHERE [order] = 1
	
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.WarehouseDocument.correctiveExternalOutcome''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/warehouseDocument[1]'') WHERE [key] = ''templates.WarehouseDocument.correctiveExternalOutcome''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.CommercialDocument.bill''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.bill''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //countryId'') WHERE [key] = ''templates.Contractor.businessEntity''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //nipPrefixCountryId'') WHERE [key] = ''templates.Contractor.businessEntity''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <countryId>{xs:string(sql:variable("@countryId"))}</countryId> as first into /root[1]/contractor[1]/addresses[1]/address[1]'') WHERE [key] = ''templates.Contractor.businessEntity''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <nipPrefixCountryId>{xs:string(sql:variable("@countryId"))}</nipPrefixCountryId> as first into /root[1]/contractor[1]'') WHERE [key] = ''templates.Contractor.businessEntity''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.WarehouseDocument.internalOutcome''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/warehouseDocument[1]'') WHERE [key] = ''templates.WarehouseDocument.internalOutcome''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.CommercialDocument.correctiveSalesInvoice''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/commericalDocument[1]'') WHERE [key] = ''templates.CommercialDocument.correctiveSalesInvoice''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //issuePlaceId'') WHERE [key] = ''templates.CommercialDocument.correctiveSalesInvoice''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <issuePlaceId>{xs:string(sql:variable("@issuePlaceId"))}</issuePlaceId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.correctiveSalesInvoice''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.CommercialDocument.correctivePurchaseInvoice''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/commericalDocument[1]'') WHERE [key] = ''templates.CommercialDocument.correctivePurchaseInvoice''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //issuePlaceId'') WHERE [key] = ''templates.CommercialDocument.correctivePurchaseInvoice''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <issuePlaceId>{xs:string(sql:variable("@issuePlaceId"))}</issuePlaceId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.correctivePurchaseInvoice''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.WarehouseDocument.correctiveExternalIncome''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/warehouseDocument[1]'') WHERE [key] = ''templates.WarehouseDocument.correctiveExternalIncome''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.CommercialDocument.invoice''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.invoice''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //issuePlaceId'') WHERE [key] = ''templates.CommercialDocument.invoice''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <issuePlaceId>{xs:string(sql:variable("@issuePlaceId"))}</issuePlaceId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.invoice''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.WarehouseDocument.externalOutcome''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/warehouseDocument[1]'') WHERE [key] = ''templates.WarehouseDocument.externalOutcome''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.FinancialDocument.cashIncome''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/financialDocument[1]'') WHERE [key] = ''templates.FinancialDocument.cashIncome''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //systemCurrencyId'') WHERE [key] = ''templates.FinancialDocument.cashIncome''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <systemCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</systemCurrencyId> as first into /root[1]/financialDocument[1]'') WHERE [key] = ''templates.FinancialDocument.cashIncome''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.CommercialDocument.order''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.order''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //issuePlaceId'') WHERE [key] = ''templates.CommercialDocument.order''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <issuePlaceId>{xs:string(sql:variable("@issuePlaceId"))}</issuePlaceId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.order''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.FinancialDocument.cashOutcome''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/financialDocument[1]'') WHERE [key] = ''templates.FinancialDocument.cashOutcome''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //systemCurrencyId'') WHERE [key] = ''templates.FinancialDocument.cashOutcome''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <systemCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</systemCurrencyId> as first into /root[1]/financialDocument[1]'') WHERE [key] = ''templates.FinancialDocument.cashOutcome''
	SELECT @vatRateId = id FROM dictionary.VatRate WHERE [symbol] = ''0''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //unitId'') WHERE [key] = ''templates.Item.service''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <unitId>{xs:string(sql:variable("@unitId"))}</unitId> as first into /root[1]/item[1]'') WHERE [key] = ''templates.Item.service''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //vatRateId'') WHERE [key] = ''templates.Item.service''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <vatRateId>{xs:string(sql:variable("@vatRateId"))}</vatRateId> as first into /root[1]/item[1]'') WHERE [key] = ''templates.Item.service''
	SELECT @vatRateId = id FROM dictionary.VatRate WHERE [symbol] = ''22''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //unitId'') WHERE [key] = ''templates.Item.good''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <unitId>{xs:string(sql:variable("@unitId"))}</unitId> as first into /root[1]/item[1]'') WHERE [key] = ''templates.Item.good''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //vatRateId'') WHERE [key] = ''templates.Item.good''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <vatRateId>{xs:string(sql:variable("@vatRateId"))}</vatRateId> as first into /root[1]/item[1]'') WHERE [key] = ''templates.Item.good''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //nipPrefixCountryId'') WHERE [key] = ''templates.Contractor.person''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <nipPrefixCountryId>{xs:string(sql:variable("@countryId"))}</nipPrefixCountryId> as first into /root[1]/contractor[1]'') WHERE [key] = ''templates.Contractor.person''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.CommercialDocument.correctiveBill''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.correctiveBill''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //issuePlaceId'') WHERE [key] = ''templates.CommercialDocument.correctiveBill''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <issuePlaceId>{xs:string(sql:variable("@issuePlaceId"))}</issuePlaceId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.correctiveBill''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.FinancialDocument.bankIncome''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/financialDocument[1]'') WHERE [key] = ''templates.FinancialDocument.bankIncome''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //systemCurrencyId'') WHERE [key] = ''templates.FinancialDocument.bankIncome''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <systemCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</systemCurrencyId> as first into /root[1]/financialDocument[1]'') WHERE [key] = ''templates.FinancialDocument.bankIncome''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.CommercialDocument.purchaseInvoice''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.purchaseInvoice''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //issuePlaceId'') WHERE [key] = ''templates.CommercialDocument.purchaseInvoice''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <issuePlaceId>{xs:string(sql:variable("@issuePlaceId"))}</issuePlaceId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.purchaseInvoice''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.WarehouseDocument.internalIncome''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/warehouseDocument[1]'') WHERE [key] = ''templates.WarehouseDocument.internalIncome''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.CommercialDocument.reservation''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.reservation''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //issuePlaceId'') WHERE [key] = ''templates.CommercialDocument.reservation''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <issuePlaceId>{xs:string(sql:variable("@issuePlaceId"))}</issuePlaceId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.reservation''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.WarehouseDocument.outcomeShift''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/warehouseDocument[1]'') WHERE [key] = ''templates.WarehouseDocument.outcomeShift''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.FinancialDocument.bankOutcome''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/financialDocument[1]'') WHERE [key] = ''templates.FinancialDocument.bankOutcome''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //systemCurrencyId'') WHERE [key] = ''templates.FinancialDocument.bankOutcome''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <systemCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</systemCurrencyId> as first into /root[1]/financialDocument[1]'') WHERE [key] = ''templates.FinancialDocument.bankOutcome''
	UPDATE configuration.Configuration SET xmlValue.modify(''delete //documentCurrencyId'') WHERE [key] = ''templates.WarehouseDocument.externalIncome''
	UPDATE configuration.Configuration SET xmlValue.modify(''insert <documentCurrencyId>{xs:string(sql:variable("@documentCurrencyId"))}</documentCurrencyId> as first into /root[1]/warehouseDocument[1]'') WHERE [key] = ''templates.WarehouseDocument.externalIncome''

	IF (EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ''OutgoingXmlQueue'' AND COLUMN_NAME = ''databaseId'' AND COLUMN_DEFAULT IS NOT NULL))
	ALTER TABLE communication.OutgoingXmlQueue DROP CONSTRAINT DF_OutgoingXmlQueue_databaseId
	SELECT @sql = N''ALTER TABLE communication.OutgoingXmlQueue ADD CONSTRAINT
	DF_OutgoingXmlQueue_databaseId DEFAULT ('''''' + CAST(@databaseId AS varchar(50)) + '''''') FOR databaseId''
	EXEC(@sql)
END
' 
END
GO

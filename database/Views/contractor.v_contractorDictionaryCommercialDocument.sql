/*
name=[contractor].[v_contractorDictionaryCommercialDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
63tgsmRGP5Q0006Nlk/3qg==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorDictionaryCommercialDocument]'))
DROP VIEW [contractor].[v_contractorDictionaryCommercialDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorDictionaryCommercialDocument]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [contractor].[v_contractorDictionaryCommercialDocument] WITH SCHEMABINDING AS
SELECT   COUNT_BIG(*) counter, [contractor].ContractorDictionary.field,[contractor].ContractorDictionary.id, h.id commercialDocumentHeaderId
FROM         [contractor].ContractorDictionary 
	INNER JOIN [contractor].ContractorDictionaryRelation ON [contractor].ContractorDictionary.id = [contractor].ContractorDictionaryRelation.contractorDictionaryId
	JOIN [document].CommercialDocumentHeader h 
			ON	[contractor].ContractorDictionaryRelation.contractorId = h.contractorId
			OR  [contractor].ContractorDictionaryRelation.contractorId = h.receivingPersonContractorId
			--OR  [contractor].ContractorDictionaryRelation.contractorId = h.issuingPersonContractorId
			--OR  [contractor].ContractorDictionaryRelation.contractorId = h.issuerContractorId
GROUP BY [contractor].ContractorDictionary.field, h.id, [contractor].ContractorDictionary.id
' 
GO

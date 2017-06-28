/*
name=[contractor].[v_contractorDictionaryFinancialDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
BGqlBUEn8fIS4Co/2kNxWg==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorDictionaryFinancialDocument]'))
DROP VIEW [contractor].[v_contractorDictionaryFinancialDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorDictionaryFinancialDocument]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [contractor].[v_contractorDictionaryFinancialDocument] WITH SCHEMABINDING AS
SELECT   COUNT_BIG(*) counter, [contractor].ContractorDictionary.field,[contractor].ContractorDictionary.id, h.id financialDocumentHeaderId
FROM         [contractor].ContractorDictionary 
	INNER JOIN [contractor].ContractorDictionaryRelation ON [contractor].ContractorDictionary.id = [contractor].ContractorDictionaryRelation.contractorDictionaryId
	JOIN [document].FinancialDocumentHeader h 
			ON	[contractor].ContractorDictionaryRelation.contractorId = h.contractorId
GROUP BY [contractor].ContractorDictionary.field, h.id, [contractor].ContractorDictionary.id
' 
GO

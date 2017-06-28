/*
name=[contractor].[v_contractorDictionaryComplaintDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
PIkcHRdm1ZM/LSEkqvkEMw==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorDictionaryComplaintDocument]'))
DROP VIEW [contractor].[v_contractorDictionaryComplaintDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorDictionaryComplaintDocument]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [contractor].[v_contractorDictionaryComplaintDocument] WITH SCHEMABINDING AS
SELECT   COUNT_BIG(*) counter, [contractor].ContractorDictionary.field,[contractor].ContractorDictionary.id, h.id complaintDocumentHeaderId
FROM         [contractor].ContractorDictionary 
	INNER JOIN [contractor].ContractorDictionaryRelation ON [contractor].ContractorDictionary.id = [contractor].ContractorDictionaryRelation.contractorDictionaryId
	JOIN [complaint].ComplaintDocumentHeader h 
			ON	[contractor].ContractorDictionaryRelation.contractorId = h.contractorId
			OR  [contractor].ContractorDictionaryRelation.contractorId = h.issuerContractorId
GROUP BY [contractor].ContractorDictionary.field, h.id, [contractor].ContractorDictionary.id
' 
GO

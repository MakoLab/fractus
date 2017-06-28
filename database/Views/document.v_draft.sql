/*
name=[document].[v_draft]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
HfjDb3puvBtUiDThzEO8yA==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[document].[v_draft]'))
DROP VIEW [document].[v_draft]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[document].[v_draft]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [document].[v_draft] WITH SCHEMABINDING AS
SELECT   COUNT_BIG(*) counter, [contractor].ContractorDictionary.field,[contractor].ContractorDictionary.id, h.id draftId
FROM         [contractor].ContractorDictionary 
	INNER JOIN [contractor].ContractorDictionaryRelation ON [contractor].ContractorDictionary.id = [contractor].ContractorDictionaryRelation.contractorDictionaryId
	JOIN [document].Draft h 
			ON	[contractor].ContractorDictionaryRelation.contractorId = h.contractorId
GROUP BY [contractor].ContractorDictionary.field, h.id, [contractor].ContractorDictionary.id
' 
GO

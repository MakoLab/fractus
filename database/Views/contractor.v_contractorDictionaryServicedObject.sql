/*
name=[contractor].[v_contractorDictionaryServicedObject]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Bhx/CbQjdplGGWtAxWPsFg==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorDictionaryServicedObject]'))
DROP VIEW [contractor].[v_contractorDictionaryServicedObject]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorDictionaryServicedObject]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [contractor].[v_contractorDictionaryServicedObject]
WITH SCHEMABINDING
AS
SELECT   COUNT_BIG(*) counter, [contractor].ContractorDictionary.field,[contractor].ContractorDictionary.id, s.id servicedObjectId
FROM         [contractor].ContractorDictionary 
	INNER JOIN [contractor].ContractorDictionaryRelation ON [contractor].ContractorDictionary.id = [contractor].ContractorDictionaryRelation.contractorDictionaryId
	JOIN [service].ServicedObject s ON	[contractor].ContractorDictionaryRelation.contractorId = s.ownerContractorId
GROUP BY [contractor].ContractorDictionary.field, s.id, [contractor].ContractorDictionary.id;
' 
GO

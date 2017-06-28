/*
name=[contractor].[v_contractorDictionaryWarehouseDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
QyAHMWSi82VgPRLnoAcAVw==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorDictionaryWarehouseDocument]'))
DROP VIEW [contractor].[v_contractorDictionaryWarehouseDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorDictionaryWarehouseDocument]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [contractor].[v_contractorDictionaryWarehouseDocument] WITH SCHEMABINDING AS
SELECT   COUNT_BIG(*) counter, [contractor].ContractorDictionary.field,[contractor].ContractorDictionary.id, h.id warehouseDocumentHeaderId
FROM         [contractor].ContractorDictionary 
	INNER JOIN [contractor].ContractorDictionaryRelation ON [contractor].ContractorDictionary.id = [contractor].ContractorDictionaryRelation.contractorDictionaryId
	JOIN [document].WarehouseDocumentHeader h ON  [contractor].ContractorDictionaryRelation.contractorId = h.contractorId
GROUP BY [contractor].ContractorDictionary.field, h.id, [contractor].ContractorDictionary.id
' 
GO

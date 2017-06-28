/*
name=[contractor].[v_contractorDictionary]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
1QsJMD+Vmr/ecXK4Lt94Ww==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorDictionary]'))
DROP VIEW [contractor].[v_contractorDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorDictionary]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [contractor].[v_contractorDictionary] WITH SCHEMABINDING AS


SELECT   COUNT_BIG(*) counter, [contractor].ContractorDictionary.field,[contractor].ContractorDictionary.id, [contractor].ContractorDictionaryRelation.contractorId
FROM         [contractor].ContractorDictionary INNER JOIN
                      [contractor].ContractorDictionaryRelation ON 
                      [contractor].ContractorDictionary.id = [contractor].ContractorDictionaryRelation.contractorDictionaryId
GROUP BY [contractor].ContractorDictionary.field, [contractor].ContractorDictionaryRelation.contractorId, [contractor].ContractorDictionary.id' 
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorDictionary]') AND name = N'ind_vContractorDictionary')
CREATE UNIQUE CLUSTERED INDEX [ind_vContractorDictionary] ON [contractor].[v_contractorDictionary]
(
	[field] ASC,
	[contractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

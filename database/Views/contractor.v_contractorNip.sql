/*
name=[contractor].[v_contractorNip]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
P2TxBTBx8pxBbEc68QgnUA==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorNip]'))
DROP VIEW [contractor].[v_contractorNip]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorNip]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [contractor].[v_contractorNip] WITH SCHEMABINDING AS
SELECT   COUNT_BIG(*) counter, [contractor].Contractor.id contractorId, [contractor].Contractor.strippedNip field
FROM         [contractor].Contractor
GROUP BY [contractor].Contractor.id, [contractor].Contractor.strippedNip
' 
GO

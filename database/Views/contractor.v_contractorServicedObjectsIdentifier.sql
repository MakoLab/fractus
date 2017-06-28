/*
name=[contractor].[v_contractorServicedObjectsIdentifier]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JYDd9uxNnPj9Hy1hdicCxA==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorServicedObjectsIdentifier]'))
DROP VIEW [contractor].[v_contractorServicedObjectsIdentifier]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorServicedObjectsIdentifier]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [contractor].[v_contractorServicedObjectsIdentifier]
WITH SCHEMABINDING
AS
SELECT   COUNT_BIG(*) counter, c.id contractorId, s.id servicedObjectId, s.identifier field
FROM [contractor].Contractor c
	JOIN [service].ServicedObject s ON c.id = s.ownerContractorId
GROUP BY  c.id , s.id, s.identifier ;
' 
GO

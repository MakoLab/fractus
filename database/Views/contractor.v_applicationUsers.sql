/*
name=[contractor].[v_applicationUsers]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
IwnSUl1i8qDggtz5drtFkA==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_applicationUsers]'))
DROP VIEW [contractor].[v_applicationUsers]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_applicationUsers]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [contractor].[v_applicationUsers]  WITH SCHEMABINDING AS
SELECT  COUNT_BIG(*) counter, id, login, code ,shortName, permissionProfile,  isActive, restrictDatabaseId
FROM      contractor.ApplicationUser au 
	JOIN contractor.Contractor c  ON au.contractorId = c.id
GROUP BY  id, login, code ,shortName, permissionProfile,[password],restrictDatabaseId,isActive
' 
GO

/*
name=[service].[v_servicedObjects]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ETBiDBUCB4iGUuq0lI/Srw==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[service].[v_servicedObjects]'))
DROP VIEW [service].[v_servicedObjects]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[service].[v_servicedObjects]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [service].[v_servicedObjects]
WITH SCHEMABINDING
AS
 
SELECT  COUNT_BIG(*) counter,field , servicedObjectId
FROM (
	SELECT  ServicedObject.identifier field , id servicedObjectId
	FROM  [service].ServicedObject  
	UNION
	SELECT   ServicedObject.[description] field, id servicedObjectId
	FROM  [service].ServicedObject 
	) x 
GROUP BY field , servicedObjectId
' 
GO

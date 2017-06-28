/*
name=[dbo].[v_confPermission]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
cECai77LdbrtiQ6FB8En6g==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_confPermission]'))
DROP VIEW [dbo].[v_confPermission]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_confPermission]'))
EXEC dbo.sp_executesql @statement = N'
create VIEW v_confPermission
AS
SELECT  *
FROM    [configuration].[Configuration] 
WHERE [key] like ''permissions.%''
' 
GO

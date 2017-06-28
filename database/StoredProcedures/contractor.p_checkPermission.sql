/*
name=[contractor].[p_checkPermission]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
n4vwUt1JvHbCxrcEyU8iMQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_checkPermission]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_checkPermission]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_checkPermission]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N' CREATE PROCEDURE [contractor].[p_checkPermission] @xmlVar XML
 AS
 BEGIN
 DECLARE @password nvarchar(256), @key nvarchar(500)
 SELECT @password = @xmlVar.value(''(root/@password)[1]'',''varchar(500)'')
	IF EXISTS(  SELECT * 
				FROM  configuration.Configuration 
				WHERE [key] in (SELECT ''permissions.profiles.'' +permissionProfile FROM contractor.ApplicationUser WHERE [password] = @password) 
					AND xmlValue.value(''(profile/permissions/permission[@key="administration.permissions.authorization"]/@level)[1]'',''varchar(50)'') = ''2''
					)
		SELECT CAST(''<root>true</root>'' as XML)
	ELSE
		SELECT CAST(''<root>false</root>'' as XML)
 END
' 
END
GO

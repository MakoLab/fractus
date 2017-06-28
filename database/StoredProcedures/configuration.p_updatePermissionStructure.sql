/*
name=[configuration].[p_updatePermissionStructure]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
cCywOd7gHnqS9kjb9WzBhQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_updatePermissionStructure]') AND type in (N'P', N'PC'))
DROP PROCEDURE [configuration].[p_updatePermissionStructure]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_updatePermissionStructure]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE configuration.p_updatePermissionStructure @xmlVar XML
AS
BEGIN
	DECLARE @superUserProfiles xml, @structure xml, @userProfile xml, @profileLabels XML, @id uniqueidentifier
	DECLARE @tmp_query TABLE (i INT IDENTITY(1,1), query varchar(4000))
	DECLARE @tmp_superUserProfiles TABLE ( k varchar(500), leve int)
	DECLARE @tmp_deleted TABLE (i INT IDENTITY(1,1), k VARCHAR(500))
	DECLARE @tmp_profiles TABLE (i INT IDENTITY(1,1), x xml , id uniqueidentifier)
	DECLARE @tmp_userPermissions TABLE ( k varchar(500), leve int)

	DECLARE @i INT , @rows INT, @k VARCHAR(500), @levelCount INT, @xquery NVARCHAR(max)

	SELECT @structure =  xmlValue 
	FROM configuration.Configuration WHERE [key] = ''permissions.superUserStructure''

	SELECT @superUserProfiles = xmlValue 
	FROM configuration.Configuration WHERE [key] = ''permissions.superUserProfiles''

	INSERT INTO @tmp_superUserProfiles
	SELECT x.value(''(@key)[1]'',''varchar(500)'') ,x.value(''(@level)[1]'',''varchar(500)'') 
	FROM @superUserProfiles.nodes(''profile/permissions/permission'') as a(x)

	/* Kasowanie level0*/
	INSERT INTO @tmp_deleted (k)
	SELECT x.value(''(@key)[1]'',''varchar(500)'') k
	FROM @superUserProfiles.nodes(''profile/permissions/permission[@level="0"]'') as a(x)


	SELECT @i = 1 , @rows = @@rowcount

	WHILE @i <= @rows
		BEGIN
			SELECT @k = REPLACE(k, ''.'',''"]/permissions/permission[@key="'') FROM @tmp_deleted WHERE i = @i 
			SELECT @xquery = ''SET @structure.modify(''''delete (permission/permissions/permission[@key="'' + @k + ''"])[1]'''' )''
			EXECUTE sp_executesql @xquery, N''@structure xml OUTPUT'', @structure OUTPUT
		
		SELECT @i =  @i + 1
		END

	UPDATE configuration.Configuration SET xmlValue = @structure WHERE  [key] = ''permissions.structure''

	INSERT INTO @tmp_profiles(x,id)
	SELECT xmlValue, id FROM configuration.Configuration WHERE [key] like ''permissions.profiles.%''

	SELECT @i = 1 , @rows = @@rowcount

	WHILE @i <= @rows
		BEGIN
				SELECT @userProfile = x , @profileLabels = x.query(''profile/labels'') , @id = id FROM @tmp_profiles WHERE i = @i

				INSERT INTO @tmp_userPermissions
				SELECT x.value(''@key'',''varchar(500)''),x.value(''@level'',''int'')
				FROM @userProfile.nodes(''profile/permissions/permission'') as a(x)

				DELETE FROM @tmp_userPermissions WHERE k IN (
																SELECT up.k
																FROM @tmp_userPermissions up
																	LEFT JOIN @tmp_superUserProfiles su  ON su.k = up.k
																WHERE su.k IS NULL OR  (su.leve = 0 AND  up.leve <> 0)
															)

				INSERT INTO @tmp_userPermissions
				SELECT su.k, 0 
				FROM @tmp_superUserProfiles su 
					LEFT JOIN @tmp_userPermissions up ON su.k = up.k 
				WHERE up.k IS NULL 
			

				UPDATE configuration.Configuration SET xmlValue = 
						(
							SELECT @profileLabels, (SELECT  (SELECT k AS ''@key'' , leve as ''@level'' FROM @tmp_userPermissions  ORDER BY k FOR XML PATH(''permission''),TYPE) FOR XML PATH(''permissions''),TYPE)
							FOR XML PATH(''profile''),TYPE
						)
				WHERE id = @id

				SELECT @i =  @i + 1
				DELETE FROM @tmp_userPermissions
		END

	EXEC dictionary.p_updateVersion ''Configuration''
	SELECT CAST(''<root>OK</root>'' as XML)

END

--exec configuration.p_updatePermissionStructure ''<root/>''
--SELECT  * , xmlValue, id FROM configuration.Configuration WHERE [key] like ''permissions.profiles.%''

--SELECT xmlValue 
--	FROM configuration.Configuration WHERE [key] = ''permissions.superUserProfiles''
' 
END
GO

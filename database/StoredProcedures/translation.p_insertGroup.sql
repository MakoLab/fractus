/*
name=[translation].[p_insertGroup]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
hNCPlvw5/EmgrEc7qTpxsA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertGroup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertGroup]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_insertGroup] @serverName VARCHAR(50), @dbName VARCHAR(50), @translationServer VARCHAR(50), @dbTranslation VARCHAR(50) AS
BEGIN
	DECLARE @newid uniqueidentifier,
			@id numeric,
			@nazwa VARCHAR(50), 
			@kod VARCHAR(150),
			@newid2 uniqueidentifier,
			@id2 numeric,
			@nazwa2 VARCHAR(50), 
			@kod2 VARCHAR(150),
			@counter NUMERIC,
			@query NVARCHAR(3000),
			@groups XML,
			@group XML,
			@subgroups nvarchar(max),
			@result nvarchar(max)
			

	SELECT @query = ''DELETE FROM [''+@translationServer+''].''+@dbTranslation+''.dbo.ItemGroup''
	EXEC(@query)
	SELECT @query = ''DELETE FROM [''+@translationServer+''].''+@dbTranslation+''.dbo.ContractorGroup''
	EXEC(@query)

	SELECT @groups = (
		SELECT
			newid() as ''@id'', 
			(SELECT
				(SELECT ''pl'' as ''@lang'', ''Grupy towarowe'' FOR XML PATH(''label''), TYPE),
				(SELECT ''en'' as ''@lang'', ''Item groups'' FOR XML PATH(''label''), TYPE)
			FOR XML PATH(''labels''), TYPE),
			(SELECT '''' FOR XML PATH(''subgroups''), TYPE)	
		FOR XML PATH(''group''), TYPE
	)

	SELECT @counter = 0
	SELECT @query = ''DECLARE c CURSOR FOR SELECT id, LTRIM(RTRIM(nazwa)) as nazwa, kod FROM [''+@serverName+''].''+@dbName+''.dbo.GrupyDef WHERE wsk = ''''T'''' AND right(left(kod,10),5) = ''''00000'''' ORDER BY id''
	EXEC(@query)
	OPEN c
	FETCH FROM c INTO @id, @nazwa, @kod
	WHILE (@@fetch_status = 0)
	BEGIN
		SELECT @newid = newid()
		SELECT @group = 
			(SELECT
				@newid as ''@id'', 
				(SELECT
					(SELECT ''pl'' as ''@lang'', @nazwa FOR XML PATH(''label''), TYPE),
					(SELECT ''en'' as ''@lang'', @nazwa FOR XML PATH(''label''), TYPE)
				FOR XML PATH(''labels''), TYPE),
				(SELECT '''' FOR XML PATH(''subgroups''), TYPE)	
			FOR XML PATH(''group''), TYPE)	

		SELECT @query = ''INSERT INTO [''+@translationServer+''].''+@dbTranslation+''.dbo.ItemGroup (groupId, megaId) VALUES ('''''' + convert(varchar(50),@newid) + '''''', '' + convert(varchar(50),@id) + '')''
		EXEC dbo.sp_executesql @query

		SELECT @query = ''DECLARE d CURSOR FOR SELECT id, LTRIM(RTRIM(nazwa)) as nazwa, kod FROM [''+@serverName+''].''+@dbName+''.dbo.GrupyDef WHERE wsk = ''''T'''' AND right(left(kod,10),5) <> ''''00000'''' AND left(kod,5) = left(''''''+@kod+'''''',5) ORDER BY id''
		EXEC(@query)
		OPEN d
		FETCH FROM d INTO @id2,@nazwa2, @kod2
		WHILE (@@fetch_status = 0)
		BEGIN
			SELECT @newid2 = newid()
			SELECT @query = ''SELECT @subgroups = CONVERT(nvarchar(max),
				(SELECT
					'''''' + convert(varchar(50),@newid2) + '''''' as ''''@id'''', 
					(SELECT
						(SELECT ''''pl'''' as ''''@lang'''', '''''' + @nazwa2 + '''''' FOR XML PATH(''''label''''), TYPE),
						(SELECT ''''en'''' as ''''@lang'''', '''''' + @nazwa2 + '''''' FOR XML PATH(''''label''''), TYPE)
					FOR XML PATH(''''labels''''), TYPE)
				FOR XML PATH(''''group''''), TYPE)
			)''
			EXEC dbo.sp_executesql @query, N''@subgroups nvarchar(max) OUTPUT'', @subgroups = @subgroups OUTPUT;

			IF @subgroups IS NOT NULL
			BEGIN
				SELECT @query = ''SET @group.modify(''''insert '' + @subgroups + '' as last into /group[1]/subgroups[1]'''');''
				EXEC dbo.sp_executesql @query, N''@group XML OUTPUT'', @group = @group OUTPUT;
			END		
			SELECT @query = ''INSERT INTO [''+@translationServer+''].''+@dbTranslation+''.dbo.ItemGroup (groupId, megaId) VALUES ('''''' + convert(varchar(1000),@newid2) + '''''', '' + convert(varchar(50),@id2) + '')''
			EXEC dbo.sp_executesql @query	
			FETCH FROM d INTO @id2,@nazwa2, @kod2
		END
		CLOSE d
		DEALLOCATE d
		
		IF @subgroups IS NULL
		BEGIN
			SELECT @query = ''SET @group.modify(''''delete /group[1]/subgroups[1]'''');''
			EXEC dbo.sp_executesql @query, N''@group XML OUTPUT'', @group = @group OUTPUT;
		END 

		SELECT @query = ''SET @groups.modify(''''insert '' + CONVERT(nvarchar(max),@group) + '' as first into /group[1]/subgroups[1]'''');''
		EXEC dbo.sp_executesql @query, N''@groups XML OUTPUT'', @groups = @groups OUTPUT;

		SELECT @subgroups = NULL
		FETCH FROM c INTO @id, @nazwa, @kod
	END
	UPDATE configuration.Configuration SET xmlValue = @groups WHERE [key] = ''items.group''
	CLOSE c
	DEALLOCATE c


	SELECT @groups = (
		SELECT
			newid() as ''@id'', 
			(SELECT
				(SELECT ''pl'' as ''@lang'', ''Grupy kontrahentów'' FOR XML PATH(''label''), TYPE),
				(SELECT ''en'' as ''@lang'', ''Contractor groups'' FOR XML PATH(''label''), TYPE)
			FOR XML PATH(''labels''), TYPE),
			(SELECT '''' FOR XML PATH(''subgroups''), TYPE)	
		FOR XML PATH(''group''), TYPE
	)

	SELECT @counter = 0
	SELECT @query = ''DECLARE c CURSOR FOR SELECT id, LTRIM(RTRIM(nazwa)) as nazwa, kod FROM [''+@serverName+''].''+@dbName+''.dbo.GrupyDef WHERE wsk = ''''K'''' AND right(left(kod,10),5) = ''''00000'''' ORDER BY id''
	EXEC(@query)
	OPEN c
	FETCH FROM c INTO @id, @nazwa, @kod
	WHILE (@@fetch_status = 0)
	BEGIN
		SELECT @newid = newid()
		SELECT @group = 
			(SELECT
				@newid as ''@id'', 
				(SELECT
					(SELECT ''pl'' as ''@lang'', @nazwa FOR XML PATH(''label''), TYPE),
					(SELECT ''en'' as ''@lang'', @nazwa FOR XML PATH(''label''), TYPE)
				FOR XML PATH(''labels''), TYPE),
				(SELECT '''' FOR XML PATH(''subgroups''), TYPE)	
			FOR XML PATH(''group''), TYPE)	

		SELECT @query = ''INSERT INTO [''+@translationServer+''].''+@dbTranslation+''.dbo.ContractorGroup (groupId, megaId) VALUES ('''''' + convert(varchar(50),@newid) + '''''', '' + convert(varchar(50),@id) + '')''
		EXEC dbo.sp_executesql @query

		SELECT @query = ''DECLARE d CURSOR FOR SELECT id, LTRIM(RTRIM(nazwa)) as nazwa, kod FROM [''+@serverName+''].''+@dbName+''.dbo.GrupyDef WHERE wsk = ''''K'''' AND right(left(kod,10),5) <> ''''00000'''' AND left(kod,5) = left(''''''+@kod+'''''',5) ORDER BY id''
		EXEC(@query)
		OPEN d
		FETCH FROM d INTO @id2,@nazwa2, @kod2
		WHILE (@@fetch_status = 0)
		BEGIN
			SELECT @newid2 = newid()
			SELECT @query = ''SELECT @subgroups = CONVERT(nvarchar(max),
				(SELECT
					'''''' + convert(varchar(50),@newid2) + '''''' as ''''@id'''', 
					(SELECT
						(SELECT ''''pl'''' as ''''@lang'''', '''''' + @nazwa2 + '''''' FOR XML PATH(''''label''''), TYPE),
						(SELECT ''''en'''' as ''''@lang'''', '''''' + @nazwa2 + '''''' FOR XML PATH(''''label''''), TYPE)
					FOR XML PATH(''''labels''''), TYPE)
				FOR XML PATH(''''group''''), TYPE)
			)''
			EXEC dbo.sp_executesql @query, N''@subgroups nvarchar(max) OUTPUT'', @subgroups = @subgroups OUTPUT;

			IF @subgroups IS NOT NULL
			BEGIN
				SELECT @query = ''SET @group.modify(''''insert '' + @subgroups + '' as last into /group[1]/subgroups[1]'''');''
				EXEC dbo.sp_executesql @query, N''@group XML OUTPUT'', @group = @group OUTPUT;
			END		
			SELECT @query = ''INSERT INTO [''+@translationServer+''].''+@dbTranslation+''.dbo.ContractorGroup (groupId, megaId) VALUES ('''''' + convert(varchar(1000),@newid2) + '''''', '' + convert(varchar(50),@id2) + '')''
			EXEC dbo.sp_executesql @query	
			FETCH FROM d INTO @id2,@nazwa2, @kod2
		END
		CLOSE d
		DEALLOCATE d
		
		IF @subgroups IS NULL
		BEGIN
			SELECT @query = ''SET @group.modify(''''delete /group[1]/subgroups[1]'''');''
			EXEC dbo.sp_executesql @query, N''@group XML OUTPUT'', @group = @group OUTPUT;
		END 

		SELECT @query = ''SET @groups.modify(''''insert '' + CONVERT(nvarchar(max),@group) + '' as first into /group[1]/subgroups[1]'''');''
		EXEC dbo.sp_executesql @query, N''@groups XML OUTPUT'', @groups = @groups OUTPUT;

		SELECT @subgroups = NULL
		FETCH FROM c INTO @id, @nazwa, @kod
	END
	UPDATE configuration.Configuration SET xmlValue = @groups WHERE [key] = ''contractors.group''
	CLOSE c
	DEALLOCATE c
END
' 
END
GO

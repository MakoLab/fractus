/*
name=[translation].[p_insertBranch]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
+A5zcuYkZqjowW3R8x7tfA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertBranch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertBranch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertBranch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_insertBranch] @serverName VARCHAR(50), @dbName VARCHAR(50) AS
BEGIN
	DECLARE @nazwa VARCHAR(50), 
			@ident VARCHAR(5),
			@counter NUMERIC,
			@query NVARCHAR(300),
			@databaseId VARCHAR(50),
			@id NUMERIC,
			@branchId UNIQUEIDENTIFIER,
			@prefix NUMERIC

	DELETE FROM dictionary.Branch	
	DELETE FROM communication.[Statistics]
	SELECT @counter = 0
	
	INSERT INTO dictionary.Branch([id],[companyId], [databaseId], [xmlLabels], [version], [order], [symbol])
		SELECT	
			NEWID(),
			(SELECT TOP 1 contractorId FROM dictionary.Company) as [companyId],
			(SELECT textValue FROM configuration.Configuration WHERE [key] = ''communication.databaseId'') as [databaseId],
			(SELECT
				(SELECT ''pl'' as ''@lang'', ''Centrala'' FOR XML PATH(''label''), TYPE)
			FOR XML PATH(''labels''), TYPE) as [xmlLabels],
			NEWID(),
			(SELECT @counter) as [order],
			''CE'' as [symbol]	

	INSERT INTO communication.[Statistics] (databaseId) SELECT textValue FROM configuration.Configuration WHERE [key] = ''communication.databaseId''	

	SELECT @query = ''DECLARE c CURSOR FOR SELECT LTRIM(RTRIM(nazwa)) as nazwa, ident, id, prefiksOddzialu FROM [''+@serverName+''].''+@dbName+''.dbo.Punkty ORDER BY id''
	EXEC(@query)
	OPEN c
	FETCH FROM c INTO @nazwa, @ident, @id, @prefix
	WHILE (@@fetch_status = 0)
	BEGIN
		SELECT @counter = @counter + 1
		SELECT @databaseId = NEWID()
		SELECT @branchId = NEWID()
		INSERT INTO dictionary.Branch([id],[companyId], [databaseId], [xmlLabels], [version], [order], [symbol])
		SELECT	
			@branchId,
			(SELECT TOP 1 contractorId FROM dictionary.Company) as [companyId],
			@databaseId,
			(SELECT
				(SELECT ''pl'' as ''@lang'', (SELECT @nazwa as label) FOR XML PATH(''label''), TYPE)
			FOR XML PATH(''labels''), TYPE) as [xmlLabels],
			NEWID(),
			(SELECT @counter) as [order],
			(SELECT @ident) as [symbol]	
		INSERT INTO communication.[Statistics] (databaseId) SELECT @databaseId
		INSERT INTO translation.Punkty(megaId,fractus2Id) VALUES (@id,@branchId)
		INSERT INTO translation.BranchAttributes(branchId,prefix) VALUES (@branchId,@prefix)
	
		FETCH FROM c INTO @nazwa, @ident, @id, @prefix
	END
	CLOSE c
	DEALLOCATE c
END
' 
END
GO

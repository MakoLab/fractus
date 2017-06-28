/*
name=[translation].[p_insertWarehouse]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
yrZwX2v1/FCPgr0Uo4LcOg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertWarehouse]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertWarehouse]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertWarehouse]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_insertWarehouse] @serverName VARCHAR(50), @dbName VARCHAR(50) AS
BEGIN
	DECLARE @nazwa VARCHAR(50), 
			@kod VARCHAR(5),
			@oddzial VARCHAR(50),
			@lokalizacja VARCHAR(50),
			@counter NUMERIC,
			@query NVARCHAR(1500)
	
	DELETE FROM dictionary.Warehouse
	SELECT @counter = 0
	
	INSERT INTO dictionary.Warehouse([id],[symbol], [branchId], [valuationMethod], [isActive], [xmlLabels], [xmlMetadata], [version], [order], [issuePlaceId])
		SELECT	
			NEWID() as [id],
			''CE'' as [symbol],
			(SELECT id FROM dictionary.Branch WHERE [order] = 0) as [branchId],
			0 as [valuationMethod],
			1 as [isActive],
			(SELECT
				(SELECT ''pl'' as ''@lang'', ''Magazyn Centrala'' FOR XML PATH(''label''), TYPE)
			FOR XML PATH(''labels''), TYPE) as [xmlLabels],
			''<metadata/>'' as [xmlMetadata],
			NEWID()as [version],
			(SELECT @counter) as [order],
			(SELECT TOP 1 id FROM dictionary.IssuePlace)	

	SELECT @query = ''DECLARE c CURSOR FOR SELECT LTRIM(RTRIM(nazwa)) as nazwa, kod, 
					(SELECT nazwa FROM [''+@serverName+''].''+@dbName+''.dbo.Punkty 
					WHERE id_oddzialu = (SELECT id_oddzialu FROM [''+@serverName+''].''+@dbName+''.dbo.Oddzial_magazyn WHERE id_magazynu = Tow_MagazynyDef.id )) as oddzial,
					(SELECT lokalizacja FROM [''+@serverName+''].''+@dbName+''.dbo.Punkty 
					WHERE id_oddzialu = (SELECT id_oddzialu FROM [''+@serverName+''].''+@dbName+''.dbo.Oddzial_magazyn WHERE id_magazynu = Tow_MagazynyDef.id )) as lokalizacja 
					FROM [''+@serverName+''].''+@dbName+''.dbo.Tow_MagazynyDef WHERE id IN (SELECT id_magazynu FROM [''+@serverName+''].''+@dbName+''.dbo.Oddzial_magazyn WHERE id_oddzialu IN (SELECT id_oddzialu FROM [''+@serverName+''].''+@dbName+''.dbo.Punkty ))''
	EXEC(@query)
	OPEN c
	FETCH FROM c INTO @nazwa, @kod, @oddzial, @lokalizacja
	WHILE (@@fetch_status = 0)
	BEGIN
		SELECT @counter = @counter + 1
		INSERT INTO dictionary.Warehouse([id],[symbol], [branchId], [valuationMethod], [isActive], [xmlLabels], [xmlMetadata], [version], [order], [issuePlaceId])
		SELECT	
			NEWID() as [id],
			(SELECT @kod) as [symbol],
			(SELECT id FROM dictionary.Branch WHERE xmlLabels.value(''data((/labels//label)[1])'',''nvarchar(max)'') = @oddzial) as [branchId],
			1 as [valuationMethod],
			1 as [isActive],
			(SELECT
				(SELECT ''pl'' as ''@lang'', (SELECT @nazwa as label) FOR XML PATH(''label''), TYPE)
			FOR XML PATH(''labels''), TYPE) as [xmlLabels],
			''<metadata/>'' as [xmlMetadata],
			NEWID()as [version],
			(SELECT @counter) as [order],
			(SELECT TOP 1 id FROM dictionary.IssuePlace WHERE [name] = @lokalizacja)	
		FETCH FROM c INTO @nazwa, @kod, @oddzial, @lokalizacja
	END
	CLOSE c
	DEALLOCATE c
END
' 
END
GO

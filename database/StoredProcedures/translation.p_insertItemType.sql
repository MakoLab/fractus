/*
name=[translation].[p_insertItemType]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
FkEB4VMwb5u7+kr/EgKgiQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertItemType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertItemType]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertItemType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create PROCEDURE [translation].[p_insertItemType] @serverName VARCHAR(50), @dbName VARCHAR(50) AS
BEGIN
	DECLARE @nazwa VARCHAR(50), 
			@symbol VARCHAR(3),
			@counter NUMERIC,
			@query NVARCHAR(300)

	SELECT @counter = ISNULL(MAX([order]),0) FROM dictionary.ItemType
	SELECT @query = ''DECLARE c CURSOR FOR SELECT LTRIM(RTRIM(nazwa)) as nazwa FROM [''+@serverName+''].''+@dbName+''.dbo.Tow_Typy''
	EXEC(@query)
	OPEN c
	FETCH FROM c INTO @nazwa
	WHILE (@@fetch_status = 0)
	BEGIN
		SELECT @counter = @counter + 1
		IF NOT EXISTS(SELECT * FROM dictionary.ItemType WHERE xmlLabels.value(''(//labels/label[@lang=''''pl''''])[1]'',''varchar(50)'') = @nazwa)
			INSERT INTO dictionary.ItemType([id],[name], [xmlLabels], [xmlMetadata], [version], [order], [isWarehouseStorable])
			SELECT	
				NEWID(),
				(SELECT @nazwa) as [nazwa],
				(SELECT
					(SELECT ''pl'' as ''@lang'',(SELECT @nazwa as label) FOR XML PATH(''label''), TYPE)
				FOR XML PATH(''labels''), TYPE) as [xmlLabels],
				''<metadata />'',
				NEWID(),
				(SELECT @counter) as [order],
				''True''		
		FETCH FROM c INTO @nazwa
	END
	CLOSE c
	DEALLOCATE c
END
' 
END
GO

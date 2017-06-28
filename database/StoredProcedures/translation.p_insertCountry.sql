/*
name=[translation].[p_insertCountry]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
XxJ7dHC/FJzAJWmbnByY1Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertCountry]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertCountry]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertCountry]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_insertCountry] @serverName VARCHAR(50), @dbName VARCHAR(50), @translationServer VARCHAR(50), @dbTranslation VARCHAR(50)  AS
BEGIN
	DECLARE @nazwa VARCHAR(50), 
			@skrot VARCHAR(5),
			@counter NUMERIC,
			@query NVARCHAR(500)
	
	SELECT @counter = 0
	SELECT @query = ''DECLARE c CURSOR FOR SELECT LTRIM(RTRIM(nazwa)) as nazwa FROM [''+@serverName+''].''+@dbName+''.dbo.Slow_Panstwa''
	EXEC(@query)
	OPEN c
	FETCH FROM c INTO @nazwa
	WHILE (@@fetch_status = 0)
	BEGIN
		SELECT @counter = MAX([order]) + 1 FROM dictionary.Country
		--DELETE FROM dictionary.Country WHERE symbol = ''US''
		IF NOT EXISTS(SELECT * FROM dictionary.Country WHERE xmlLabels.value(''(//labels/label)[1]'', ''nvarchar(50)'') = @nazwa)
			INSERT INTO dictionary.Country([id],[symbol], [xmlLabels], [version], [order])
			SELECT	
				NEWID(),
				''??'' as [symbol],
				(SELECT
					(SELECT ''pl'' as ''@lang'', (SELECT @nazwa as label) FOR XML PATH(''label''), TYPE)
				FOR XML PATH(''labels''), TYPE) as [xmlLabels],
				NEWID(),
				(SELECT @counter) as [order]			
		FETCH FROM c INTO @nazwa
		SELECT @query = ''UPDATE dictionary.Country SET symbol = 
		ISNULL((SELECT symbol FROM [''+@translationServer+''].''+@dbTranslation+''.dbo.CountryList WHERE name = '''''' + @nazwa + ''''''),''''??'''')
		WHERE xmlLabels.value(''''(//labels/label)[1]'''', ''''nvarchar(50)'''') = '''''' + @nazwa + ''''''''
		EXEC(@query)	
	END
	CLOSE c
	DEALLOCATE c
END
' 
END
GO

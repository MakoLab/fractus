/*
name=[translation].[p_insertCurrency]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dXW7l4+TyuvgoMZHaMHO+w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertCurrency]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertCurrency]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertCurrency]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_insertCurrency] @serverName VARCHAR(50), @dbName VARCHAR(50) AS
BEGIN
	DECLARE @nazwa VARCHAR(50), 
			@symbol VARCHAR(3),
			@counter NUMERIC,
			@query NVARCHAR(300)

	SELECT @counter = 0
	SELECT @query = ''DECLARE c CURSOR FOR SELECT LTRIM(RTRIM(nazwa)) as nazwa, symbol FROM [''+@serverName+''].''+@dbName+''.dbo.Slow_Waluta''
	EXEC(@query)
	OPEN c
	FETCH FROM c INTO @nazwa, @symbol
	WHILE (@@fetch_status = 0)
	BEGIN
		SELECT @counter = @counter + 1
		UPDATE dictionary.Currency
		SET xmlLabels = (SELECT
					(SELECT ''pl'' as ''@lang'', (SELECT @nazwa as label) FOR XML PATH(''label''), TYPE)
				FOR XML PATH(''labels''), TYPE)
		WHERE symbol = @symbol
		IF NOT EXISTS(SELECT * FROM dictionary.Currency WHERE symbol = @symbol)
			INSERT INTO dictionary.Currency([id],[symbol], [xmlLabels], [version], [order])
			SELECT	
				NEWID(),
				(SELECT @symbol) as [symbol],
				(SELECT
					(SELECT ''pl'' as ''@lang'',(SELECT @nazwa as label) FOR XML PATH(''label''), TYPE)
				FOR XML PATH(''labels''), TYPE) as [xmlLabels],
				NEWID(),
				(SELECT @counter) as [order]			
		FETCH FROM c INTO @nazwa, @symbol
	END
	CLOSE c
	DEALLOCATE c
END
' 
END
GO

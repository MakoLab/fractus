/*
name=[translation].[p_insertVatRate]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
gr49AtoJ5J0TA4TGHyfhzQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertVatRate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertVatRate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertVatRate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_insertVatRate] @serverName VARCHAR(50), @dbName VARCHAR(50) AS
BEGIN
	DECLARE @nazwa VARCHAR(50), 
			@stawka NUMERIC,
			@symbol VARCHAR(3),
			@fiskalna CHAR(1),
			@counter NUMERIC,
			@query NVARCHAR(300)

	SELECT @counter = 0
	SELECT @query = ''DECLARE c CURSOR FOR SELECT LTRIM(RTRIM(nazwa)) as nazwa, stawka, symbol, fiskalna FROM [''+@serverName+''].''+@dbName+''.dbo.Slow_Podatek''
	EXEC(@query)
	OPEN c
	FETCH FROM c INTO @nazwa, @stawka, @symbol, @fiskalna
	WHILE (@@fetch_status = 0)
	BEGIN
		SELECT @counter = MAX([order]) + 1 FROM dictionary.VatRate
		UPDATE dictionary.VatRate
		SET xmlLabels = (SELECT
					(SELECT ''pl'' as ''@lang'', (SELECT @nazwa as label) FOR XML PATH(''label''), TYPE)
				FOR XML PATH(''labels''), TYPE),
			rate = @stawka,
			fiscalSymbol = @fiskalna
		WHERE symbol = @symbol
		IF NOT EXISTS(SELECT * FROM dictionary.VatRate WHERE symbol = @symbol)
		INSERT INTO dictionary.VatRate([id],[symbol], [rate], [fiscalSymbol], [xmlLabels], [version], [order])
		SELECT	
			NEWID(),
			(SELECT @symbol) as [symbol],
			(SELECT @stawka) as [rate],
			(SELECT @fiskalna) as [fiscalSymbol],
			(SELECT
				(SELECT ''pl'' as ''@lang'',(SELECT @nazwa as label) FOR XML PATH(''label''), TYPE)
			FOR XML PATH(''labels''), TYPE) as [xmlLabels],
			NEWID(),
			(SELECT @counter) as [order]			
		FETCH FROM c INTO @nazwa, @stawka, @symbol, @fiskalna
	END
	CLOSE c
	DEALLOCATE c
END
' 
END
GO

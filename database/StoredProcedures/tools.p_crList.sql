/*
name=[tools].[p_crList]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
X0tIzDy6dNFZfz3h+SvszQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_crList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_crList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_crList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [tools].[p_crList] 
	@table varchar(500) = ''?'',
	@schema varchar(50) = ''dbo'',
	@type char(2) = NULL
AS
BEGIN
	DECLARE @tmp TABLE ( col varchar(500), dt varchar(500))
	DECLARE @out nvarchar(max)
	
	IF @table = ''?''
		BEGIN 
		PRINT '' 
		[tools].[p_crList] 
		
		Procedura zwracająca listy kolumn z obiektów systemowych w różnych konfiguracjach.
		Parametry:
			@table - tabela dla której pobieramy listę kolumn
			
			@schema - schema w której znajduje sie obiekt, domyślnie wartość dbo
			
			@type - określa układ w jakim zostaną zwrócone kolumny. Występują następujące opcje:
				L - zwykła lista kolumn w formacie; schema.kolumna
				SL - liska kolumn bez prefiksu; kolumna
				OL - lista kolumn do wnętrza odczytu OPENXML; kolumna typ ''''kolumn''''
				UP - lista do polecenia typu update bezpośrednio z xQuery;[kolumna] =  CASE WHEN con.exist(''''kolumna'''') = 1 THEN con.query(''''kolumna'''').value(''''.'''',''''typ'''') ELSE NULL END ,
				UL - lista dziwna taka;kolumna typ ''''kolumna''''
				LX - zalpytanie z xQuery;SELECT  NULLIF(x.value(''''(kolumna)[1]'''',''''typ'''') ,''''''''),  FROM @xmlVar.nodes(''''root'''') as a(x) 
			''
		RETURN 0;	
		END
	
	INSERT INTO @tmp(col,dt)
	SELECT column_name, DATA_TYPE +
		CASE 
			WHEN DATA_TYPE IN (''nvarchar'',''char'',''varchar'', ''nchar'', ''varbinary'',''binary'') THEN ''('' + REPLACE( CAST(CHARACTER_MAXIMUM_LENGTH AS varchar(50)),''-1'',''max'') + '')''
			WHEN DATA_TYPE IN (''numeric'',''decimal'') THEN ''('' + CAST(NUMERIC_PRECISION AS varchar(50)) + '','' + CAST(NUMERIC_SCALE AS varchar(50)) + '')''
			ELSE '''' 
		END
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = @table
	
	IF @type = ''L'' -- Lista kolumn z prefixem
		SELECT CAST(( SELECT @table + ''.'' + col + '','' AS ''data()'' FROM @tmp FOR XML PATH(''''),TYPE) AS varchar(max))
	ELSE IF @type = ''SL'' -- Lista kolumn prosta
		SELECT CAST(( SELECT col + '','' AS ''data()'' FROM @tmp FOR XML PATH(''''),TYPE) AS varchar(max))
	ELSE IF @type = ''OL'' -- Lista do wnętrza OPENXML
		SELECT CAST(( SELECT col + '' '' + dt + '' '''''' + col + '''''' , '' AS ''data()'' FROM @tmp FOR XML PATH(''''),TYPE) AS varchar(max))
	ELSE IF @type = ''UP'' -- Lista do polecenia typu update
		SELECT CAST(( SELECT ''[''+col+'']'' + '' =  CASE WHEN con.exist('''''' + col + '''''') = 1 THEN con.query('''''' + col + '''''').value(''''.'''','''''' + dt + '''''') ELSE NULL END , ''  AS ''data()'' FROM @tmp FOR XML PATH(''''),TYPE) AS varchar(max))
	ELSE IF @type = ''UL'' --Lista 
		SELECT CAST(( 	SELECT col + '' '' + dt + '' '''''' + col + '''''' , '' AS ''data()'' FROM @tmp FOR XML PATH(''''),TYPE) AS varchar(max))
		
	ELSE IF @type = ''LX'' --Lista do xquery
		SELECT ''SELECT '' + CAST(( 	SELECT ''NULLIF(x.value(''''('' + col + '')[1]'''','''''' + dt + '''''') ,''''''''), '' AS ''data()'' FROM @tmp FOR XML PATH(''''),TYPE) AS varchar(max)) + '' FROM @xmlVar.nodes(''''root'''') as a(x) ''

	ELSE IF @type = ''COM'' --Lista do xquery
		SELECT CAST(( 	SELECT ''h.'' + col + '' <> h2.'' + col +  '' OR '' AS ''data()'' FROM @tmp FOR XML PATH(''''),TYPE) AS varchar(max))

	--SELECT CAST(( 	SELECT ''h.'' + col + '' <> h2.'' + col +  '' OR '' AS ''data()'' FROM @tmp FOR XML PATH(''''),TYPE) AS varchar(max))
	
	END
' 
END
GO

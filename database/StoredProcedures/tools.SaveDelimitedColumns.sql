/*
name=[tools].[SaveDelimitedColumns]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
G1k2N3E/U3d2I28iVNG7FQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[SaveDelimitedColumns]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[SaveDelimitedColumns]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[SaveDelimitedColumns]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- coolik:
-- Procedura służy do uruchamianie innych procedur, widoków i zapytań,
-- przy czym wynik zwracany jest w formacie CSV (z możliwością zmiany separatora i różną konfiguracją)
-- Specyfikacja pod url''em podanym niżej.
-- Chciałem użyć tej procki do sformatowania wyniku zwracanego przez custom.v_allDocuments,
-- ale są z tym jeszcze problemy. 

/*
SaveDelimitedColumns
http://www.virtualobjectives.com.au

History:
15/09/2006 - J.Buoro - Added @Delimiter and @TextQuote parameters.
25/09/2006 - J.Buoro - Added @Header parameter.
08/04/2009 - J.Buoro - Reviewed script.
*/

CREATE PROCEDURE [tools].[SaveDelimitedColumns]
    @PCWrite varchar(1000) = NULL,
    @DBFetch varchar(4000),
    @DBWhere varchar(2000) = NULL,
    @DBThere varchar(2000) = NULL,
    @DBUltra bit = 0,
    @Delimiter varchar(100) = ''CHAR(44)'', -- Default is ,
    @TextQuote varchar(100) = ''CHAR(34)'', -- Default is "  Use SPACE(0) for none.
    @Header bit = 0 -- Output header. Default is 0.
AS

SET NOCOUNT ON

DECLARE @Return int
DECLARE @Retain int
DECLARE @Status int

SET @Status = 0

DECLARE @TPre varchar(10)

DECLARE @TDo3 tinyint
DECLARE @TDo4 tinyint

SET @TPre = ''''

SET @TDo3 = LEN(@TPre)
SET @TDo4 = LEN(@TPre) + 1

DECLARE @DBAE varchar(40)
DECLARE @Task varchar(6000)
DECLARE @Bank varchar(4000)
DECLARE @Cash varchar(2000)
DECLARE @Risk varchar(2000)
DECLARE @Next varchar(8000)
DECLARE @Save varchar(8000)
DECLARE @Work varchar(8000)
DECLARE @Wish varchar(8000)

DECLARE @Name varchar(100)
DECLARE @Same varchar(100)

DECLARE @Rank smallint
DECLARE @Kind varchar(20)
DECLARE @Mask bit
DECLARE @Bond bit
DECLARE @Size int
DECLARE @Wide smallint
DECLARE @More smallint

DECLARE @DBAI varchar(2000)
DECLARE @DBAO varchar(8000)
DECLARE @DBAU varchar(8000)

DECLARE @Fuse int
DECLARE @File int

DECLARE @HeaderString varchar(8000)
DECLARE @HeaderDone int

SET @DBAE = ''##SaveFile'' + RIGHT(CONVERT(varchar(10),@@SPID+100000),5)

SET @Task = ''IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects WHERE name = '' + CHAR(39) + @DBAE + CHAR(39) + '') DROP TABLE '' + @DBAE
EXECUTE (@Task)

SET @Bank = @TPre + @DBFetch

IF NOT EXISTS (SELECT * FROM sysobjects WHERE RTRIM(type) = ''U'' AND name = @Bank)
BEGIN
	SET @Bank = CASE WHEN LEFT(LTRIM(@DBFetch),6) = ''SELECT'' THEN ''('' + @DBFetch + '')'' ELSE @DBFetch END
	SET @Bank = REPLACE(@Bank,         CHAR(94),CHAR(39))
	SET @Bank = REPLACE(@Bank,CHAR(45)+CHAR(45),CHAR(32))
	SET @Bank = REPLACE(@Bank,CHAR(47)+CHAR(42),CHAR(32))
END

IF @DBWhere IS NOT NULL
BEGIN
	SET @Cash = REPLACE(@DBWhere,''WHERE''       ,CHAR(32))
	SET @Cash = REPLACE(@Cash,         CHAR(94),CHAR(39))
	SET @Cash = REPLACE(@Cash,CHAR(45)+CHAR(45),CHAR(32))
	SET @Cash = REPLACE(@Cash,CHAR(47)+CHAR(42),CHAR(32))
END

IF @DBThere IS NOT NULL
BEGIN
	SET @Risk = REPLACE(@DBThere,''ORDER BY''    ,CHAR(32))
	SET @Risk = REPLACE(@Risk,         CHAR(94),CHAR(39))
	SET @Risk = REPLACE(@Risk,CHAR(45)+CHAR(45),CHAR(32))
	SET @Risk = REPLACE(@Risk,CHAR(47)+CHAR(42),CHAR(32))
END

SET @DBAI = ''''
SET @DBAO = ''''
SET @DBAU = ''''

IF ASCII(LEFT(@Bank,1)) < 64
BEGIN
	SET @Task = ''SELECT * INTO '' + @DBAE + '' FROM '' + @Bank + '' AS T WHERE 0 = 1''
	IF @Status = 0 EXECUTE (@Task) SET @Return = @@ERROR
	IF @Status = 0 SET @Status = @Return

	DECLARE Fields CURSOR FAST_FORWARD FOR
	SELECT C.name, C.colid, T.name, C.isnullable, C.iscomputed, C.length, C.prec, C.scale
	FROM tempdb.dbo.sysobjects AS O
	JOIN tempdb.dbo.syscolumns AS C
	  ON O.id = C.id
	JOIN tempdb.dbo.systypes AS T
	  ON C.xusertype = T.xusertype
	WHERE O.name = @DBAE
	ORDER BY C.colid

	SET @Retain = @@ERROR IF @Status = 0 SET @Status = @Retain
END
ELSE
BEGIN
	DECLARE Fields CURSOR FAST_FORWARD FOR
	SELECT C.name, C.colid, T.name, C.isnullable, C.iscomputed, C.length, C.prec, C.scale
	FROM sysobjects AS O
	JOIN syscolumns AS C
	  ON O.id = C.id
	JOIN systypes AS T
	  ON C.xusertype = T.xusertype
	WHERE ISNULL(OBJECTPROPERTY(O.id,''IsMSShipped''),1) = 0
	 AND RTRIM(O.type) IN (''U'',''V'',''IF'',''TF'')
	 AND O.name = @Bank
	ORDER BY C.colid
	
	SET @Retain = @@ERROR IF @Status = 0 SET @Status = @Retain
END

OPEN Fields

SET @Retain = @@ERROR IF @Status = 0 SET @Status = @Retain

FETCH NEXT FROM Fields INTO @Same, @Rank, @Kind, @Mask, @Bond, @Size, @Wide, @More

SET @Retain = @@ERROR IF @Status = 0 SET @Status = @Retain

-- Convert to character for header.
SET @HeaderString = ''''
declare @sql nvarchar(4000)
declare @cDelimiter nvarchar(9)
declare @cTextQuote nvarchar(9)
set @sql = N''select @cDelimiter = '' + @Delimiter
exec sp_executesql @sql, N''@cDelimiter varchar(9) output'', @cDelimiter output
set @sql = N''select @cTextQuote = '' + @TextQuote
exec sp_executesql @sql, N''@cTextQuote varchar(9) output'', @cTextQuote output

WHILE @@FETCH_STATUS = 0 AND @Status = 0
BEGIN
	-- Build header.
	IF LEN(@HeaderString) > 0 SET @HeaderString = @HeaderString + @cDelimiter + ISNULL(@cTextQuote + REPLACE(@Same, @cTextQuote, REPLICATE(@cTextQuote, 2))+@cTextQuote, SPACE(0))
	IF LEN(@HeaderString) = 0 SET @HeaderString = ISNULL(@cTextQuote + REPLACE(@Same, @cTextQuote, REPLICATE(@cTextQuote, 2))+@cTextQuote, SPACE(0))

	IF @Kind IN (''char'',''varchar'',''nchar'',''nvarchar'')

	BEGIN
		IF @Rank = 1 SET @DBAU =                       '' ISNULL(''+@TextQuote+''+REPLACE('' + @Same + '',''+@TextQuote+'',REPLICATE(''+@TextQuote+'',2))+''+@TextQuote+'',SPACE(0))''
		IF @Rank > 1 SET @DBAU = @DBAU + ''+'' + @Delimiter + ''+ISNULL(''+@TextQuote+''+REPLACE('' + @Same + '',''+@TextQuote+'',REPLICATE(''+@TextQuote+'',2))+''+@TextQuote+'',SPACE(0))''
	END

	IF @Kind IN (''bit'',''tinyint'',''smallint'',''int'',''bigint'')
	BEGIN
		IF @Rank = 1 SET @DBAU =                       '' ISNULL(CONVERT(varchar(40),'' + @Same + ''),SPACE(0))''
		IF @Rank > 1 SET @DBAU = @DBAU + ''+'' + @Delimiter + ''+ISNULL(CONVERT(varchar(40),'' + @Same + ''),SPACE(0))''
	END

	IF @Kind IN (''numeric'',''decimal'',''money'',''smallmoney'',''float'',''real'')
	BEGIN
		IF @Rank = 1 SET @DBAU =                       '' ISNULL(CONVERT(varchar(80),'' + @Same + ''),SPACE(0))''
		IF @Rank > 1 SET @DBAU = @DBAU + ''+'' + @Delimiter + ''+ISNULL(CONVERT(varchar(80),'' + @Same + ''),SPACE(0))''
	END

	IF @Kind IN (''uniqueidentifier'')
	BEGIN
		IF @Rank = 1 SET @DBAU =                       '' ISNULL(''+@TextQuote+''+CONVERT(varchar(80),'' + @Same + '')+''+@TextQuote+'',SPACE(0))''
		IF @Rank > 1 SET @DBAU = @DBAU + ''+'' + @Delimiter + ''+ISNULL(''+@TextQuote+''+CONVERT(varchar(80),'' + @Same + '')+''+@TextQuote+'',SPACE(0))''
	END

	IF @Kind IN (''datetime'',''smalldatetime'')
	BEGIN
		IF @Rank = 1 SET @DBAU =                       '' ISNULL(''+@TextQuote+''+CONVERT(varchar(40),'' + @Same + '',120)+''+@TextQuote+'',SPACE(0))''
		IF @Rank > 1 SET @DBAU = @DBAU + ''+'' + @Delimiter + ''+ISNULL(''+@TextQuote+''+CONVERT(varchar(40),'' + @Same + '',120)+''+@TextQuote+'',SPACE(0))''
	END

	FETCH NEXT FROM Fields INTO @Same, @Rank, @Kind, @Mask, @Bond, @Size, @Wide, @More

	SET @Retain = @@ERROR IF @Status = 0 SET @Status = @Retain
END

CLOSE Fields DEALLOCATE Fields

IF LEN(@DBAU) = 0 SET @DBAU = ''*''

SET @DBAI = '' SELECT ''
SET @DBAO = ''   FROM '' + @Bank + '' AS T''
	+ CASE WHEN @DBWhere IS NULL THEN '''' ELSE '' WHERE ('' + @Cash + '') AND 0 = 0'' END
	+ CASE WHEN @DBThere IS NULL THEN '''' ELSE '' ORDER BY '' + @Risk + '','' + CHAR(39) + ''DBA'' + CHAR(39) END

IF LEN(ISNULL(@PCWrite,''*'')) > 7 AND @DBUltra = 0
BEGIN
	SET @Wish = ''USE '' + DB_NAME() + @DBAI + @DBAU + @DBAO
	SET @Work = ''bcp "'' + @Wish + ''" queryout "'' + @PCWrite + ''" -c -T''
	EXECUTE @Return = master.dbo.xp_cmdshell @Work, NO_OUTPUT

	SET @Retain = @@ERROR

	IF @Status = 0 SET @Status = @Retain
	IF @Status = 0 SET @Status = @Return

	GOTO ABORT
END

IF LEN(ISNULL(@PCWrite,''*'')) > 7
BEGIN
	IF @Status = 0 EXECUTE @Return = sp_OACreate ''Scripting.FileSystemObject'', @Fuse OUTPUT

	SET @Retain = @@ERROR
	IF @Status = 0 SET @Status = @Retain
	IF @Status = 0 SET @Status = @Return

	IF @Status = 0 EXECUTE @Return = sp_OAMethod @Fuse, ''CreateTextFile'', @File OUTPUT, @PCWrite, -1

	SET @Retain = @@ERROR
	IF @Status = 0 SET @Status = @Retain
	IF @Status = 0 SET @Status = @Return

	IF @Status <> 0 GOTO ABORT
END

SET @DBAI = ''DECLARE Records CURSOR GLOBAL FAST_FORWARD FOR'' + @DBAI

IF @Status = 0 EXECUTE (@DBAI+@DBAU+@DBAO) SET @Return = @@ERROR
IF @Status = 0 SET @Status = @Return

OPEN Records

SET @Retain = @@ERROR IF @Status = 0 SET @Status = @Retain

FETCH NEXT FROM Records INTO @Next

SET @Retain = @@ERROR IF @Status = 0 SET @Status = @Retain

SET @HeaderDone = 0
WHILE @@FETCH_STATUS = 0 AND @Status = 0
BEGIN
	IF ISNULL(@File,0) = 0
	BEGIN
		-- Print header (TEXT).
		IF @Header = 1 and @HeaderDone = 0
		BEGIN
			PRINT @HeaderString + CHAR(13) + CHAR(10) --zzz
			SET @HeaderDone = 1
		END
		PRINT @Next
	END
	ELSE
	BEGIN
		-- Print header (FILE).
		IF @Header = 1 and @HeaderDone = 0
		BEGIN
			SET @Save = @HeaderString + CHAR(13) + CHAR(10)
			IF @Status = 0 EXECUTE @Return = sp_OAMethod @File, ''Write'', NULL, @Save
			SET @HeaderDone = 1
		END

		-- Print the data.
		SET @Save = @Next + CHAR(13) + CHAR(10)

		IF @Status = 0 EXECUTE @Return = sp_OAMethod @File, ''Write'', NULL, @Save
		IF @Status = 0 SET @Status = @Return
	END

	FETCH NEXT FROM Records INTO @Next
	SET @Retain = @@ERROR IF @Status = 0 SET @Status = @Retain
END

CLOSE Records DEALLOCATE Records

IF ISNULL(@File,0) <> 0
BEGIN
	EXECUTE @Return = sp_OAMethod @File, ''Close'', NULL
	IF @Status = 0 SET @Status = @Return

	EXECUTE @Return = sp_OADestroy @File
	IF @Status = 0 SET @Status = @Return

	EXECUTE @Return = sp_OADestroy @Fuse
	IF @Status = 0 SET @Status = @Return
END

ABORT: -- This label is referenced when OLE automation fails.

IF @Status = 1 OR @Status NOT BETWEEN 0 AND 50000 RAISERROR (''SaveDelimitedColumns Windows error [%d]'',16,1,@Status)

SET @Task = ''IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects WHERE name = '' + CHAR(39) + @DBAE + CHAR(39) + '') DROP TABLE '' + @DBAE
EXECUTE (@Task)

SET NOCOUNT OFF

RETURN (@Status)
' 
END
GO

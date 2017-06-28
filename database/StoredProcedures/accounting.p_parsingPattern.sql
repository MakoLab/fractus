/*
name=[accounting].[p_parsingPattern]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
h65nr9kbpCRUi4zlRMCnTg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_parsingPattern]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_parsingPattern]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_parsingPattern]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [accounting].[p_parsingPattern]
( 
	@strPattern	varchar(255)    ,	
	@source		int				,	
	@id			uniqueidentifier,	
	@result		varchar(255) OUT,	
	@message	varchar(255) OUT	
)
AS
BEGIN

	DECLARE	@pattern	varchar(255) 
	DECLARE @valPattern	varchar(255)
	DECLARE @sql		varchar(8000)
	DECLARE @ok			smallint
	DECLARE @indexSTART	smallint
	DECLARE @indexEND	smallint

	SET @message = ''''
	SET @ok = 1
	SET @result = ISNULL(@strPattern,'''')

	WHILE (@ok = 1) AND (@message = '''')
	BEGIN
		
		SET @indexStart = PATINDEX( ''%{%}%'', @result )

		IF @indexStart <> 0
		BEGIN


			SET @indexEnd = CHARINDEX( ''}'', @result )
			SET @pattern = SUBSTRING( @result, @indexStart, @indexEnd-@indexStart+1 )

			
			SELECT @sql = p.codeSql 
			FROM [accounting].[Pattern] p 
			WHERE (p.namePattern = @pattern) AND (p.source = @source)

			IF @@ROWCOUNT <> 0
			BEGIN
				
				SET @sql = REPLACE( @sql, ''{ID}'', CAST(@id AS VARCHAR(50)) )

				UPDATE ##ExchangeTemp SET field = ''''
				BEGIN TRY
					EXEC( @sql ) 
				END TRY
				BEGIN CATCH
					Set @message = ''Błąd SQL w definiowaniu wzorca:'' + @pattern + ''! ('' + ERROR_MESSAGE() +'')''
				END CATCH
			END
			ELSE
				SET @message = ''Brak definicji wzorca:'' + @pattern

			IF @message = ''''
			BEGIN
				SELECT @valPattern = field FROM ##ExchangeTemp
				SET @result = REPLACE( @result, @pattern, @valPattern )
			END
		END
		ELSE
			SET @ok = 0	
	END 

END' 
END
GO

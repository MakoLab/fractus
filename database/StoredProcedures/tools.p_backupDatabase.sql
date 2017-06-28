/*
name=[tools].[p_backupDatabase]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
QPuOQGOqla8KMzWIwtksjg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_backupDatabase]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_backupDatabase]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_backupDatabase]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [tools].[p_backupDatabase]
@xmlVar XML
AS
BEGIN 

DECLARE @path nvarchar(500),@file nvarchar(500),@database varchar(500), @sqlstm nvarchar(4000),@archivizationTemplate nvarchar(1000)
DECLARE @message varchar(1000), @error int

	SELECT  @path =  x.value(''path[1]'',''nvarchar(500)''),
			@file = x.value(''file[1]'',''nvarchar(500)''),
		   @database = x.value(''database[1]'',''nvarchar(500)'')
	FROM @xmlVar.nodes(''root'') as a(x)
	
	SELECT @sqlstm =  ''	BACKUP DATABASE '' +@database + ''
		TO  DISK = ''''''+ @path + @file + ''''''
		WITH NOFORMAT, NOINIT,  
		NAME = N''''Fraktusek2-Full Database Backup'''', SKIP, NOREWIND, NOUNLOAD,  STATS = 10 ''
		
	IF @sqlstm IS NULL
		SELECT @message = ''Błędne parametry wejściowe''
	ELSE
	BEGIN
		EXEC(@sqlstm)

		SELECT @error = @@error
		
		IF @error <> 0
		SELECT TOP 1 @message = ''Błąd podczas tworzenia kopii zapasowej: '' + CAST(@error as varchar(10)) + '' ('' + text + '')''
		FROM sys.messages
		WHERE message_id = @error

		IF @error = 0
			BEGIN		
				SELECT @archivizationTemplate = textValue 
				FROM configuration.Configuration 
				WHERE [key] = ''system.archivizationTemplate''
				
				IF @archivizationTemplate IS NOT NULL
					BEGIN
					
						SELECT @sqlstm = REPLACE( REPLACE( @archivizationTemplate,''{file}'',@file ),''{path}'' ,@path )
						
						DECLARE @result int
						EXEC @result = master.dbo.xp_cmdshell @sqlstm, NO_OUTPUT
			
						IF @result <> 0
						SELECT TOP 1 @message = ''Błąd podczas przetwarzania pliku kopii zapasowej.''
					--print @sqlstm
					END
			END
	END
	
	IF @message IS NULL SET @message = ''Operacja zakończona sukcesem.''

	SELECT @message FOR XML PATH(''message''), TYPE
END


' 
END
GO

/*
name=[repository].[p_insertFileDescriptor]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
EUc3LR5w65Fcuy8w6PBVDA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[repository].[p_insertFileDescriptor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [repository].[p_insertFileDescriptor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[repository].[p_insertFileDescriptor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [repository].[p_insertFileDescriptor]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    
    /*Wstawienie danych o opisie plików*/
    INSERT  INTO [repository].FileDescriptor
            (
              id,
              repositoryId,
              mimeTypeId,
              modificationDate,
              modificationApplicationUserId,
              originalFilename,
              tag,
              version
            )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''repositoryId'').value(''.'', ''char(36)''),''''),
                    NULLIF(con.query(''mimeTypeId'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''modificationDate'').value(''.'', ''datetime''),''''),
                    NULLIF(con.query(''modificationApplicationUserId'').value(''.'', ''char(36)''),''''),
                    NULLIF(con.query(''originalFilename'').value(''.'', ''nvarchar(256)''),''''),
                    NULLIF(con.query(''tag'').value(''.'', ''nvarchar(500)''), ''''),
                    NULLIF(con.query(''version'').value(''.'', ''char(36)''), '''')
            FROM    @xmlVar.nodes(''/root/fileDescriptor/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:FileDescriptor; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            
            IF @rowcount = 0 
                RAISERROR ( 50011, 16, 1 ) ;
        END
' 
END
GO

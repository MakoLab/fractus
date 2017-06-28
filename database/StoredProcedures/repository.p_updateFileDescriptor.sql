/*
name=[repository].[p_updateFileDescriptor]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fO26ByC47ziMXrFQvj1vXw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[repository].[p_updateFileDescriptor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [repository].[p_updateFileDescriptor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[repository].[p_updateFileDescriptor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [repository].[p_updateFileDescriptor]
@xmlVar XML
AS
BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
        /*Aktualizacja danych o repozytorium plików*/
        UPDATE  repository.FileDescriptor
        SET     repositoryId = CASE WHEN con.exist(''repositoryId'') = 1
                                    THEN con.query(''repositoryId'').value(''.'', ''char(36)'')
                                    ELSE NULL
                               END,
                mimeTypeId = CASE WHEN con.exist(''mimeTypeId'') = 1
                                  THEN con.query(''mimeTypeId'').value(''.'', ''char(36)'')
                                  ELSE NULL
                             END,
                modificationDate = CASE WHEN con.exist(''modificationDate'') = 1
                                        THEN con.query(''modificationDate'').value(''.'', ''datetime'')
                                        ELSE NULL
                                   END,
                modificationApplicationUserId = CASE WHEN con.exist(''modificationApplicationUserId'') = 1
                                                     THEN con.query(''modificationApplicationUserId'').value(''.'', ''char(36)'')
                                                     ELSE NULL
                                                END,
                originalFilename = CASE WHEN con.exist(''originalFilename'') = 1
                                        THEN con.query(''originalFilename'').value(''.'', ''nvarchar(500)'')
                                        ELSE NULL
                                   END,
                tag = CASE WHEN con.exist(''tag'') = 1
                           THEN con.query(''tag'').value(''.'', ''char(36)'')
                           ELSE NULL
                      END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/fileDescriptor/entry'') AS C ( con )
        WHERE   FileDescriptor.id = con.query(''id'').value(''.'', ''char(36)'')
                AND FileDescriptor.version = con.query(''version'').value(''.'', ''char(36)'') 


		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:FileDescriptor; error:''
                    + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                
                IF @rowcount = 0 
                    RAISERROR ( 50012, 16, 1 ) ;
            END
    END
' 
END
GO

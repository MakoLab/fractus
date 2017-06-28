/*
name=[dictionary].[p_updateMimeType]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Y0oZPrg/4hfnYr/hd1Ah4w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateMimeType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_updateMimeType]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateMimeType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_updateMimeType]
@xmlVar XML
AS
BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
        /*Aktualizacja danych typóe mime*/
        UPDATE  dictionary.MimeType
        SET     name = CASE WHEN con.exist(''name'') = 1
                            THEN con.query(''name'').value(''.'', ''varchar(50)'')
                            ELSE NULL
                       END,
                extensions = CASE WHEN con.exist(''extensions'') = 1
                                  THEN con.query(''extensions'').value(''.'', ''varchar(50)'')
                                  ELSE NULL
                             END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/mimeType/entry'') AS C ( con )
        WHERE   MimeType.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobieranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
        /*Aktualizacja wersji słowników*/
        EXEC [dictionary].[p_updateVersion] ''MimeType''
        
        /*Obsługa błędów i wyjątków*/
        IF @@error <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:MimeType; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
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

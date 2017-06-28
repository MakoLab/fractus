/*
name=[dictionary].[p_updateDocumentType]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
IemyVAyUAzx1TgTwaaev8g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateDocumentType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_updateDocumentType]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateDocumentType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_updateDocumentType]
@xmlVar XML
AS
BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
        /*Aktualizacja danych o typach dokumentów*/
        UPDATE  dictionary.DocumentType
        SET     symbol = CASE WHEN con.exist(''symbol'') = 1
                              THEN con.query(''symbol'').value(''.'',''varchar(20)'')
                              ELSE NULL
                         END,
                xmlLabels = CASE WHEN con.exist(''xmlLabels'') = 1
                                 THEN con.query(''xmlLabels/*'')
                                 ELSE NULL
                            END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END,
                [order] = CASE WHEN con.exist(''order'') = 1
                               THEN con.query(''order'').value(''.'', ''int'')
                               ELSE NULL
                          END,
                documentCategory = CASE WHEN con.exist(''documentCategory'') = 1
                               THEN con.query(''documentCategory'').value(''.'', ''int'')
                               ELSE NULL
                          END,
                [xmlOptions] = CASE WHEN con.exist(''xmlOptions'') = 1
                               THEN con.query(''xmlOptions/*'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/documentType/entry'') AS C ( con )
        WHERE   DocumentType.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
        /*AKtualizacja wersji słowników*/
        EXEC [dictionary].[p_updateVersion] ''DocumentType''
        
        /*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:DocumentType; error:''
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

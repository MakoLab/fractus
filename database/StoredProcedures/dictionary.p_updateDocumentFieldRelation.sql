/*
name=[dictionary].[p_updateDocumentFieldRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
HAzmFlYW+UskS5RAmmlbPA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateDocumentFieldRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_updateDocumentFieldRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateDocumentFieldRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_updateDocumentFieldRelation]
@xmlVar XML
AS
BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
        /*Aktualizacja danych o powiązaniach atrybutów dokumentów*/
        UPDATE  dictionary.DocumentFieldRelation
        SET     documentFieldId = CASE WHEN con.exist(''documentFieldId'') = 1
                                       THEN con.query(''documentFieldId'').value(''.'', ''char(36)'')
                                       ELSE NULL
                                  END,
                documentTypeId = CASE WHEN con.exist(''documentTypeId'') = 1
                                      THEN con.query(''documentTypeId'').value(''.'', ''char(36)'')
                                      ELSE NULL
                                 END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/documentFieldRelation/entry'') AS C ( con )
        WHERE   DocumentFieldRelation.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
        /*Aktualizacja wersji słowników*/
        EXEC [dictionary].[p_updateVersion] ''DocumentFieldRelation''
        
        /*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:DocumentFieldRelation; error:''
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

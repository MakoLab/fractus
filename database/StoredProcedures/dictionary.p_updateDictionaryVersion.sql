/*
name=[dictionary].[p_updateDictionaryVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
paNqJzXp0YGDidp+j7x5LA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateDictionaryVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_updateDictionaryVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateDictionaryVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_updateDictionaryVersion]
@xmlVar XML
AS
BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
        /*Aktualizacja danych o wersjach słowników*/
        UPDATE  dictionary.DictionaryVersion
        SET     tableName = CASE WHEN con.exist(''tableName'') = 1
                                 THEN con.query(''tableName'').value(''.'', ''varchar(255)'')
                                 ELSE NULL
                            END,
                versionNumber = CASE WHEN con.exist(''versionNumber'') = 1
                                     THEN con.query(''versionNumber'').value(''.'', ''int'')
                                     ELSE NULL
                                END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/dictionaryVersion/entry'') AS C ( con )
        WHERE   DictionaryVersion.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:DictionaryVersion; error:''
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

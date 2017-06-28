/*
name=[dictionary].[p_updateNumberSetting]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4RHRq4a5LuHYmW3yGQjbqg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateNumberSetting]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_updateNumberSetting]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateNumberSetting]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_updateNumberSetting]
@xmlVar XML
AS
BEGIN
		
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
        /*Aktualizacja danych o ustawieniach numeracji*/
        UPDATE  dictionary.NumberSetting
        SET
                numberFormat = CASE WHEN con.exist(''numberFormat'') = 1
                                    THEN con.query(''numberFormat'').value(''.'', ''nvarchar(100)'')
                                    ELSE NULL
                               END,
                seriesFormat = CASE WHEN con.exist(''seriesFormat'') = 1
                                    THEN con.query(''seriesFormat'').value(''.'', ''nvarchar(100)'')
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
                          END
        FROM    @xmlVar.nodes(''/root/NumberSetting/entry'') AS C ( con )
        WHERE   NumberSetting.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobieranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
        /*Aktualizacja wersji słowników*/
        EXEC [dictionary].[p_updateVersion] ''NumberSetting''
        
        /*Obsługa błędów i wyjątków*/
        IF @@error <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:NumberSetting; error:''
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

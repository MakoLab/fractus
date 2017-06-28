/*
name=[finance].[p_updateExchangeRate]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
WpFTD34UYTH8X7Aacpstjw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_updateExchangeRate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_updateExchangeRate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_updateExchangeRate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [finance].[p_updateExchangeRate]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    
    /*Aktualizacja danych o kursach walut*/
    UPDATE  [finance].[ExchangeRate]
    SET     date = CASE WHEN con.exist(''date'') = 1
                        THEN con.query(''date'').value(''.'', ''datetime'')
                        ELSE NULL
                   END,
            currencyId = CASE WHEN con.exist(''currencyId'') = 1
                              THEN con.query(''currencyId'').value(''.'', ''char(36)'')
                              ELSE NULL
                         END,
            scale = CASE WHEN con.exist(''scale'') = 1
                         THEN con.query(''scale'').value(''.'', ''numeric(18,0)'')
                         ELSE NULL
                    END,
            rate = CASE WHEN con.exist(''rate'') = 1
                        THEN con.query(''rate'').value(''.'', ''numeric(18,6)'')
                        ELSE NULL
                   END,
            version = CASE WHEN con.exist(''_version'') = 1
                           THEN con.query(''_version'').value(''.'', ''char(36)'')
                           ELSE NULL
                      END
    FROM    @xmlVar.nodes(''/root/exchangeRate/entry'') AS C ( con )
    WHERE   ExchangeRate.id = con.query(''id'').value(''.'', ''char(36)'')
            AND ExchangeRate.version = con.query(''version'').value(''.'', ''char(36)'')

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błedów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:ExchangeRate; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            
            IF @rowcount = 0 
                RAISERROR ( 50012, 16, 1 ) ;
        END
' 
END
GO

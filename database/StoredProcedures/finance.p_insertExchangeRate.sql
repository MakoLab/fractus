/*
name=[finance].[p_insertExchangeRate]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
WgDry4iddJbdSxXobiSaeA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_insertExchangeRate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_insertExchangeRate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_insertExchangeRate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [finance].[p_insertExchangeRate]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    
    /*Wstawianie danych o kursach walut*/
    INSERT  INTO [finance].[ExchangeRate]
            (
              id,
              date,
              currencyId,
              scale,
              rate,
              version
            )
            SELECT  con.query(''id'').value(''.'', ''char(36)''),
                    con.query(''date'').value(''.'', ''datetime''),
                    con.query(''currencyId'').value(''.'', ''char(36)''),
                    con.query(''scale'').value(''.'', ''numeric(18,0)''),
                    con.query(''rate'').value(''.'', ''numeric(18,6)''),
                    con.query(''version'').value(''.'', ''char(36)'')
            FROM    @xmlVar.nodes(''/root/exchangeRate/entry'') AS C ( con )

	
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:ExchangeRate; error:''
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

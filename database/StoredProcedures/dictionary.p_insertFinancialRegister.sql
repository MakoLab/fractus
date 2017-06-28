/*
name=[dictionary].[p_insertFinancialRegister]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
M92c2LxreNrUnGQWiELG6Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertFinancialRegister]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_insertFinancialRegister]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertFinancialRegister]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_insertFinancialRegister]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    /*Wstawienie danych o miejscach wystawienia*/
    INSERT  INTO dictionary.FinancialRegister
            (
              id,
              version,
              symbol,
              xmlLabels,
              currencyId,
              accountingAccount,
              bankContractorId,
              bankAccountNumber,
              registerCategory,
              xmlOptions,
              [order],
              branchId
            )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
					con.query(''version'').value(''.'', ''char(36)''),
                    NULLIF(con.query(''symbol'').value(''.'', ''nvarchar(10)''),''''),
                    CASE WHEN con.exist(''xmlLabels'') = 1
                         THEN con.query(''xmlLabels/*'')
                         ELSE NULL
                    END,
                    NULLIF(con.query(''currencyId'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''accountingAccount'').value(''.'', ''nvarchar(50)''),''''),
                    NULLIF(con.query(''bankContractorId'').value(''.'', ''char(36)''),''''),
                    con.query(''bankAccountNumber'').value(''.'', ''varchar(40)''),
                    con.query(''registerCategory'').value(''.'', ''int''),
                    CASE WHEN con.exist(''xmlOptions'') = 1
                         THEN con.query(''xmlOptions/*'')
                         ELSE NULL
                    END,
                    con.query(''order'').value(''.'', ''int''),
                    NULLIF(con.query(''branchId'').value(''.'', ''char(36)''), '''')
            FROM    @xmlVar.nodes(''/root/financialRegister/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Aktualizacja miejsc wystawienia*/
    EXEC [dictionary].[p_updateVersion] ''FinancialRegister''
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR	<> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:financialRegister; error:''
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

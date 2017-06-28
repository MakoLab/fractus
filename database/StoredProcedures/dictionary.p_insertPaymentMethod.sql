/*
name=[dictionary].[p_insertPaymentMethod]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
skyLW1xlxU/1C3d3bgwV2A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertPaymentMethod]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_insertPaymentMethod]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertPaymentMethod]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dictionary].[p_insertPaymentMethod]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    
    /*Wstawienie danych o metodach płatności*/
    INSERT  INTO [dictionary].[PaymentMethod]
            (
              id,
              xmlLabels,
              dueDays,
              isGeneratingCashierDocument,
              isIncrementingDueAmount,
              version,
              [order],
              isRequireSettlement
            )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
                    con.query(''xmlLabels/*''),
                    con.query(''dueDays'').value(''.'', ''int''),
                    NULLIF(con.query(''isGeneratingCashierDocument'').value(''.'', ''char(1)''),''''),
                    NULLIF(con.query(''isGeneratingCashierDocument'').value(''.'', ''char(1)''),''''),
                    con.query(''version'').value(''.'', ''char(36)''),
                    con.query(''order'').value(''.'', ''int''),
                    NULLIF(con.query(''isRequireSettlement'').value(''.'', ''char(1)''),'''')
            FROM    @xmlVar.nodes(''/root/paymentMethod/entry'') AS C ( con )


	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Aktualizacja wersji słowników*/
    EXEC [dictionary].[p_updateVersion] ''PaymentMethod''
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:PaymentMethod; error:''
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

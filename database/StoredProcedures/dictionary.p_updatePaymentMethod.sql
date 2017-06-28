/*
name=[dictionary].[p_updatePaymentMethod]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
7yDMYkKvK9GWuh9u3R4h4Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updatePaymentMethod]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_updatePaymentMethod]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updatePaymentMethod]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dictionary].[p_updatePaymentMethod]
@xmlVar XML
AS
DECLARE @errorMsg varchar(2000),
        @rowcount int

    
    
    /*Aktualizacja danych o metodach płatności*/
    UPDATE  [dictionary].[PaymentMethod]
    SET     xmlLabels = CASE WHEN con.exist(''xmlLabels'') = 1
                             THEN con.query(''xmlLabels/*'')
                             ELSE NULL
                        END,
            dueDays = CASE WHEN con.exist(''dueDays'') = 1
                           THEN con.query(''dueDays'').value(''.'', ''int'')
                           ELSE NULL
                      END,
            isGeneratingCashierDocument = CASE WHEN con.exist(''isGeneratingCashierDocument'') = 1
                                               THEN con.query(''isGeneratingCashierDocument'').value(''.'', ''char(1)'')
                                               ELSE NULL
                                          END,
            isIncrementingDueAmount = CASE WHEN con.exist(''isIncrementingDueAmount'') = 1
                                           THEN con.query(''isIncrementingDueAmount'').value(''.'', ''char(1)'')
                                           ELSE NULL
                                      END,
            isRequireSettlement = CASE WHEN con.exist(''isRequireSettlement'') = 1
                                           THEN con.query(''isRequireSettlement'').value(''.'', ''char(1)'')
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
    FROM    @xmlVar.nodes(''/root/paymentMethod/entry'') AS C ( con )
    WHERE   PaymentMethod.id = con.query(''id'').value(''.'', ''char(36)'')

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Aktualizacja wersji słowników*/
    EXEC [dictionary].[p_updateVersion] ''PaymentMethod''
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:PaymentMethod; error:''
                + cast(@@error as varchar(50)) + ''; ''
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

/*
name=[finance].[p_deletePaymentSettlement]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
gIkkHVBEZ1t0+71w2FZVug==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_deletePaymentSettlement]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_deletePaymentSettlement]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_deletePaymentSettlement]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [finance].[p_deletePaymentSettlement]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    /*Kasowanie danych o rozliczeniach płatności*/
    DELETE  FROM [finance].PaymentSettlement
    WHERE   id IN (
            SELECT  NULLIF(con.value(''(id)[1]'', ''char(36)''), '''')
            FROM    @xmlVar.nodes(''/root/paymentSettlement/entry'') AS C ( con )
            )

	 
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd kasowania danych:PaymentSettlement; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
' 
END
GO

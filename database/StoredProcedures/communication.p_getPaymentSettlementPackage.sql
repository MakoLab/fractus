/*
name=[communication].[p_getPaymentSettlementPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
YPcPqOk/OOXO6FcwcinwJQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getPaymentSettlementPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getPaymentSettlementPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getPaymentSettlementPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getPaymentSettlementPackage]
@id UNIQUEIDENTIFIER
AS 
    BEGIN
	/*Deklaracja zmiennych*/
        DECLARE @result XML
	/*Budowanie obrazy danych*/
        SELECT  @result = (
							SELECT (
								SELECT  *
								FROM    finance.PaymentSettlement
								WHERE   PaymentSettlement.id = @id
								FOR XML PATH(''entry''),TYPE
							) FOR XML PATH(''paymentSettlement''),TYPE
                          )
		
	/*Zwrócenie wyników*/
        SELECT  @result
        FOR     XML PATH(''root''),
                    TYPE
    END
' 
END
GO

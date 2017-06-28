/*
name=[finance].[p_checkPaymentVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
FhX9EVCMsrceOFQyjwAuLA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_checkPaymentVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_checkPaymentVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_checkPaymentVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [finance].[p_checkPaymentVersion]
    @version UNIQUEIDENTIFIER
AS
    BEGIN
		
		/*Walidacja wersji Paymentu*/
        IF NOT EXISTS ( SELECT  id
                        FROM    finance.Payment
                        WHERE   Payment.version = @version ) 
            RAISERROR ( 50012, 16, 1 )
END
' 
END
GO

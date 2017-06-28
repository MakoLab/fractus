/*
name=[communication].[p_getFinancialDocumentPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
/BQZu8DgZOG0MKMHpWzgEA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getFinancialDocumentPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getFinancialDocumentPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getFinancialDocumentPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getFinancialDocumentPackage] @id UNIQUEIDENTIFIER
AS /*Gets item xml package that match input parameter*/
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @result XML
        
		/*Tworzenie obrazu danych*/
        SELECT  @result = (         
							
							( 

							SELECT    ( SELECT    ( SELECT    CDL.*
                                          FROM      document.FinancialDocumentHeader  CDL
                                          WHERE     CDL.id = @id
                                        FOR XML PATH(''entry''),TYPE
                                        )
                            FOR XML PATH(''financialDocumentHeader''), TYPE
                            ),
                            ( SELECT    ( SELECT   *
                                          FROM      finance.Payment
                                          WHERE     financialDocumentHeaderId = @id
										  FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''payment''), TYPE
                            ),
                            ( SELECT    ( SELECT    s.*
                                          FROM      finance.PaymentSettlement s
												JOIN finance.Payment p ON s.incomePaymentId = p.id OR s.outcomePaymentId = p.id
											WHERE   p.financialDocumentHeaderId = @id 
                                        FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''paymentSettlement''),TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].DocumentAttrValue
                                          WHERE     financialDocumentHeaderId = @id
                                        FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''documentAttrValue''), TYPE
                            )
                FOR XML PATH(''root''), TYPE
                ) )

        /*Zwrócenie wyników*/                  
        SELECT  @result 
        /*Obsługa pustego resulta*/
        IF @@rowcount = 0 
            SELECT  ''''
            FOR     XML PATH(''root''),
                        TYPE
    END
' 
END
GO

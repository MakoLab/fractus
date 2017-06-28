/*
name=[communication].[p_createFinancialDocumentPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
0ZeVHE9mpzaJsGcpJ0R/dw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createFinancialDocumentPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_createFinancialDocumentPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createFinancialDocumentPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_createFinancialDocumentPackage] @xmlVar XML
AS 
    BEGIN

		/*Deklaracja zmiennych*/
        DECLARE @snap XML,
            @errorMsg VARCHAR(2000),
            @rowcount INT,
            @financialDocumentHeaderId UNIQUEIDENTIFIER,
            @previousVersion UNIQUEIDENTIFIER,
            @localTransactionId UNIQUEIDENTIFIER,
            @deferredTransactionId UNIQUEIDENTIFIER,
			@databaseId UNIQUEIDENTIFIER


		/*Pobranie danych o transakcji*/
        SELECT  @financialDocumentHeaderId = x.value(''@businessObjectId'', ''char(36)''),
				@databaseId =  x.value(''@databaseId'', ''char(36)''),
                @previousVersion = x.value(''@previousVersion'', ''char(36)''),
                @localTransactionId = x.value(''@localTransactionId'',''char(36)''),
                @deferredTransactionId = x.value(''@deferredTransactionId'',''char(36)'')
        FROM    @xmlVar.nodes(''root'') AS a ( x )

		/*Walidacja dokumentu*/
        IF NOT EXISTS ( SELECT  id
                        FROM     document.FinancialDocumentHeader
                        WHERE   id = @financialDocumentHeaderId ) 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych; table: OutgoingXmlQueue; Brak dokumentu o id = ''
					+ CAST(@financialDocumentHeaderId AS VARCHAR(36)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
                RETURN 0
            END

		/*Tworzenie obrazu danych*/
        SELECT  @snap = (         
							
							( 

							SELECT @previousVersion AS ''@previousVersion'',   ( SELECT    ( SELECT    CDL.*
                                          FROM      document.FinancialDocumentHeader  CDL
                                          WHERE     CDL.id = @financialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''financialDocumentHeader''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT   *
                                          FROM      finance.Payment
                                          WHERE     financialDocumentHeaderId = @financialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''payment''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT * FROM (
										  SELECT    s.*
                                          FROM      finance.PaymentSettlement s
												JOIN finance.Payment p ON s.incomePaymentId = p.id 
										  WHERE   p.financialDocumentHeaderId = @financialDocumentHeaderId 
										  UNION		
										  SELECT    s.*
                                          FROM      finance.PaymentSettlement s
												JOIN finance.Payment p ON s.outcomePaymentId = p.id
										  WHERE   p.financialDocumentHeaderId = @financialDocumentHeaderId
										  ) x
										   
                                        FOR XML PATH(''entry''),  TYPE
                                        )
                            FOR
                              XML PATH(''paymentSettlement''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].DocumentAttrValue
                                          WHERE     financialDocumentHeaderId = @financialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''documentAttrValue''),
                                  TYPE
                            )
                FOR
                  XML PATH(''root''),
                      TYPE
                ) )

		/*Wstawienie danych*/
        INSERT  INTO communication.OutgoingXmlQueue
                (
                  id,
                  localTransactionId,
				  databaseId,
                  deferredTransactionId,
                  [type],
                  [xml],
                  creationDate
                )
                SELECT  NEWID(),
                        @localTransactionId,
						@databaseId,
                        @deferredTransactionId,
                        ''FinancialDocumentSnapshot'',
                        @snap,
                        GETDATE()

		/*Pobranie liczby zmodyfikowanych wierszy*/
        SET @rowcount = @@ROWCOUNT

		/*Obsługa wyjątków i błędów*/
        IF @@error <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table: OutgoingXmlQueue; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                IF @rowcount = 0 
                    RAISERROR ( 50011, 16, 1 ) ;
            END

    END
' 
END
GO

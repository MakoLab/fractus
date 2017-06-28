/*
name=[communication].[p_createPaymentPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
lXi69JiU39MHhLh2p1zjCw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createPaymentPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_createPaymentPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createPaymentPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [communication].[p_createPaymentPackage] @xmlVar XML   
AS 
    BEGIN
--[communication].[p_createPaymentPackage] ''<root action="delete" previousVersion="95B40426-EC85-43A2-A032-AE0B64615982" businessObjectId="6ECF58FB-F8ED-4569-89DE-83ABFBD1EACB" databaseId="E06C6D88-CB0C-4FDB-A24F-1DC3969281EA" localTransactionId="6A30C782-6DAD-4F1F-94B9-FA8A0DFB5E6D" deferredTransactionId="9F5EC4A5-45DE-4BA3-BACC-683A64AECD3B" />''
		/*Deklaracja zmiennych*/
        DECLARE @snap XML,
            @errorMsg VARCHAR(2000),
            @rowcount INT,
            @paymentId UNIQUEIDENTIFIER,
            @previousVersion UNIQUEIDENTIFIER,
            @localTransactionId UNIQUEIDENTIFIER,
            @deferredTransactionId UNIQUEIDENTIFIER,
			@databaseId UNIQUEIDENTIFIER,
			@action varchar(50)


		/*Pobranie danych o transakcji*/
        SELECT  @paymentId = x.value(''@businessObjectId'', ''char(36)''),
				@databaseId =  x.value(''@databaseId'', ''char(36)''),
                @previousVersion = x.value(''@previousVersion'', ''char(36)''),
                @localTransactionId = x.value(''@localTransactionId'',''char(36)''),
                @deferredTransactionId = x.value(''@deferredTransactionId'',''char(36)''),
                @action =  x.value(''@action'',''varchar(50)'')
        FROM    @xmlVar.nodes(''root'') AS a ( x )

		 IF @paymentId IS NULL 
            BEGIN
               RETURN 0;
            END

		/*Walidacja dokumentu*/
        IF NOT EXISTS ( SELECT  id
                        FROM     finance.Payment
                        WHERE   id = @paymentId ) 
            AND  ISNULL(@action,'''')  <> ''delete''        
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table: OutgoingXmlQueue; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
                RETURN 0
            END
            
		IF @action = ''delete''
			BEGIN
				/*Tworzenie obrazu danych*/
				SELECT  @snap = (  SELECT       
												( SELECT    
														(	SELECT    @action AS ''@action'', @paymentId AS  ''id'',@previousVersion AS ''previousVersion''
															FOR XML PATH(''entry''), TYPE
														)
													FOR XML PATH(''payment''), TYPE
												)
									FOR XML PATH(''root'') ,TYPE
								) 
			
			END
		ELSE
			BEGIN
				/*Tworzenie obrazu danych*/
			        SELECT  @snap = (         
							
							( 

							SELECT @previousVersion AS ''@previousVersion'',
                            ( SELECT    ( SELECT  @action AS ''@action'',   *
                                          FROM      finance.Payment
                                          WHERE     id = @paymentId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''payment''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    s.*
                                          FROM      finance.PaymentSettlement s
												JOIN finance.Payment p ON s.incomePaymentId = p.id OR s.outcomePaymentId = p.id
											WHERE   p.id = @paymentId 
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''paymentSettlement''),
                                  TYPE
                            )
                FOR
                  XML PATH(''root''),
                      TYPE
                ) )
			END
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
                        ''Payment'',
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

/*
name=[communication].[p_createCommercialDocumentPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Mykn41AG/d9yr9BUGfl9Zg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createCommercialDocumentPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_createCommercialDocumentPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createCommercialDocumentPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [communication].[p_createCommercialDocumentPackage]
@xmlVar XML
AS
BEGIN
 --RAISERROR ( 50012, 16, 1 ) ;
		/*Deklaracja zmiennych*/
        DECLARE @snap XML,
            @errorMsg VARCHAR(2000),
            @rowcount INT,
            @commercialDocumentHeaderId UNIQUEIDENTIFIER,
            @previousVersion UNIQUEIDENTIFIER,
            @localTransactionId UNIQUEIDENTIFIER,
            @deferredTransactionId UNIQUEIDENTIFIER,
			@databaseId UNIQUEIDENTIFIER,
			@packageName varchar(500)


		/*Pobranie danych o transakcji*/
        SELECT  @commercialDocumentHeaderId = x.value(''@businessObjectId'', ''char(36)''),
				@databaseId =  x.value(''@databaseId'', ''char(36)''),
                @previousVersion = x.value(''@previousVersion'', ''char(36)''),
                @localTransactionId = x.value(''@localTransactionId'',''char(36)''),
                @deferredTransactionId = x.value(''@deferredTransactionId'',''char(36)''),
                @packageName = NULLIF(x.value(''@packageName'',''varchar(500)''),'''')
        FROM    @xmlVar.nodes(''root'') AS a ( x )

		/*Walidacja dokumentu*/
        IF NOT EXISTS ( SELECT  id
                        FROM     [document].CommercialDocumentHeader
                        WHERE   id = @commercialDocumentHeaderId ) 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych; table: OutgoingXmlQueue; Brak dokumentu o id = ''
					+ CAST(@commercialDocumentHeaderId AS VARCHAR(36)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
                RETURN 0
            END

        
		/*Tworzenie obrazu danych*/
        SELECT  @snap = (         
							
							( 

							SELECT @previousVersion AS ''@previousVersion'',   ( SELECT    ( SELECT    CDL.*--,  s.[numberSettingId]
                                          FROM      [document].CommercialDocumentHeader CDL 
										---	LEFT JOIN document.Series s ON CDL.seriesId = s.id
                                          WHERE     CDL.id = @commercialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''commercialDocumentHeader''),
                                  TYPE
                            ),
                            ( 
							SELECT    (  SELECT    sh.*
												  FROM  service.ServiceHeader sh 
												  WHERE     sh.commercialDocumentHeaderId = @commercialDocumentHeaderId
												  FOR XML PATH(''entry''),TYPE )
                                     FOR XML PATH(''serviceHeader''), TYPE
                            ),
							(
                            SELECT    (  SELECT    sh.*
												  FROM  service.ServiceHeaderEmployees sh 
												  WHERE     sh.serviceHeaderId = @commercialDocumentHeaderId
												  FOR XML PATH(''entry''),TYPE )
                                     FOR XML PATH(''serviceHeaderEmployees''), TYPE
                            ),
                            (
                            SELECT    (  SELECT    sh.*
												  FROM  service.ServiceHeaderServicedObjects sh 
												  WHERE     sh.serviceHeaderId = @commercialDocumentHeaderId
												  FOR XML PATH(''entry''),TYPE )
                                     FOR XML PATH(''serviceHeaderServicedObjects''), TYPE
                            ),
                            (                         
                            SELECT    (  SELECT    sh.*
												  FROM  service.ServiceHeaderServicePlace sh 
												  WHERE     sh.serviceHeaderId = @commercialDocumentHeaderId
												  FOR XML PATH(''entry''),TYPE )
                                     FOR XML PATH(''serviceHeaderServicePlace''), TYPE
                            ),
                            ( SELECT    ( SELECT   *
                                          FROM      [document].CommercialDocumentLine 
                                          WHERE     commercialDocumentHeaderId = @commercialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''commercialDocumentLine''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].CommercialDocumentVatTable
                                          WHERE     commercialDocumentHeaderId = @commercialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''commercialDocumentVatTable''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].DocumentAttrValue
                                          WHERE     commercialDocumentHeaderId = @commercialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''documentAttrValue''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].DocumentLineAttrValue
                                          WHERE     commercialDocumentLineId IN (SELECT id FROM document.CommercialDocumentLine WHERE commercialDocumentHeaderId = @commercialDocumentHeaderId )
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''documentLineAttrValue''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [finance].Payment
                                          WHERE     commercialDocumentHeaderId = @commercialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''payment''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [finance].PaymentSettlement
                                          WHERE     incomePaymentId IN (
                                                    SELECT  id
                                                    FROM    [finance].Payment
                                                    WHERE   commercialDocumentHeaderId = @commercialDocumentHeaderId )
                                                    OR outcomePaymentId IN (
                                                    SELECT  id
                                                    FROM    [finance].Payment
                                                    WHERE   commercialDocumentHeaderId = @commercialDocumentHeaderId )
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
                        ISNULL(@packageName,''CommercialDocumentSnapshot''),
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

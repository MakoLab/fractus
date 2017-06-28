/*
name=[communication].[p_getCommercialDocumentPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
iLqTKqO18xQiQgeTjRB0fg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getCommercialDocumentPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getCommercialDocumentPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getCommercialDocumentPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getCommercialDocumentPackage] @id UNIQUEIDENTIFIER
AS /*Gets item xml package that match input parameter*/
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @result XML
        
		/*Budowa obrazu danych*/
          SELECT  @result = (         SELECT  ( SELECT    ( SELECT    ( SELECT    CDL.*,  s.[numberSettingId]
                                          FROM      [document].CommercialDocumentHeader CDL 
											LEFT JOIN document.Series s ON CDL.seriesId = s.id
                                          WHERE     CDL.id = @id
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''commercialDocumentHeader''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT   *
                                          FROM      [document].CommercialDocumentLine 
                                          WHERE     commercialDocumentHeaderId = @id
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''commercialDocumentLine''),
                                  TYPE
                            ),
                            
                            ( 
							SELECT    (  SELECT    sh.*
												  FROM  service.ServiceHeader sh 
												  WHERE     sh.commercialDocumentHeaderId = @id
												  FOR XML PATH(''entry''),TYPE )
                                     FOR XML PATH(''serviceHeader''), TYPE
                            ),
							(
                            SELECT    (  SELECT    sh.*
												  FROM  service.ServiceHeaderEmployees sh 
												  WHERE     sh.serviceHeaderId = @id
												  FOR XML PATH(''entry''),TYPE )
                                     FOR XML PATH(''serviceHeaderEmployees''), TYPE
                            ),
                            (
                            SELECT    (  SELECT    sh.*
												  FROM  service.ServiceHeaderServicedObjects sh 
												  WHERE     sh.serviceHeaderId = @id
												  FOR XML PATH(''entry''),TYPE )
                                     FOR XML PATH(''serviceHeaderServicedObjects''), TYPE
                            ),
                            (                         
                            SELECT    (  SELECT    sh.*
												  FROM  service.ServiceHeaderServicePlace sh 
												  WHERE     sh.serviceHeaderId = @id
												  FOR XML PATH(''entry''),TYPE )
                                     FOR XML PATH(''serviceHeaderServicePlace''), TYPE
                            ),
                            
                            ( SELECT    ( SELECT    *
                                          FROM      [document].CommercialDocumentVatTable
                                          WHERE     commercialDocumentHeaderId = @id
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
                                          WHERE     commercialDocumentHeaderId = @id
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
                                          WHERE     commercialDocumentLineId IN (SELECT id FROM document.CommercialDocumentLine WHERE commercialDocumentHeaderId = @id )
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
                                          WHERE     commercialDocumentHeaderId = @id
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
                                                    WHERE   commercialDocumentHeaderId = @id )
                                                    OR outcomePaymentId IN (
                                                    SELECT  id
                                                    FROM    [finance].Payment
                                                    WHERE   commercialDocumentHeaderId = @id )
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

/*
name=[finance].[p_getPaymentData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
wPOcEcMuzBeypKMmNHXD+Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getPaymentData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_getPaymentData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getPaymentData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [finance].[p_getPaymentData]
    @paymentId UNIQUEIDENTIFIER
AS
		/*Budowanie XML z kompletem informacji o dokumencie*/
         SELECT   
                            ( SELECT    ( SELECT   DISTINCT *
                                          FROM      [finance].Payment
                                          WHERE     id =  @paymentId 
											OR id in ( 
												SELECT    p.id
												FROM      [finance].PaymentSettlement ps
													JOIN finance.Payment p ON ps.incomePaymentId = p.id  OR ps.outcomePaymentId = p.id
												WHERE    ( ps.incomePaymentId = @paymentId OR ps.outcomePaymentId = @paymentId )
													 AND NULLIF(p.id,@paymentId) IS NOT NULL
														)
	                                      FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''payment''),TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [contractor].Contractor
                                          WHERE     id = ( SELECT   contractorId
                                                           FROM     finance.Payment
                                                           WHERE    id = @paymentId)
	                                      FOR XML PATH(''entry''), TYPE
                                        )
                            FOR
                              XML PATH(''contractor''),TYPE
                            ),

                            ( SELECT    ( SELECT    *
                                          FROM      [contractor].ContractorAddress
                                          WHERE     id = ( SELECT   contractorAddressId
                                                           FROM     finance.Payment
                                                           WHERE    id = @paymentId
                                                         )
                                                    
                                        FOR XML PATH(''entry''),TYPE
                                        )
                            FOR XML PATH(''contractorAddress''),TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [finance].PaymentSettlement
                                          WHERE     incomePaymentId = @paymentId
                                                    OR outcomePaymentId = @paymentId
                                        FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''paymentSettlement''), TYPE
                            )
                FOR XML PATH(''root''), TYPE
' 
END
GO

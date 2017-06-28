/*
name=[document].[p_getFinancialDocumentData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
yZaBVWtU+fptBtxLGTgBWw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getFinancialDocumentData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getFinancialDocumentData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getFinancialDocumentData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getFinancialDocumentData]
    @financialDocumentHeaderId UNIQUEIDENTIFIER
AS 
    BEGIN
    
		/*Budowanie XML z kompletem informacji o dokumencie*/
        SELECT  ( SELECT    ( SELECT    ( SELECT    CDL.*,  s.[numberSettingId]
                                          FROM      document.FinancialDocumentHeader CDL 
											LEFT JOIN document.Series s ON CDL.seriesId = s.id
                                          WHERE     CDL.id = @financialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR XML PATH(''financialDocumentHeader''), TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [contractor].Contractor
                                          WHERE     id in ( SELECT   issuingPersonContractorId
                                                           FROM     document.FinancialDocumentHeader
                                                           WHERE    id = @financialDocumentHeaderId
                                                         )
													OR id in ( SELECT   modificationApplicationUserId
                                                           FROM     document.FinancialDocumentHeader
                                                           WHERE    id = @financialDocumentHeaderId
                                                         )
													OR id in ( SELECT   contractorId
                                                           FROM     document.FinancialDocumentHeader
                                                           WHERE    id = @financialDocumentHeaderId
                                                         )
                                                    OR id IN (
														   SELECT   contractorId
                                                           FROM     finance.Payment
                                                           WHERE    financialDocumentHeaderId = @financialDocumentHeaderId
                                                    )
                                                    OR id IN ( SELECT  relatedContractorId
															   FROM    contractor.ContractorRelation
															   WHERE   ContractorId IN ( 
																					SELECT   contractorId
																				   FROM     document.FinancialDocumentHeader
																				   WHERE    id = @financialDocumentHeaderId
																					)
												   )						
	                                      FOR
                                          XML PATH(''entry'') ,TYPE
                                        )
                            FOR
                              XML PATH(''contractor''),
                                  TYPE
                            ),
                           ( SELECT ( 
								SELECT * 
								FROM contractor.ContractorAccount
								WHERE contractorId IN ( SELECT   contractorId
                                                           FROM     document.FinancialDocumentHeader
                                                           WHERE    id = @financialDocumentHeaderId
													)
								FOR XML PATH(''entry''), TYPE
										 )
                            FOR XML PATH(''contractorAccount''), TYPE                    
						),
						( SELECT    (  SELECT    *
									   FROM    contractor.ContractorRelation
									   WHERE   ContractorId IN ( 
															SELECT   contractorId
                                                           FROM     document.FinancialDocumentHeader
                                                           WHERE    id = @financialDocumentHeaderId
															)
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractorRelation''),
                                  TYPE
                            ),
                          ( SELECT    ( SELECT    *
                                          FROM      [contractor].ContractorAttrValue
                                          WHERE     contractorid IN ( 
															SELECT   contractorId
                                                           FROM     document.FinancialDocumentHeader
                                                           WHERE    id = @financialDocumentHeaderId
                                                            )
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractorAttrValue''),
                                  TYPE
                            ),
                            
                            ( SELECT    ( SELECT    *
                                          FROM      [finance].FinancialReport
                                          WHERE     id = (	SELECT    financialReportId
															FROM      document.FinancialDocumentHeader  
															WHERE    id = @financialDocumentHeaderId
                                                         )
                                                    
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''financialReport''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [contractor].ContractorAddress
                                          WHERE     id = ( SELECT   contractorAddressId
                                                           FROM     document.FinancialDocumentHeader
                                                           WHERE    id = @financialDocumentHeaderId
                                                         )
                                                    
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractorAddress''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [finance].PaymentSettlement
                                          WHERE     incomePaymentId IN (
                                                    SELECT  id
                                                    FROM    [finance].Payment
                                                    WHERE   financialDocumentHeaderId = @financialDocumentHeaderId )
                                                    OR outcomePaymentId IN (
                                                    SELECT  id
                                                    FROM    [finance].Payment
                                                    WHERE   financialDocumentHeaderId = @financialDocumentHeaderId )
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
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
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].DocumentRelation
                                          WHERE     @financialDocumentHeaderId IN (firstFinancialDocumentHeaderId, secondFinancialDocumentHeaderId)
												
	                                      FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR XML PATH(''documentRelation''), TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [finance].Payment
                                          WHERE     financialDocumentHeaderId = @financialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''payment''),
                                  TYPE
                            )


                FOR
                  XML PATH(''root''),
                      TYPE
                ) AS returnsXML
    END
' 
END
GO

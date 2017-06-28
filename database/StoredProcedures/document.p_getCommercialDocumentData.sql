/*
name=[document].[p_getCommercialDocumentData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
n7WDocvASBZpWt66f4ItSA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCommercialDocumentData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getCommercialDocumentData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCommercialDocumentData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_getCommercialDocumentData]
    @commercialDocumentHeaderId UNIQUEIDENTIFIER

AS 
 BEGIN

 
DECLARE  @procedure varchar(500)


IF EXISTS (SELECT id FROM configuration.Configuration WHERE textValue = ''custom.p_getCommercialDocumentData'')
	AND NOT EXISTS( SELECT id FROM [document].CommercialDocumentHeader  WHERE id = @commercialDocumentHeaderId)
 BEGIN
	SELECT @procedure = ''EXEC custom.p_getCommercialDocumentData '''''' + CAST(@commercialDocumentHeaderId as varchar(50))+ ''''''''
	EXEC ( @procedure )
	RETURN 0;
 END


		/*Budowanie XML z kompletem informacji o dokumencie*/
        SELECT  ( SELECT    ( SELECT    ( SELECT    CDL.*,  s.[numberSettingId]
                                          FROM      [document].CommercialDocumentHeader CDL 
											LEFT JOIN document.Series s ON CDL.seriesId = s.id
                                          WHERE     CDL.id = @commercialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''commercialDocumentHeader''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT   CommercialDocumentLine.*, 
												Item.code itemCode, 
												Item.itemTypeId itemTypeId, 
												(
													SELECT ia.value
													FROM item.ItemGroupMembership m 
														JOIN item.ItemGroupAttributes ia ON m.itemGroupId = ia.itemGroupId
													WHERE ia.name = ''hideItems'' AND  m.itemId  = Item.id
												) visible
                                          FROM      [document].CommercialDocumentLine 
											JOIN item.Item ON CommercialDocumentLine.itemId = item.id
											
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
                                          FROM      [document].CommercialWarehouseValuation
                                          WHERE     commercialDocumentLineId IN (
																		SELECT id 
																		FROM document.CommercialDocumentLine 
																		WHERE CommercialDocumentHeaderId = @commercialDocumentHeaderId
																				)
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''commercialWarehouseValuation''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].DocumentRelation
                                          WHERE     @commercialDocumentHeaderId IN (firstCommercialDocumentHeaderId, secondCommercialDocumentHeaderId)
												
	                                      FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR XML PATH(''documentRelation''), TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].CommercialWarehouseRelation
                                          WHERE     commercialDocumentLineId IN (
																		SELECT id 
																		FROM document.CommercialDocumentLine 
																		WHERE CommercialDocumentHeaderId = @commercialDocumentHeaderId
																				)
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''commercialWarehouseRelation''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [contractor].Contractor
                                          WHERE     id = ( SELECT   contractorId
                                                           FROM     [document].CommercialDocumentHeader
                                                           WHERE    id = @commercialDocumentHeaderId
                                                         )
                                                    OR id = ( SELECT    receivingPersonContractorId
                                                              FROM      [document].CommercialDocumentHeader
                                                              WHERE     id = @commercialDocumentHeaderId
                                                            )
                                                    OR id = ( SELECT    issuingPersonContractorId
                                                              FROM      [document].CommercialDocumentHeader
                                                              WHERE     id = @commercialDocumentHeaderId
                                                            )
                                                    OR id = ( SELECT    issuerContractorId
                                                              FROM      [document].CommercialDocumentHeader
                                                              WHERE     id = @commercialDocumentHeaderId
                                                            )
                                                    OR id IN ( SELECT  contractorId
															   FROM    [finance].Payment
															   WHERE   commercialDocumentHeaderId = @commercialDocumentHeaderId 
															)
                                                    OR id IN ( SELECT  relatedContractorId
															   FROM    contractor.ContractorRelation
															   WHERE   ContractorId = ( SELECT   contractorId
																						FROM     [document].CommercialDocumentHeader
																						WHERE    id = @commercialDocumentHeaderId
																					)
															)
		
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractor''),
                                  TYPE
                            ), 
						( SELECT ( 
								SELECT * 
								FROM contractor.ContractorAccount
								WHERE contractorId = (
															  SELECT    issuerContractorId
                                                              FROM      [document].CommercialDocumentHeader
                                                              WHERE     id = @commercialDocumentHeaderId
													)
								FOR XML PATH(''entry''), TYPE
										 )
                            FOR XML PATH(''contractorAccount''), TYPE                    
						),
						( SELECT    (  SELECT    *
									   FROM    contractor.ContractorRelation
									   WHERE   ContractorId = ( SELECT   contractorId
																FROM     [document].CommercialDocumentHeader
																WHERE    id = @commercialDocumentHeaderId
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
                                          FROM      [contractor].ContractorAddress
                                          WHERE     id = ( SELECT   contractorAddressId
                                                           FROM     [document].CommercialDocumentHeader
                                                           WHERE    id = @commercialDocumentHeaderId
                                                         )
                                                    OR id = ( SELECT    issuerContractorAddressId
                                                              FROM      [document].CommercialDocumentHeader
                                                              WHERE     id = @commercialDocumentHeaderId
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
                                          FROM      [contractor].ContractorAttrValue
                                          WHERE     contractorid IN ( 
															SELECT   contractorId
															FROM     [document].CommercialDocumentHeader
															WHERE    id = @commercialDocumentHeaderId
                                                         UNION
                                                            SELECT    issuerContractorAddressId
                                                            FROM      [document].CommercialDocumentHeader
                                                            WHERE     id = @commercialDocumentHeaderId
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
                ) AS returnsXML
    END
' 
END
GO

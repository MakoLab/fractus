/*
name=[document].[p_getWarehouseDocumentData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
c/Y4945+3CGi6giibtsWdQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getWarehouseDocumentData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getWarehouseDocumentData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getWarehouseDocumentData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_getWarehouseDocumentData] --''334DA5F0-86B6-4345-A1E1-A4B2CADF06F2''
    @warehouseDocumentHeaderId UNIQUEIDENTIFIER
AS 
    BEGIN
    
		/*Budowanie XML z kompletem informacji o dokumencie*/
        SELECT  ( SELECT    ( SELECT    ( SELECT    CDL.*,  s.[numberSettingId]
                                          FROM      [document].WarehouseDocumentHeader CDL 
											LEFT JOIN document.Series s ON CDL.seriesId = s.id
                                          WHERE     CDL.id = @warehouseDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''warehouseDocumentHeader''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT   *, i.name itemName, i.code itemCode, i.itemTypeId itemTypeId
                                          FROM      [document].WarehouseDocumentLine  l
											JOIN item.Item i ON  l.itemId = i.id
                                          WHERE     warehouseDocumentHeaderId = @warehouseDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''warehouseDocumentLine''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [contractor].Contractor
                                          WHERE     id = ( SELECT   contractorId
                                                           FROM     [document].WarehouseDocumentHeader
                                                           WHERE    id = @warehouseDocumentHeaderId
                                                         )
                                                    OR id IN ( SELECT  relatedContractorId
															   FROM    contractor.ContractorRelation
															   WHERE   ContractorId = (	   SELECT   contractorId
																						   FROM     [document].WarehouseDocumentHeader
																						   WHERE    id = @warehouseDocumentHeaderId
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
								WHERE contractorId IN ( SELECT   contractorId
                                                        FROM     [document].WarehouseDocumentHeader
                                                        WHERE    id = @warehouseDocumentHeaderId
													)
								FOR XML PATH(''entry''), TYPE
										 )
                            FOR XML PATH(''contractorAccount''), TYPE                    
						),
						( SELECT    (  SELECT    *
									   FROM    contractor.ContractorRelation
									   WHERE   ContractorId IN ( 
															SELECT   contractorId
                                                            FROM     [document].WarehouseDocumentHeader
                                                            WHERE    id = @warehouseDocumentHeaderId
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
                                                            FROM     [document].WarehouseDocumentHeader
                                                            WHERE    id = @warehouseDocumentHeaderId
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
                                          FROM      [document].IncomeOutcomeRelation
                                          WHERE     incomeWarehouseDocumentLineId IN ( SELECT   id
                                                           FROM     [document].WarehouseDocumentLine
                                                           WHERE    warehouseDocumentHeaderId = @warehouseDocumentHeaderId)
												OR 	outcomeWarehouseDocumentLineId IN ( SELECT   id
                                                           FROM     [document].WarehouseDocumentLine
                                                           WHERE    warehouseDocumentHeaderId = @warehouseDocumentHeaderId)
	                                      FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''incomeOutcomeRelation''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [contractor].ContractorAddress
                                          WHERE     contractorId = ( SELECT   contractorId
                                                           FROM     [document].WarehouseDocumentHeader
                                                           WHERE    id = @warehouseDocumentHeaderId
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
                                          FROM      [document].WarehouseDocumentValuation
                                          WHERE     incomeWarehouseDocumentLineId IN ( SELECT   id
                                                           FROM     [document].WarehouseDocumentLine
                                                           WHERE    warehouseDocumentHeaderId = @warehouseDocumentHeaderId)
												OR 	outcomeWarehouseDocumentLineId IN ( SELECT   id
                                                           FROM     [document].WarehouseDocumentLine
                                                           WHERE    warehouseDocumentHeaderId = @warehouseDocumentHeaderId)
	                                      FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''warehouseDocumentValuation''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].CommercialWarehouseValuation
                                          WHERE     warehouseDocumentLineId IN ( SELECT   id
                                                           FROM     [document].WarehouseDocumentLine
                                                           WHERE    warehouseDocumentHeaderId = @warehouseDocumentHeaderId)
												
	                                      FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''commercialWarehouseValuation''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].DocumentLineAttrValue
                                          WHERE     warehouseDocumentLineId IN ( SELECT   id
                                                           FROM     [document].WarehouseDocumentLine
                                                           WHERE    warehouseDocumentHeaderId = @warehouseDocumentHeaderId)
												
	                                      FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''documentLineAttrValue''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].DocumentRelation
                                          WHERE     @warehouseDocumentHeaderId IN (firstWarehouseDocumentHeaderId, secondWarehouseDocumentHeaderId)
												
	                                      FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR XML PATH(''documentRelation''), TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].CommercialWarehouseRelation
                                          WHERE     warehouseDocumentLineId IN ( SELECT   id
                                                           FROM     [document].WarehouseDocumentLine
                                                           WHERE    warehouseDocumentHeaderId = @warehouseDocumentHeaderId)
	                                      FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''commercialWarehouseRelation''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].DocumentAttrValue
                                          WHERE     warehouseDocumentHeaderId = @warehouseDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''documentAttrValue''),
                                  TYPE
                            )
						--)
                FOR
                  XML PATH(''root''),
                      TYPE
                ) AS returnsXML
    END
' 
END
GO

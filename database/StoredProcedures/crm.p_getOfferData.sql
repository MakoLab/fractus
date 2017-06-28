/*
name=[crm].[p_getOfferData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Ux3lTkWvoTpDFse44gAnzA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_getOfferData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [crm].[p_getOfferData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_getOfferData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [crm].[p_getOfferData] @offerId UNIQUEIDENTIFIER

AS 

    BEGIN
    
		/*Budowanie XML z kompletem informacji o dokumencie*/
        SELECT  ( SELECT    
        
							( SELECT    ( SELECT    CDL.*,  s.[numberSettingId]
                                          FROM      [crm].Offer CDL 
											LEFT JOIN document.Series s ON CDL.seriesId = s.id
                                          WHERE     CDL.id = @offerId
										  FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''offer''), TYPE
                            ),
                            ( SELECT    ( SELECT   OfferLine.*, Item.code itemCode, Item.itemTypeId itemTypeId
                                          FROM      [crm].OfferLine 
											JOIN item.Item ON OfferLine.itemId = item.id
                                          WHERE     offerId = @offerId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR XML PATH(''offerLine''),TYPE
                            ),
    
                            ( SELECT    ( SELECT    *
                                          FROM      [document].DocumentAttrValue
                                          WHERE     offerId = @offerId
                                        FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''documentAttrValue''), TYPE
                            ),
                            
                            ( SELECT    ( SELECT    *
                                          FROM      [document].DocumentLineAttrValue
                                          WHERE     offerLineId IN (SELECT id FROM crm.OfferLine WHERE offerId = @offerId )
										  FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''documentLineAttrValue''),TYPE
                            )
                            
                FOR XML PATH(''root''), TYPE
                ) AS returnsXML
    END
' 
END
GO

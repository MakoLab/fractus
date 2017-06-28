/*
name=[document].[p_getCommercialDocumentDataParameter]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
+y82h6iYfoyUKy9PhCB69g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCommercialDocumentDataParameter]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getCommercialDocumentDataParameter]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCommercialDocumentDataParameter]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getCommercialDocumentDataParameter]
@commercialDocumentHeaderId UNIQUEIDENTIFIER, @xmlVar XML OUTPUT
AS
BEGIN

	DECLARE
	@contractorId UNIQUEIDENTIFIER,
	@receivingPersonContractorId UNIQUEIDENTIFIER,
	@issuingPersonContractorId UNIQUEIDENTIFIER,
	@issuerContractorId UNIQUEIDENTIFIER,
	@contractorAddressId UNIQUEIDENTIFIER,
	@issuerContractorAddressId UNIQUEIDENTIFIER

	SELECT 
	@contractorId = contractorId, 
	@receivingPersonContractorId = receivingPersonContractorId,
	@issuingPersonContractorId = issuingPersonContractorId,
	@issuerContractorId = issuerContractorId,
	@contractorAddressId = contractorAddressId,
	@issuerContractorAddressId = issuerContractorAddressId
	FROM      [document].CommercialDocumentHeader WITH(ROWLOCK)
	WHERE     id = @commercialDocumentHeaderId

    
		/*Budowanie XML z kompletem informacji o dokumencie*/
SELECT @xmlVar = (        
SELECT  ( SELECT    ( SELECT    ( SELECT    CDL.*,  s.[numberSettingId]
                                          FROM      [document].CommercialDocumentHeader CDL WITH(ROWLOCK)
											LEFT JOIN document.Series s WITH(ROWLOCK) ON CDL.seriesId = s.id
                                          WHERE     CDL.id = @commercialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''commercialDocumentHeader''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT   *
                                          FROM      [document].CommercialDocumentLine  WITH(ROWLOCK)
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
                                          FROM      [document].CommercialDocumentVatTable WITH(ROWLOCK)
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
                                          FROM      [document].DocumentAttrValue WITH(ROWLOCK)
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
                                          FROM      [finance].Payment WITH(ROWLOCK)
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
                                          FROM      [contractor].Contractor WITH(ROWLOCK)
                                          WHERE     id = @contractorId
                                                    OR id = @receivingPersonContractorId
                                                    OR id = @issuingPersonContractorId
                                                    OR id = @issuerContractorId
                                                    OR id IN (
                                                    SELECT  contractorId
                                                    FROM    [finance].Payment WITH(ROWLOCK)
                                                    WHERE   commercialDocumentHeaderId = @commercialDocumentHeaderId )
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractor''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [contractor].ContractorAddress WITH(ROWLOCK)
                                          WHERE     id = @contractorAddressId
                                                    OR id = @issuerContractorAddressId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractorAddress''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [finance].PaymentSettlement WITH(ROWLOCK)
                                          WHERE     incomePaymentId IN (
                                                    SELECT  id
                                                    FROM    [finance].Payment WITH(ROWLOCK)
                                                    WHERE   commercialDocumentHeaderId = @commercialDocumentHeaderId )
                                                    OR outcomePaymentId IN (
                                                    SELECT  id
                                                    FROM    [finance].Payment WITH(ROWLOCK)
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
                )
		)
    END
' 
END
GO

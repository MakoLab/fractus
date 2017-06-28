/*
name=[document].[p_insertCommercialDocumentLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
aF8ZXp1I2jtrDCslJca5Sg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertCommercialDocumentLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertCommercialDocumentLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertCommercialDocumentLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_insertCommercialDocumentLine] @xmlVar XML
AS 
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
			@idoc int

	/*Fragment dodany na potrzeby przeliczeń walutowych, wielowalutowość*/
	DECLARE @tmp_inserted TABLE (id uniqueidentifier, commercialDocumentHeaderId uniqueidentifier,sysNetValue numeric(18,2),sysGrossValue numeric(18,2), sysVatValue numeric(18,2))

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

	/*Wstawienie danych o pozycjach dokumentu handlowego*/
    INSERT  INTO [document].[CommercialDocumentLine]
            (
              id,
              commercialDocumentHeaderId,
              ordinalNumber,
			  commercialDirection,
			  orderDirection,
              itemId,
			  warehouseId,
			  unitId,
              itemVersion,
              itemName,
              quantity,
              netPrice,
              grossPrice,
              initialNetPrice,
              initialGrossPrice,
              discountRate,
              discountNetValue,
              discountGrossValue,
              initialNetValue,
              initialGrossValue,
              netValue,
              grossValue,
              vatValue,
              vatRateId,
              version,
			  correctedCommercialDocumentLineId,
			  initialCommercialDocumentLineId,
			  sysNetValue,
			  sysGrossValue,
			  sysVatValue
            )
            OUTPUT INSERTED.id, INSERTED.commercialDocumentHeaderId, INSERTED.sysNetValue, INSERTED.sysGrossValue, INSERTED.sysVatValue 
            INTO @tmp_inserted 
            SELECT 
		      id,
              commercialDocumentHeaderId,
              ordinalNumber,
			  commercialDirection,
			  orderDirection,
              itemId,
			  warehouseId,
			  unitId,
              itemVersion,
              itemName,
              quantity,
              netPrice,
              grossPrice,
              initialNetPrice,
              initialGrossPrice,
              discountRate,
              discountNetValue,
              discountGrossValue,
              initialNetValue,
              initialGrossValue,
              netValue,
              grossValue,
              vatValue,
              vatRateId,
              version,
			  correctedCommercialDocumentLineId,
			  initialCommercialDocumentLineId,
			  sysNetValue,
			  sysGrossValue,
			  sysVatValue
			FROM OPENXML(@idoc, ''/root/commercialDocumentLine/entry'')
				WITH(
					id char(36) ''id'',
                    commercialDocumentHeaderId char(36) ''commercialDocumentHeaderId'',
                    ordinalNumber int ''ordinalNumber'',
					commercialDirection int ''commercialDirection'',
					orderDirection int ''orderDirection'',
                    itemId char(36) ''itemId'',
					warehouseId char(36) ''warehouseId'',
                    unitId char(36) ''unitId'',
                    itemVersion char(36) ''itemVersion'',
                    itemName nvarchar(500) ''itemName'',
                    quantity numeric(18,6) ''quantity'',
                    netPrice numeric(18,2) ''netPrice'',
                    grossPrice numeric(18,2) ''grossPrice'',
                    initialNetPrice numeric(18,2) ''initialNetPrice'',
                    initialGrossPrice numeric(18,2) ''initialGrossPrice'',
                    discountRate numeric(18,2) ''discountRate'',
                    discountNetValue numeric(18,2) ''discountNetValue'',
                    discountGrossValue numeric(18,2) ''discountGrossValue'',
                    initialNetValue numeric(18,2) ''initialNetValue'',
                    initialGrossValue numeric(18,2) ''initialGrossValue'',
                    netValue numeric(18,2) ''netValue'',
                    grossValue numeric(18,2) ''grossValue'',
                    vatValue numeric(18,2) ''vatValue'',
                    vatRateId char(36) ''vatRateId'',
                    version char(36) ''version'',
					correctedCommercialDocumentLineId char(36) ''correctedCommercialDocumentLineId'',
					initialCommercialDocumentLineId char(36) ''initialCommercialDocumentLineId'',
					sysNetValue numeric(18,2) ''sysNetValue'',
					sysGrossValue numeric(18,2) ''sysGrossValue'',
					sysVatValue numeric(18,2) ''sysVatValue''
             )
	EXEC sp_xml_removedocument @idoc

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT

	UPDATE x
	SET 
		x.sysNetValue = (x.netValue * h.exchangeRate) / h.exchangeScale,
		x.sysGrossValue = (x.grossValue *  h.exchangeRate) / h.exchangeScale,
		x.sysVatValue = (x.vatValue *  h.exchangeRate) / h.exchangeScale
	FROM  document.CommercialDocumentLine x 
		JOIN @tmp_inserted i ON x.id = i.id
		JOIN document.CommercialDocumentHeader h ON i.commercialDocumentHeaderId = h.id
	WHERE i.sysNetValue IS NULL	
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:CommercialDocumentLine; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            IF @rowcount = 0 
                RAISERROR ( 50011, 16, 1 ) ;
        END
' 
END
GO

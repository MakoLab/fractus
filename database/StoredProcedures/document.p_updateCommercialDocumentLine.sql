/*
name=[document].[p_updateCommercialDocumentLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JhNAKLob8dOqNAbN0VE9dg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateCommercialDocumentLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateCommercialDocumentLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateCommercialDocumentLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_updateCommercialDocumentLine]
@xmlVar XML
AS
BEGIN
		
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
		/*Aktualizacja pozycji dokumentu handlowego*/
        UPDATE  [document].[CommercialDocumentLine]
        SET     commercialDocumentHeaderId = CASE WHEN con.exist(''commercialDocumentHeaderId'') = 1
                                                  THEN con.value(''(commercialDocumentHeaderId)[1]'', ''char(36)'')
                                                  ELSE NULL
                                             END,
                ordinalNumber = CASE WHEN con.exist(''ordinalNumber'') = 1
                                     THEN con.value(''(ordinalNumber)[1]'', ''int'')
                                     ELSE NULL
                                END,
                commercialDirection = CASE WHEN con.exist(''commercialDirection'') = 1
                                     THEN con.value(''(commercialDirection)[1]'', ''int'')
                                     ELSE NULL
                                END,
                orderDirection = CASE WHEN con.exist(''orderDirection'') = 1
                                     THEN con.value(''(orderDirection)[1]'', ''int'')
                                     ELSE NULL
                                END,
                itemId = CASE WHEN con.exist(''itemId'') = 1
                              THEN con.value(''(itemId)[1]'', ''char(36)'')
                              ELSE NULL
                         END,
                warehouseId = CASE WHEN con.exist(''warehouseId'') = 1
                              THEN con.value(''(warehouseId)[1]'', ''char(36)'')
                              ELSE NULL
                         END,
                unitId = CASE WHEN con.exist(''unitId'') = 1
                              THEN con.value(''(unitId)[1]'', ''char(36)'')
                              ELSE NULL
                         END,

                itemVersion = CASE WHEN con.exist(''itemVersion'') = 1
                                   THEN con.value(''(itemVersion)[1]'', ''char(36)'')
                                   ELSE NULL
                              END,
                itemName = CASE WHEN con.exist(''itemName'') = 1
                                THEN con.value(''(itemName)[1]'', ''nvarchar(500)'')
                                ELSE NULL
                           END,
                quantity = CASE WHEN con.exist(''quantity'') = 1
                                THEN con.value(''(quantity)[1]'', ''numeric(18,6)'')
                                ELSE NULL
                           END,
                netPrice = CASE WHEN con.exist(''netPrice'') = 1
                                THEN con.value(''(netPrice)[1]'', ''numeric(18,2)'')
                                ELSE NULL
                           END,
                grossPrice = CASE WHEN con.exist(''grossPrice'') = 1
                                  THEN con.value(''(grossPrice)[1]'', ''numeric(18,2)'')
                                  ELSE NULL
                             END,
                initialNetPrice = CASE WHEN con.exist(''initialNetPrice'') = 1
                                       THEN con.value(''(initialNetPrice)[1]'', ''numeric(18,2)'')
                                       ELSE NULL
                                  END,
                initialGrossPrice = CASE WHEN con.exist(''initialGrossPrice'') = 1
                                         THEN con.value(''(initialGrossPrice)[1]'', ''numeric(18,2)'')
                                         ELSE NULL
                                    END,
                discountRate = CASE WHEN con.exist(''discountRate'') = 1
                                    THEN con.value(''(discountRate)[1]'', ''numeric(18,2)'')
                                    ELSE NULL
                               END,
                discountNetValue = CASE WHEN con.exist(''discountNetValue'') = 1
                                        THEN con.value(''(discountNetValue)[1]'', ''numeric(18,2)'')
                                        ELSE NULL
                                   END,
                discountGrossValue = CASE WHEN con.exist(''discountGrossValue'') = 1
                                          THEN con.value(''(discountGrossValue)[1]'', ''numeric(18,2)'')
                                          ELSE NULL
                                     END,
                initialNetValue = CASE WHEN con.exist(''initialNetValue'') = 1
                                       THEN con.value(''(initialNetValue)[1]'', ''numeric(18,2)'')
                                       ELSE NULL
                                  END,
                initialGrossValue = CASE WHEN con.exist(''initialGrossValue'') = 1
                                         THEN con.value(''(initialGrossValue)[1]'', ''numeric(18,2)'')
                                         ELSE NULL
                                    END,
                netValue = CASE WHEN con.exist(''netValue'') = 1
                                THEN con.value(''(netValue)[1]'', ''numeric(18,2)'')
                                ELSE NULL
                           END,
                grossValue = CASE WHEN con.exist(''grossValue'') = 1
                                  THEN con.value(''(grossValue)[1]'', ''numeric(18,2)'')
                                  ELSE NULL
                             END,
                vatValue = CASE WHEN con.exist(''vatValue'') = 1
                                THEN con.value(''(vatValue)[1]'', ''numeric(18,2)'')
                                ELSE NULL
                           END,
                vatRateId = CASE WHEN con.exist(''vatRateId'') = 1
                                 THEN con.value(''(vatRateId)[1]'', ''char(36)'')
                                 ELSE NULL
                            END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.value(''(_version)[1]'', ''char(36)'')
                               ELSE NULL
                          END,
				correctedCommercialDocumentLineId = CASE WHEN con.exist(''correctedCommercialDocumentLineId'') = 1
                               THEN con.value(''(correctedCommercialDocumentLineId)[1]'', ''char(36)'')
                               ELSE NULL
                          END,
				initialCommercialDocumentLineId = CASE WHEN con.exist(''initialCommercialDocumentLineId'') = 1
                               THEN con.value(''(initialCommercialDocumentLineId)[1]'', ''char(36)'')
                               ELSE NULL
                          END,
                sysNetValue = CASE WHEN con.exist(''sysNetValue'') = 1
                                THEN con.value(''(sysNetValue)[1]'', ''numeric(18,2)'')
                                ELSE (con.value(''(netValue)[1]'', ''numeric(18,2)'') * h.exchangeRate)/ h.exchangeScale
                           END,
                sysGrossValue = CASE WHEN con.exist(''sysGrossValue'') = 1
                                  THEN con.value(''(sysGrossValue)[1]'', ''numeric(18,2)'')
                                  ELSE (con.value(''(grossValue)[1]'', ''numeric(18,2)'') * h.exchangeRate)/ h.exchangeScale
                             END,
                sysVatValue = CASE WHEN con.exist(''sysVatValue'') = 1
                                THEN con.value(''(sysVatValue)[1]'', ''numeric(18,2)'')
                                ELSE (con.value(''(vatValue)[1]'', ''numeric(18,2)'') * h.exchangeRate)/ h.exchangeScale
                           END      
        FROM    @xmlVar.nodes(''/root/commercialDocumentLine/entry'') AS C ( con )
			JOIN document.CommercialDocumentHeader h ON CAST(con.value(''(commercialDocumentHeaderId)[1]'', ''char(36)'') AS uniqueidentifier) = h.id
		WHERE   CommercialDocumentLine.id = con.value(''(id)[1]'', ''char(36)'')
			
		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błedów i wyjatków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:CommercialDocumentLine; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                
                IF @rowcount = 0 
                    RAISERROR ( 50012, 16, 1 ) ;
            END
    END
' 
END
GO

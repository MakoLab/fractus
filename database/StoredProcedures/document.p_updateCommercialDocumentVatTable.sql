/*
name=[document].[p_updateCommercialDocumentVatTable]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
mcZziR9g/vx5f2B7wAEsxw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateCommercialDocumentVatTable]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateCommercialDocumentVatTable]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateCommercialDocumentVatTable]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_updateCommercialDocumentVatTable]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT
    BEGIN 

        

		/*Aktualizacja danych o pozycjach vat w dokumentach handlowych*/
        UPDATE  [document].[CommercialDocumentVatTable]
        SET     commercialDocumentHeaderId = CASE WHEN con.exist(''commercialDocumentHeaderId'') = 1
                                                  THEN con.query(''commercialDocumentHeaderId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
                vatRateId = CASE WHEN con.exist(''vatRateId'') = 1
                                 THEN con.query(''vatRateId'').value(''.'', ''char(36)'')
                                 ELSE NULL
                            END,
                netValue = CASE WHEN con.exist(''netValue'') = 1
                                THEN con.query(''netValue'').value(''.'', ''numeric(18,2)'')
                                ELSE NULL
                           END,
                grossValue = CASE WHEN con.exist(''grossValue'') = 1
                                  THEN con.query(''grossValue'').value(''.'', ''numeric(18,2)'')
                                  ELSE NULL
                             END,
                vatValue = CASE WHEN con.exist(''vatValue'') = 1
                                THEN con.query(''vatValue'').value(''.'', ''numeric(18,2)'')
                                ELSE NULL
                           END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END,
                [order] = CASE WHEN con.exist(''order'') = 1
                               THEN con.query(''order'').value(''.'', ''int'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/commercialDocumentVatTable/entry'') AS C ( con )
        WHERE   CommercialDocumentVatTable.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:CommercialDocumentVatTable; error:''
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

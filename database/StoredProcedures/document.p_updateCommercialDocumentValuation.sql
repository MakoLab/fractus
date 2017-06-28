/*
name=[document].[p_updateCommercialDocumentValuation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
mog58nepDffy0BcvxwRjaQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateCommercialDocumentValuation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateCommercialDocumentValuation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateCommercialDocumentValuation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_updateCommercialDocumentValuation]
@xmlVar XML
AS
BEGIN
		
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
		/*Aktualizacja pozycji powiązań wartościowych */
        UPDATE  [document].CommercialWarehouseValuation
        SET     commercialDocumentLineId = CASE WHEN con.exist(''commercialDocumentLineId'') = 1
                                                  THEN con.query(''commercialDocumentLineId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
                warehouseDocumentLineId = CASE WHEN con.exist(''warehouseDocumentLineId'') = 1
                                     THEN con.query(''warehouseDocumentLineId'').value(''.'', ''char(36)'')
                                     ELSE NULL
                                END,
                quantity = CASE WHEN con.exist(''quantity'') = 1
                                THEN con.query(''quantity'').value(''.'', ''numeric(18,6)'')
                                ELSE NULL
                           END,
                [value] = CASE WHEN con.exist(''value'') = 1
                                THEN con.query(''value'').value(''.'', ''numeric(18,2)'')
                                ELSE NULL
                           END,
                price = CASE WHEN con.exist(''price'') = 1
                                THEN con.query(''price'').value(''.'', ''numeric(18,2)'')
                                ELSE NULL
                           END,
				version = CASE WHEN con.exist(''version'') = 1
                                     THEN con.query(''version'').value(''.'', ''char(36)'')
                                     ELSE NULL
                                END
        FROM    @xmlVar.nodes(''/root/commercialWarehouseValuation/entry'') AS C ( con )
        WHERE   CommercialWarehouseValuation.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błedów i wyjatków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table: CommercialWarehouseValuation; error:''
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

/*
name=[document].[p_updateCommercialWarehouseRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
OgaoiSJMELaBFi8/xbYARQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateCommercialWarehouseRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateCommercialWarehouseRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateCommercialWarehouseRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_updateCommercialWarehouseRelation]
@xmlVar XML
AS
BEGIN
		
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

 
        
		/*Aktualizacja pozycji powiązań ilościowych dokumentu magazynowego*/
        UPDATE  [document].CommercialWarehouseRelation
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
                isValuated = CASE WHEN con.exist(''valuated'') = 1
                                THEN con.query(''valuated'').value(''.'', ''bit'')
                                ELSE NULL
                           END,
                isOrderRelation = CASE WHEN con.exist(''isOrderRelation'') = 1
                                THEN con.query(''isOrderRelation'').value(''.'', ''bit'')
                                ELSE NULL
                           END,
                isCommercialRelation = CASE WHEN con.exist(''isCommercialRelation'') = 1
                                THEN con.query(''isCommercialRelation'').value(''.'', ''bit'')
                                ELSE NULL
                           END,
                isServiceRelation = CASE WHEN con.exist(''isServiceRelation'') = 1
                                THEN con.query(''isServiceRelation'').value(''.'', ''bit'')
                                ELSE NULL
                           END,
                version = CASE WHEN con.exist(''version'') = 1
                                THEN con.query(''version'').value(''.'', ''char(36)'')
                                ELSE NULL
                           END
        FROM    @xmlVar.nodes(''/root/commercialWarehouseRelation/entry'') AS C ( con )
        WHERE   CommercialWarehouseRelation.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błedów i wyjatków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table: CommercialWarehouseRelation; error:''
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
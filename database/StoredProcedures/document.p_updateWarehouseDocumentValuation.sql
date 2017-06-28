/*
name=[document].[p_updateWarehouseDocumentValuation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
gbXeXUCiSV+Ct0G6nciJOQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateWarehouseDocumentValuation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateWarehouseDocumentValuation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateWarehouseDocumentValuation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_updateWarehouseDocumentValuation]
@xmlVar XML
AS
BEGIN
		
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
		/*Aktualizacja pozycji powiązań ilościowych dokumentu magazynowego*/
        UPDATE  [document].WarehouseDocumentValuation
        SET     incomeWarehouseDocumentLineId = CASE WHEN con.exist(''incomeWarehouseDocumentLineId'') = 1
                                                  THEN con.query(''incomeWarehouseDocumentLineId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
                outcomeWarehouseDocumentLineId = CASE WHEN con.exist(''outcomeWarehouseDocumentLineId'') = 1
                                     THEN con.query(''outcomeWarehouseDocumentLineId'').value(''.'', ''char(36)'')
                                     ELSE NULL
                                END,
                quantity = CASE WHEN con.exist(''quantity'') = 1
                                THEN con.query(''quantity'').value(''.'', ''numeric(18,6)'')
                                ELSE NULL
                           END,
                incomePrice = CASE WHEN con.exist(''incomePrice'') = 1
                                THEN con.query(''incomePrice'').value(''.'', ''numeric(18,2)'')
                                ELSE NULL
                           END,
                incomeValue = CASE WHEN con.exist(''incomeValue'') = 1
                                THEN con.query(''incomeValue'').value(''.'', ''numeric(18,2)'')
                                ELSE NULL
                           END
        FROM    @xmlVar.nodes(''/root/warehouseDocumentValuation/entry'') AS C ( con )
        WHERE   WarehouseDocumentValuation.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błedów i wyjatków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table: WarehouseDocumentValuation; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        
    END
' 
END
GO

/*
name=[document].[p_updateWarehouseDocumentLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
qRlI9MAQiEiU7ZvfSFCs0w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateWarehouseDocumentLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateWarehouseDocumentLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateWarehouseDocumentLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_updateWarehouseDocumentLine]
@xmlVar XML
AS
BEGIN
		
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
		/*Aktualizacja pozycji dokumentu magazynowego*/
        UPDATE  [document].WarehouseDocumentLine
        SET     warehouseDocumentHeaderId = CASE WHEN con.exist(''warehouseDocumentHeaderId'') = 1
                                                  THEN con.query(''warehouseDocumentHeaderId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
                direction = CASE WHEN con.exist(''direction'') = 1
                                     THEN con.query(''direction'').value(''.'', ''int'')
                                     ELSE NULL
                                END,
                itemId = CASE WHEN con.exist(''itemId'') = 1
                              THEN con.query(''itemId'').value(''.'', ''char(36)'')
                              ELSE NULL
                         END,
                warehouseId = CASE WHEN con.exist(''warehouseId'') = 1
                                   THEN con.query(''warehouseId'').value(''.'', ''char(36)'')
                                   ELSE NULL
                              END,
                unitId = CASE WHEN con.exist(''unitId'') = 1
                                THEN con.query(''unitId'').value(''.'', ''char(36)'')
                                ELSE NULL
                           END,
                quantity = CASE WHEN con.exist(''quantity'') = 1
                                THEN con.query(''quantity'').value(''.'', ''numeric(18,6)'')
                                ELSE NULL
                           END,
                price = CASE WHEN con.exist(''price'') = 1
                                THEN con.query(''price'').value(''.'', ''numeric(18,2)'')
                                ELSE NULL
                           END,
                [value] = CASE WHEN con.exist(''value'') = 1
                                THEN con.query(''value'').value(''.'', ''numeric(18,2)'')
                                ELSE NULL
                           END,
                incomeDate = CASE WHEN con.exist(''incomeDate'') = 1
                                THEN con.query(''incomeDate'').value(''.'', ''datetime'')
                                ELSE NULL
                           END,
                outcomeDate = CASE WHEN con.exist(''outcomeDate'') = 1
                                  THEN con.query(''outcomeDate'').value(''.'', ''datetime'')
                                  ELSE NULL
                             END,
				ordinalNumber = CASE WHEN con.exist(''ordinalNumber'') = 1
                                     THEN con.query(''ordinalNumber'').value(''.'', ''int'')
                                     ELSE NULL
                                END,
                [description] = CASE WHEN con.exist(''description'') = 1
                                       THEN con.query(''description'').value(''.'', ''nvarchar(500)'')
                                       ELSE NULL
                                  END,
				isDistributed = CASE WHEN con.exist(''isDistributed'') = 1
                                     THEN con.query(''isDistributed'').value(''.'', ''int'')
                                     ELSE NULL
                                END,
                previousIncomeWarehouseDocumentLineId = CASE WHEN con.exist(''previousIncomeWarehouseDocumentLineId'') = 1
                                   THEN con.query(''previousIncomeWarehouseDocumentLineId'').value(''.'', ''char(36)'')
                                   ELSE NULL
                              END,
                correctedWarehouseDocumentLineId = CASE WHEN con.exist(''correctedWarehouseDocumentLineId'') = 1
                                   THEN con.query(''correctedWarehouseDocumentLineId'').value(''.'', ''char(36)'')
                                   ELSE NULL
                              END,
                initialWarehouseDocumentLineId = CASE WHEN con.exist(''initialWarehouseDocumentLineId'') = 1
                                   THEN con.query(''initialWarehouseDocumentLineId'').value(''.'', ''char(36)'')
                                   ELSE NULL
                              END,
                lineType = CASE WHEN con.exist(''lineType'') = 1
                                   THEN con.query(''lineType'').value(''.'', ''int'')
                                   ELSE NULL
                              END,
                [version] = CASE WHEN con.exist(''_version'') = 1
							  THEN con.query(''_version'').value(''.'', ''char(36)'')
									ELSE NULL
							  END
        FROM    @xmlVar.nodes(''/root/warehouseDocumentLine/entry'') AS C ( con )
        WHERE   WarehouseDocumentLine.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błedów i wyjatków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table: WarehouseDocumentLine; error:''
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

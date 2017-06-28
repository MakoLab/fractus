/*
name=[warehouse].[p_updateShift]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
mAGXKxqNICXkO7P0QP4p1A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_updateShift]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_updateShift]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_updateShift]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_updateShift] @xmlVar XML
AS 
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT
    BEGIN 

		/*Aktualizacja danych o przesunięciach wewnątrz magazynowych*/
        UPDATE  warehouse.Shift
        SET     shiftTransactionId = CASE WHEN con.exist(''shiftTransactionId'') = 1
                                                  THEN con.query(''shiftTransactionId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
				incomeWarehouseDocumentLineId = CASE WHEN con.exist(''incomeWarehouseDocumentLineId'') = 1
                                                  THEN con.query(''incomeWarehouseDocumentLineId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
				warehouseId = CASE WHEN con.exist(''warehouseId'') = 1
                                                  THEN con.query(''warehouseId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
				containerId = CASE WHEN con.exist(''containerId'') = 1
                                                  THEN con.query(''containerId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
				warehouseDocumentLineId = CASE WHEN con.exist(''warehouseDocumentLineId'') = 1
                                                  THEN con.query(''warehouseDocumentLineId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
				sourceShiftId = CASE WHEN con.exist(''sourceShiftId'') = 1
                                                  THEN con.query(''sourceShiftId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
                quantity = CASE WHEN con.exist(''quantity'') = 1
                                 THEN con.query(''quantity'').value(''.'', ''numeric(18,6)'')
                                 ELSE NULL
                            END,
                [status] = CASE WHEN con.exist(''status'') = 1
                                 THEN con.query(''status'').value(''.'', ''int'')
                                 ELSE NULL
                            END,
                ordinalNumber = CASE WHEN con.exist(''ordinalNumber'') = 1
                                 THEN con.query(''ordinalNumber'').value(''.'', ''int'')
                                 ELSE NULL
                            END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/shift/entry'') AS C ( con )
        WHERE   Shift.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table: Shift; error:''
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

/*
name=[warehouse].[p_editShiftTransaction]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
RI9zC5lJqXD0l/GKudisPA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_editShiftTransaction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_editShiftTransaction]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_editShiftTransaction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_editShiftTransaction]
@xmlVar XML
AS
BEGIN

DECLARE 	@shiftTransactionId UNIQUEIDENTIFIER

		/*Aktualizacja danych o przesunięciach wewnątrz magazynowych*/
        UPDATE  warehouse.ContainerShift
        SET     containerId = CASE WHEN con.exist(''containerId'') = 1
                                                  THEN con.query(''containerId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
				parentContainerId = CASE WHEN con.exist(''parentContainerId'') = 1
                                                  THEN con.query(''parentContainerId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
				slotContainerId = CASE WHEN con.exist(''slotContainerId'') = 1
                                                  THEN con.query(''slotContainerId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
				shiftTransactionId = CASE WHEN con.exist(''shiftTransactionId'') = 1
                                                  THEN con.query(''shiftTransactionId'').value(''.'', ''char(36)'')
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
        FROM    @xmlVar.nodes(''/root/containerShift/entry'') AS C ( con )
        WHERE   ContainerShift.id = con.query(''id'').value(''.'', ''char(36)'')



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



        SELECT @shiftTransactionId = con.query(''shiftTransactionId'').value(''.'', ''char(36)'')
		FROM    @xmlVar.nodes(''/root/shift/entry'') AS C ( con )

IF EXISTS (
		SELECT s.id
		FROM  warehouse.Shift s
			LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.status >= 40 GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
		WHERE (s.quantity - ISNULL(x.q,0)) < 0 AND s.status >= 40 AND  s.containerId IN (
							SELECT containerId 
							FROM warehouse.Shift 
							WHERE shiftTransactionId = @shiftTransactionId AND Shift.status >= 40
						UNION 
							SELECT containerId 
							FROM warehouse.Shift 
							WHERE id IN  (SELECT sourceShiftId FROM warehouse.Shift  WHERE shiftTransactionId = @shiftTransactionId) AND Shift.status >= 40
							)
			)
		BEGIN
			SELECT (
			SELECT s.id, (s.quantity - ISNULL(x.q,0)) quantity
			FROM  warehouse.Shift s
				LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.status >= 40 GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
			WHERE (s.quantity - ISNULL(x.q,0)) < 0 AND s.status >= 40 AND s.containerId IN (
								SELECT containerId 
								FROM warehouse.Shift 
								WHERE shiftTransactionId = @shiftTransactionId
							UNION 
								SELECT containerId 
								FROM warehouse.Shift 
								WHERE id IN  (SELECT sourceShiftId FROM warehouse.Shift WHERE shiftTransactionId = @shiftTransactionId)
								)
			FOR XML PATH(''shift'') , TYPE	
			) FOR XML PATH(''root'') , TYPE	
		END
	ELSE IF EXISTS (
			SELECT s.id
			FROM  warehouse.Shift s
				LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx  WHERE sx.status >= 40  GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
			WHERE (s.quantity - ISNULL(x.q,0)) < 0 AND s.shiftTransactionId = @shiftTransactionId AND s.status >= 40
			)
			SELECT CAST(''<root><sourceQuantityExceeded/></root>'' as XML)
	ELSE

		SELECT CAST(''<root/>'' as XML)


END
' 
END
GO

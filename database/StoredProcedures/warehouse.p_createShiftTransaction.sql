/*
name=[warehouse].[p_createShiftTransaction]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
i832/93FEa3nXaNSsjR/Qw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_createShiftTransaction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_createShiftTransaction]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_createShiftTransaction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_createShiftTransaction]
@xmlVar XML
AS
BEGIN
	DECLARE @tmp_shift TABLE (id uniqueidentifier, shiftTransactionId uniqueidentifier, incomeWarehouseDocumentLineId uniqueidentifier, warehouseId uniqueidentifier, containerId uniqueidentifier, quantity decimal(18,6), warehouseDocumentLineId uniqueidentifier, sourceShiftId uniqueidentifier, [status] int, ordinalNumber int, [version] uniqueidentifier)
	DECLARE @tmp_containerShift TABLE ( id uniqueidentifier, containerId uniqueidentifier, parentContainerId uniqueidentifier, slotContainerId uniqueidentifier, shiftTransactionId uniqueidentifier, ordinalNumber int, [version] uniqueidentifier)

	DECLARE
	@idoc int,
	@shiftTransactionId UNIQUEIDENTIFIER

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

	/*Wstawienie danych o pozycjach przesunięcia towarów*/
    --INSERT  INTO [warehouse].[Shift] ( id, shiftTransactionId, incomeWarehouseDocumentLineId, warehouseId, containerId, quantity, warehouseDocumentLineId, sourceShiftId, status, ordinalNumber, version )
	INSERT INTO @tmp_shift 
	SELECT id, shiftTransactionId, incomeWarehouseDocumentLineId, warehouseId, containerId, quantity, warehouseDocumentLineId, sourceShiftId, status, ordinalNumber, version
	FROM OPENXML(@idoc, ''/root/shift/entry'')
		WITH(
			id char(36) ''id'',
			shiftTransactionId char(36) ''shiftTransactionId'',
			incomeWarehouseDocumentLineId char(36) ''incomeWarehouseDocumentLineId'',
			warehouseId char(36) ''warehouseId'',
			containerId char(36) ''containerId'',
			quantity numeric(18,6) ''quantity'',
			warehouseDocumentLineId char(36) ''warehouseDocumentLineId'',
			sourceShiftId char(36) ''sourceShiftId'',
			status int ''status'',
			ordinalNumber int ''ordinalNumber'',
			version char(36) ''version''
		)

	INSERT  INTO [warehouse].[Shift] ( id, shiftTransactionId, incomeWarehouseDocumentLineId, warehouseId, containerId, quantity, warehouseDocumentLineId, sourceShiftId, status, ordinalNumber, version )
	SELECT * FROM @tmp_shift
	
	
	/*Wstawienie danych o pozycjach przesunięcia kontenera*/
   
	INSERT INTO @tmp_containerShift
    SELECT id, containerId, parentContainerId, slotContainerId, shiftTransactionId, ordinalNumber, version	
	FROM OPENXML(@idoc, ''/root/containerShift/entry'')
		WITH(
			id char(36) ''id'',
            containerId char(36) ''containerId'',
            parentContainerId char(36) ''parentContainerId'',
			slotContainerId char(36) ''slotContainerId'',
			shiftTransactionId char(36) ''shiftTransactionId'',
			ordinalNumber int ''ordinalNumber'',
			version char(36) ''version''
     )

EXEC sp_xml_removedocument @idoc

	 INSERT  INTO [warehouse].ContainerShift (id, containerId, parentContainerId, slotContainerId, shiftTransactionId, ordinalNumber, version )
	 SELECT * FROM @tmp_containerShift
 
 
        SELECT @shiftTransactionId = con.query(''shiftTransactionId'').value(''.'', ''char(36)'')
		FROM    @xmlVar.nodes(''/root/shift/entry'') AS C ( con )
		
		 

IF EXISTS (
		SELECT s.containerId 
		FROM  warehouse.Shift s
			LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.status >= 40 GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
		WHERE s.status >= 40 AND  s.containerId is not null AND  s.quantity < ISNULL(x.q,0) AND s.id IN (select sourceShiftId FROM @tmp_shift)
		)
		SELECT (
				SELECT s.id 
					FROM  warehouse.Shift s
						LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.status >= 40 GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
					WHERE s.status >= 40 AND  s.containerId is not null AND  s.quantity < ISNULL(x.q,0) AND s.id IN (select sourceShiftId FROM @tmp_shift)
						FOR XML PATH(''shift'') , TYPE	
			) FOR XML PATH(''root'') , TYPE	
		--SELECT CAST(''<root><containerQuantityExceeded/></root>'' as XML)
ELSE		
IF EXISTS (
		SELECT s.containerId
		FROM  warehouse.Shift s
			LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.status >= 40 GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
		WHERE s.status >= 40 AND  s.containerId IN (
							SELECT containerId 
							FROM warehouse.Shift 
							WHERE shiftTransactionId IN (SELECT shiftTransactionId FROM @tmp_containerShift)
						UNION 
							SELECT containerId 
							FROM warehouse.Shift 
							WHERE status >= 40 AND id IN  (SELECT sourceShiftId FROM warehouse.Shift WHERE shiftTransactionId IN (SELECT shiftTransactionId FROM @tmp_containerShift))
							)
		GROUP BY  s.containerId		
		HAVING SUM(s.quantity ) <  SUM( ISNULL(x.q,0)) 
		
			) AND NOT EXISTS ( SELECT id FROM warehouse.Shift WHERE Shift.status >= 40 AND incomeWarehouseDocumentLineId <> warehouseDocumentLineId  AND shiftTransactionId IN (SELECT shiftTransactionId FROM @tmp_containerShift) )
	BEGIN
			SELECT (
				SELECT s.id
				FROM  warehouse.Shift s
					LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.status >= 40 GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
				WHERE s.status >= 40 AND (s.quantity - ISNULL(x.q,0)) < 0 AND s.containerId IN (
									SELECT containerId 
									FROM warehouse.Shift 
									WHERE shiftTransactionId IN (SELECT shiftTransactionId FROM @tmp_containerShift)
								UNION 
									SELECT containerId 
									FROM warehouse.Shift 
									WHERE id IN  (SELECT sourceShiftId FROM warehouse.Shift WHERE shiftTransactionId IN (SELECT shiftTransactionId FROM @tmp_containerShift))
									)
				FOR XML PATH(''shift'') , TYPE	
			) FOR XML PATH(''root'') , TYPE	
	END
ELSE IF  EXISTS (
					SELECT id  
					FROM document.WarehouseDocumentLine l 
						JOIN (	SELECT sh.incomeWarehouseDocumentLineId , SUM( sh.quantity - ISNULL(x.q,0) ) qty
								FROM warehouse.Shift sh
									LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.status >= 40 GROUP BY sx.sourceShiftId ) x ON sh.id = x.sourceShiftId
								WHERE sh.containerId IS NOT NULL AND sh.shiftTransactionId IN (SELECT shiftTransactionId FROM @tmp_containerShift UNION SELECT shiftTransactionId FROM @tmp_shift) AND sh.status >= 40
								GROUP BY sh.incomeWarehouseDocumentLineId 
							) s ON l.id = s.incomeWarehouseDocumentLineId
					WHERE ABS(l.quantity) < s.qty 
			) 

		BEGIN
		SELECT CAST(''<root><unassignedQuantityExceeded/></root>'' as XML)


		END
	ELSE
	
		SELECT CAST(''<root/>'' as XML)


END



--SELECT s.*
--FROM document.WarehouseDocumentLine l 
--	JOIN (	SELECT sh.incomeWarehouseDocumentLineId , SUM( sh.quantity - ISNULL(x.q,0) ) qty
--			FROM warehouse.Shift sh
--				LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.status >= 40 GROUP BY sx.sourceShiftId ) x ON sh.id = x.sourceShiftId
--			WHERE sh.containerId IS NOT NULL --AND sh.shiftTransactionId IN (SELECT shiftTransactionId FROM @tmp_containerShift) AND sh.status >= 40
--			--GROUP BY sh.incomeWarehouseDocumentLineId 
--		) s ON l.id = s.incomeWarehouseDocumentLineId
--	where l.itemId = ''9C4403EF-302A-4A3D-AA9A-12FA72525BF2'' AND ABS(l.quantity) < s.qty 
	
	
--	select * from 	item.item where name = ''ŻARÓWKA H4 OSRAM 12V 60/55W P43t''
	
--	delete from warehouse.Shift where incomeWarehouseDocumentLineId = ''87A9C299-85B8-481C-ADD6-675A69D947A6''
--select *   
--FROM warehouse.Shift sh
--	LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.status >= 40 GROUP BY sx.sourceShiftId ) x ON sh.id = x.sourceShiftId
--where sh.incomeWarehouseDocumentLineId = ''87A9C299-85B8-481C-ADD6-675A69D947A6''' 
END
GO

/*
name=[warehouse].[p_handheld_insertShift]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
b11rw+ld+CTlVahhzh1P/w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_handheld_insertShift]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_handheld_insertShift]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_handheld_insertShift]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_handheld_insertShift]
@xmlVar XML

AS

DECLARE @shiftTransactionId UNIQUEIDENTIFIER,
		@shiftId UNIQUEIDENTIFIER

	-- format XML
   --     <root>
			--<shiftTransaction>
			--	<applicationUserId></applicationUserId>
			--	<issueDate></issueDate>
			--	<description></description>
			--	<reasonId></reasonId>
			--</shiftTransaction>
			--<shift>
			--	<sourceShiftId></sourceShiftId>
			--	<destinationContainerId></destinationContainerId>
			--	<quantity></quantity>
			--</shift>
   --     </root>

	BEGIN TRAN
		
		SELECT 	@shiftTransactionId = newid(),
				@shiftId = newid()
			
			
	/*Wstawienie informacji o nagłówku transakcji*/
	INSERT INTO warehouse.ShiftTransaction ([id],  [applicationUserId],  [issueDate], [version],  [description],  [reasonId])   
	SELECT @shiftTransactionId, 
	       NULLIF(x.query(''applicationUserId'').value(''.'', ''char(36)''), ''''),
		   NULLIF(x.query(''issueDate'').value(''.'', ''datetime''), ''''),
		   NEWID(), 
	       NULLIF(x.query(''description'').value(''.'', ''nvarchar(500)''), ''''),
	       NULLIF(x.query(''reasonId'').value(''.'', ''char(36)''), '''')
 	FROM  @xmlVar.nodes(''/root/shiftTransaction'') as a(x)
	
	
	IF  @@error <> 0 AND @@rowcount <> 0 
	BEGIN
		SELECT ''Blad odczytu danych z xml lub wstawienia ShiftTransaction'' ;
		ROLLBACK TRAN ;
		RETURN 0;
	END
	
	/*Wstawienie pozycji przesunięcia*/
	INSERT INTO warehouse.Shift ([id],  [shiftTransactionId],  [incomeWarehouseDocumentLineId],  [warehouseId],  [containerId],  [quantity],  [warehouseDocumentLineId],  [sourceShiftId],  [status],  [ordinalNumber],  [version])   
	SELECT	@shiftId,  
			@shiftTransactionId, 
			s.incomeWarehouseDocumentLineId,  
			s.warehouseId,  
			CAST(x.query(''destinationContainerId'').value(''.'', ''char(36)'') AS uniqueidentifier),  
			x.query(''quantity'').value(''.'', ''numeric(18,6)''),  
			null,  
			s.id,  
			40,  
			1,  
			newid()
	FROM  @xmlVar.nodes(''/root/shift'') as a(x) 
		JOIN warehouse.Shift s ON s.id = x.query(''sourceShiftId'').value(''.'', ''char(36)'')
	
	IF  @@error <> 0 OR @@rowcount = 0 
	BEGIN
		SELECT ''Blad odczytu danych z xml lub wstawienia Shift'' ;
		ROLLBACK TRAN ;
		RETURN 0;
	END
	
	
	
IF EXISTS (

		SELECT s.containerId
		FROM  warehouse.Shift s
			LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.status >= 40 GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
		WHERE s.status >= 40 AND  s.containerId IN (
							SELECT containerId 
							FROM warehouse.Shift 
							WHERE shiftTransactionId = @shiftTransactionId
						UNION 
							SELECT containerId 
							FROM warehouse.Shift 
							WHERE status >= 40 AND id IN  (SELECT sourceShiftId FROM warehouse.Shift WHERE shiftTransactionId = @shiftTransactionId)
							)
		GROUP BY  s.containerId		
		HAVING SUM(s.quantity ) <  SUM( ISNULL(x.q,0)) 
		
			) AND NOT EXISTS ( SELECT id FROM warehouse.Shift WHERE Shift.status >= 40 AND incomeWarehouseDocumentLineId <> warehouseDocumentLineId  AND shiftTransactionId = @shiftTransactionId )
	BEGIN
			SELECT ''Przekroczono ilość dostępną na kontenerze''
			ROLLBACK TRAN;
			RETURN 0;
	END


IF @@error = 0 
	BEGIN
	COMMIT TRAN
	/*Tu trzeba ustaliś zwot do uruchamiającego*/
	
	END
ELSE
	BEGIN 
	SELECT ''Wstawienie przesunięcia nieudane '' + CAST(@@error  as varchar(50))
	ROLLBACK TRAN
	END
' 
END
GO

/*
name=[warehouse].[p_createIncomeShiftCorrection]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
NWKZFyI6EYb4/4NjauCNxQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_createIncomeShiftCorrection]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_createIncomeShiftCorrection]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_createIncomeShiftCorrection]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_createIncomeShiftCorrection] 
@xmlVar XML
AS
BEGIN

/*PONIEWARZ JEST TO KOREKTA WIĘC NIE BĘDZIE TO DZIAŁAĆ SZYBKO!!*/	
/*Nie mam zamiaru się z tym więcej męczyć, jest to algorytm bardzo zagmatwany a kto tego nie pojmuje niech sie jeszcze zastanowi nad wszystkimi przypadkami*/

	DECLARE 
	@PZK_id UNIQUEIDENTIFIER,
	@ShiftTransaction_id UNIQUEIDENTIFIER,
	@i int , 
	@z int,
	@lineId UNIQUEIDENTIFIER,
	@correctedLineId UNIQUEIDENTIFIER,
	@kQuantity numeric(18,6)


	DECLARE @tmp_ TABLE (id uniqueidentifier, incomeWarehouseDocumentLineId uniqueidentifier, containerId uniqueidentifier,warehouseDocumentLineId uniqueidentifier, quantityLeft numeric(18,6),incomeQuantityCorrection uniqueidentifier, outcomeQuantityCorrection uniqueidentifier, warehouseId uniqueidentifier, i int identity(1,1) )
	DECLARE @tmpShift  TABLE (id uniqueidentifier default newid(), shiftTransactionId uniqueidentifier, incomeWarehouseDocumentLineId uniqueidentifier, warehouseId uniqueidentifier,containerId uniqueidentifier, quantity numeric(18,6), warehouseDocumentLineId uniqueidentifier, sourceShiftId uniqueidentifier, ordinalNumber int identity(1,1) ,  tmpContainerId uniqueidentifier , tmp_sourceShiftId uniqueidentifier)
	DECLARE @tmp TABLE (correctedWarehouseDocumentLineId uniqueidentifier, i int identity(1,1))
	
	/*Pobieram dane o korekcie*/
	SELECT 
		@PZK_id = x.value(''correctiveWarehouseDocumentHeaderId[1]'' , ''char(36)''),
		@ShiftTransaction_id = x.value(''shiftTransactionId[1]'' , ''char(36)'')
	FROM @xmlVar.nodes(''/root'') AS a(x)


	/*Stany wolnych dostaw*/
		/*Potencjalnie niebezpieczny fragment wyciągający linię ujemną dokumentu korygującego (jeśli by się okazało ze są 2 to nie wiem), za status odpowiada "direction * quantity"*/
	INSERT INTO @tmp_ (id, incomeWarehouseDocumentLineId, containerId, quantityLeft, warehouseDocumentLineId, outcomeQuantityCorrection, warehouseId , incomeQuantityCorrection)
	SELECT s.id,  incomeWarehouseDocumentLineId, s.containerId ,s.quantity - ISNULL(x.qty ,0), s.warehouseDocumentLineId, 
					(SELECT l.id FROM document.WarehouseDocumentLine l WHERE l.previousIncomeWarehouseDocumentLineId = incomeWarehouseDocumentLineId AND (l.quantity * l.direction) < 0 AND l.direction = 1), 
					(SELECT l.warehouseId FROM document.WarehouseDocumentLine l WHERE l.previousIncomeWarehouseDocumentLineId = incomeWarehouseDocumentLineId AND (l.quantity * l.direction) < 0 AND l.direction = 1),
					(SELECT l.id FROM document.WarehouseDocumentLine l WHERE l.previousIncomeWarehouseDocumentLineId = incomeWarehouseDocumentLineId AND (l.quantity * l.direction) > 0 AND l.direction = 1)
	FROM warehouse.Shift s
		LEFT JOIN (SELECT SUM(quantity) qty, sourceShiftId FROM warehouse.Shift  WHERE Shift.status >= 40 GROUP BY sourceShiftId ) x ON s.id = x.sourceShiftId
	WHERE incomeWarehouseDocumentLineId IN (
											SELECT l.previousIncomeWarehouseDocumentLineId 
											FROM document.WarehouseDocumentLine l
											WHERE l.warehouseDocumentHeaderId = @PZK_id )
		AND s.containerId IS NOT NULL 
		AND s.quantity - ISNULL(x.qty ,0) > 0
		AND s.status >= 40
			
	/*Lista korygowanych pozycji, po nich będzie główna pętla*/
	INSERT INTO @tmp (  correctedWarehouseDocumentLineId)
	SELECT   DISTINCT l.correctedWarehouseDocumentLineId
	FROM document.WarehouseDocumentLine l 
	WHERE l.warehouseDocumentHeaderId = @PZK_id  
	
	SELECT @i = 1, @z = max(i) FROM @tmp

	WHILE @i <= @z
		BEGIN
			/*Dane*/ 
			SELECT @correctedLineId = correctedWarehouseDocumentLineId FROM @tmp WHERE i = @i 

			/*Część rozchodową korekty Shift wstawiamy zgodnie z pozostałą ilością na shiftach, może być kilka pozycji które były dopięte do korygowanej pozycji przychodowej*/
			INSERT INTO @tmpShift ( shiftTransactionId,	incomeWarehouseDocumentLineId,  warehouseId, containerId,     quantity,  warehouseDocumentLineId, sourceShiftId , tmp_sourceShiftId)
			SELECT                @ShiftTransaction_id, incomeWarehouseDocumentLineId , warehouseId,        NULL, quantityLeft,outcomeQuantityCorrection,           t.id, t.id
			FROM @tmp_ t					 
			WHERE incomeWarehouseDocumentLineId = @correctedLineId
			/*Suma pozostałych dla dostawy transz z WMS, minus dostępne na magazynie po korekcie ...*/
			SELECT @kQuantity =  
					(
						SELECT ISNULL(l.quantity,0) - ISNULL(qty,0) 
						FROM  document.WarehouseDocumentLine l 
							 LEFT JOIN(SELECT SUM(ir.quantity) qty,  ir.incomeWarehouseDocumentLineId  FROM document.IncomeOutcomeRelation ir GROUP BY  ir.incomeWarehouseDocumentLineId   ) x ON l.id = x.incomeWarehouseDocumentLineId
						WHERE l.correctedWarehouseDocumentLineId = @correctedLineId  AND (l.direction * l.quantity ) > 0
					)


		/*Musi być pętla bo może nastąpić zmniejszenie ilości, wtedy trzeba zmniejszyć ilość na shiftach by sumarycznie dostępne transze były zgodne z samą dostawą po korekcie*/
		WHILE @kQuantity > 0 
			BEGIN 
				/*Wstawiam shifty aż do wyczerpania stanu pozostałego po korekcie*/
				INSERT INTO @tmpShift ( shiftTransactionId,	incomeWarehouseDocumentLineId,  warehouseId, containerId,															        quantity, warehouseDocumentLineId, sourceShiftId , tmp_sourceShiftId)
				SELECT TOP 1          @ShiftTransaction_id,     incomeQuantityCorrection ,  warehouseId, containerId, CASE WHEN quantityLeft <= @kQuantity THEN quantityLeft ELSE @kQuantity END,incomeQuantityCorrection,           NULL, t.id
				FROM @tmp_ t					 
				WHERE  incomeWarehouseDocumentLineId = @correctedLineId AND t.id NOT IN ( SELECT tmp_sourceShiftId FROM @tmpShift WHERE sourceShiftId IS NULL)

				
				SELECT @kQuantity =  @kQuantity  - (SELECT quantity FROM @tmpShift WHERE ordinalNumber = @@identity)
			
			END
	
		
		SELECT @i = @i + 1	
		END

--select * from @tmpShift


	INSERT INTO warehouse.Shift (id,  shiftTransactionId, incomeWarehouseDocumentLineId, warehouseId, containerId, quantity, warehouseDocumentLineId, sourceShiftId, [status], ordinalNumber , version)
	SELECT					newid(), shiftTransactionId , incomeWarehouseDocumentLineId, warehouseId, containerId, quantity, warehouseDocumentLineId, sourceShiftId,      40 , ordinalNumber , newid()
	FROM @tmpShift



	INSERT INTO warehouse.ShiftAttrValue (id, shiftId, shiftFieldId, decimalValue, textValue, xmlValue, version, dateValue )
	SELECT                           newid(), shiftId, shiftFieldId, decimalValue, textValue, xmlValue, newid(), dateValue 
	FROM @tmpShift s 
		JOIN warehouse.ShiftAttrValue sav ON s.tmp_sourceShiftId = sav.shiftId
 	WHERE s.shiftTransactionId = @ShiftTransaction_id AND s.sourceShiftId IS NOT NULL




END
' 
END
GO

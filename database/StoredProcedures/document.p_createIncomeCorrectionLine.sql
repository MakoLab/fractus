/*
name=[document].[p_createIncomeCorrectionLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
shVkyvSBtWxn5Flr0Gy9iw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_createIncomeCorrectionLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_createIncomeCorrectionLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_createIncomeCorrectionLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_createIncomeCorrectionLine]
	@correctedPositionId UNIQUEIDENTIFIER,			--id pozycji PZ (lub PZK+, jeśli PZ było już korygowane) do skorygowania
	@positionValueAfterCorrection NUMERIC(18,2),	--wartość pozycji po korekcie
	@positionQuantityAfterCorrection NUMERIC(18,6),	--ilość na pozycji przychodu po korekcie
	@xmlOut XML OUT									--dane wynikowe zwracane przez procedurę

AS

SET NOCOUNT ON
--RAISERROR (N''p_createIncomeCorrectionLine'',16,1); 
/*Deklaracja zmiennych*/
--DECLARE

/*Tabela z pozycjami dokumentu PZK*/
DECLARE @warehouseDocumentLine_PZK TABLE 
	(
		[id] UNIQUEIDENTIFIER,
		[direction] INT,
		[itemId] UNIQUEIDENTIFIER,
		[warehouseId] UNIQUEIDENTIFIER,
		[unitId] UNIQUEIDENTIFIER,
		[quantity] NUMERIC(18,6),
		[price] NUMERIC(18,2),
		[value] NUMERIC(18,2),
		[incomeDate] DATETIME,
		[description] NVARCHAR(500),
		[version] UNIQUEIDENTIFIER,
		[isDistributed] BIT,
		[previousIncomeWarehouseDocumentLineId] UNIQUEIDENTIFIER,
		[correctedWarehouseDocumentLineId] UNIQUEIDENTIFIER,
		[initialWarehouseDocumentLineId] UNIQUEIDENTIFIER,
		[lineType] INT
	)
	
/*Tabela z pozycjami dokumentu WZK*/
DECLARE @warehouseDocumentLine_WZK TABLE 
	(
		[direction] INT,
		[itemId] UNIQUEIDENTIFIER,
		[warehouseId] UNIQUEIDENTIFIER,
		[unitId] UNIQUEIDENTIFIER,
		[quantity] NUMERIC(18,6),
		[price] NUMERIC(18,2),
		[value] NUMERIC(18,2),
		[incomeDate] DATETIME,
		[description] NVARCHAR(500),
		[version] UNIQUEIDENTIFIER,
		[isDistributed] BIT,
		[previousIncomeWarehouseDocumentLineId] UNIQUEIDENTIFIER,
		[correctedWarehouseDocumentLineId] UNIQUEIDENTIFIER,
		[initialWarehouseDocumentLineId] UNIQUEIDENTIFIER,
		[lineType] INT
	)

/*Wstawienie storna dla korygowanej pozycji PZ (PZK -)*/
INSERT INTO @warehouseDocumentLine_PZK ([id], [direction], [itemId], [warehouseId], [unitId], [quantity],
	[price], [value], [incomeDate], [description], [version], [isDistributed],
	[previousIncomeWarehouseDocumentLineId], [correctedWarehouseDocumentLineId],
	[initialWarehouseDocumentLineId], [lineType])
SELECT NEWID(), 1, itemId, warehouseId, unitId, quantity * -1, 
	price, value, incomeDate, [description], NEWID(), isDistributed,
	@correctedPositionId, @correctedPositionId, 
	ISNULL(initialWarehouseDocumentLineId, @correctedPositionId), -1
FROM  document.WarehouseDocumentLine
WHERE id = @correctedPositionId

/*Jeśli korekta nie jest całkowitym zwrotem do dostawcy, czyli ilość po korekcie (@positionQuantityAfterCorrection) <> 0,
wstawienie ponownego przychodu dla korygowanej pozycji PZ (PZK +)*/
IF @positionQuantityAfterCorrection <> 0
BEGIN
	INSERT INTO @warehouseDocumentLine_PZK ([id], [direction], [itemId], [warehouseId], [unitId], [quantity],
		[price], [value], [incomeDate], [description], [version], [isDistributed],
		[previousIncomeWarehouseDocumentLineId], [correctedWarehouseDocumentLineId],
		[initialWarehouseDocumentLineId], [lineType])
	SELECT NEWID(), 1, itemId, warehouseId, unitId, @positionQuantityAfterCorrection,
		ROUND(@positionValueAfterCorrection/@positionQuantityAfterCorrection,2), @positionValueAfterCorrection, 
		incomeDate, [description], NEWID(), isDistributed,
		@correctedPositionId, @correctedPositionId,
		ISNULL(initialWarehouseDocumentLineId, @correctedPositionId), 1
	FROM  document.WarehouseDocumentLine
	WHERE id = @correctedPositionId
END

/*Jeśli korygowana pozycja PZ posiada rozchody, wystawienie korekty do tych rozchodów*/
IF EXISTS 
	(
		SELECT id 
		FROM document.IncomeOutcomeRelation 
		WHERE incomeWarehouseDocumentLineId = @correctedPositionId
	)
BEGIN

	/*Wstawienie pozycji storna dla rozchodów z korygowanej pozycji PZ (WZK +).
	Powstanie tyle pozycji, z ilu przychodów zdejmowały WZ lub ich ostatnie korekty.
	(Orginalne WZ znajdziemy tylko przez correctedWarehouseDocumentLineId).*/
	INSERT INTO @warehouseDocumentLine_WZK ([direction], [itemId], [warehouseId], [unitId], [quantity],
		[price], [value], [incomeDate], [description],
		[version], [isDistributed], [previousIncomeWarehouseDocumentLineId], [correctedWarehouseDocumentLineId],
		[initialWarehouseDocumentLineId], [lineType])
	SELECT -1, l.itemId, l.warehouseId, l.unitId, ABS(ir.quantity) * -1,
		ISNULL(valuation.price,0), ISNULL(valuation.price * ABS(ir.quantity) * -1,0), ir.incomeDate, l.[description],
		NEWID(), l.isDistributed, ir.incomeWarehouseDocumentLineId, l.id,
		ISNULL(l.initialWarehouseDocumentLineId, l.id), 3
	FROM document.IncomeOutcomeRelation ir 
	JOIN document.WarehouseDocumentLine l ON ir.outcomeWarehouseDocumentLineId = l.id
	LEFT JOIN 
	(
		SELECT SUM(quantity) quantity, SUM(incomeValue) [value], SUM(incomeValue)/ISNULL(SUM(quantity),1) [price],
			outcomeWarehouseDocumentLineId  
		FROM document.WarehouseDocumentValuation wdv 
		WHERE incomeWarehouseDocumentLineId = @correctedPositionId
		GROUP BY outcomeWarehouseDocumentLineId
	) valuation ON l.id = valuation.outcomeWarehouseDocumentLineId											
	WHERE ir.outcomeWarehouseDocumentLineId in 
		( 
			/*Funkcja [document].[f_getOutcomeLineAfterCostCorrection] zwraca pozycję rozchodową po jej ostatniej
			korekcie jeśli taka istniała lub pozycję rozchodową, jesli nie było do niej jeszcze korekt*/
			SELECT [document].[f_getOutcomeLineAfterCostCorrection](outcomeWarehouseDocumentLineId)
			FROM document.IncomeOutcomeRelation 
			WHERE incomeWarehouseDocumentLineId = @correctedPositionId
		)

	/*Wstawienie ponownych wydań (WZK -).
	Powstanie tyle pozycji, ile bylo pozycji rozchodowych pochodzących z korygowanego przychodu.
	(To oznacza, że moga być np. trzy pozycje WZK + i jedna WZK -).*/
	INSERT INTO @warehouseDocumentLine_WZK ([direction], [itemId], [warehouseId], [unitId], [quantity],
		[price], [value], [incomeDate], [description],
		[version], [isDistributed], [previousIncomeWarehouseDocumentLineId], [correctedWarehouseDocumentLineId],
		[initialWarehouseDocumentLineId], [lineType])
	SELECT -1, x.itemId, x.warehouseId, x.unitId, x.quantity,
		NULL, NULL, x.incomeDate, NULL,
		NEWID(), x.isDistributed, NULL, x.correctedWarehouseDocumentLineId,
		ISNULL(x.initialWarehouseDocumentLineId, x.correctedWarehouseDocumentLineId), -3
	FROM
	(
		SELECT itemId, warehouseId, unitId, ABS(SUM(quantity)) quantity, incomeDate, isDistributed,
			correctedWarehouseDocumentLineId, initialWarehouseDocumentLineId
		FROM @warehouseDocumentLine_WZK
		WHERE lineType = 3
		GROUP BY itemId, warehouseId, unitId, incomeDate, isDistributed, correctedWarehouseDocumentLineId,
			initialWarehouseDocumentLineId
	) x
END

/*Przekazane utworzonych pozycji w postaci XMLa*/
SELECT @xmlOut = 
(
	SELECT
		(SELECT * FROM @warehouseDocumentLine_PZK FOR XML PATH(''warehouseDocumentLine_PZK''),TYPE),
		(SELECT * FROM @warehouseDocumentLine_WZK FOR XML PATH(''warehouseDocumentLine_WZK''),TYPE)
	FOR XML PATH(''correctedLine''),TYPE
)
' 
END
GO

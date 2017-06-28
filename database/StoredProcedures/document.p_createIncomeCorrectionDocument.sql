/*
name=[document].[p_createIncomeCorrectionDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
6r5ALC5XZg3tANUn3hUA4w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_createIncomeCorrectionDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_createIncomeCorrectionDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_createIncomeCorrectionDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_createIncomeCorrectionDocument]
@xmlVar XML

/*
Struktura XMLa przekazywanego do procedury przez kernel (@xmlValue):

<root>
	<incomeCorrectionDocumentHeaderId> @incomeCorrectionDocumentHeaderId </incomeCorrectionDocumentHeaderId>
	<outcomeCorrectionDocumentHeaderId> @outcomeCorrectionDocumentHeaderId </outcomeCorrectionDocumentHeaderId>
	<date> @date </date>
	<correctedPosition>
		<id> @correctedPositionId </id>
		<commercialDocumentLineId> @commercialDocumentLineId </commercialDocumentLineId>
		<value> @positionValueAfterCorrection </value>
		<quantity> @positionQuantityAfterCorrection </quantity>
	</correctedPosition>
	<correctedPosition>
		(...)
	</correctedPosition>
</root>
*/

AS

SET NOCOUNT ON
--RAISERROR (N''p_createIncomeCorrectionDocument'',16,1); 
/*Deklaracja zmiennych*/
DECLARE
	@incomeCorrectionDocumentHeaderId UNIQUEIDENTIFIER,		--id PZK
	@outcomeCorrectionDocumentHeaderId UNIQUEIDENTIFIER,	--id WZK
	@date DATETIME,											--data operacji
	@correctedPositionId UNIQUEIDENTIFIER,					--id pozycji PZ (lub PZK+, jeśli PZ było już korygowane) do skorygowania
	@commercialDocumentLineId UNIQUEIDENTIFIER,				--id pozycji FKZ
	@positionValueAfterCorrection NUMERIC(18,2),			--wartość pozycji po korekcie
	@positionQuantityAfterCorrection NUMERIC(18,6),			--ilość na pozycji przychodu po korekcie
	@i INT,													--zmienna pomocnicza - licznik do pętli
	@numberOfCorrectedLines INT,							--liczba korygowanych pozycji PZ
	@xmlOut XML,											--XML przyjmujący dane z [document].[p_createIncomeCorrectionLine]
	@pzk_p INT,						--zmienna pomocnicza do kursora - przechowuje ordinalNumber PZK+
	@wzk_p INT,						--zmienna pomocnicza do kursora - przechowuje ordinalNumber WZK+
	@wzk_pQuantity NUMERIC(18,6),	--zmienna pomocnicza do kursora - przechowuje ilość na pozycji WZK+
	@pzk_pQuantity NUMERIC(18,6),	--zmienna pomocnicza do kursora - przechowuje ilość na pozycji PZK+
	@pzkRel NUMERIC(18,6),			--zmienna pomocnicza do kursora - przechowuje już rozchodowaną ilość PZK+
	@pzk_p_id UNIQUEIDENTIFIER,		--zmienna pomocnicza do kursora - przechowuje id pozycji PZK+
	@wzk_m_id UNIQUEIDENTIFIER,		--zmienna pomocnicza do kursora - przechowuje id pozycji WZK-
	@wzk_mQuantity NUMERIC(18,6),	--zmienna pomocnicza do pętki - przechowuje niepowiązaną ilość na pozycji WZK-
	@end BIT						--zmienna pomocnicza warunkująca zakończenie działania pętli
	
/*Tabela z danymi pobranymi z @xmlValue*/
DECLARE @correctedPositionsData TABLE 
	(
		[ordinalNumber] INT IDENTITY(1,1), 
		[id] UNIQUEIDENTIFIER,
		[commercialDocumentLineId] UNIQUEIDENTIFIER,
		[value] NUMERIC(18,2),
		[quantity] NUMERIC(18,6)
	)

/*Tabela z pozycjami dokumentu PZK*/
DECLARE @warehouseDocumentLine_PZK TABLE 
	(
		[ordinalNumber] INT IDENTITY(1,1), 
		[id] UNIQUEIDENTIFIER,
		[warehouseDocumentHeaderId] UNIQUEIDENTIFIER,
		[direction] INT,
		[itemId] UNIQUEIDENTIFIER,
		[warehouseId] UNIQUEIDENTIFIER,
		[unitId] UNIQUEIDENTIFIER,
		[quantity] NUMERIC(18,6),
		[price] NUMERIC(18,2),
		[value] NUMERIC(18,2),
		[incomeDate] DATETIME,
		[outcomeDate] DATETIME,
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
		[ordinalNumber] INT IDENTITY(1,1), 
		[id] UNIQUEIDENTIFIER,
		[warehouseDocumentHeaderId] UNIQUEIDENTIFIER,
		[direction] INT,
		[itemId] UNIQUEIDENTIFIER,
		[warehouseId] UNIQUEIDENTIFIER,
		[unitId] UNIQUEIDENTIFIER,
		[quantity] NUMERIC(18,6),
		[price] NUMERIC(18,2),
		[value] NUMERIC(18,2),
		[incomeDate] DATETIME,
		[outcomeDate] DATETIME,
		[description] NVARCHAR(500),
		[version] UNIQUEIDENTIFIER,
		[isDistributed] BIT,
		[previousIncomeWarehouseDocumentLineId] UNIQUEIDENTIFIER,
		[correctedWarehouseDocumentLineId] UNIQUEIDENTIFIER,
		[initialWarehouseDocumentLineId] UNIQUEIDENTIFIER,
		[lineType] INT
	)
	
/*Tabela z pozycjami dokumentu WZK przed agregacją zdublowanych pozycji*/
DECLARE @warehouseDocumentLine_WZK_forAggregate TABLE 
	(
		[warehouseDocumentHeaderId] UNIQUEIDENTIFIER,
		[direction] INT,
		[itemId] UNIQUEIDENTIFIER,
		[warehouseId] UNIQUEIDENTIFIER,
		[unitId] UNIQUEIDENTIFIER,
		[quantity] NUMERIC(18,6),
		[price] NUMERIC(18,2),
		[value] NUMERIC(18,2),
		[incomeDate] DATETIME,
		[outcomeDate] DATETIME,
		[description] NVARCHAR(500),
		[version] UNIQUEIDENTIFIER,
		[isDistributed] BIT,
		[previousIncomeWarehouseDocumentLineId] UNIQUEIDENTIFIER,
		[correctedWarehouseDocumentLineId] UNIQUEIDENTIFIER,
		[initialWarehouseDocumentLineId] UNIQUEIDENTIFIER,
		[lineType] INT
	)
	
/*Tabela z powiązaniami IncomeOutcomeRelation dla pozycji korygujących rozchody*/
DECLARE @incomeOutcomeRelation TABLE 
	( 
		[id] UNIQUEIDENTIFIER, 
		[incomeWarehouseDocumentLineId] UNIQUEIDENTIFIER, 
		[outcomeWarehouseDocumentLineId] UNIQUEIDENTIFIER, 
		[incomeDate] DATETIME,
		[quantity] NUMERIC(18,6),
		[version] UNIQUEIDENTIFIER
	)

/*Tabela powiązań dokumentów handlowych z magazynowymi*/
DECLARE @commercialWarehouseRelation TABLE
	(
		[id] UNIQUEIDENTIFIER,
		[commercialDocumentLineId] UNIQUEIDENTIFIER,
		[warehouseDocumentLineId] UNIQUEIDENTIFIER,
		[quantity] NUMERIC(18,6),
		[value] NUMERIC(18,2),
		[isValuated] BIT,
		[isOrderRelation] BIT,
		[isCommercialRelation] BIT,
		[isServiceRelation] BIT,
		[version] UNIQUEIDENTIFIER
	)

/*Tabela z ślepymi wycenami pozycji stornującej rozchód*/
DECLARE @commercialWarehouseValuation TABLE
	(
		[id] UNIQUEIDENTIFIER,
		[commercialDocumentLineId] UNIQUEIDENTIFIER,
		[warehouseDocumentLineId] UNIQUEIDENTIFIER,
		[quantity] NUMERIC(18,6),
		[value] NUMERIC(18,2),
		[price] NUMERIC(18,2),
		[version] UNIQUEIDENTIFIER
	)

/*Tabela z wycenami dokumentów rozchodowych*/
DECLARE @warehouseDocumentValuation TABLE
	(
		[id] UNIQUEIDENTIFIER,
		[incomeWarehouseDocumentLineId] UNIQUEIDENTIFIER,
		[outcomeWarehouseDocumentLineId] UNIQUEIDENTIFIER,
		[valuationId] UNIQUEIDENTIFIER,
		[quantity] NUMERIC(18,2),
		[incomePrice] NUMERIC(18,2),
		[incomeValue] NUMERIC(18,2),
		[version] UNIQUEIDENTIFIER
	)

/*Pobranie danych*/
SELECT @i = 1,
	@end = 0
	
SELECT @incomeCorrectionDocumentHeaderId = b.value(''(incomeCorrectionDocumentHeaderId)[1]'',''CHAR(36)''),
	@outcomeCorrectionDocumentHeaderId = b.value(''(outcomeCorrectionDocumentHeaderId)[1]'',''CHAR(36)''),
	@date = b.value(''(date)[1]'',''DATETIME'')
FROM @xmlVar.nodes(''root'') a ( b )

INSERT INTO @correctedPositionsData ([id], [commercialDocumentLineId], [value], [quantity])
SELECT 
	b.value(''(id)[1]'',''CHAR(36)''), 
	NULLIF(b.value(''(commercialDocumentLineId)[1]'',''CHAR(36)''),''''),
	b.value(''(value)[1]'',''NUMERIC(18,2)''), 
	b.value(''(quantity)[1]'',''NUMERIC(18,6)'')
FROM @xmlVar.nodes(''root/correctedPosition'') a ( b )

SELECT @numberOfCorrectedLines = MAX(ordinalNumber)
FROM @correctedPositionsData

/*Wywołanie procedury [document].[p_createIncomeCorrectionLine] (tworzącej pozycje korekt)
dla każdej korygowanej pozycji*/
WHILE @i <= @numberOfCorrectedLines
BEGIN
	
	/*Uzupełnienie wartości zmiennych, które bedą stanowić parametry dla wywoływanej procedury*/
	SELECT @correctedPositionId = id,
		@positionValueAfterCorrection = value,
		@positionQuantityAfterCorrection = quantity
	FROM @correctedPositionsData
	WHERE ordinalNumber = @i
	
	/*Wywołanie procedury [document].[p_createIncomeCorrectionLine]*/
	EXEC [document].[p_createIncomeCorrectionLine] @correctedPositionId, @positionValueAfterCorrection,
		@positionQuantityAfterCorrection, @xmlOut OUT
		
	/*Odczytanie pozycji dokumentu PZK stworzonych przez procedurę [document].[p_createIncomeCorrectionLine]*/
	INSERT INTO @warehouseDocumentLine_PZK ([id], [warehouseDocumentHeaderId], [direction], [itemId], 
		[warehouseId], [unitId], [quantity], [price], [value], [incomeDate], [description], [version], 
		[isDistributed], [previousIncomeWarehouseDocumentLineId], [correctedWarehouseDocumentLineId],
		[initialWarehouseDocumentLineId], [lineType])
	SELECT 
		b.value(''(id)[1]'',''CHAR(36)''),
		@incomeCorrectionDocumentHeaderId,
		b.value(''(direction)[1]'',''INT''),
		b.value(''(itemId)[1]'',''CHAR(36)''),
		b.value(''(warehouseId)[1]'',''CHAR(36)''),
		b.value(''(unitId)[1]'',''CHAR(36)''),
		b.value(''(quantity)[1]'',''NUMERIC(18,6)''),
		b.value(''(price)[1]'',''NUMERIC(18,2)''),
		b.value(''(value)[1]'',''NUMERIC(18,2)''),
		b.value(''(incomeDate)[1]'',''DATETIME''),
		b.value(''(description)[1]'',''NVARCHAR(500)''),
		b.value(''(version)[1]'',''CHAR(36)''),
		b.value(''(isDistributed)[1]'',''BIT''),
		b.value(''(previousIncomeWarehouseDocumentLineId)[1]'',''CHAR(36)''),
		b.value(''(correctedWarehouseDocumentLineId)[1]'',''CHAR(36)''),
		b.value(''(initialWarehouseDocumentLineId)[1]'',''CHAR(36)''),
		b.value(''(lineType)[1]'',''INT'')
	FROM @xmlOut.nodes(''correctedLine/warehouseDocumentLine_PZK'') a ( b )
		
	/*Odczytanie pozycji dokumentu WZK stworzonych przez procedurę [document].[p_createIncomeCorrectionLine]*/
	INSERT INTO @warehouseDocumentLine_WZK_forAggregate ([warehouseDocumentHeaderId], [direction], [itemId], 
		[warehouseId], [unitId], [quantity], [price], [value], [incomeDate], [description], [version], 
		[isDistributed], [previousIncomeWarehouseDocumentLineId], [correctedWarehouseDocumentLineId],
		[initialWarehouseDocumentLineId], [lineType])
	SELECT 
		@outcomeCorrectionDocumentHeaderId,
		b.value(''(direction)[1]'',''INT''),
		b.value(''(itemId)[1]'',''CHAR(36)''),
		b.value(''(warehouseId)[1]'',''CHAR(36)''),
		b.value(''(unitId)[1]'',''CHAR(36)''),
		b.value(''(quantity)[1]'',''NUMERIC(18,6)''),
		b.value(''(price)[1]'',''NUMERIC(18,2)''),
		b.value(''(value)[1]'',''NUMERIC(18,2)''),
		b.value(''(incomeDate)[1]'',''DATETIME''),
		b.value(''(description)[1]'',''NVARCHAR(500)''),
		b.value(''(version)[1]'',''CHAR(36)''),
		b.value(''(isDistributed)[1]'',''BIT''),
		NULLIF(b.value(''(previousIncomeWarehouseDocumentLineId)[1]'',''CHAR(36)''),''''),
		b.value(''(correctedWarehouseDocumentLineId)[1]'',''CHAR(36)''),
		b.value(''(initialWarehouseDocumentLineId)[1]'',''CHAR(36)''),
		b.value(''(lineType)[1]'',''INT'')
	FROM @xmlOut.nodes(''correctedLine/warehouseDocumentLine_WZK'') a ( b )
	
	SET @i = @i + 1
END

/*Wybranie tylko unikalnych pozycji dokumentu WZK, ponieważ jeden rozchód może dotyczyć jednocześnie 
więcej niż jednej z korygowanych pozycji, a wówczas wygenerowane linie dokumentu WZK sa zdublowane.*/
INSERT INTO @warehouseDocumentLine_WZK ([warehouseDocumentHeaderId], [direction], [itemId], 
	[warehouseId], [unitId], [quantity], [price], [value], [incomeDate], [description], [version], 
	[isDistributed], [previousIncomeWarehouseDocumentLineId], [correctedWarehouseDocumentLineId],
	[initialWarehouseDocumentLineId], [lineType])
SELECT DISTINCT [warehouseDocumentHeaderId], [direction], [itemId], 
	[warehouseId], [unitId], [quantity], [price], [value], [incomeDate], [description], [version], 
	[isDistributed], [previousIncomeWarehouseDocumentLineId], [correctedWarehouseDocumentLineId],
	[initialWarehouseDocumentLineId], [lineType]
FROM @warehouseDocumentLine_WZK_forAggregate

/*Nadanie identyfikatorów pozycjom WZK*/
UPDATE @warehouseDocumentLine_WZK
SET id = NEWID()

/*Wstawienie powiązań ilościowych PZ - PZK- dla niecałkowicie rozchodowanych korygowanych pozycji PZ*/
INSERT INTO @incomeOutcomeRelation ([id], [incomeWarehouseDocumentLineId], [outcomeWarehouseDocumentLineId],
	[incomeDate], [quantity], [version]) 			
SELECT NEWID(), pzk.correctedWarehouseDocumentLineId, pzk.id, pzk.incomeDate, pz.quantity - ior.quantity, NEWID()
FROM 
(
	/*Wybranie tylko pozycji PZK-*/
	SELECT *
	FROM @warehouseDocumentLine_PZK 
	WHERE lineType = -1
) pzk
JOIN document.WarehouseDocumentLine pz ON pzk.correctedWarehouseDocumentLineId = pz.id
LEFT JOIN
(
	/*Zliczenie ilości rozchodowanych z korygowanych pozycji PZ*/
	SELECT SUM(quantity) quantity, incomeWarehouseDocumentLineId   
	FROM document.IncomeOutcomeRelation
	WHERE incomeWarehouseDocumentLineId IN (SELECT id FROM @correctedPositionsData)
	GROUP BY incomeWarehouseDocumentLineId
) ior ON pz.id = ior.incomeWarehouseDocumentLineId
WHERE pz.quantity - ior.quantity > 0

/*Jeśli istniały rozchody z którejkolwiek korygowanej pozycji PZ, wstawienie powiązań ilościowych WZK - PZK*/
IF EXISTS (SELECT id FROM @warehouseDocumentLine_WZK)
BEGIN
	/*Wstawienie powiązań ilościowych WZK+ - PZK-*/
	INSERT INTO @incomeOutcomeRelation ([id], [incomeWarehouseDocumentLineId], [outcomeWarehouseDocumentLineId],
		[incomeDate], [quantity], [version])
	SELECT NEWID(), wzk.id, pzk.id, wzk.incomeDate, wzk.quantity, NEWID()
	FROM
	(
		/*Wybranie tylko pozycji WZK+*/
		SELECT *
		FROM @warehouseDocumentLine_WZK
		WHERE lineType = 3
	) wzk
	JOIN
	(
		/*Wybranie tylko pozycji PZK-*/
		SELECT *
		FROM @warehouseDocumentLine_PZK
		WHERE lineType = -1
	/*Funkcja [document].[f_compareIncomeDocumentLines] sprawdza, czy korygowana pozycja przychodowa
	stanowi przychód lub któryś z poprzednich przychodów dla pozycji WZK+.
	W ten sposób następuje odfiltrowanie tylko pozycji WZK+ pochodzących z korygowanego przychodu.
	(Odrzucone zostają pozycje WZK+, które nie pochodzą z korygowanego przychodu, a są wynikiem rozchodu
	pochodzącego z wielu przychodów - tzn. jedna pozycja WZ rozchodowywała towar z wielu pozycji przychodowych).*/
	) pzk ON (SELECT [document].[f_compareIncomeDocumentLines](wzk.previousIncomeWarehouseDocumentLineId, pzk.previousIncomeWarehouseDocumentLineId)) = pzk.previousIncomeWarehouseDocumentLineId
	
	/*Jesli pozostały jakieś niepowiązane pozycje WZK+ (dotyczące rozchodów z niekorygowanych aktualnie
	przychodów) wstawienie powiązań ilościowych WZK+ - WZK-*/
	IF EXISTS 
		(
			SELECT id
			FROM @warehouseDocumentLine_WZK
			WHERE lineType = 3
			AND id NOT IN (SELECT incomeWarehouseDocumentLineId FROM @incomeOutcomeRelation)
		)
	BEGIN
		INSERT INTO @incomeOutcomeRelation ([id], [incomeWarehouseDocumentLineId], [outcomeWarehouseDocumentLineId],
			[incomeDate], [quantity], [version])
		SELECT NEWID(), wzk_p.id, wzk_m.id, wzk_p.incomeDate, wzk_p.quantity, NEWID()
		FROM
		(
			/*Wybranie tylko pozycji WZK+ nie mających jeszcze powiązań w @incomeOutcomeRelation*/
			SELECT *
			FROM @warehouseDocumentLine_WZK
			WHERE lineType = 3
			AND id NOT IN (SELECT incomeWarehouseDocumentLineId FROM @incomeOutcomeRelation)
		) wzk_p
		JOIN
		(
			/*Wybranie tylko pozycji WZK-*/
			SELECT *
			FROM @warehouseDocumentLine_WZK
			WHERE lineType = -3
		) wzk_m ON wzk_p.correctedWarehouseDocumentLineId = wzk_m.correctedWarehouseDocumentLineId
	END
	
	/*Wstawienie powiązań ilościowych PZK+ - WZK-*/
	/*Kursor cur_pzk chodzi po wszystkich pozycjach PZK+, które mają mieć rozchody*/
	DECLARE cur_pzk CURSOR FOR
		/*Wybranie ordinalNumber (pole UNIQUE), identyfikatora i ilości pozycji PZK+ dotyczących tylko tych
		korygowanych pozycji przychodowych, które posiadały rozchody.*/
		SELECT DISTINCT pzk.ordinalNumber, pzk.id, pzk.quantity
		FROM
		(
			/*Wybranie tylko pozycji PZK+*/
			SELECT *
			FROM @warehouseDocumentLine_PZK 
			WHERE lineType = 1
		) pzk
		JOIN
		(
			/*Wybranie tylko pozycji WZK+ pochodzących od korygowanych przychodów*/
			SELECT *
			FROM @warehouseDocumentLine_WZK
			WHERE lineType = 3
		/*Funkcja [document].[f_compareIncomeDocumentLines] sprawdza, czy korygowana pozycja przychodowa,
		której dotyczy dana pozycja PZK+ stanowi przychód lub któryś z poprzednich przychodów dla pozycji WZK+.*/
		) wzk_p ON (SELECT [document].[f_compareIncomeDocumentLines](wzk_p.previousIncomeWarehouseDocumentLineId, pzk.previousIncomeWarehouseDocumentLineId)) = pzk.previousIncomeWarehouseDocumentLineId
		ORDER BY pzk.ordinalNumber
	OPEN cur_pzk 
	FETCH NEXT FROM cur_pzk 
	INTO @pzk_p, @pzk_p_id, @pzk_pQuantity
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		/*Kursor cur_wzk chodzi po wszystkich pozycjach WZK+, które wiążą się z daną pozycja PZK+
		i pobiera ordinalNumber tych pozycji oraz identyfikatory skorelowanych pozycji WZK-*/
		DECLARE cur_wzk CURSOR FOR
			/*Wybranie identyfikatora pozycji WZK- oraz ordinalNumber (pole UNIQUE) i ilości pozycji WZK+.
			Ilość z WZK+ wskazuje, na jaką ilość powinno być powiązane PZK+ z WZK-.*/
			SELECT wzk_p.ordinalNumber, wzk_m.id, wzk_p.quantity
			FROM
			(
				/*Wybranie tylko pozycji PZK+*/
				SELECT *
				FROM @warehouseDocumentLine_PZK 
				WHERE lineType = 1
			) pzk
			JOIN
			(
				/*Wybranie tylko pozycji WZK+ pochodzących od korygowanych przychodów*/
				SELECT *
				FROM @warehouseDocumentLine_WZK
				WHERE lineType = 3
			) wzk_p ON (SELECT [document].[f_compareIncomeDocumentLines](wzk_p.previousIncomeWarehouseDocumentLineId, pzk.previousIncomeWarehouseDocumentLineId)) = pzk.previousIncomeWarehouseDocumentLineId
			JOIN
			(
				/*Wybranie tylko pozycji WZK-*/
				SELECT *
				FROM @warehouseDocumentLine_WZK
				WHERE lineType = -3
			) wzk_m ON wzk_p.correctedWarehouseDocumentLineId = wzk_m.correctedWarehouseDocumentLineId
			WHERE pzk.ordinalNumber = @pzk_p
			ORDER BY wzk_p.ordinalNumber
		OPEN cur_wzk
		FETCH NEXT FROM cur_wzk
		INTO @wzk_p, @wzk_m_id, @wzk_pQuantity
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			/*Pobranie ilości, na jaką pozycja PZK+ została już rozchodowana.*/
			SELECT @pzkRel = ISNULL(SUM(quantity),0)
			FROM @incomeOutcomeRelation
			WHERE incomeWarehouseDocumentLineId = @pzk_p_id
			
			/*Wstawienie relacji IncomeOutcome jest wstawiane tylko jeśli pozycja PZK+ nie została
			jeszcze całkowicie rozchodowana*/
			IF (@pzkRel < @pzk_pQuantity)
			BEGIN
				INSERT INTO @incomeOutcomeRelation ([id], [incomeWarehouseDocumentLineId], [outcomeWarehouseDocumentLineId],
					[incomeDate], [quantity], [version])
				SELECT NEWID(), @pzk_p_id, @wzk_m_id, incomeDate, 
					CASE
						/*Jeśli pozostała (nierozchodowana) ilość z PZK+ jest niemniejsza
						od ilości na WZK+, powiązanie z WZK- tworzone jest na pełną ilość WZK+*/
						WHEN @pzk_pQuantity - @pzkRel >= @wzk_pQuantity THEN @wzk_pQuantity
						/*W przeciwnym razie powiązanie tworzone jest na nierozchodowaną ilość z PZK+*/
						ELSE @pzk_pQuantity - @pzkRel
					END, 
					NEWID()
				FROM @warehouseDocumentLine_PZK
				WHERE id = @pzk_p_id
			END
			
			FETCH NEXT FROM cur_wzk
			INTO @wzk_p, @wzk_m_id, @wzk_pQuantity
		END
		CLOSE cur_wzk
		DEALLOCATE cur_wzk
		FETCH NEXT FROM cur_pzk
		INTO @pzk_p, @pzk_p_id, @pzk_pQuantity
	END
	CLOSE cur_pzk
	DEALLOCATE cur_pzk
	
	/*Wstawienie powiązań między niepowiązanymi ilościami pozycji WZK- a innymi (niekorygowanymi aktualnie)
	przychodami. (Tylko jeśli korekta przychodu jest ilościowa i nowa ilość jest mniejsza od już rozchodowanej).*/
	/*Sprawdzenie, czy są niecałkowicie powiązane pozycje WZK-*/
	WHILE EXISTS 
		(  
			SELECT wzk.id 
			FROM @warehouseDocumentLine_WZK wzk 
			LEFT JOIN 
			(
				SELECT SUM(quantity) quantity, outcomeWarehouseDocumentLineId
				FROM @incomeOutcomeRelation
				GROUP BY outcomeWarehouseDocumentLineId
			) ir ON wzk.id = ir.outcomeWarehouseDocumentLineId 
			WHERE wzk.lineType = -3 
			AND wzk.quantity > ISNULL(ir.quantity, 0)
		)
	 BEGIN
		SELECT @wzk_m_id = wzk.id, @wzk_mQuantity = wzk.quantity - ISNULL(ir.quantity, 0)
		FROM @warehouseDocumentLine_WZK wzk 
		LEFT JOIN 
		(
			SELECT SUM(quantity) quantity, outcomeWarehouseDocumentLineId
			FROM @incomeOutcomeRelation
			GROUP BY outcomeWarehouseDocumentLineId
		) ir ON wzk.id = ir.outcomeWarehouseDocumentLineId 
		WHERE wzk.lineType = -3 
		AND wzk.quantity > ISNULL(ir.quantity, 0)
		
		INSERT INTO @incomeOutcomeRelation ([id], [incomeWarehouseDocumentLineId], [outcomeWarehouseDocumentLineId],
			[incomeDate], [quantity], [version])
		SELECT TOP 1 NEWID(), income.id, @wzk_m_id, income.incomeDate, 
			CASE
				WHEN income.quantity >= @wzk_mQuantity THEN @wzk_mQuantity
				ELSE income.quantity
			END,
			NEWID()
		FROM
		(
			SELECT ad.id, ad.quantity - ISNULL(ir.quantity, 0) quantity, ad.itemId, ad.warehouseId, ad.incomeDate
			FROM [document].[v_getAvailableDeliveries] ad
			LEFT JOIN
			(
				SELECT incomeWarehouseDocumentLineId, SUM(quantity) quantity
				FROM @incomeOutcomeRelation
				GROUP BY incomeWarehouseDocumentLineId
			) ir ON ad.id = ir.incomeWarehouseDocumentLineId
			WHERE ad.quantity > ISNULL(ir.quantity, 0)
			UNION ALL
			SELECT pzk.id, pzk.quantity - ISNULL(ir.quantity, 0) quantity, pzk.itemId, pzk.warehouseId, pzk.incomeDate
			FROM
			(
				SELECT id, quantity, itemId, warehouseId, incomeDate
				FROM @warehouseDocumentLine_PZK
				WHERE lineType = 1
			) pzk
			LEFT JOIN
			(
				SELECT incomeWarehouseDocumentLineId, SUM(quantity) quantity
				FROM @incomeOutcomeRelation
				GROUP BY incomeWarehouseDocumentLineId
			) ir ON pzk.id = ir.incomeWarehouseDocumentLineId
			WHERE pzk.quantity > ISNULL(ir.quantity, 0)
		) income
		JOIN @warehouseDocumentLine_WZK wzk ON wzk.itemId = income.itemId AND wzk.warehouseId = income.warehouseId
		ORDER BY incomeDate
		
		/*Jeśli brak dostępnych dostaw dla danej pozycji WZK- procedura zwraca komunikat i kończy swoje działanie*/
		IF @@ROWCOUNT = 0
		BEGIN
		
			DECLARE @itemName NVARCHAR(200)
			
			SELECT @itemName = i.name 
			FROM @warehouseDocumentLine_WZK wzk 
			JOIN item.Item i ON wzk.itemId = i.id
			WHERE wzk.id = @wzk_m_id
			
			SELECT ''Brak towaru '' + ISNULL(@itemName, '''') + '' na stanie w ilości '' + CAST(@wzk_mQuantity as varchar(50))
			FOR XML PATH(''root''), TYPE
				
			RETURN 0;
		END
	END
END

/*Jeżeli istnieje dokument FKZ dotyczący wystawianej korekty, wprowadzenie powiazań między pozycjami FKZ a PZK*/
IF EXISTS
	(
		SELECT id
		FROM @correctedPositionsData
		WHERE commercialDocumentLineId IS NOT NULL
	)
BEGIN
	/*Wprowadzenie powiązań pomiędzy FKZ a PZK-*/
	INSERT INTO @commercialWarehouseRelation ([id], [commercialDocumentLineId], [warehouseDocumentLineId],
		[quantity], [value], [isValuated], [isOrderRelation], [isCommercialRelation], [isServiceRelation],
		[version])
	SELECT NEWID(), cpd.commercialDocumentLineId, pzk.id,
		ABS(cwv.quantity) * -1, ABS(cwv.value) * -1, 1, 0, 1, 0,
		NEWID()
	FROM @correctedPositionsData cpd
	JOIN @warehouseDocumentLine_PZK pzk ON cpd.id = pzk.correctedWarehouseDocumentLineId
	JOIN document.CommercialWarehouseValuation cwv ON cpd.id = cwv.warehouseDocumentLineId
	WHERE cpd.commercialDocumentLineId IS NOT NULL
	AND pzk.lineType = -1
	
	/*Wprowadzenie powiązań pomiędzy FKZ a PZK+*/
	INSERT INTO @commercialWarehouseRelation ([id], [commercialDocumentLineId], [warehouseDocumentLineId],
		[quantity], [value], [isValuated], [isOrderRelation], [isCommercialRelation], [isServiceRelation],
		[version])
	SELECT NEWID(), cpd.commercialDocumentLineId, pzk.id,
		cpd.quantity, cpd.value, 1, 0, 1, 0,
		NEWID()
	FROM @correctedPositionsData cpd
	JOIN @warehouseDocumentLine_PZK pzk ON cpd.id = pzk.correctedWarehouseDocumentLineId
	WHERE cpd.commercialDocumentLineId IS NOT NULL
	AND pzk.lineType = 1
END

/*Tworzenie waluacji (wycen) WZK +*/
INSERT INTO @commercialWarehouseValuation ([id], [commercialDocumentLineId], [warehouseDocumentLineId], [quantity],
	[value], [price], [version])
SELECT NEWID(), NULL, wzk.id, wdv.quantity,
	wdv.incomeValue, wdv.incomePrice, NEWID()
FROM @warehouseDocumentLine_WZK wzk
JOIN document.WarehouseDocumentValuation wdv ON wzk.correctedWarehouseDocumentLineId = wdv.outcomeWarehouseDocumentLineId  
	AND wzk.previousIncomeWarehouseDocumentLineId = wdv.incomeWarehouseDocumentLineId
WHERE wzk.lineType = 3

/*Wstawienie waluacji (wycen) storna PZ (PZK -)*/
INSERT INTO @commercialWarehouseValuation ([id], [commercialDocumentLineId], [warehouseDocumentLineId], [quantity],
	[value], [price], [version])
SELECT NEWID(), ISNULL(cpd.commercialDocumentLineId, cwv.commercialDocumentLineId), pzk.id, ABS(cwv.quantity) * -1,
	ABS(cwv.value) * -1, cwv.price, NEWID()
FROM @warehouseDocumentLine_PZK pzk
JOIN document.CommercialWarehouseValuation cwv ON pzk.correctedWarehouseDocumentLineId = cwv.warehouseDocumentLineId
JOIN @correctedPositionsData cpd ON pzk.correctedWarehouseDocumentLineId = cpd.id
WHERE pzk.lineType = -1

/*Wstawienie waluacji (wycen) przychodu ponownego dla PZ (PZK +)*/
INSERT INTO @commercialWarehouseValuation ([id], [commercialDocumentLineId], [warehouseDocumentLineId], [quantity],
	[value], [price], [version])
SELECT NEWID(),	cpd.commercialDocumentLineId, pzk.id, cpd.quantity,
	cpd.value, ROUND(cpd.value/cpd.quantity,2), NEWID()
FROM @warehouseDocumentLine_PZK pzk
JOIN @correctedPositionsData cpd ON pzk.correctedWarehouseDocumentLineId = cpd.id
WHERE pzk.lineType = 1

/*Wstawienie waluacji (wycen) pomiędzy utworzonymi rozchodami i ich przychodami.
Waluacje zawsze są przenoszone niezmienione od źródlowych waluacji CommercialWarehouseValuation.*/
WHILE @end = 0
BEGIN
	INSERT INTO @WarehouseDocumentValuation ([id], [incomeWarehouseDocumentLineId], [outcomeWarehouseDocumentLineId],
		[valuationId], [quantity], [incomePrice], [incomeValue], [version])
	SELECT TOP 1 NEWID(), ior.incomeWarehouseDocumentLineId, l.id,
		cwv.id,
		CASE
			/*Jesli jeszcze niepowiązana wartościowo ilość z rozchodu jest większa od niepowiązanej
			jeszcze waluacji z CommercialWarehouseValuation...*/
			WHEN (l.quantity - ISNULL(v.quantity, 0)) > (cwv.quantity - ISNULL(usedValuations.quantity, 0))
			/*...wstaw tę niepowiązaną ilość z waluacji z CommercialWarehouseValuation...*/
			THEN cwv.quantity - ISNULL(usedValuations.quantity, 0)
			/*...w przeciwnym wypadku wstaw niepowiązaną wartościowo ilość z rozchodu*/
			ELSE l.quantity - ISNULL(v.quantity, 0)
		END,
		cwv.price,
		CASE
			WHEN (l.quantity - ISNULL(v.quantity, 0)) > (cwv.quantity - ISNULL(usedValuations.quantity, 0))
			THEN (cwv.quantity - ISNULL(usedValuations.quantity, 0)) * cwv.price
			ELSE (l.quantity - ISNULL(v.quantity, 0)) * cwv.price
		END,
		NEWID()
	FROM 
	(
		/*Wybranie pozycji rozchodowych wystawianych dokumentów magazynowych, czyli PZK- i WZK-*/
		SELECT id, quantity
		FROM @warehouseDocumentLine_PZK
		WHERE lineType = -1
		UNION
		SELECT id, quantity
		FROM @warehouseDocumentLine_WZK
		WHERE lineType = -3
	) l
	JOIN @IncomeOutcomeRelation ior ON l.id = ior.outcomeWarehouseDocumentLineId
	JOIN
	(
		SELECT *
		FROM document.CommercialWarehouseValuation
		UNION
		SELECT *
		FROM @CommercialWarehouseValuation
	) cwv ON ior.incomeWarehouseDocumentLineId = cwv.warehouseDocumentLineId
	LEFT JOIN
	(
		/*Zliczenie, na jaką ilość zostały już powiązane wartościowo rozchody*/
		SELECT outcomeWarehouseDocumentLineId, SUM(quantity) AS quantity
		FROM @WarehouseDocumentValuation
		GROUP BY outcomeWarehouseDocumentLineId
	) v ON l.id = v.outcomeWarehouseDocumentLineId
	LEFT JOIN
	(
		/*Zliczenie, na jaką ilość zostały już powiązane waluacje z CommercialWarehouseValuation
		w WarehouseDocumentValuation*/
		SELECT valuationId, SUM(quantity) quantity
		FROM
		(
			SELECT valuationId, SUM(quantity) quantity
			FROM @WarehouseDocumentValuation
			GROUP BY valuationId
			UNION
			SELECT valuationId, SUM(quantity) quantity
			FROM document.WarehouseDocumentValuation
			GROUP BY valuationId
		) usedValuations
		GROUP BY valuationId
	) usedValuations ON cwv.id = usedValuations.valuationId
	
	WHERE
		/*Wybranie tylko rozchodów nie w pełni powiązanych w WarehouseDocumentValuation*/
		l.quantity > ISNULL(v.quantity, 0)	
		/*Zabezpieczenie przed wielokrotnym wstawieniem tej samej relacji WarehouseDocumentValuation*/
		AND NOT EXISTS
			(
				SELECT id
				FROM @WarehouseDocumentValuation alreadyInserted
				WHERE alreadyInserted.incomeWarehouseDocumentLineId = ior.incomeWarehouseDocumentLineId
				AND alreadyInserted.valuationId = cwv.id
				AND alreadyInserted.outcomeWarehouseDocumentLineId = l.id
			)
		
	/*Jesli nie wstawiono żadnego rekordu, czyli nie ma już relacji do wprowadzenia koniec działania pętli*/
	IF (@@ROWCOUNT = 0)
		SELECT @end = 1
END

/*Przeniesienie zawartości tabel tymczasowych do bazy danych*/

INSERT INTO document.WarehouseDocumentLine ([id], [warehouseDocumentHeaderId], [direction], [itemId],
	[warehouseId], [unitId], [quantity], [price], [value], [incomeDate], [outcomeDate], [description],
	[ordinalNumber], [version], [isDistributed], [previousIncomeWarehouseDocumentLineId],
	[correctedWarehouseDocumentLineId], [initialWarehouseDocumentLineId], [lineType])
SELECT [id], [warehouseDocumentHeaderId], [direction], [itemId],
	[warehouseId], [unitId], [quantity], [price], [value], [incomeDate], [outcomeDate], [description],
	[ordinalNumber], [version], [isDistributed], [previousIncomeWarehouseDocumentLineId],
	[correctedWarehouseDocumentLineId], [initialWarehouseDocumentLineId], [lineType]
FROM @warehouseDocumentLine_PZK

INSERT INTO document.WarehouseDocumentLine ([id], [warehouseDocumentHeaderId], [direction], [itemId],
	[warehouseId], [unitId], [quantity], [price], [value], [incomeDate], [outcomeDate], [description],
	[ordinalNumber], [version], [isDistributed], [previousIncomeWarehouseDocumentLineId],
	[correctedWarehouseDocumentLineId], [initialWarehouseDocumentLineId], [lineType])
SELECT [id], [warehouseDocumentHeaderId], [direction], [itemId],
	[warehouseId], [unitId], [quantity], [price], [value], [incomeDate], [outcomeDate], [description],
	[ordinalNumber], [version], [isDistributed], [previousIncomeWarehouseDocumentLineId],
	[correctedWarehouseDocumentLineId], [initialWarehouseDocumentLineId], [lineType]
FROM @warehouseDocumentLine_WZK

INSERT INTO document.IncomeOutcomeRelation ([id], [incomeWarehouseDocumentLineId],
	[outcomeWarehouseDocumentLineId], [incomeDate], [quantity], [version])
SELECT [id], [incomeWarehouseDocumentLineId],
	[outcomeWarehouseDocumentLineId], [incomeDate], [quantity], [version]
FROM @incomeOutcomeRelation

INSERT INTO document.CommercialWarehouseRelation ([id], [commercialDocumentLineId], [warehouseDocumentLineId],
	[quantity], [value], [isValuated], [isOrderRelation], [isCommercialRelation], [isServiceRelation], [version])
SELECT [id], [commercialDocumentLineId], [warehouseDocumentLineId],
	[quantity], [value], [isValuated], [isOrderRelation], [isCommercialRelation], [isServiceRelation], [version]
FROM @commercialWarehouseRelation

INSERT INTO document.CommercialWarehouseValuation ([id], [commercialDocumentLineId], [warehouseDocumentLineId],
	[quantity], [value], [price], [version])
SELECT [id], [commercialDocumentLineId], [warehouseDocumentLineId],
	[quantity], [value], [price], [version]
FROM @commercialWarehouseValuation

INSERT INTO document.WarehouseDocumentValuation ([id], [incomeWarehouseDocumentLineId],
	[outcomeWarehouseDocumentLineId], [valuationId], [quantity], [incomePrice], [incomeValue], [version])
SELECT [id], [incomeWarehouseDocumentLineId],
	[outcomeWarehouseDocumentLineId], [valuationId], [quantity], [incomePrice], [incomeValue], [version]
FROM @warehouseDocumentValuation

/*Aktualizacja kosztów na rozchodowej części PZK i WZK*/
EXEC document.p_updateWarehouseDocumentCost @incomeCorrectionDocumentHeaderId, 1
EXEC document.p_updateWarehouseDocumentCost @outcomeCorrectionDocumentHeaderId, 1

/*Aktualizacja daty rozchodu dla dostaw które się skończyły (oznaczenie rozchodów których już nie ma)*/
UPDATE l
SET l.outcomeDate = ISNULL(NULLIF(@date,''1900-01-01 00:00:00.000''),getdate())
FROM document.WarehouseDocumentLine l 
JOIN
(
	SELECT SUM(quantity) quantity, incomeWarehouseDocumentLineId
	FROM document.IncomeOutcomeRelation
	GROUP BY incomeWarehouseDocumentLineId
) x ON l.id = x.incomeWarehouseDocumentLineId
WHERE (l.direction * l.quantity) > 0
AND ((l.direction * l.quantity) - x.quantity) = 0
AND l.id IN (SELECT incomeWarehouseDocumentLineId FROM @incomeOutcomeRelation)












/*
+ 1.  Pobrać z XMLa @xmlVar dane o korygowanych pozycjach i wstawić do tabeli tymczasowej każdą korygowaną pozycję.
+ 2.  Wywołać [document].[p_createIncomeCorrectionLine] dla każdej korygowanej pozycji, a dane z XMLi wynikowych 
      wprowadzić do @warehouseDocumentLine_PZK i @warehouseDocumentLine_WZK.
+ 2a. Wybrać tylko unikalne rekordy z @warehouseDocumentLine_WZK.
+ 3.  Wstawić powiązania PZ - PZK-.
+ 4.  Wstawić powiązania WZK+ - PZK-.
+ 5.  Wstawić powiązania WZK+ - WZK-.
+ 6.  Wstawić powiązania PZK+ - WZK-.
+ 7.  Wstawić powiązania Inne dostępne przychody - WZK-.
+ 8.  Dodać powiązania w @CommercialWarehouseRelation.
+ 9.  Dodać waluacje w @CommercialWarehouseValuation.
+ 9a. Dadać waluacje w WarehouseDocumentValuation.
+ 10. Przenieść wszystko z tabel tymczasowych do produkcyjnych.
+ 11. Zaktualizować co trzeba ;)
12. Obsłużyć zwracanie komunikatów jeśli nie można wystawić korekty
.
.
.
xx. Jeszcze WMS!
*/
' 
END
GO

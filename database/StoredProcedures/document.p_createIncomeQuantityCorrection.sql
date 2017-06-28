/*
name=[document].[p_createIncomeQuantityCorrection]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
QFjv2RaiTCpX8MBJlnw6xw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_createIncomeQuantityCorrection]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_createIncomeQuantityCorrection]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_createIncomeQuantityCorrection]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [document].[p_createIncomeQuantityCorrection]
@xmlVar XML
AS
BEGIN
--return 0;
DECLARE
	@errorMsg NVARCHAR(200), 
	@incomeCorrectionOrdinalNumber INT,
	@quantity NUMERIC(18,6),
	@quantity_tmp NUMERIC(18,6),
	@value NUMERIC(18,2),

	@id UNIQUEIDENTIFIER,--id pozycji PZ do skorygowania
	@warehouseDocumentHeaderId UNIQUEIDENTIFIER, --idPZK
	@outcomeCorrectionDocumentHeaderId UNIQUEIDENTIFIER, --id nagłówka WZK, jeśli korygowany przychód miał rozchody
	@commercialDocumentLineId UNIQUEIDENTIFIER, --id pozycji faktury zakupowej korygującej
	@data DATETIME, -- data całej akcji 
	@incomeOrdinalNumber INT,
	@outcomeOrdinalNumber INT,

	@incomeCorrectionLineId UNIQUEIDENTIFIER, -- Pozycja -PZK wstawiona by wystornować orginalny PZ
	@outcomeCorrectionLineId UNIQUEIDENTIFIER, -- Pozycja -WZK wstawiona by ponownie wydać WZ
	@localTransactionId UNIQUEIDENTIFIER,
	@deferredTransactionId UNIQUEIDENTIFIER,
	@databaseId UNIQUEIDENTIFIER,
	@incompleteIncome BIT,
	@itemId uniqueidentifier, 
	@warehouseId uniqueidentifier,
	@incomeWarehouseDocumentLineId uniqueidentifier, 
	@outcomeWarehouseDocumentLineId uniqueidentifier , 
	@i int,
	@incomeDocId uniqueidentifier,
	@q decimal(18,6),
	@quantityLeft decimal(18,6),
	@quantityTemp decimal(18,6), 
	@incompleteIncomePriceCorrection bit,
    @wzkm int, 
    @wzkmLine int,
    @pzkp_id uniqueidentifier, 
    @pzkp_incomeDate datetime, 
    @pzkp_quantityLeft numeric(18,6)
    ,@wzLineFlag int
    
	
/*Tabela z pozycjami przydowymi korekty zwracającej wydanie*/
DECLARE @warehouseDocumentLine_PZ TABLE (ordinalNumber int identity(1,1), id  uniqueidentifier, warehouseDocumentHeaderId uniqueidentifier,direction int,itemId uniqueidentifier,warehouseId uniqueidentifier,unitId uniqueidentifier,quantity numeric(18,6),price numeric(18,2),[value] numeric(18,2),incomeDate datetime,outcomeDate datetime,[description] nvarchar(500),version uniqueidentifier,isDistributed bit,previousIncomeWarehouseDocumentLineId uniqueidentifier,correctedWarehouseDocumentLineId uniqueidentifier,initialWarehouseDocumentLineId uniqueidentifier,lineType int, insertedId uniqueidentifier, incomeWarehouseDocumentLineId uniqueidentifier)
DECLARE @warehouseDocumentLine_WZ TABLE (ordinalNumber int identity(1,1), id  uniqueidentifier, warehouseDocumentHeaderId uniqueidentifier,direction int,itemId uniqueidentifier,warehouseId uniqueidentifier,unitId uniqueidentifier,quantity numeric(18,6),price numeric(18,2),[value] numeric(18,2),incomeDate datetime,outcomeDate datetime,[description] nvarchar(500),version uniqueidentifier,isDistributed bit,previousIncomeWarehouseDocumentLineId uniqueidentifier,correctedWarehouseDocumentLineId uniqueidentifier,initialWarehouseDocumentLineId uniqueidentifier,lineType int, insertedId uniqueidentifier, incomeWarehouseDocumentLineId uniqueidentifier) --, incomeOutcomeRelationId uniqueidentifier

/*Tabela z pozycjami powiązania IncomeOutcomeRelation dla pozycji korygującej rozchody*/
DECLARE @incomeOutcomeRelation TABLE (ordinalNumber int identity(1,1), id uniqueidentifier,insertedId uniqueidentifier, incomeWarehouseDocumentLineId uniqueidentifier, outcomeWarehouseDocumentLineId uniqueidentifier, incomeDate datetime, quantity numeric(18,6),version uniqueidentifier)			

/*Tabela z ślepymi wycenami pozycji stornującej rozchód*/
DECLARE @commercialWarehouseValuation TABLE (ordinalNumber int identity(1,1),test varchar(50), [id] uniqueidentifier,[commercialDocumentLineId] uniqueidentifier,[warehouseDocumentLineId] uniqueidentifier,[quantity] numeric(18,6),[value] numeric(18,2),[price] numeric(18,2),[version] uniqueidentifier)

/*Tabela z powiązaniami dokumentów handlowych z magazynowymi*/
DECLARE @commercialWarehouseRelation TABLE ([id] uniqueidentifier,[commercialDocumentLineId] uniqueidentifier,[warehouseDocumentLineId] uniqueidentifier,[quantity] numeric(18,6),[value] numeric(18,2),[isValuated] bit,[isOrderRelation] bit,[isCommercialRelation] bit, [version] uniqueidentifier)

/*Tabela z wycenami dokumentów rozchodowych*/
DECLARE @warehouseDocumentValuation TABLE  ([id] uniqueidentifier,[incomeWarehouseDocumentLineId] uniqueidentifier,[outcomeWarehouseDocumentLineId] uniqueidentifier,[valuationId] uniqueidentifier,[quantity]  numeric(18,2),[incomePrice] numeric(18,6),[incomeValue] numeric(18,6),[version] uniqueidentifier)


/*Pobranie danych o operacji*/
SELECT 
	@incomeOrdinalNumber = ISNULL(b.value(''(incomeOrdinalNumber)[1]'',''int''),0),
	@outcomeOrdinalNumber = ISNULL(b.value(''(outcomeOrdinalNumber)[1]'',''int''),0),
	@commercialDocumentLineId = NULLIF(b.value(''(commercialDocumentLineId)[1]'' ,''char(36)''),''''), 
	@id = b.value(''(id)[1]'' ,''char(36)''), 
	@warehouseDocumentHeaderId = b.value(''(warehouseDocumentHeaderId)[1]'' ,''char(36)''),
	@outcomeCorrectionDocumentHeaderId = NULLIF(b.value(''(outcomeCorrectionDocumentHeaderId)[1]'' ,''char(36)''),''''),
	@data =  b.value(''(data)[1]'' ,''datetime''),

	@quantity = b.value(''(quantity)[1]'' ,''numeric(18,6)''),
	@value =  b.value(''(value)[1]'' ,''numeric(18,2)''),

	@localTransactionId = b.value(''(localTransactionId)[1]'' ,''char(36)''), 
	@deferredTransactionId = b.value(''(deferredTransactionId)[1]'' ,''char(36)''),
	@databaseId = b.value(''(databaseId)[1]'' ,''char(36)''),
	@incompleteIncome = 0
FROM @xmlVar.nodes(''root'') a ( b ) 

--IF @id = ''8352DD7B-119E-4ABC-8930-EA77DD2EC0E7''
--       RAISERROR (''test'', 16, 1 ) ;


--IF @id = ''29EBB765-C467-436B-9D45-8148AA87159F''
--return 0;
/*Czyli tu mam załatwiony zwrot całkowity pozycji rochodowej WZki, jeśli takowa występuje.
Dalej wystawiam ponowne wydanie WZKi, dopinam jej powiązania ilościowe na dostawy nie pochodzące od korygowanego PZ,
uzupełniam wyceny 
*/
IF @outcomeCorrectionDocumentHeaderId IS NOT NULL 
	AND EXISTS ( select id from document.IncomeOutcomeRelation where incomeWarehouseDocumentLineId  = @id )
	/*To jest obejście jeśli są korygowane dwie pozycje i tylko jedna ma rozchod*/
	BEGIN

		/*
			Wstawienie pozycji storna czyli używam relacji ilościowej z przychodem korygowanej PZki, 
			do stworzenia pozycji stornującej, powstanie tyle pozycji z ilu 
			przychodów zdejmował WZ lub ostatnia jego korekta orginalny WZ znajdziemy tylko przez corrected, 
			może być z kilku różnych WZ 
		*/
		
		INSERT INTO @warehouseDocumentLine_WZ     ([id],       [warehouseDocumentHeaderId],[direction],[itemId],[warehouseId],[unitId],      [quantity],                           [price],        [value],[outcomeDate],[description],[version],[isDistributed],[previousIncomeWarehouseDocumentLineId],[correctedWarehouseDocumentLineId],[initialWarehouseDocumentLineId]              ,[lineType],[incomeDate] , insertedId, incomeWarehouseDocumentLineId) --, incomeOutcomeRelationId
		SELECT								    NEWID(),@outcomeCorrectionDocumentHeaderId,         -1,l.itemId,l.warehouseId,l.unitId,ABS(ir.quantity) * -1,ISNULL(valuation.value/valuation.quantity,0),ISNULL(valuation.value,0),         NULL ,l.description,  NEWID(),l.isDistributed,       ir.incomeWarehouseDocumentLineId,                              l.id,ISNULL(l.initialWarehouseDocumentLineId, l.id),         3,ir.incomeDate, l.id, ir.incomeWarehouseDocumentLineId -- , ir.id
		FROM document.IncomeOutcomeRelation ir 
			JOIN document.WarehouseDocumentLine l  ON ir.outcomeWarehouseDocumentLineId = l.id
			LEFT JOIN (		SELECT SUM(quantity) quantity,SUM(incomeValue) [value], outcomeWarehouseDocumentLineId  
							FROM document.WarehouseDocumentValuation wdv 
							WHERE incomeWarehouseDocumentLineId = @id
							GROUP BY outcomeWarehouseDocumentLineId ) valuation ON l.id = valuation.outcomeWarehouseDocumentLineId
			JOIN document.WarehouseDocumentLine l2  ON ir.incomeWarehouseDocumentLineId = l2.id									
		WHERE ir.outcomeWarehouseDocumentLineId in ( 
						SELECT [document].[f_getOutcomeLineAfterCostCorrection](outcomeWarehouseDocumentLineId)
						FROM document.IncomeOutcomeRelation 
						WHERE incomeWarehouseDocumentLineId = @id
						)
		-- Nie możemy brać pozycji dostawionych przez ten sam dokument korekty, czyli jeśli są takie same towary na korygowanycm przychodzie, druga pozycja korekkty je pomija
		-- Poprawka dodana 26sty 2011	CzarekW			
			AND ir.outcomeWarehouseDocumentLineId NOT IN (
			
				SELECT  id
				FROM document.WarehouseDocumentLine 
				WHERE warehouseDocumentHeaderId = @outcomeCorrectionDocumentHeaderId
						)
			AND l2.warehouseDocumentHeaderId NOT IN ( @warehouseDocumentHeaderId,@outcomeCorrectionDocumentHeaderId) 
	

		
		/*	
			Sytuacja oznacza że korekta WZ została wygenerowana na wcześniejszej pozycji korekty, ma to wpływ na powiązania pozycjki PZK+ z WZK-
			Przykład: Jeżli PZ ma dwoie pozycje tego samego towaru i rozchody, to po uruchomieniu procedury na drugiej pozycji nie robimy
			ponownego zwrotu tylko dopinamy korekte do istniejącego zwrotu
			Flaga ma oznaczyć taka sytuację i ma wpływ na dalszy przebieg procedury
		*/
		--SELECT  id
		--		FROM document.WarehouseDocumentLine 
		--		WHERE warehouseDocumentHeaderId = @outcomeCorrectionDocumentHeaderId
		--select * from @warehouseDocumentLine_WZ			
			/* 2013-05-16 */
			SELECT @wzLineFlag = ISNULL( (
											SELECT COUNT(*)  
											FROM document.WarehouseDocumentLine  
											WHERE warehouseDocumentHeaderId = @outcomeCorrectionDocumentHeaderId 
												AND itemId = (
															SELECT itemId 
															FROM document.WarehouseDocumentLine 
															WHERE warehouseDocumentHeaderId = @outcomeCorrectionDocumentHeaderId AND id = @id)
											),0)

						/* 
							WZka może pochodzić z wielu PZ więc zwracamy wszyskie powiązania, nie tylko te z korygowanym PZ
							funkcja na lini WZ poszukuje ostatniej korekty kosztowej tego WZ
							dodaję kolumnę incomeWarehouseDocumentLineId w celu późniejszej identyfikacji pozycji z której pochodzi PZ */
/*PROBLEM PODWÓJNEJ POZYCJI TEGO SAMEGO TOWARU, ZWROT KILKUKROTNY NIE JEST POTRZEBNY A PROCKA ODPALANA JEST DLA KAŻDEJ POZYCJI KORYGOWANEJ PZ*/

	IF @wzLineFlag = 0
		BEGIN
			SELECT @outcomeCorrectionLineId = NEWID()
			/*Wstawienie WZK wydającego pozycje WZK-*/
			INSERT INTO @warehouseDocumentLine_WZ     ([id],       [warehouseDocumentHeaderId],[direction],[itemId],[warehouseId],[unitId],   [quantity],[price],    [value],[outcomeDate],[incomeDate],[description],[version],[isDistributed],[previousIncomeWarehouseDocumentLineId],[correctedWarehouseDocumentLineId],[initialWarehouseDocumentLineId]                      ,[lineType])
			SELECT                                  NEWID(),@outcomeCorrectionDocumentHeaderId,         -1,x.itemId,x.warehouseId,x.unitId,   x.quantity,   NULL,    x.value,         NULL,x.incomeDate,        NULL , NEWID(),x.isDistributed,                                   NULL,                      x.insertedId,ISNULL(x.initialWarehouseDocumentLineId, x.insertedId),-3
			FROM (
				SELECT l.itemId,l.warehouseId,l.unitId, ABS(SUM(quantity)) quantity, null [value],l.isDistributed,l.insertedId,l.initialWarehouseDocumentLineId, l.incomeDate
				FROM @warehouseDocumentLine_WZ l
				WHERE l.lineType = 3
				GROUP BY l.itemId,l.warehouseId,l.unitId,l.isDistributed,l.initialWarehouseDocumentLineId, l.insertedId, l.incomeDate
			) x


			/* Budowa ślepych wycen dla pozycji przychodowej korekty wydania
			linie pochodzą z właśnie dodanych linii, pozycje wycen powiązane są po l.previousIncomeWarehouseDocumentLineId
			l.id - id nowego przychodu do którego dopinamy wycenę
			@commercialDocumentLineId - w przypadku gdy podane jest id FSK, dopinam wyceny storna doń :) */
			INSERT INTO @commercialWarehouseValuation ([id],commercialDocumentLineId,[warehouseDocumentLineId],[quantity],[value],[price],[version], test)
			SELECT NEWID(), NULL, l.id, wdv.quantity, wdv.incomeValue, wdv.incomePrice,NEWID(), ''WZK1''
			FROM @warehouseDocumentLine_WZ l
				JOIN document.WarehouseDocumentValuation wdv ON l.correctedWarehouseDocumentLineId = wdv.outcomeWarehouseDocumentLineId  AND l.previousIncomeWarehouseDocumentLineId = wdv.incomeWarehouseDocumentLineId
			WHERE lineType = 3
		END	
	
END
	
        
SELECT @incomeCorrectionLineId = NEWID() --Stanowić będzie pozycję rozchodu dla powiązania ilościowego PZK - WZK

/*Wstawienie storna dla PZ (PZK -)*/
	/*Zwrot zakłada że udało się zwrócić wszystkie rozchody z PZki i teraz mogę je wszystkie wydać*/
	INSERT INTO @warehouseDocumentLine_PZ     ([id],[warehouseDocumentHeaderId],[direction],[itemId],[warehouseId],[unitId],     [quantity],[price],[value],[outcomeDate],[description],[version],[isDistributed],[previousIncomeWarehouseDocumentLineId],[correctedWarehouseDocumentLineId],[initialWarehouseDocumentLineId]             ,[lineType],[incomeDate] , insertedId)
	SELECT				 @incomeCorrectionLineId, @warehouseDocumentHeaderId,          1,l.itemId,l.warehouseId,l.unitId,l.quantity * -1,l.price,l.value,         NULL,l.description,  NEWID(),l.isDistributed,                                    @id,                               @id,ISNULL(l.initialWarehouseDocumentLineId, @id),         -1, l.incomeDate, l.id
	FROM  document.WarehouseDocumentLine l
	WHERE l.id = @id

	/*Wstawienie ilościowych relacji do storna PZ (PZK -)*/
	IF @commercialDocumentLineId IS NOT NULL
	INSERT INTO @commercialWarehouseRelation ([id] ,[commercialDocumentLineId] ,[warehouseDocumentLineId] ,[quantity] ,   [value] ,[isValuated] ,[isOrderRelation] ,[isCommercialRelation] ,[version] )
	SELECT NEWID(), ISNULL( @commercialDocumentLineId,c.commercialDocumentLineId), @incomeCorrectionLineId, ABS(c.quantity) * -1 , ABS(c.value) * -1, 1 ,0,1, NEWID()
	FROM document.CommercialWarehouseValuation c 
	WHERE warehouseDocumentLineId = @id

	/*Wstawienie wycen do storna PZ (PZK -)*/
	INSERT INTO @commercialWarehouseValuation ([id],commercialDocumentLineId,[warehouseDocumentLineId],[quantity],[value],[price],[version], test)
	SELECT NEWID(), ISNULL( @commercialDocumentLineId,c.commercialDocumentLineId), @incomeCorrectionLineId, ABS(c.quantity) * -1 , ABS(c.value) * -1, c.price , NEWID(), ''storno PZ''
	FROM document.CommercialWarehouseValuation c 
	WHERE warehouseDocumentLineId = @id

--------------------------------------------Bardzo ciekawy fragment korekty -------------------------------------------------------------------------------

		/*Funkcja poszukiwania częściowo rozchodowanych już PZ, będziemy dopinać brakującą część z pozostałych na magazynie przychodów, zgodnie z fifo*/
		SELECT  @quantityLeft =  SUM( ir.quantity ), @quantityTemp = @quantity
		FROM document.WarehouseDocumentLine l
			LEFT JOIN document.IncomeOutcomeRelation ir ON l.id = ir.incomeWarehouseDocumentLineId
		WHERE l.id = @id
		/*''
			@quantityLeft -- to jest ilość na jaką orginalny PZ był rozchodowany, ilość ta musi być dopięta do przychodów jaki powstaną po korekcie PZ , ewnetualnie do innych przychodów z tego magazynu
			@quantityTemp -- to jest ilość jaka pozostała po orginalnym PZ
		*/
		--IF (@quantity < @quantityLeft) 
		--	SELECT @incompleteIncome = 1 --, @quantity =  ABS(@quantityLeft) - ABS(@quantity)
		IF  (( @quantity = (SELECT l.quantity FROM document.WarehouseDocumentLine l WHERE l.id = @id)) AND @quantityLeft <> 0)
			SELECT 	@incompleteIncomePriceCorrection = 1,@incompleteIncome = 1
			
------------------------------------------------------------------------------------------------------------------------------------------------------------
 

IF @quantity <> 0  --czyli nie dla całkowitego zwrotu do dostawcy
	BEGIN

		DECLARE  @pzk_plus UNIQUEIDENTIFIER
		SELECT @pzk_plus = NEWID()

		/*Wstawienie przychodu ponownego dla PZ (PZK +)*/
		INSERT INTO @warehouseDocumentLine_PZ     ([id],[warehouseDocumentHeaderId],[direction],[itemId],[warehouseId],[unitId],     [quantity],[price],[value],[outcomeDate],[description],[version],[isDistributed],[previousIncomeWarehouseDocumentLineId],[correctedWarehouseDocumentLineId],[initialWarehouseDocumentLineId]             ,[lineType], [incomeDate] , insertedId)
		SELECT								  @pzk_plus, @warehouseDocumentHeaderId,          1,l.itemId,l.warehouseId,l.unitId,@quantity ,ROUND(@value/@quantity,2),ABS(@value)* SIGN(@quantity),        NULL,l.description,  NEWID(),l.isDistributed,                                         @id,                               @id,ISNULL(l.initialWarehouseDocumentLineId, @id),         1, l.incomeDate, l.id
		FROM  document.WarehouseDocumentLine l
		WHERE l.id = @id 

		IF @commercialDocumentLineId IS NULL
			
			/*Wstawienie wycen przychodu ponownego dla PZ (PZK +)*/
			INSERT INTO @commercialWarehouseValuation ([id],commercialDocumentLineId,[warehouseDocumentLineId],[quantity],[value],					  [price],[version], test)
			SELECT									NEWID(),					NULL,						id, @quantity, @value, ROUND(@value/@quantity,2) ,  NEWID(), ''przychod dla PZ''
			FROM @warehouseDocumentLine_PZ 
			WHERE lineType = 1
		ELSE
			BEGIN

 				/*Wstawienie relacji lini dokumentów handlowych z magazynowymi*/
				INSERT INTO @commercialWarehouseRelation ([id] ,[commercialDocumentLineId] ,[warehouseDocumentLineId] ,[quantity] ,   [value] ,[isValuated] ,[isOrderRelation] ,[isCommercialRelation] ,[version] )
				SELECT									NEWID(), @commercialDocumentLineId,					 @pzk_plus, @quantity, @value,           1 ,                 0,                      1,NEWID()
				FROM document.CommercialDocumentLine c 
				WHERE c.id = @commercialDocumentLineId 


				/*Wstawienie wycen przychodu ponownego dla PZ (PZK  +)*/
				INSERT INTO @commercialWarehouseValuation ([id],  commercialDocumentLineId,[warehouseDocumentLineId],     [quantity],[value],                    [price],[version], test)
				SELECT									NEWID(), @commercialDocumentLineId,				   @pzk_plus, ABS(@quantity), @value, ROUND(@value/@quantity,2) ,  NEWID(), ''przychod dla PZ''
				FROM document.CommercialDocumentLine c 
				WHERE c.id = @commercialDocumentLineId 
				
		
			END
	END
	

/*Wstawienie powiązania ilościowego PZK- z PZ*/
INSERT INTO @incomeOutcomeRelation (id, incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId , incomeDate , quantity ,version ) 			
SELECT * FROM (
	SELECT NEWID() id, @id incomeWarehouseDocumentLineId, l2.id outcomeWarehouseDocumentLineId, l.incomeDate incomeDate, 
	(ABS(l.quantity ) - ABS(ISNULL(x.quantity,0)) ) quantity, NEWID() [version]
	FROM document.WarehouseDocumentLine l
		JOIN @warehouseDocumentLine_PZ l2 ON l.id = l2.insertedId
	LEFT JOIN (
					SELECT SUM(quantity) quantity, incomeWarehouseDocumentLineId   
					FROM document.IncomeOutcomeRelation ir 
					WHERE ir.incomeWarehouseDocumentLineId  = @id
					GROUP BY ir.incomeWarehouseDocumentLineId ) x ON l2.insertedId = x.incomeWarehouseDocumentLineId 
	WHERE l.id = @id AND l2.lineType = -1
) x
WHERE x.quantity > 0


---------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*Wstawienie powiązania ilościowego PZK WZK */ --
IF @outcomeCorrectionDocumentHeaderId IS NOT NULL
	BEGIN
	
		/*PZK- WZK+*/
		INSERT INTO @incomeOutcomeRelation (id, incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId , incomeDate , quantity ,version ) --, insertedId )			
		SELECT NEWID(), l.id,lp.id, l.incomeDate, ABS(l.quantity) , NEWID()
		FROM @warehouseDocumentLine_WZ l 
			JOIN @warehouseDocumentLine_PZ lp ON l.previousIncomeWarehouseDocumentLineId = lp.previousIncomeWarehouseDocumentLineId 
				AND l.lineType = 3  
				AND lp.lineType = -1
		/*
			Czarekw :2012-11-20
			Korygując drugą pozycje na tym samym dokumencie, pamietamy że zwrot rozchodów jest juz wstawiony do bazy, 
			wiec nie znajdziemy go w zmiennych tabelarycznych a w tabelach docelowych
		*/
		
		IF @@rowcount = 0 
			BEGIN
				INSERT INTO @incomeOutcomeRelation (id, incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId , incomeDate , quantity ,version ) --, insertedId )			
				SELECT NEWID(), l.id,lp.id, l.incomeDate, ABS(l.quantity) , NEWID()
				FROM document.WarehouseDocumentLine l 
					JOIN @warehouseDocumentLine_PZ lp ON l.previousIncomeWarehouseDocumentLineId = lp.previousIncomeWarehouseDocumentLineId 
					AND l.lineType = 3  
					AND lp.lineType = -1
				
			END


		/*PZK+ WZK-*/
		
		/*Wstawiamy powiązanie PZK+ z WZK- na tę ilość obecnie wstawianego przychodu jaka pozostała po orginalnym PZ, korekta może zmniejszyć tę ilość nawet tak że
		 z obecnego PZ nic nie można powiązać z WZK -*/

		/*nowy sposób-- zmiana 2010-08-11 CW*/
		
		IF @wzLineFlag = 0 
			BEGIN
				SELECT @wzkm = max(ordinalNumber) , @wzkmLine = min(ordinalNumber)
				FROM @warehouseDocumentLine_WZ l 
				WHERE l.lineType = -3 


				SELECT @pzkp_incomeDate = incomeDate ,@pzkp_quantityLeft = quantity, @pzkp_id = id
				FROM @warehouseDocumentLine_PZ 
				WHERE lineType = 1
			END
		ELSE
			BEGIN
				SELECT @wzkm = max(ordinalNumber) , @wzkmLine = min(ordinalNumber)
				FROM document.WarehouseDocumentLine l 
				WHERE l.warehouseDocumentHeaderId = @outcomeCorrectionDocumentHeaderId AND l.lineType = -3 
				SELECT @pzkp_incomeDate = incomeDate ,@pzkp_quantityLeft = quantity, @pzkp_id = id
				FROM @warehouseDocumentLine_PZ 
				WHERE lineType = 1
			END

		WHILE @wzkmLine <= @wzkm AND @pzkp_quantityLeft > 0
			BEGIN
				/*Proste uzupełnienie ilości, da sie to zrobić kwerendą bez pętli ale powodowało to trudności w zrozumieniu algorytmu*/
				INSERT INTO @incomeOutcomeRelation (id, incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId , incomeDate , quantity ,version )
				SELECT NEWID(),@pzkp_id, l.id, @pzkp_incomeDate, CASE WHEN @pzkp_quantityLeft >= l.quantity THEN l.quantity ELSE @pzkp_quantityLeft END , NEWID()
				FROM @warehouseDocumentLine_WZ l 
				WHERE ordinalNumber = @wzkmLine
				
				IF @@rowcount = 0 
					BEGIN
						INSERT INTO @incomeOutcomeRelation (id, incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId , incomeDate , quantity ,version )
						SELECT NEWID(),@pzkp_id, l.id, @pzkp_incomeDate, CASE WHEN @pzkp_quantityLeft >= l.quantity THEN l.quantity ELSE @pzkp_quantityLeft END , NEWID()
						FROM document.WarehouseDocumentLine l 
						WHERE warehouseDocumentHeaderId = @outcomeCorrectionDocumentHeaderId AND ordinalNumber = @wzkmLine
						
					END
				SELECT @pzkp_quantityLeft = @pzkp_quantityLeft - CASE WHEN @pzkp_quantityLeft >= l.quantity THEN l.quantity ELSE @pzkp_quantityLeft END
				FROM @warehouseDocumentLine_WZ l 
				WHERE ordinalNumber = @wzkmLine
				
			SELECT @wzkmLine = @wzkmLine + 1
			END

	END
	--select * from @warehouseDocumentLine_WZ
/*Wstawienie pozycji dokumentu korekty - zostawiłem na koniec dla jednego inserta*/
INSERT INTO document.WarehouseDocumentLine ([id],[warehouseDocumentHeaderId],[direction],[itemId],[warehouseId],[unitId],[quantity],[price],[value],[incomeDate],[outcomeDate],[description],                 [ordinalNumber],[version],[isDistributed],[previousIncomeWarehouseDocumentLineId],[correctedWarehouseDocumentLineId],[initialWarehouseDocumentLineId],[lineType])
SELECT                                      [id],[warehouseDocumentHeaderId],[direction],[itemId],[warehouseId],[unitId],[quantity],ISNULL([price],0),ISNULL([value],0),[incomeDate],[outcomeDate],[description],@outcomeOrdinalNumber +[ordinalNumber],[version],[isDistributed],[previousIncomeWarehouseDocumentLineId],[correctedWarehouseDocumentLineId],[initialWarehouseDocumentLineId],[lineType]
FROM @warehouseDocumentLine_WZ


INSERT INTO document.WarehouseDocumentLine ([id],[warehouseDocumentHeaderId],[direction],[itemId],[warehouseId],[unitId],[quantity],[price],[value],[incomeDate],[outcomeDate],[description],                 [ordinalNumber],[version],[isDistributed],[previousIncomeWarehouseDocumentLineId],[correctedWarehouseDocumentLineId],[initialWarehouseDocumentLineId],[lineType])
SELECT                                      [id],[warehouseDocumentHeaderId],[direction],[itemId],[warehouseId],[unitId],[quantity],ISNULL([price],0),ISNULL([value],0),[incomeDate],[outcomeDate],[description],@incomeOrdinalNumber +[ordinalNumber],[version],[isDistributed],[previousIncomeWarehouseDocumentLineId],[correctedWarehouseDocumentLineId],[initialWarehouseDocumentLineId],[lineType]
FROM @warehouseDocumentLine_PZ


/*Wstawienie powiązań przychodów z rozchodami*/
INSERT INTO document.IncomeOutcomeRelation	(id, incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId, incomeDate, quantity,version)			
SELECT id, incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId, incomeDate, quantity,version 
FROM @incomeOutcomeRelation

/*Wstawienie wycen*/
INSERT INTO  document.CommercialWarehouseValuation ([id],[commercialDocumentLineId],[warehouseDocumentLineId],[quantity],[value],[price],[version])
SELECT [id],[commercialDocumentLineId], [warehouseDocumentLineId],[quantity],ABS([value]) * SIGN([quantity]),[price],[version] 
FROM @commercialWarehouseValuation

/*Wstawienie powiązań ilościowych z korektą faktury zakupowej*/
INSERT INTO commercialWarehouseRelation ([id] ,[commercialDocumentLineId] ,[warehouseDocumentLineId] ,[quantity] ,[value] ,[isValuated] ,[isOrderRelation] ,[isCommercialRelation], [isServiceRelation],[version] )
SELECT [id] ,[commercialDocumentLineId] ,[warehouseDocumentLineId] ,[quantity] ,[value] ,[isValuated] ,[isOrderRelation] ,[isCommercialRelation], 0 ,[version] 
FROM  @commercialWarehouseRelation
  
	INSERT INTO document.WarehouseDocumentValuation ([id],[incomeWarehouseDocumentLineId],[outcomeWarehouseDocumentLineId],[valuationId],[quantity],[incomePrice],[incomeValue],[version])
	SELECT	newid(), x.incomeWarehouseDocumentLineId, x.outcomeWarehouseDocumentLineId, x.id, CASE WHEN x.usedQuantity < x.quantity THEN x.usedQuantity ELSE x.quantity END,
			x.incomePrice,((CASE WHEN x.usedQuantity < x.quantity THEN x.usedQuantity ELSE x.quantity END ) * x.incomePrice) incomeValue, NEWID()
    FROM  
		(	SELECT 
				ir.incomeWarehouseDocumentLineId, ir.outcomeWarehouseDocumentLineId, cv.id, ir.quantity,
				abs(cv.quantity - ISNULL( (SELECT SUM( quantity ) FROM document.WarehouseDocumentValuation wv WHERE wv.valuationId = cv.id ), 0 ) ) usedQuantity, 
				cv.price incomePrice,ir.incomeDate,	l.ordinalNumber,l.isDistributed
			FROM document.IncomeOutcomeRelation ir
				JOIN document.CommercialWarehouseValuation cv ON ir.incomeWarehouseDocumentLineId = cv.warehouseDocumentLineId
				JOIN document.WarehouseDocumentLine l ON ir.outcomeWarehouseDocumentLineId = l.id
			WHERE l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId 
				AND (l.direction * l.quantity) < 0 
		) x 
			ORDER BY incomeDate, ordinalNumber

	
/*Uzupełnianie powiązań przychodowo rozchodowych. Opcja wprowadzona z możliwością korekty rozchodowanego przychodu*/  

		/*
			Storno dokumentów rozchodowych z założenia wykonywane jest na pełną ilość jaka była na tych rozchodach. 
			Może się okazać że rozchód wystornowany, po korekcie wogole nie będzie wyceniony z PZK, więc trzeba go dopiąć do innych dostępnych przychodów
		*/
		DECLARE @container varchar(50)
		SELECT @container = textValue 
		FROM configuration.Configuration 
		WHERE [key] like ''warhouse.correctionSlot''
	

		DECLARE @wzkm_id uniqueidentifier, @licz int
		set @licz = 0

				/*Warunek pętli na niewyceniony rozchód*/	
				WHILE EXISTS (  SELECT l.id 
								FROM @warehouseDocumentLine_WZ l 
									LEFT JOIN document.IncomeOutcomeRelation ir ON l.id = ir.outcomeWarehouseDocumentLineId 
								WHERE l.lineType = -3 
								GROUP BY l.id, l.quantity 
								HAVING ABS(l.quantity) > SUM(ISNULL(ir.quantity,0))
								) 
					BEGIN

						/*Pobranie lini WZK do wyceny , pierwsza z tych którym brakuje wycen*/
						SELECT TOP 1 @wzkm_id = l.id, @q = ABS(SUM(l.quantity)) - SUM(ISNULL(ir.quantity,0)), @incomeDocId = newid()
						FROM @warehouseDocumentLine_WZ l
							LEFT JOIN document.IncomeOutcomeRelation ir ON l.id = ir.outcomeWarehouseDocumentLineId  
						WHERE l.lineType = -3 
						GROUP BY l.id, l.quantity
						HAVING ABS(l.quantity) > ABS(SUM(ISNULL(ir.quantity,0)))
					
						
						/*Warunek na magazyn WMS */
						IF @container IS NULL 
							OR (@container IS NOT NULL 
									AND NOT EXISTS(	SELECT * 
													FROM @warehouseDocumentLine_PZ pz 
														JOIN warehouse.Shift s ON pz.id = s.incomeWarehouseDocumentLineId
														)
									)
							BEGIN
								/*Wstawienie powiązania IR*/
								INSERT INTO document.IncomeOutcomeRelation	(id, incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId,       incomeDate, quantity,version)			
								SELECT TOP 1					   @incomeDocId,					 income.id,						  @wzkm_id,income.incomeDate,     
										CASE WHEN @q > income.quantity THEN income.quantity ELSE @q END ,newid()
								FROM document.WarehouseDocumentLine l
									JOIN document.v_getAvailableDeliveries income ON l.itemId = income.itemId 
										AND l.warehouseId = income.warehouseId 
								WHERE l.id = @wzkm_id
								ORDER BY income.incomeDate
							END
						ELSE
							BEGIN
							
								/*Na kontenerze technicznym musi być wystarczająca ilość do pokrycia rozchodowanej już część przychodu*/
										
								/*Wstawienie powiązania IR*/
								INSERT INTO document.IncomeOutcomeRelation	(id, incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId,       incomeDate, quantity,version)				
								SELECT TOP 1	@incomeDocId,income.id,	@wzkm_id,income.incomeDate,
									   CASE WHEN @q > qty THEN qty ELSE @q END ,newid()
								FROM document.WarehouseDocumentLine l
									JOIN document.v_getAvailableDeliveries income ON l.itemId = income.itemId AND l.warehouseId = income.warehouseId 
									JOIN (
										SELECT ISNULL(s.quantity - ISNULL(x.q,0),0) qty, s.containerId, s.incomeWarehouseDocumentLineId
										FROM warehouse.Shift s  
											LEFT JOIN ( 
												SELECT SUM(sx.quantity) q , sx.sourceShiftId
												FROM warehouse.Shift sx
												WHERE sx.status >= 40
												GROUP BY sx.sourceShiftId
											) X ON s.id = X.sourceShiftId
										) con ON con.incomeWarehouseDocumentLineId = income.id
									JOIN warehouse.Container c ON con.containerId = c.id
								WHERE c.name = @container AND l.id = @wzkm_id
								ORDER BY income.incomeDate
								IF @@rowcount = 0
									BEGIN
									
											DECLARE @itemName VARCHAR(500)
											SELECT @itemName = name 
											FROM document.warehouseDocumentLine l 
												JOIN item.Item i ON l.itemId = i.id
											WHERE l.id = @wzkm_id
											
											SELECT ''Brak towaru: '' + ISNULL(@itemName,'''') + '' na kontnerze technicznym: '' + @container  + '' w ilości: '' +
											 CAST( (SELECT  @q - ISNULL( (
													SELECT qty 
													FROM document.WarehouseDocumentLine l
														JOIN document.v_getAvailableDeliveries income ON l.itemId = income.itemId AND l.warehouseId = income.warehouseId 
														JOIN (
															SELECT ISNULL(s.quantity - ISNULL(x.q,0),0) qty, s.containerId, s.incomeWarehouseDocumentLineId
															FROM warehouse.Shift s  
																LEFT JOIN ( 
																	SELECT SUM(sx.quantity) q , sx.sourceShiftId
																	FROM warehouse.Shift sx
																	WHERE sx.status >= 40
																	GROUP BY sx.sourceShiftId
																) X ON s.id = X.sourceShiftId
															) con ON con.incomeWarehouseDocumentLineId = income.id
														JOIN warehouse.Container c ON con.containerId = c.id
													WHERE c.name = @container AND l.id = @wzkm_id
												),0)) as varchar(50))
											FOR XML PATH(''root'') ,TYPE
											
										RETURN 0;
									END
							END		
							
						/*Wstawiam do tabeli tymczasowej gdyz muszę zwrócic z procedury to co wstawiłem*/
						INSERT INTO @incomeOutcomeRelation( id,incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId,incomeDate,quantity, version)
						SELECT id,incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId,incomeDate,quantity, version 
						FROM document.IncomeOutcomeRelation 
						WHERE id = @incomeDocId
						
						/*Aktualizacja daty rozchodu dla dostaw które się skończyły*/
						/*Oznaczenie rozchodów których już nie ma*/
						UPDATE wl
						SET wl.outcomeDate = ISNULL(NULLIF(@data,''1900-01-01 00:00:00.000''),getdate())
						FROM document.WarehouseDocumentLine wl 
							JOIN document.IncomeOutcomeRelation ior ON wl.id = ior.incomeWarehouseDocumentLineId
							LEFT JOIN ( SELECT SUM(quantity) q , incomeWarehouseDocumentLineId 
										FROM document.IncomeOutcomeRelation 
										GROUP BY incomeWarehouseDocumentLineId
										) x ON wl.id = x.incomeWarehouseDocumentLineId
						WHERE (wl.direction * wl.quantity) > 0 AND ((wl.direction * wl.quantity) - x.q) = 0
							AND wl.id IN (SELECT incomeWarehouseDocumentLineId FROM @incomeOutcomeRelation)
	
						/*OPTYMALIZACJA< narazie działa dla wszystkich dostaw*/
						select @licz= @licz + 1
					END


/*To jest dziwny przypadek w którym powiązania powtarzają się pomiędzy takimi samymi dokumentami*/	
  IF @incompleteIncomePriceCorrection = 1 
	BEGIN
		SELECT @q = 0
		
		SELECT @incomeWarehouseDocumentLineId = incomeWarehouseDocumentLineId, @outcomeWarehouseDocumentLineId = outcomeWarehouseDocumentLineId , @i = count(id), @q = sum(quantity)
		FROM @incomeOutcomeRelation 
		GROUP BY incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId,incomeDate
		HAVING count(id) > 1
		

		WHILE @i > 1
			BEGIN
			
				SELECT TOP 1 @id = id
				FROM document.IncomeOutcomeRelation 
				WHERE  @incomeWarehouseDocumentLineId = incomeWarehouseDocumentLineId 
					AND @outcomeWarehouseDocumentLineId = outcomeWarehouseDocumentLineId 
		
				DELETE FROM  document.IncomeOutcomeRelation WHERE id = @id
				
				SELECT TOP 1 @id = id
				FROM @incomeOutcomeRelation 
				WHERE  @incomeWarehouseDocumentLineId = incomeWarehouseDocumentLineId 
					AND @outcomeWarehouseDocumentLineId = outcomeWarehouseDocumentLineId 
		
				DELETE FROM  @incomeOutcomeRelation WHERE id = @id
	 
			SELECT @i = @i - 1
			END
			
		UPDATE document.IncomeOutcomeRelation 
		SET quantity = @q
		WHERE  @incomeWarehouseDocumentLineId = incomeWarehouseDocumentLineId 
				AND @outcomeWarehouseDocumentLineId = outcomeWarehouseDocumentLineId 
		UPDATE @incomeOutcomeRelation 
		SET quantity = @q
		WHERE  @incomeWarehouseDocumentLineId = incomeWarehouseDocumentLineId 
				AND @outcomeWarehouseDocumentLineId = outcomeWarehouseDocumentLineId 		
	END
	
	

	
/*W przypadku zwrotu zapasu magazynowego, należy aktualizowac datę rozchodu pozostałych dostaw. 
Opcja wprowadzona na chwilę przed zakończeniem projektu fractus*/
	UPDATE wl
	SET wl.outcomeDate = ISNULL(NULLIF(@data,''1900-01-01 00:00:00.000''),getdate())
	FROM document.WarehouseDocumentLine wl 
		JOIN @warehouseDocumentLine_WZ pz ON pz.id = wl.id
		LEFT JOIN ( SELECT SUM(quantity) q , incomeWarehouseDocumentLineId 
					FROM document.IncomeOutcomeRelation 
					GROUP BY incomeWarehouseDocumentLineId
					) x ON pz.id = x.incomeWarehouseDocumentLineId
	WHERE (pz.direction * pz.quantity) > 0 AND ((pz.direction * pz.quantity) - x.q) = 0
		
	UPDATE wl
	SET wl.outcomeDate = ISNULL(NULLIF(@data,''1900-01-01 00:00:00.000''),getdate())
	FROM document.WarehouseDocumentLine wl 
		JOIN @warehouseDocumentLine_PZ pz ON pz.id = wl.id
		LEFT JOIN ( SELECT SUM(quantity) q , incomeWarehouseDocumentLineId 
					FROM document.IncomeOutcomeRelation 
					GROUP BY incomeWarehouseDocumentLineId
					) x ON pz.id = x.incomeWarehouseDocumentLineId
	WHERE (pz.direction * pz.quantity) > 0 AND ((pz.direction * pz.quantity) - x.q) <= 0
		
	EXEC document.p_updateWarehouseDocumentCost @warehouseDocumentHeaderId , 1
  		
  		
		
		
----------- Test stanu magazynowego	-----------	
------------------------------------------------------------------------------------------------------------------------------------------
	SELECT TOP 1 @itemId = itemId,@warehouseId = warehouseId  FROM @warehouseDocumentLine_PZ
  
  IF EXISTS(
			  SELECT  *  
			  FROM document.WarehouseDocumentLine l 
			  WHERE @itemId = itemId AND @warehouseId = warehouseId 
			  GROUP BY  itemId, warehouseId
			  HAVING SUM(quantity * direction) < 0
			  
			  )
	BEGIN
		SELECT TOP 1 @errorMsg = @errorMsg + ''@'' + CAST(COUNT(i.name) AS varchar(50))
		FROM document.WarehouseDocumentLine l 
			JOIN item.Item i ON l.itemId = i.id
		WHERE @itemId = itemId AND @warehouseId =warehouseId 
		GROUP BY  itemId, warehouseId
		HAVING SUM(quantity * direction) < 0
		
		RAISERROR ( @errorMsg, 16, 1 )
						
	END	

------------------------------------------------------------------------------------------------------------------------------------------




IF @outcomeOrdinalNumber IS NOT NULL
	SELECT @outcomeOrdinalNumber = ISNULL(MAX(ordinalNumber),0) FROM @warehouseDocumentLine_WZ
SELECT @incomeOrdinalNumber = MAX(ordinalNumber) FROM @warehouseDocumentLine_PZ


SELECT @outcomeOrdinalNumber outcomeOrdinalNumber, @incomeOrdinalNumber incomeOrdinalNumber,
(SELECT ( SELECT id FROM @commercialWarehouseRelation FOR XML PATH(''entry''),TYPE ) FOR XML PATH(''commercialWarehouseRelation''),TYPE ), -- dodać po obsłudze korekty wystawionej z FZK
(SELECT ( SELECT id FROM @commercialWarehouseValuation FOR XML PATH(''entry''),TYPE ) FOR XML PATH(''commercialWarehouseValuation''), TYPE ),
(SELECT ( SELECT id FROM @incomeOutcomeRelation FOR XML PATH(''entry''),TYPE ) FOR XML PATH(''incomeOutcomeRelation''), TYPE )
FOR XML PATH(''root'') ,TYPE

END
' 
END
GO

/*
name=[document].[p_createOutcomeQuantityCorrection]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
lD4samBnxh5A3nISdsgPJQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_createOutcomeQuantityCorrection]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_createOutcomeQuantityCorrection]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_createOutcomeQuantityCorrection]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_createOutcomeQuantityCorrection]
@xmlVar XML
AS
BEGIN
--return 0;
DECLARE 
	@ordinalNumber INT,
	@quantity NUMERIC(18,6),
	@quantity_tmp NUMERIC(18,6),
	@id UNIQUEIDENTIFIER,
	@warehouseDocumentHeaderId UNIQUEIDENTIFIER,
	@outcomeId UNIQUEIDENTIFIER,
	@localTransactionId UNIQUEIDENTIFIER,
	@deferredTransactionId UNIQUEIDENTIFIER,
	@databaseId UNIQUEIDENTIFIER,
	@commercialDocumentLineId UNIQUEIDENTIFIER,
	@commercialDocumentHeaderId UNIQUEIDENTIFIER,
	@wzCout INT



/*Tabela z pozycjami przydowymi korekty zwracającej wydanie*/
DECLARE @warehouseDocumentLine TABLE (ordinalNumber int identity(1,1), id  uniqueidentifier, warehouseDocumentHeaderId uniqueidentifier,direction int,itemId uniqueidentifier,warehouseId uniqueidentifier,unitId uniqueidentifier,quantity numeric(18,6),price numeric(18,2),[value] numeric(18,2),incomeDate datetime,outcomeDate datetime,[description] nvarchar(500),version uniqueidentifier,isDistributed bit,previousIncomeWarehouseDocumentLineId uniqueidentifier,correctedWarehouseDocumentLineId uniqueidentifier,initialWarehouseDocumentLineId uniqueidentifier,lineType int)

/*Tabela z pozycjami powiązania IncomeOutcomeRelation dla pozycji korygującej rozchody*/
DECLARE @incomeOutcomeRelation TABLE (id uniqueidentifier,insertedId uniqueidentifier, incomeWarehouseDocumentLineId uniqueidentifier, outcomeWarehouseDocumentLineId uniqueidentifier, incomeDate datetime, quantity numeric(18,6),version uniqueidentifier)			

/*Tabela z ślepymi wycenami pozycji stornującej rozchód*/
DECLARE @commercialWarehouseValuation TABLE ([id] uniqueidentifier,[commercialDocumentLineId] uniqueidentifier,[warehouseDocumentLineId] uniqueidentifier,[quantity] numeric(18,6),[value] numeric(18,2),[price] numeric(18,2),[version] uniqueidentifier)

/*Tabela z powiązaniami dokumentów handlowych z magazynowymi*/
DECLARE @commercialWarehouseRelation TABLE ([id] uniqueidentifier,[commercialDocumentLineId] uniqueidentifier,[warehouseDocumentLineId] uniqueidentifier,[quantity] numeric(18,6),[value] numeric(18,2),[isValuated] bit,[isOrderRelation] bit,[isCommercialRelation] bit,[version] uniqueidentifier)

/*Pobranie danych o operacji*/
SELECT 
	@ordinalNumber = b.query(''ordinalNumber'').value(''.'',''int''),
	@id = b.query(''id'').value(''.'' ,''char(36)''), 
	@commercialDocumentLineId = NULLIF(b.query(''commercialDocumentLineId'').value(''.'' ,''char(36)''),''''), 
	@warehouseDocumentHeaderId = b.query(''warehouseDocumentHeaderId'').value(''.'' ,''char(36)''),
	@localTransactionId = b.query(''localTransactionId'').value(''.'' ,''char(36)''), 
	@deferredTransactionId = b.query(''deferredTransactionId'').value(''.'' ,''char(36)''),
	@databaseId = b.query(''databaseId'').value(''.'' ,''char(36)''), 
	@quantity = b.query(''quantity'').value(''.'' ,''numeric(18,6)'')
FROM @xmlVar.nodes(''root'') a ( b ) 


/*Wstawienie pozycji storna
czyli używam relacji ilościowej z przychodem korygowanej WZki, do stworzenia pozycji stornującej, powstanie tyle pozycji z ilu przychodów zdejmował WZ
16-03-2011 - zmiana ze sredniej ceny dla pozycji na cenę dokładnie z powiązań, mam nadzieję że nie powielą się linie stornujące ze względu na rozbierzność powiązania IR z Valuacjami
*/

INSERT INTO @warehouseDocumentLine     ([id],[warehouseDocumentHeaderId],[direction],[itemId],[warehouseId],[unitId],      [quantity],							  		   [price],					 [value],[outcomeDate],[description],[version],[isDistributed],[previousIncomeWarehouseDocumentLineId],[correctedWarehouseDocumentLineId],[initialWarehouseDocumentLineId]             ,[lineType],[incomeDate] )
SELECT								 NEWID(), @warehouseDocumentHeaderId,         -1,l.itemId,l.warehouseId,l.unitId,ir.quantity * -1,ISNULL(valuation.value/valuation.quantity,0),ISNULL(valuation.value,0),         NULL,l.description,  NEWID(),l.isDistributed,       ir.incomeWarehouseDocumentLineId,                               @id,ISNULL(l.initialWarehouseDocumentLineId, @id),         2,ir.incomeDate
FROM document.WarehouseDocumentLine l 
	JOIN document.IncomeOutcomeRelation ir ON ir.outcomeWarehouseDocumentLineId = l.id
	LEFT JOIN (		
				SELECT SUM(quantity) quantity,SUM(incomeValue) [value], incomeWarehouseDocumentLineId  
				FROM document.WarehouseDocumentValuation wdv 
				WHERE wdv.outcomeWarehouseDocumentLineId = @id
				GROUP BY incomeWarehouseDocumentLineId 
				) valuation ON ir.incomeWarehouseDocumentLineId = valuation.incomeWarehouseDocumentLineId
WHERE l.id = @id



/*
Budowa ślepych wycen dla pozycji przychodowej korekty wydania
linie pochodzą z właśnie dodanych linii, pozycje wycen powiązane są po l.previousIncomeWarehouseDocumentLineId
l.id - id nowego przychodu do którego dopinamy wycenę
@commercialDocumentLineId - w przypadku gdy podane jest id FSK, dopinam wyceny storna doń :)
*/
INSERT INTO @commercialWarehouseValuation ([id],commercialDocumentLineId,[warehouseDocumentLineId],[quantity],[value],[price],[version])
SELECT NEWID(),@commercialDocumentLineId,l.id,ABS(wdv.quantity) * -1 ,ABS(wdv.incomeValue) * -1,wdv.incomePrice,NEWID()
FROM @warehouseDocumentLine l
	JOIN document.WarehouseDocumentValuation wdv on l.previousIncomeWarehouseDocumentLineId = wdv.incomeWarehouseDocumentLineId  AND wdv.outcomeWarehouseDocumentLineId  = @id
WHERE lineType = 2


/*Warunek na korektę części ilości z dokumentu*/
IF @quantity <> 0 
	BEGIN
		/*Nowa pozycja */
		SELECT @outcomeId = NEWID(),@quantity_tmp = @quantity, @wzCout = 1


		/*Zakładam pozycję korygującą storno dokumentu rozchodowego, tabela tymczasowa - (lineType -2)*/	
		INSERT INTO @warehouseDocumentLine     ([id],[warehouseDocumentHeaderId],[direction],[itemId],[warehouseId],[unitId], [quantity],[price],[value],[outcomeDate],[description],[version],[isDistributed],[previousIncomeWarehouseDocumentLineId],[correctedWarehouseDocumentLineId],[initialWarehouseDocumentLineId]             ,[lineType],[incomeDate] )
		SELECT	TOP 1					  @outcomeId, @warehouseDocumentHeaderId,         -1,l.itemId,l.warehouseId,l.unitId, @quantity ,   0.00,   0.00,         NULL,l.description,  NEWID(),l.isDistributed,                                   NULL,                               @id,ISNULL(l.initialWarehouseDocumentLineId, @id),         -2,ir.incomeDate
		FROM document.WarehouseDocumentLine l 
			JOIN document.IncomeOutcomeRelation ir ON ir.outcomeWarehouseDocumentLineId = l.id
		WHERE l.id = @id
		ORDER BY l.incomeDate


		WHILE @quantity_tmp > 0 AND @wzCout > 0
			BEGIN
	
				/*Jeśli rozchód jest niewyceniony to wstawiamy jedno powiązanie na pełną ilość
					16-03-2011 - poprawka dla korekty rozchodu wycenianego z wielu przychodów, suma valuacji była grupowana dla pierwszej pozycji wyceniającej czyli mogło brakować wycen co było obsługiwane jak brak wycen
				*/
											
				IF EXISTS (
							SELECT  SUM(ABS(ISNULL(cwv.quantity,0))) test, @quantity_tmp 
							FROM @warehouseDocumentLine l 
								JOIN @commercialWarehouseValuation cwv ON cwv.warehouseDocumentLineId = l.id
							HAVING SUM(ABS(ISNULL(cwv.quantity,0))) >= @quantity_tmp
							)
					OR EXISTS (
							SELECT  l.warehouseDocumentHeaderId
							FROM @warehouseDocumentLine l 
							WHERE l.direction * l.quantity > 0
							GROUP BY l.warehouseDocumentHeaderId
							HAVING COUNT(l.id) > 1
							)
						BEGIN 
						
							IF EXISTS (	
								SELECT l.id
								FROM @warehouseDocumentLine l
									JOIN @commercialWarehouseValuation cwv ON cwv.warehouseDocumentLineId = l.id
								WHERE cwv.id  IS NOT NULL 
									AND cwv.id NOT IN ( SELECT insertedId FROM @incomeOutcomeRelation )	
								)
									BEGIN
									
										/*Wypełnienie relacji przychodrozchod dla WZK korygującego ilosc, wiazany jest z pozycją stornującą dokument pierwotny*/
										INSERT INTO @incomeOutcomeRelation (id, incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId , incomeDate , quantity ,version, insertedId )			
										SELECT TOP 1 NEWID(), l.id, @outcomeId,  l.incomeDate, ABS( CASE WHEN @quantity_tmp <= ABS(ISNULL(cwv.quantity,0)) THEN @quantity_tmp ELSE ABS(cwv.quantity) END ), NEWID(),cwv.id 
										FROM @warehouseDocumentLine l
											/*Zmiana dotycząca błędu drugiej korekty WZ, brakowało powiązań IO*/
											JOIN @commercialWarehouseValuation cwv ON cwv.warehouseDocumentLineId = l.id
										WHERE cwv.id NOT IN ( SELECT insertedId FROM @incomeOutcomeRelation )	
										ORDER BY l.incomeDate
									END
								ELSE	
									BEGIN 
										/*Wypełnienie relacji przychodrozchod dla WZK korygującego ilosc, wiazany jest z pozycją stornującą dokument pierwotny
										 -	w tej wersji nie ma powiązań wyceniających dokument przychodowy*/
										INSERT INTO @incomeOutcomeRelation (id, incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId , incomeDate , quantity ,version, insertedId )			
										SELECT TOP 1 NEWID(), l.id, @outcomeId,  l.incomeDate, ABS( CASE WHEN @quantity_tmp <= ABS(ISNULL(l.quantity,0)) THEN @quantity_tmp ELSE ABS(l.quantity) END ), NEWID(),l.id 
										FROM @warehouseDocumentLine l
										WHERE l.id NOT IN ( SELECT incomeWarehouseDocumentLineId FROM @incomeOutcomeRelation )	AND l.direction * l.quantity > 0
										ORDER BY l.incomeDate
									
									END
						END
				ELSE 
						BEGIN
							INSERT INTO @incomeOutcomeRelation (id, incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId , incomeDate , quantity ,version, insertedId )			
							SELECT TOP 1 NEWID(), l.id, @outcomeId,  l.incomeDate, @quantity_tmp, NEWID(),NULL 
							FROM @warehouseDocumentLine l
						END		
				
				SELECT @wzCout = @@rowcount
				SELECT @quantity_tmp = @quantity - SUM(quantity) FROM @incomeOutcomeRelation 

			END
	END


--SELECT * FROM @incomeOutcomeRelation

/*Wstawienie pozycji dokumentu korekty - zostawiłem na koniec dla jednego inserta*/
INSERT INTO document.WarehouseDocumentLine ([id],[warehouseDocumentHeaderId],[direction],[itemId],[warehouseId],[unitId],[quantity],[price],                     [value],[incomeDate],[outcomeDate],[description],                 [ordinalNumber],[version],[isDistributed],[previousIncomeWarehouseDocumentLineId],[correctedWarehouseDocumentLineId],[initialWarehouseDocumentLineId],[lineType])
SELECT                                      [id],[warehouseDocumentHeaderId],[direction],[itemId],[warehouseId],[unitId],[quantity],[price],(ABS([value]) * sign(quantity)),[incomeDate],[outcomeDate],[description],@ordinalNumber +[ordinalNumber],[version],[isDistributed],[previousIncomeWarehouseDocumentLineId],[correctedWarehouseDocumentLineId],[initialWarehouseDocumentLineId],[lineType]
FROM @warehouseDocumentLine

/*Wstawienie relacji FSK z WZK*/
IF @commercialDocumentLineId IS NOT NULL
	BEGIN


	INSERT INTO @commercialWarehouseRelation ([id],[commercialDocumentLineId],[warehouseDocumentLineId],[quantity],[value],[isValuated],[isOrderRelation],[isCommercialRelation],[version])
	SELECT NEWID(), @commercialDocumentLineId, id, quantity , [value] * sign(quantity), 1,0,1,newid()
	FROM @warehouseDocumentLine

	INSERT INTO document.CommercialWarehouseRelation ([id],[commercialDocumentLineId],[warehouseDocumentLineId],[quantity],[value],[isValuated],[isOrderRelation],[isCommercialRelation],[isServiceRelation],[version])
	SELECT [id],[commercialDocumentLineId],[warehouseDocumentLineId],[quantity],[value],[isValuated],[isOrderRelation],[isCommercialRelation],0,[version]
	FROM @commercialWarehouseRelation



-- Po czasie należy wywołać EXEC document.xp_valuateInvoice @commercialDocumentHeaderId,@localTransactionId,@deferredTransactionId,@databaseId
--	INSERT INTO @commercialWarehouseValuation ([id],commercialDocumentLineId,[warehouseDocumentLineId],[quantity],[value],[price],[version])
--	SELECT newid(),  @commercialDocumentLineId, l.id, l.quantity,l.value, l.price, newid()
--	FROM @warehouseDocumentLine l 
--		JOIN  @commercialWarehouseRelation r ON l.id = r.warehouseDocumentLineId
--		JOIN 
--	WHERE lineType = -2	
	END

/*Wstawienie wycen*/
INSERT INTO  document.CommercialWarehouseValuation ([id],[commercialDocumentLineId],[warehouseDocumentLineId],[quantity],[value],[price],[version])
SELECT [id],[commercialDocumentLineId],[warehouseDocumentLineId],[quantity],ABS([value]) * SIGN([quantity]),[price],[version] 
FROM @commercialWarehouseValuation

/*Wstawienie powiązań przychodów z rozchodami*/
INSERT INTO document.IncomeOutcomeRelation	(id, incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId, incomeDate, quantity,version)			
SELECT id, incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId, incomeDate, quantity,version 
FROM @incomeOutcomeRelation

SELECT @commercialDocumentHeaderId = commercialDocumentHeaderId FROM document.CommercialDocumentLine WHERE id = @commercialDocumentLineId

/*To powinno być odpalane po całym dokumencie*/
-- 2009-05-27, przeniesione do jądra 
--EXEC document.xp_valuateInvoice @commercialDocumentHeaderId,@localTransactionId,@deferredTransactionId,@databaseId
--EXEC document.p_updateWarehouseDocumentCost @warehouseDocumentHeaderId


SELECT MAX(ordinalNumber) as ordinalNumber,
(SELECT ( SELECT id FROM @commercialWarehouseRelation FOR XML PATH(''entry''),TYPE ) FOR XML PATH(''commercialWarehouseRelation''),TYPE ),
(SELECT ( SELECT id FROM @commercialWarehouseValuation FOR XML PATH(''entry''),TYPE ) FOR XML PATH(''commercialWarehouseValuation''), TYPE ),
(SELECT ( SELECT id FROM @incomeOutcomeRelation FOR XML PATH(''entry''),TYPE ) FOR XML PATH(''incomeOutcomeRelation''), TYPE )
FROM @warehouseDocumentLine FOR XML PATH(''root'') ,TYPE


END
' 
END
GO

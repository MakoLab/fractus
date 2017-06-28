/*
name=[document].[p_valuateIncome]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4fgWXIb7z7B43bSCdf619g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_valuateIncome]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_valuateIncome]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_valuateIncome]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_valuateIncome] 
@warehouseDocumentHeaderId UNIQUEIDENTIFIER,
@localTransactionId UNIQUEIDENTIFIER,
@deferredTransactionId UNIQUEIDENTIFIER,
@databaseId UNIQUEIDENTIFIER,
@package BIT = NULL

AS 
    BEGIN
		
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
				@rowcount INT,
				@commercialDocumentHeaderId UNIQUEIDENTIFIER,
				@i INT,
				@xml XML,
				@oldVersion uniqueidentifier,
				@oppositeWarehouseDocumentFieldId uniqueidentifier,
				@oppositeDocumentDocumentFieldId uniqueidentifier,
				@oppositeDocumentId uniqueidentifier,
				@oppositeDocumentVersionId uniqueidentifier

		DECLARE @tmp_WarehouseDoc TABLE (id int identity(1,1), warehouseDocumentHeaderId uniqueidentifier, stat int, version uniqueidentifier)
		DECLARE @tmp_CommercialDoc TABLE (id int identity(1,1), commercialDocumentHeaderId uniqueidentifier, stat int)

		/*Pobranie fielda od magazynu przeciwnego*/
		SELECT @oppositeWarehouseDocumentFieldId = f.id 
		FROM dictionary.DocumentField f
		WHERE name = ''ShiftDocumentAttribute_OppositeWarehouseId''
		
		/*Pobranie fielda od dokumentu przeciwnego*/
		SELECT @oppositeDocumentDocumentFieldId = f.id 
		FROM dictionary.DocumentField f
		WHERE name = ''ShiftDocumentAttribute_OppositeDocumentId''
		
		
		/*Lista dokumentów rozchodujących przychód*/
		INSERT INTO @tmp_WarehouseDoc ( warehouseDocumentHeaderId, stat, version)
		SELECT DISTINCT l_out.warehouseDocumentHeaderId , [status], h.version
		FROM document.WarehouseDocumentLine l_in
			JOIN document.IncomeOutcomeRelation i ON l_in.id = incomeWarehouseDocumentLineId
			JOIN document.WarehouseDocumentLine l_out ON i.outcomeWarehouseDocumentLineId = l_out.id
			JOIN document.WarehouseDocumentHeader h ON l_out.warehouseDocumentHeaderId  = h.id
		WHERE l_in.warehouseDocumentHeaderId = @warehouseDocumentHeaderId
		
		SELECT @rowcount = @@rowcount, @i = 1


	/*Sprawdzenie czy aktualizowane dokumenty są zaksięgowane*/       
	IF EXISTS( SELECT id FROM @tmp_WarehouseDoc WHERE stat >= 60 ) 
		AND EXISTS(SELECT session_id FROM sys.dm_exec_sessions WHERE session_id = @@SPID AND program_name <> ''FractusCommunication'')
		BEGIN
			SELECT (
				SELECT ( 
					SELECT fullNumber number 
					FROM document.WarehouseDocumentHeader h 
						JOIN @tmp_WarehouseDoc d ON h.id = d.warehouseDocumentHeaderId
					WHERE h.status >= 60
					FOR XML PATH(''''),TYPE
				) FOR XML PATH(''bookedOutcome''),TYPE
			) FOR XML PATH(''root''),TYPE
			RETURN 0;
		END

		DECLARE @valuationsChanged BIT

		WHILE @i <= @rowcount
			BEGIN
				SELECT @warehouseDocumentHeaderId = warehouseDocumentHeaderId , @oldVersion = version
				FROM @tmp_WarehouseDoc 
				WHERE id = @i
				
				SET @valuationsChanged = 1

				EXEC document.xp_valuateOutcome @warehouseDocumentHeaderId, @localTransactionId, @deferredTransactionId, @databaseId, @valuationsChanged output
				IF @valuationsChanged = 1 BEGIN EXEC document.p_updateWarehouseDocumentCost @warehouseDocumentHeaderId END


				
				/*Test na MMkę lokalną*/
				/*W skrócie MMki lokalne mają mieć przenoszone wyceny automatycznie bez konieczności udziału komunikacji
				  -	rozpoznawanie lokalnej MMki po kolumnie branch
				  - powiązania zapisane w atrybutach */
				IF EXISTS(	SELECT  w2.id
							FROM document.WarehouseDocumentHeader h 
								JOIN dictionary.Warehouse w1 ON h.warehouseId = w1.id
								JOIN document.WarehouseDocumentLine l ON h.id = l.warehouseDocumentHeaderId
								JOIN document.DocumentAttrValue av ON av.documentFieldId = @oppositeWarehouseDocumentFieldId AND h.id = av.warehouseDocumentHeaderId
								JOIN dictionary.Warehouse w2 ON av.textValue = w2.id
							WHERE l.isDistributed = 1 
								AND l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId 
								AND w1.branchId = w2.branchId
						)
						BEGIN
							SET @valuationsChanged = 1
							/*Pobranie id dokumentu przeciwnego*/
							SELECT @oppositeDocumentId = h.id,@oppositeDocumentVersionId = h.version 
							FROM document.DocumentAttrValue av 
								JOIN document.WarehouseDocumentHeader h ON h.id = CAST(av.textValue as UNIQUEIDENTIFIER)
							WHERE av.warehouseDocumentHeaderId = @warehouseDocumentHeaderId AND av.documentFieldId = @oppositeDocumentDocumentFieldId
							
							/*Kasowanie wycen przychodowej części MM */
							DELETE FROM [document].[CommercialWarehouseValuation]
							WHERE warehouseDocumentLineId IN (	SELECT l.id
																FROM document.WarehouseDocumentLine l 
																WHERE l.warehouseDocumentHeaderId = @oppositeDocumentId
															  )
							
							/*Wstawienie wycen do dokumentu MM przychodowego*/
							INSERT  INTO [document].[CommercialWarehouseValuation] (id,commercialDocumentLineId,warehouseDocumentLineId,quantity,[value],price,version)
							SELECT newid(), NULL, id, quantity , incomeValue ,incomePrice , newid()
							FROM (
								SELECT lopos.id, v.quantity, v.incomeValue, v.incomePrice
								FROM document.WarehouseDocumentLine l
									JOIN document.WarehouseDocumentLine lopos ON l.ordinalNumber = lopos.ordinalNumber AND lopos.warehouseDocumentHeaderId = @oppositeDocumentId
									JOIN document.WarehouseDocumentValuation v ON l.id = v.outcomeWarehouseDocumentLineId
								WHERE l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId
								GROUP BY lopos.id, v.quantity, v.incomeValue, v.incomePrice
								) x 							
							/*Aktualizacja części przychodowej MM */
							UPDATE document.WarehouseDocumentLine
							SET [value] = ABS(ISNULL((	SELECT SUM( ISNULL(wv.price * wv.quantity,0) ) incomeValue 
											FROM document.CommercialWarehouseValuation wv 
											WHERE wl.id = wv.warehouseDocumentLineId ),0)) * SIGN( wl.quantity ),
								[version] = newid()
							FROM document.WarehouseDocumentLine wl
							WHERE warehouseDocumentHeaderId = @oppositeDocumentId
								AND (quantity * direction) > 0 
								
							/*Aktualizacja ceny*/
							UPDATE document.WarehouseDocumentLine
							SET price = ISNULL(ABS( ROUND([value]/quantity,2) ),0)
							WHERE warehouseDocumentHeaderId = @oppositeDocumentId
							
							/*Aktualizacja nagłówka części przychdowej*/
							UPDATE document.WarehouseDocumentHeader
							SET [value] = ISNULL((	SELECT SUM( ABS(ISNULL(value,0)) * SIGN(quantity) )
											FROM document.WarehouseDocumentLine 
											WHERE warehouseDocumentHeaderId = @oppositeDocumentId ),0),
								version = newid()
							WHERE id = @oppositeDocumentId	
							 
							SELECT @xml = CAST(''<root businessObjectId="'' + CAST(@oppositeDocumentId AS CHAR(36)) + ''" databaseId="'' + CAST(@databaseId AS CHAR(36)) + ''" localTransactionId="''  + CAST(@localTransactionId AS CHAR(36)) + ''" deferredTransactionId="'' + CAST(@deferredTransactionId AS CHAR(36)) + ''" previousVersion="'' + CAST(@oppositeDocumentVersionId AS CHAR(36)) + ''"  />'' AS XML)
							EXEC communication.p_createWarehouseDocumentPackage @xml
							 
							/*Coś jakby rekurencja, czyli wycena przeciwnej strony*/
							EXEC [document].[p_valuateIncome] @oppositeDocumentId ,@localTransactionId ,@deferredTransactionId ,@databaseId ,@package
						END

				
				IF @package IS NOT NULL AND @valuationsChanged = 1
					BEGIN
						SELECT @xml = CAST(''<root businessObjectId="'' + CAST(@warehouseDocumentHeaderId AS CHAR(36)) + ''" databaseId="'' + CAST(@databaseId AS CHAR(36)) + ''" localTransactionId="''  + CAST(@localTransactionId AS CHAR(36)) + ''" deferredTransactionId="'' + CAST(@deferredTransactionId AS CHAR(36)) + ''" previousVersion="'' + CAST(@oldVersion AS CHAR(36)) + ''"  />'' AS XML)
						EXEC communication.p_createWarehouseDocumentPackage @xml
					END

				SELECT @i = @i + 1
			END


		/*Lista powiązanych dokumentów handlowych*/
		INSERT INTO @tmp_CommercialDoc (commercialDocumentHeaderId, stat)
		SELECT DISTINCT cl.commercialDocumentHeaderId, h.status
		FROM @tmp_WarehouseDoc l_out
			JOIN document.WarehouseDocumentLine l ON  l_out.warehouseDocumentHeaderId = l.warehouseDocumentHeaderId
			JOIN document.CommercialWarehouseRelation ir ON l.id = ir.warehouseDocumentLineId	AND ir.isCommercialRelation = 1
			JOIN document.CommercialDocumentLine cl ON ir.commercialDocumentLineId = cl.id
			JOIN document.CommercialDocumentHeader h ON cl.commercialDocumentHeaderId = h.id

		SELECT @rowcount = @@rowcount, @i = 1

	/*Sprawdzenie czy aktualizowane dokumenty są zaksięgowane*/       
	IF EXISTS( SELECT id FROM @tmp_CommercialDoc WHERE stat >= 60 )
		AND EXISTS(SELECT session_id FROM sys.dm_exec_sessions WHERE session_id = @@SPID AND program_name <> ''FractusCommunication'')
		BEGIN
			SELECT (
				SELECT ( 
					SELECT fullNumber number 
					FROM document.CommercialDocumentHeader h 
						JOIN @tmp_CommercialDoc d ON h.id = d.commercialDocumentHeaderId
					WHERE h.status >= 60
					FOR XML PATH(''''),TYPE
				) FOR XML PATH(''bookedOutcome''),TYPE
			) FOR XML PATH(''root''),TYPE
			RETURN 0;
		END

		WHILE @i <= @rowcount
			BEGIN
				SELECT @commercialDocumentHeaderId = commercialDocumentHeaderId 
				FROM @tmp_CommercialDoc 
				WHERE id = @i

						/*Przeniesione do xp_valuateInvoice*/
						--				SELECT @xml = (
						--						SELECT @localTransactionId AS ''@localTransactionId'', @deferredTransactionId AS ''@deferredTransactionId'', @databaseId AS ''@databaseId'', (
						--								SELECT ''delete'' AS ''@action'', v.id AS ''@id'', v.version AS ''@version'' 
						--								FROM document.WarehouseDocumentValuation v
						--								WHERE v.outcomeWarehouseDocumentLineId IN 
						--								(	SELECT id
						--									FROM document.WarehouseDocumentLine 
						--									WHERE warehouseDocumentHeaderId = @warehouseDocumentHeaderId
						--								)
						--								FOR XML PATH(''entry''), TYPE
						--						) FOR XML PATH(''root''),TYPE )
						--				
						--				IF @package IS NOT NULL
						--					BEGIN
						--
						--						IF (SELECT x.query(''<e>{ count(entry) } </e>'').value(''e[1]'', ''int'') FROM @xml.nodes(''root'') AS a ( x ) ) > 0
						--						EXEC [communication].[p_createCommercialWarehouseValuationPackage] @xml
						--
						--					END
					
				EXEC document.xp_valuateInvoice @commercialDocumentHeaderId, @localTransactionId, @deferredTransactionId, @databaseId			

				SELECT @i = @i + 1
			END


		/*Obsługa błedów i wyjatków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:CommercialDocumentLine; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END

		SELECT CAST( ''<root></root>'' AS XML ) XML       
    END
' 
END
GO

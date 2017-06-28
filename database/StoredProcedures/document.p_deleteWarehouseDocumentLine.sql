/*
name=[document].[p_deleteWarehouseDocumentLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
QXKdnu8Aj6uwEraCIoRF4g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteWarehouseDocumentLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_deleteWarehouseDocumentLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteWarehouseDocumentLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_deleteWarehouseDocumentLine]
@xmlVar XML
AS
	DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
		    @idoc int

    DECLARE @tmp TABLE (id uniqueidentifier)
	DECLARE @tmp_shift TABLE (id uniqueidentifier, shiftTransactionId uniqueidentifier)
	
 	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
	
	INSERT INTO @tmp
	SELECT id
	FROM OPENXML(@idoc, ''/root/warehouseDocumentLine/entry'')
	WITH(		id char(36) ''id''		)
		
	SET @rowcount = @@ROWCOUNT	
	EXEC sp_xml_removedocument @idoc
	
	IF @rowcount = 0 OR @@error <> 0
		BEGIN
		    SET @errorMsg = ''Błąd odczytu danych XML; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
		END
		
	/*Aktualizacja informacji o zejściach PZ*/    
	UPDATE [document].WarehouseDocumentLine
	SET outcomeDate = NULL
	WHERE outcomeDate IS NOT NULL 
		AND id IN (	SELECT incomeWarehouseDocumentLineId 
					FROM [document].IncomeOutcomeRelation 
					WHERE outcomeWarehouseDocumentLineId IN (
						SELECT  id
						FROM    @tmp 
															)
					)

	/*Kasowanie danych o powiązaniach pozycji dokumentu magazynowego*/
    DELETE  FROM [document].IncomeOutcomeRelation
    WHERE   outcomeWarehouseDocumentLineId IN (
            SELECT  id
            FROM    @tmp
	/*To powiązanie może wystąpić jako "ślepa wycena"*/										 )
	DELETE  FROM document.CommercialWarehouseValuation
	FROM @tmp t WHERE t.id = warehouseDocumentLineId 
	
    /*Kasowanie danych o wycenie pozycji dokumentu magazynowego*/
    DELETE  FROM [document].WarehouseDocumentValuation 
    FROM  @tmp t WHERE t.id IN ( incomeWarehouseDocumentLineId,outcomeWarehouseDocumentLineId ) 
 
	/*Obsługa kasowania Shiftów*/
		/*Pamiętamy co będziemy kasować*/
		INSERT INTO @tmp_shift (id, shiftTransactionId)
		SELECT DISTINCT s.id, s.shiftTransactionId
		FROM  [warehouse].[Shift] s
			JOIN @tmp t ON t.id IN (s.incomeWarehouseDocumentLineId,s.warehouseDocumentLineId)
		
		/*Kasowanie atrybutów*/
		DELETE FROM warehouse.ShiftAttrValue 
		WHERE shiftId IN (SELECT id FROM @tmp_shift)

		/*Kasowanie linii*/
		DELETE FROM [warehouse].[Shift]
		WHERE id IN (SELECT id FROM @tmp_shift)
		
		/*Kasowanie transakcji jeśli nie posiada już linii*/
		-- chłopcy wymyślili ze może się przydać ten nagłówek do czegoś więc go nie kasuję, zle że czasem zostana w bazie same nagłówki
		--DELETE FROM [warehouse].[ShiftTransaction]
		--WHERE id IN (	SELECT st.shiftTransactionId 
		--				FROM @tmp_shift st )
		--	AND id NOT IN (	SELECT s.shiftTransactionId 
		--					FROM [warehouse].[Shift] s
		--					JOIN @tmp_shift	t ON s.shiftTransactionId = t.shiftTransactionId )
							
			
    /*Kasowanie danych pozycjach dokumentu magazynowego*/
    DELETE  FROM [document].WarehouseDocumentLine
    WHERE   id IN ( SELECT id FROM @tmp )

	/*Pobieranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd kasowania danych:WarehouseDocumentLine; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            
            IF @rowcount = 0 
                RAISERROR ( 50012, 16, 1 ) ;
        END
' 
END
GO

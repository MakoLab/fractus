/*
name=[document].[p_updateWarehouseDocumentCost]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4Z92yrT96tmPLcuqK/RYFQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateWarehouseDocumentCost]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateWarehouseDocumentCost]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateWarehouseDocumentCost]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_updateWarehouseDocumentCost]
@warehouseDocumentHeaderId UNIQUEIDENTIFIER,
@result int  = NULL

AS
	BEGIN
/*Procedura działa tylko dla rozchodów*/
		/*Deklaracja zmiennych*/
		DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT

	IF EXISTS( SELECT id FROM document.WarehouseDocumentHeader h WHERE h.status >= 60 AND h.id = @warehouseDocumentHeaderId)
		BEGIN
			IF @result IS  NULL 
			SELECT (
				SELECT ( 
					SELECT fullNumber number 
					FROM document.WarehouseDocumentHeader h 
					WHERE h.status >= 60 AND h.id = @warehouseDocumentHeaderId
					FOR XML PATH(''''),TYPE
				) FOR XML PATH(''bookedOutcome''),TYPE
			) FOR XML PATH(''root''),TYPE
			RETURN 0;
		END

--print ''1''
		/*Aktualizacja części rozchodowej dokumentu WZK , PZK (Przychodowa jest wstawiana w p_createIncomeQuantityCorrection)*/
		UPDATE document.WarehouseDocumentLine
		SET [value] = ISNULL((	SELECT SUM( ISNULL(wv.incomePrice * wv.quantity,0) ) incomeValue 
						FROM document.WarehouseDocumentValuation wv 
						WHERE wl.id = wv.outcomeWarehouseDocumentLineId ),0) * SIGN( wl.quantity ),
			[version] = newid()
		FROM document.WarehouseDocumentLine wl
		WHERE warehouseDocumentHeaderId = @warehouseDocumentHeaderId
			AND (quantity * direction) < 0 
--print ''2''	

		/*Aktualizacja części przychodowej PZK, WZK */
		UPDATE document.WarehouseDocumentLine
		SET [value] = ABS(ISNULL((	SELECT SUM( ISNULL(wv.price * wv.quantity,0) ) incomeValue 
						FROM document.CommercialWarehouseValuation wv 
						WHERE wl.id = wv.warehouseDocumentLineId ),0)) * SIGN( wl.quantity ),
			[version] = newid()
		FROM document.WarehouseDocumentLine wl
		WHERE warehouseDocumentHeaderId = @warehouseDocumentHeaderId
			AND (quantity * direction) > 0 
	
--print ''3''
		UPDATE document.WarehouseDocumentLine
		SET price = ISNULL(ABS( ROUND([value]/quantity,2) ),0)
		WHERE warehouseDocumentHeaderId = @warehouseDocumentHeaderId

--print ''4''
		UPDATE document.WarehouseDocumentHeader
		SET [value] = ISNULL((	SELECT SUM( ABS(ISNULL(value,0)) * SIGN(quantity) )
						FROM document.WarehouseDocumentLine 
						WHERE warehouseDocumentHeaderId = @warehouseDocumentHeaderId ),0),
			version = newid()
		WHERE id = @warehouseDocumentHeaderId

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:WarehouseDocumentLine; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                IF @rowcount = 0 
                    RAISERROR ( 50012, 16, 1 ) ;
            END
	IF @result IS  NULL 
		SELECT CAST( ''<root></root>'' AS XML ) XML  

	END
' 
END
GO

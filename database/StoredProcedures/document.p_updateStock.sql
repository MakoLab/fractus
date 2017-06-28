/*
name=[document].[p_updateStock]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
WnspGsXrTF9bAXlgTO/FPg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateStock]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateStock]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateStock]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_updateStock]
@xmlVar XML
AS
BEGIN
		
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT,
			@idoc INT
			

		DECLARE @tmp TABLE ( id UNIQUEIDENTIFIER, itemId UNIQUEIDENTIFIER, warehouseId UNIQUEIDENTIFIER ,unitId UNIQUEIDENTIFIER, differentialQuantity numeric(18, 6))	


		/*Odzczytanie XML`a, xmldoc jest szybszy dla wielu wierszy */
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

		INSERT INTO @tmp ( id, itemId, warehouseId, unitId, differentialQuantity)
		SELECT 	NEWID(), itemId, warehouseId, unitId, differentialQuantity
		FROM OPENXML(@idoc, ''/root/item'')
			WITH (
					warehouseId char(36) ''@warehouseId'',
					itemId char(36) ''@itemId'',
					unitId char(36) ''@unitId'',
					differentialQuantity numeric(18, 6) ''@differentialQuantity''
				)
		EXEC sp_xml_removedocument @idoc

		/*Wstawienie danych o nieużytych produktach do tabeli stanów*/
		INSERT INTO  document.WarehouseStock  WITH(TABLOCK) ( id, itemId, warehouseId, unitId, quantity)
		SELECT NEWID(),	t.itemId,t.warehouseId,	t.unitId, 0
		FROM    @tmp t
			LEFT JOIN document.WarehouseStock ws ON ws.itemId = t.itemId
				 AND ws.warehouseId = t.warehouseId
				 AND ws.unitId = t.unitId
		WHERE ws.id IS NULL

        
		/*Aktualizacja stanu magazynu*/
        UPDATE  [document].WarehouseStock  WITH(ROWLOCK)
        SET     
				quantity = quantity + t.differentialQuantity
        FROM    @tmp t
        WHERE   WarehouseStock.itemId = t.itemId
			AND WarehouseStock.warehouseId = t.warehouseId

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
 
 		IF EXISTS(	SELECT ws.id 
 					FROM @tmp t 
 						JOIN  document.WarehouseStock ws ON t.itemId = ws.itemId AND t.warehouseId = ws.warehouseId
 					WHERE ws.isBlocked = 1 AND t.differentialQuantity <> 0
					)
					BEGIN
						SELECT TOP 1 @errorMsg = i.name
 						FROM @tmp t 
 							JOIN  document.WarehouseStock ws ON t.itemId = ws.itemId AND t.warehouseId = ws.warehouseId
 							JOIN item.Item i ON  t.itemId = i.id
 						WHERE ws.isBlocked = 1 AND t.differentialQuantity <> 0
 						
 						SELECT @errorMsg = @errorMsg + ''@'' + CAST(COUNT(i.name) AS varchar(50))
 						FROM @tmp t 
 							JOIN  document.WarehouseStock ws ON t.itemId = ws.itemId AND t.warehouseId = ws.warehouseId
 							JOIN item.Item i ON  t.itemId = i.id
 						WHERE ws.isBlocked = 1 AND t.differentialQuantity <> 0
 						
						RAISERROR ( @errorMsg, 16, 1 )
					END
        
		/*Obsługa błedów i wyjatków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:CommercialDocumentLine; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                IF @rowcount = 0 
                    RAISERROR ( 50012, 16, 1 ) ;
            END
    END
' 
END
GO

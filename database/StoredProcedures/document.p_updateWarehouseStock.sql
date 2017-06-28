/*
name=[document].[p_updateWarehouseStock]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
/NI/16yvPDtdwmfZWmNt6A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateWarehouseStock]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateWarehouseStock]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateWarehouseStock]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_updateWarehouseStock] @xmlVar XML
AS 
    BEGIN
		
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT,
			@idoc int

		DECLARE @tmp TABLE (itemId uniqueidentifier, warehouseId uniqueidentifier, unitId uniqueidentifier, quantity numeric(18,6),reservedQuantity numeric(18,6),orderedQuantity numeric(18,6),isBlocked int, lastPurchaseNetPrice numeric(18,2), lastPurchaseIssueDate datetime)


EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar


		INSERT INTO @tmp 
		SELECT itemId, warehouseId, unitId, quantity,reservedQuantity,orderedQuantity, isBlocked, lastPurchaseNetPrice, lastPurchaseIssueDate
		FROM OPENXML(@idoc, ''/root/*/entry'')
		WITH (
				itemId char(36) ''itemId'',
				warehouseId char(36) ''warehouseId'',
				unitId char(36) ''unitId'',
				quantity numeric(18,6) ''quantity'',
				reservedQuantity numeric(18,6) ''reservedQuantity'',
				orderedQuantity numeric(18,6) ''orderedQuantity'',
				isBlocked int ''isBlocked'',
				lastPurchaseNetPrice numeric(18,2) ''lastPurchaseNetPrice'',
				lastPurchaseIssueDate datetime ''lastPurchaseIssueDate''
)
EXEC sp_xml_removedocument @idoc




		INSERT INTO  document.WarehouseStock ( id, itemId, warehouseId, unitId, quantity,reservedQuantity,orderedQuantity, isBlocked)
		SELECT 
				NEWID(),
				tmp.itemId,
				tmp.warehouseId,
				tmp.unitId,
				0,
				0,
				0,
				tmp.isBlocked
		FROM    @tmp tmp
			LEFT JOIN document.WarehouseStock ws ON ws.itemId = tmp.itemId
				 AND ws.warehouseId = tmp.warehouseId
		WHERE ws.id IS NULL
		GROUP BY tmp.itemId,tmp.warehouseId,tmp.unitId ,tmp.isBlocked
		
		SELECT @rowcount = @@ROWCOUNT
        
		/*Aktualizacja stanu magazynu*/
        UPDATE  [document].WarehouseStock
        SET     
				quantity = ISNULL(t.quantity ,0 ),
				reservedQuantity = ISNULL(t.reservedQuantity,0),
				orderedQuantity = ISNULL(t.orderedQuantity,0),
				lastPurchaseNetPrice = t.lastPurchaseNetPrice,
				lastPurchaseIssueDate = t.lastPurchaseIssueDate,
				isBlocked = t.isBlocked
        FROM    @tmp t
        WHERE   WarehouseStock.itemId = t.itemId
			AND WarehouseStock.warehouseId = t.warehouseId

		/*Pobranie liczby wierszy*/
        SELECT @rowcount = @rowcount + @@ROWCOUNT
        
		/*Obsługa błedów i wyjatków*/
        IF @@ERROR <> 0 
            BEGIN

                SET @errorMsg = ''Błąd wstawiania danych table:WarehouseStock; error:''
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

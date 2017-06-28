/*
name=[document].[p_updateLastPurchasePrice]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
a+2APc8txiascE+952a4TA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateLastPurchasePrice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateLastPurchasePrice]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateLastPurchasePrice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_updateLastPurchasePrice] @xmlVar XML
AS
BEGIN

		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT,
			@idoc int

		DECLARE @tmp TABLE ( id UNIQUEIDENTIFIER, itemId UNIQUEIDENTIFIER, warehouseId UNIQUEIDENTIFIER ,unitId UNIQUEIDENTIFIER, lastPurchaseNetPrice numeric(18, 2))
		DECLARE @issueDate DATETIME

		/*Odzczytanie XML`a*/
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

		INSERT INTO @tmp ( id, itemId, warehouseId, unitId, lastPurchaseNetPrice)
		SELECT 	NEWID(), itemId, warehouseId, unitId, lastPurchaseNetPrice
		FROM OPENXML(@idoc, ''/root/item'')
			WITH (
					warehouseId char(36) ''@warehouseId'',
					itemId char(36) ''@itemId'',
					unitId char(36) ''@unitId'',
					lastPurchaseNetPrice numeric(18, 6) ''@lastPurchaseNetPrice'',
					issueDate datetime ''@issueDate''
				)
				
		SELECT @issueDate = issueDate
		FROM OPENXML(@idoc, ''/root'')
			WITH (issueDate datetime ''@issueDate'')
		
		EXEC sp_xml_removedocument @idoc
		
		/*Wstawienie danych o nieużytych produktach do tabeli stanów*/
		INSERT INTO  document.WarehouseStock  WITH(TABLOCK) ( id, itemId, warehouseId, unitId, quantity)
		SELECT NEWID(),	t.itemId,t.warehouseId,	t.unitId, 0
		FROM    @tmp t
			LEFT JOIN document.WarehouseStock ws ON ws.itemId = t.itemId
				 AND ws.warehouseId = t.warehouseId
				 AND ws.unitId = t.unitId
		WHERE ws.id IS NULL
		
		/*Aktualizacja ostatniej ceny zakupu jeśli issueDate jest nowsze niż zapisane*/
        UPDATE  [document].WarehouseStock  WITH(ROWLOCK)
        SET     
				lastPurchaseNetPrice = t.lastPurchaseNetPrice,
				lastPurchaseIssueDate = @issueDate
        FROM    @tmp t
        WHERE   WarehouseStock.itemId = t.itemId
			AND WarehouseStock.warehouseId = t.warehouseId
			AND (WarehouseStock.lastPurchaseIssueDate IS NULL 
				OR WarehouseStock.lastPurchaseIssueDate <= @issueDate)
        
		/*Obsługa błedów i wyjatków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:WarehouseStock; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        
END
' 
END
GO

/*
name=[document].[p_updateReservationStock]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4M24gpAtyZzqmXDKtEbu2w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateReservationStock]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateReservationStock]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateReservationStock]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_updateReservationStock]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@idoc INT


	DECLARE @tmp TABLE ( id UNIQUEIDENTIFIER, itemId UNIQUEIDENTIFIER, warehouseId UNIQUEIDENTIFIER ,unitId UNIQUEIDENTIFIER)	


	/*Odzczytanie XML`a, xmldoc jest szybszy dla wielu wierszy */
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

	-- gdereck - dodanie distincta i wstawianie id do zmiennej tablicowej po fakcie
	INSERT INTO @tmp (itemId, warehouseId, unitId) 
	SELECT DISTINCT itemId, warehouseId, unitId
	FROM OPENXML(@idoc, ''/root/*/entry'')
		WITH (
				id char(36) ''id'',
				warehouseId char(36) ''warehouseId'',
				itemId char(36) ''itemId'',
				unitId char(36) ''unitId''
			)

	UPDATE @tmp SET id = newid()

	EXEC sp_xml_removedocument @idoc

	/*Wstawienie danych o nieużytych produktach do tabeli stanów*/
	INSERT INTO  document.WarehouseStock  WITH(TABLOCK) ( id, itemId, warehouseId, unitId, quantity)
	SELECT NEWID(),	t.itemId,t.warehouseId,	t.unitId,0
	FROM    @tmp t
		LEFT JOIN document.WarehouseStock ws ON ws.itemId = t.itemId
			 AND ws.warehouseId = t.warehouseId
			 AND ws.unitId = t.unitId
	WHERE ws.id IS NULL
	GROUP BY t.itemId,t.warehouseId,t.unitId
    

	UPDATE document.WarehouseStock
	SET reservedQuantity = ISNULL(orderLines.quantity, 0 ) - ISNULL(relationLines.quantity, 0)
	FROM @tmp items 
	JOIN	document.WarehouseStock ws  ON ws.itemId = items.itemId AND ws.warehouseId = items.warehouseId
	LEFT JOIN ( 
		SELECT SUM(l.quantity) quantity, l.itemId, l.warehouseId  
		FROM document.CommercialDocumentLine l WITH(NOLOCK)
			JOIN @tmp e ON l.warehouseId = e.warehouseId AND l.itemId = e.itemId
		WHERE l.orderDirection = -1
		GROUP BY l.itemId, l.warehouseId ) orderLines ON  ws.itemId = orderLines.itemId AND ws.warehouseId = orderLines.warehouseId 
	LEFT JOIN 
		(	SELECT SUM(cr.quantity) quantity, l.itemId, l.warehouseId 
			FROM document.CommercialDocumentLine l WITH(NOLOCK) 
				LEFT JOIN document.CommercialWarehouseRelation cr  WITH(NOLOCK) ON l.id = cr.commercialDocumentLineId AND cr.isOrderRelation = 1
				JOIN @tmp e ON l.warehouseId = e.warehouseId AND l.itemId = e.itemId
			WHERE l.orderDirection = -1
			GROUP BY l.itemId, l.warehouseId
		) relationLines ON  ws.itemId = relationLines.itemId AND ws.warehouseId = relationLines.warehouseId 

    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:WarehouseStock; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END

' 
END
GO

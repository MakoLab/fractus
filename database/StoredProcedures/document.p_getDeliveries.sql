/*
name=[document].[p_getDeliveries]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
AcaP/xo2m4t64g2VSW/isA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDeliveries]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getDeliveries]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDeliveries]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [document].[p_getDeliveries]
@xmlVar XML
AS
BEGIN
	DECLARE @rowcount INT ,
	@idoc INT

	DECLARE @tmp_table TABLE (id UNIQUEIDENTIFIER, itemId UNIQUEIDENTIFIER, warehouseId UNIQUEIDENTIFIER,unitId UNIQUEIDENTIFIER, quantity_ numeric(18,6) ) --, withNoDeliveries bit

	INSERT INTO @tmp_table ( id, itemId, warehouseId, unitId, quantity_ )--, withNoDeliveries
							


	/*Odzczytanie XML`a, xmldoc jest szybszy dla wielu wierszy */
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

	INSERT INTO @tmp_table ( id, itemId, warehouseId, unitId, quantity_)
	SELECT NEWID(), itemId, warehouseId, unitId, differentialQuantity
	FROM OPENXML(@idoc, ''/root/delivery'')
		WITH (
				warehouseId char(36) ''@warehouseId'',
				itemId char(36) ''@itemId'',
				unitId char(36) ''@unitId'',
				differentialQuantity numeric(18,6) ''@differentialQuantity''
			)

	EXEC sp_xml_removedocument @idoc

	
	/*Pobranie wartości*/
	SELECT (
		SELECT  t.itemId as ''@itemId'',
				t.warehouseId as  ''@warehouseId'',
				ISNULL(ws.reservedQuantity,0) as ''@reservedQuantity'',
				ISNULL(ws.orderedQuantity,0) as ''@orderedQuantity'',
				ISNULL(ws. Quantity,0) as ''@quantity'',
				ws.lastPurchaseNetPrice as ''@lastPurchaseNetPrice'',
			(	SELECT 
					v.id as ''@incomeWarehouseDocumentLineId'',
					v.quantity as ''@quantity'', 
					v.incomeDate as ''@incomeDate'',
					WDH.issueDate as ''@issueDate'',
					v.ordinalNumber as ''@ordinalNumber''
					,v.price as ''@price''
				FROM document.v_getAvailableDeliveries v WITH (ROWLOCK) 
				/* jakub - dodanie joina z naglowkiem w celu wyciagniecia daty wystawienia przychodu */
				JOIN document.WarehouseDocumentHeader WDH WITH (ROWLOCK) ON WDH.id = v.warehouseDocumentHeaderId
				WHERE v.itemId = t.itemId 
					AND v.warehouseId = t.warehouseId
					--AND t.withNoDeliveries = 0
				ORDER BY incomeDate	, ordinalNumber	, documentTypeId
				FOR XML PATH(''delivery''),TYPE			
			)
		FROM    @tmp_table t
			LEFT JOIN document.WarehouseStock ws WITH (ROWLOCK)  ON t.itemId = ws.itemId 
				AND t.warehouseId = ws.warehouseId
		FOR XML PATH(''item''),TYPE
			) 

	FOR XML PATH(''root''), TYPE
END
' 
END
GO

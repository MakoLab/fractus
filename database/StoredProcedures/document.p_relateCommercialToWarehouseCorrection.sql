/*
name=[document].[p_relateCommercialToWarehouseCorrection]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
MrcWL1EP3vljiUA+TtwH6w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_relateCommercialToWarehouseCorrection]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_relateCommercialToWarehouseCorrection]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_relateCommercialToWarehouseCorrection]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE document.p_relateCommercialToWarehouseCorrection 
@commercialDocumentHeaderId uniqueidentifier,  @warehouseDocumentHeaderId uniqueidentifier
AS
BEGIN
DECLARE @tmpRelation TABLE (commercialId uniqueidentifier, warehouseId uniqueidentifier, quantity decimal(18,4) ,grossValue decimal(18,4) ) 

	--SELECT @commercialDocumentHeaderId  =''78409FFF-3FE7-4F39-B31C-C718B14FB399'', @warehouseDocumentHeaderId = ''EEDD751F-6F51-4204-B9B3-C0098A8B3DEE''

	INSERT INTO @tmpRelation
	SELECT c.id, w.id, c.quantity, c.grossValue
	FROM (
			SELECT l.* FROM document.CommercialDocumentHeader h JOIN document.CommercialDocumentLine l ON h.id = l.commercialDocumentHeaderId WHERE h.id = @commercialDocumentHeaderId AND quantity <> 0 
		) c
		JOIN 
		(
			SELECT l.* FROM document.warehouseDocumentHeader h JOIN document.warehouseDocumentLine l ON h.id = l.warehouseDocumentHeaderId WHERE h.id = @warehouseDocumentHeaderId
		) w ON c.itemId = w.itemId AND c.warehouseId = w.warehouseId AND c.quantity = w.quantity


	INSERT INTO [document].[CommercialWarehouseRelation] (id, commercialDocumentLineId, warehouseDocumentLineId, quantity, value, isValuated, isOrderRelation, isCommercialRelation, isServiceRelation, [version])
	SELECT newid(), commercialId, warehouseId,quantity, grossValue, 1,0,1,0,newid()
	FROM @tmpRelation

	INSERT INTO [document].[CommercialWarehouseValuation] (id, commercialDocumentLineId, warehouseDocumentLineId, quantity, value, price, [version])
	SELECT newid(), commercialId, warehouseId,quantity, grossValue, ROUND(grossValue/quantity,2),newid()
	FROM @tmpRelation

	SELECT CAST(''<root>ok</root>'' as XML)

END
' 
END
GO

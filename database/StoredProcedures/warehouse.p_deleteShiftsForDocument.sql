/*
name=[warehouse].[p_deleteShiftsForDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Zle/VtU37tBMiVoKgPNRPQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_deleteShiftsForDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_deleteShiftsForDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_deleteShiftsForDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_deleteShiftsForDocument]
@warehouseDocumentHeaderId UNIQUEIDENTIFIER
AS
BEGIN
	UPDATE warehouse.Shift
	SET [status] = -20
	WHERE warehouseDocumentLineId IN ( SELECT id FROM document.WarehouseDocumentLine WHERE warehouseDocumentHeaderId = @warehouseDocumentHeaderId )
		OR  incomeWarehouseDocumentLineId IN ( SELECT id FROM document.WarehouseDocumentLine WHERE warehouseDocumentHeaderId = @warehouseDocumentHeaderId )



WHILE EXISTS ( SELECT id FROM warehouse.Shift WHERE sourceShiftId is not null and sourceShiftId IN (SELECT id FROM warehouse.Shift WHERE [status] = - 20) AND [status] <> - 20 )
		UPDATE warehouse.Shift
			SET [status] = -20
		WHERE  id IN (SELECT id FROM warehouse.Shift WHERE sourceShiftId is not null and sourceShiftId IN (SELECT id FROM warehouse.Shift WHERE [status] = - 20))
		
END
' 
END
GO

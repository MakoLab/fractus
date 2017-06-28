/*
name=[item].[p_getDeliveriesWithNoLock]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JweP9RPAYk5+ROahPILK3A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getDeliveriesWithNoLock]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getDeliveriesWithNoLock]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getDeliveriesWithNoLock]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getDeliveriesWithNoLock]
@xmlVar XML
AS
BEGIN
	DECLARE 
		@warehouseId uniqueidentifier

SELECT @warehouseId = x.value(''@warehouseId'',''char(36)'') 
FROM @xmlVar.nodes(''root/item'') AS a(x)

	SELECT 
			(	SELECT 
					v.quantity as ''@quantity'',
					v.incomeDate as ''@incomeDate'',
					v.price ''@price'',
					v.warehouseId ''@warehouseId'', 
					v.itemId ''@itemId'', 
					h.fullNumber ''@fullNumber'',
					h.issueDate as ''@issueDate'',
					h.id as ''@id'',
					h.documentTypeId as ''@documentTypeId'',
					h.status as ''@status'',
					l.quantity as ''@lineQuantity''
				FROM document.v_getAvailableDeliveries v WITH (NOLOCK) 
					JOIN document.WarehouseDocumentHeader h WITH (NOLOCK) ON h.id = v.warehouseDocumentHeaderId
					JOIN document.WarehouseDocumentLine l WITH (NOLOCK) ON l.id = v.id
					JOIN ( 
						SELECT distinct x.value(''@id'',''char(36)'') itemId -- w przypadku korekty dalsze działania były bardzo błędne CW 27-06-2012
						FROM @xmlVar.nodes(''root/item'') AS a(x)
						) y ON v.itemId = y.itemId
				WHERE (@warehouseId IS NULL OR v.warehouseId = @warehouseId)
				ORDER BY v.incomeDate, v.ordinalNumber 		
				FOR XML PATH(''delivery''),TYPE			
			)
	FOR XML PATH(''root''), TYPE
END
' 
END
GO

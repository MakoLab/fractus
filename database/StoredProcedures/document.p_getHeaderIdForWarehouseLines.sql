/*
name=[document].[p_getHeaderIdForWarehouseLines]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
jJbCpKTgpNMB8SOh7fuBAA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getHeaderIdForWarehouseLines]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getHeaderIdForWarehouseLines]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getHeaderIdForWarehouseLines]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getHeaderIdForWarehouseLines] @xmlVar XML
AS 
BEGIN
DECLARE @tid TABLE (id UNIQUEIDENTIFIER)
INSERT INTO @tid (id)
SELECT x.value(''@id'',''char(36)'') id 
FROM @xmlVar.nodes(''/root/line'') AS a ( x ) 

SELECT (
    SELECT DISTINCT sub.id as ''@id'', warehouseDocumentHeaderId as ''@warehouseDocumentHeaderId'', documentTypeId as ''@documentTypeId''
    FROM @tid sub
		JOIN document.WarehouseDocumentLine l  ON l.id =  sub.id
		JOIN document.WarehouseDocumentHeader h ON h.id = l.warehouseDocumentHeaderId
	FOR XML PATH(''line''),TYPE
)  	FOR XML PATH(''root''),TYPE
END
' 
END
GO

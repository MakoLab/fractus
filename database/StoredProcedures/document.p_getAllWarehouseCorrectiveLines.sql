/*
name=[document].[p_getAllWarehouseCorrectiveLines]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
YF5xoSbfCxvdVcqQKz/zzg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getAllWarehouseCorrectiveLines]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getAllWarehouseCorrectiveLines]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getAllWarehouseCorrectiveLines]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getAllWarehouseCorrectiveLines]
@warehouseDocumentHeaderId uniqueidentifier
AS
BEGIN

DECLARE @x XML 
SELECT @x = (
	SELECT * FROM (
		SELECT c.*, ch.documentTypeId, ch.fullNumber, ch.issueDate, ch.documentCurrencyId, i.name ''itemName''
			FROM document.WarehouseDocumentLine l
			JOIN document.WarehouseDocumentLine c ON l.id=c.initialWarehouseDocumentLineId
			JOIN document.WarehouseDocumentHeader ch ON ch.id=c.warehouseDocumentHeaderId
			JOIN item.item i ON i.id=c.itemId
		WHERE ch.status >= 40 and l.warehouseDocumentHeaderId=@warehouseDocumentHeaderId
	UNION
		SELECT ol.*, oh.documentTypeId, oh.fullNumber, oh.issueDate, oh.documentCurrencyId, i.name ''itemName''
			FROM document.WarehouseDocumentLine ol
			JOIN document.WarehouseDocumentHeader oh ON oh.id=ol.warehouseDocumentHeaderId
			JOIN item.item i ON i.id=ol.itemId
		WHERE oh.id=@warehouseDocumentHeaderId
	) xx
    FOR XML PATH(''line''), TYPE)

SELECT ISNULL(@x,'''') FOR XML PATH(''root'') , TYPE
END
' 
END
GO

/*
name=[document].[p_getRelatedWarehouseDocumentsId]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
D10kGr/Djb0sbl0PtTXhzQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getRelatedWarehouseDocumentsId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getRelatedWarehouseDocumentsId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getRelatedWarehouseDocumentsId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getRelatedWarehouseDocumentsId]
@commercialDocumentHeaderId UNIQUEIDENTIFIER
AS

BEGIN

SELECT (
	SELECT DISTINCT l2.warehouseDocumentHeaderId id
	FROM document.CommercialDocumentLine l  
		JOIN document.CommercialWarehouseRelation cr ON l.id = cr.commercialDocumentLineId
		JOIN document.WarehouseDocumentLine l2 ON cr.warehouseDocumentLineId = l2.id 
	WHERE l.commercialDocumentHeaderId = @commercialDocumentHeaderId
	FOR XML PATH(''''), TYPE
) FOR XML PATH(''root''), TYPE

END
' 
END
GO

/*
name=[document].[p_getPreviousWarehouseCorrectiveDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
iEhg9XFkKwHgPdOPS8jeRA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getPreviousWarehouseCorrectiveDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getPreviousWarehouseCorrectiveDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getPreviousWarehouseCorrectiveDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getPreviousWarehouseCorrectiveDocuments]
	@warehouseDocumentHeaderId UNIQUEIDENTIFIER
AS

BEGIN
/*Zwraca listę wcześniejszych korekt dokumentu magazynowego */
	DECLARE @x XML
	SELECT @x = (
	SELECT warehouseDocumentHeaderId id FROM (
		SELECT DISTINCT l2.warehouseDocumentHeaderId warehouseDocumentHeaderId, h2.issueDate issueDate
		FROM document.WarehouseDocumentLine l 
			JOIN document.WarehouseDocumentHeader h ON h.id = l.warehouseDocumentHeaderId
			JOIN document.WarehouseDocumentLine l2 ON l.initialWarehouseDocumentLineId = l2.initialWarehouseDocumentLineId
			JOIN document.WarehouseDocumentHeader h2 ON h2.id = l2.warehouseDocumentHeaderId
		WHERE l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId AND h2.status >= 40
			AND h2.issueDate < h.issueDate
		UNION 
		SELECT l2.warehouseDocumentHeaderId warehouseDocumentHeaderId, h2.issueDate issueDate
		FROM document.WarehouseDocumentLine l
			JOIN document.WarehouseDocumentLine l2 ON l.initialWarehouseDocumentLineId = l2.id
			JOIN document.WarehouseDocumentHeader h2 ON h2.id = l2.warehouseDocumentHeaderId
		WHERE l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId  
	) [document]
	ORDER BY  issueDate
	FOR XML AUTO, TYPE
	)


SELECT ISNULL(@x,'''') FOR XML PATH(''root''), TYPE
END
' 
END
GO

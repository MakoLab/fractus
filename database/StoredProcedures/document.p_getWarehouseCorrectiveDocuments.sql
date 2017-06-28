/*
name=[document].[p_getWarehouseCorrectiveDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4tPfoTgGEAGXp4USClLsfA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getWarehouseCorrectiveDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getWarehouseCorrectiveDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getWarehouseCorrectiveDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getWarehouseCorrectiveDocuments]
@warehouseDocumentHeaderId uniqueidentifier
AS
BEGIN

DECLARE @x XML 
SELECT @x = (
SELECT id FROM (
	SELECT DISTINCT l2.warehouseDocumentHeaderId id, h2.issueDate issueDate 
	FROM document.WarehouseDocumentLine l1 
		JOIN document.WarehouseDocumentHeader h1  ON l1.warehouseDocumentHeaderId = h1.id
		JOIN document.WarehouseDocumentLine l2 ON  l1.id = l2.[correctedWarehouseDocumentLineId]
		JOIN document.WarehouseDocumentHeader h2  ON l2.warehouseDocumentHeaderId = h2.id
	WHERE l1.warehouseDocumentHeaderId = @warehouseDocumentHeaderId AND h2.status >= 40
) [document] 
ORDER BY issueDate
FOR XML AUTO , TYPE
)	

SELECT ISNULL(@x,'''') FOR XML PATH(''root'') , TYPE
END
' 
END
GO

/*
name=[tools].[p_naprawPz]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
DW4PMyyPLJKpg66QPp8Bdg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_naprawPz]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_naprawPz]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_naprawPz]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tools].[p_naprawPz]
AS

UPDATE document.WarehouseDocumentLine 
SET outcomeDate = NULL
WHERE id in (
	SELECT l.id
	FROM document.WarehouseDocumentHeader h 
		JOIN document.WarehouseDocumentLine l ON h.id = l.warehouseDocumentHeaderId
		JOIN dictionary.DocumentType dt ON h.documentTypeId = dt.id AND dt.symbol = ''PZ''
		LEFT JOIN (	SELECT SUM(quantity) q, incomeWarehouseDocumentLineId 
					FROM document.IncomeOutcomeRelation 
					GROUP BY incomeWarehouseDocumentLineId ) ir ON l.id = ir.incomeWarehouseDocumentLineId
		JOIN  item.Item i ON l.itemId = i.id
	WHERE l.quantity  <> ir.q AND l.outcomeDate IS NOT NULL
	)
' 
END
GO

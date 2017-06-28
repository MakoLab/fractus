/*
name=[item].[v_itemDictionaryWarehouseDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Q7KfJWulHjPUUYldR3qMrQ==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[item].[v_itemDictionaryWarehouseDocument]'))
DROP VIEW [item].[v_itemDictionaryWarehouseDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[item].[v_itemDictionaryWarehouseDocument]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [item].[v_itemDictionaryWarehouseDocument] WITH SCHEMABINDING AS
SELECT   COUNT_BIG(*) counter, [item].ItemDictionary.field,[item].ItemDictionary.id, l.warehouseDocumentHeaderId
FROM         [item].ItemDictionary 
		INNER JOIN [item].ItemDictionaryRelation ON  [item].ItemDictionary.id = [item].ItemDictionaryRelation.itemDictionaryId
		JOIN [document].WarehouseDocumentLine l ON [item].ItemDictionaryRelation.itemId = l.itemId
GROUP BY [item].ItemDictionary.field, [item].ItemDictionary.id , l.warehouseDocumentHeaderId
' 
GO

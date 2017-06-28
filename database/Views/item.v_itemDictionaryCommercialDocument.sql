/*
name=[item].[v_itemDictionaryCommercialDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
t3zlAxc3QF+5K1w0N7HFKw==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[item].[v_itemDictionaryCommercialDocument]'))
DROP VIEW [item].[v_itemDictionaryCommercialDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[item].[v_itemDictionaryCommercialDocument]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [item].[v_itemDictionaryCommercialDocument] WITH SCHEMABINDING AS
SELECT   COUNT_BIG(*) counter, [item].ItemDictionary.field,[item].ItemDictionary.id, l.commercialDocumentHeaderId
FROM         [item].ItemDictionary 
		INNER JOIN [item].ItemDictionaryRelation ON  [item].ItemDictionary.id = [item].ItemDictionaryRelation.itemDictionaryId
		JOIN [document].CommercialDocumentLine l ON [item].ItemDictionaryRelation.itemId = l.itemId
GROUP BY [item].ItemDictionary.field, [item].ItemDictionary.id , l.commercialDocumentHeaderId
' 
GO

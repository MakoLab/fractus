/*
name=[item].[v_itemDictionaryComplaintDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
GoAlL+Vn5cwsxgiWgCXnRQ==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[item].[v_itemDictionaryComplaintDocument]'))
DROP VIEW [item].[v_itemDictionaryComplaintDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[item].[v_itemDictionaryComplaintDocument]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [item].[v_itemDictionaryComplaintDocument] WITH SCHEMABINDING AS
SELECT    [item].ItemDictionary.field,[item].ItemDictionary.id, l.complaintDocumentHeaderId
FROM         [item].ItemDictionary 
		INNER JOIN [item].ItemDictionaryRelation ON  [item].ItemDictionary.id = [item].ItemDictionaryRelation.itemDictionaryId
		JOIN [complaint].ComplaintDocumentLine l ON [item].ItemDictionaryRelation.itemId = l.itemId
GROUP BY [item].ItemDictionary.field, [item].ItemDictionary.id , l.complaintDocumentHeaderId
UNION
SELECT  [item].ItemDictionary.field,[item].ItemDictionary.id, l.complaintDocumentHeaderId
FROM         [item].ItemDictionary 
		INNER JOIN [item].ItemDictionaryRelation ON  [item].ItemDictionary.id = [item].ItemDictionaryRelation.itemDictionaryId
		JOIN [complaint].ComplaintDecision d ON [item].ItemDictionaryRelation.itemId = d.replacementItemId
		JOIN [complaint].ComplaintDocumentLine l ON d.complaintDocumentLineId = l.id
GROUP BY [item].ItemDictionary.field, [item].ItemDictionary.id , l.complaintDocumentHeaderId
' 
GO

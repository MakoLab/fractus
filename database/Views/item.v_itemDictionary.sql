/*
name=[item].[v_itemDictionary]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
byJwo5D3+XzMpMIm38NMXQ==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[item].[v_itemDictionary]'))
DROP VIEW [item].[v_itemDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[item].[v_itemDictionary]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [item].[v_itemDictionary] WITH SCHEMABINDING AS
SELECT   COUNT_BIG(*) counter, [item].ItemDictionary.field, [item].ItemDictionaryRelation.itemId, [item].ItemDictionary.id
FROM         [item].ItemDictionary INNER JOIN
                      [item].ItemDictionaryRelation ON 
                      [item].ItemDictionary.id = [item].ItemDictionaryRelation.itemDictionaryId
GROUP BY [item].ItemDictionary.field, [item].ItemDictionaryRelation.itemId, [item].ItemDictionary.id
' 
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[v_itemDictionary]') AND name = N'ind_vItemDictionary')
CREATE UNIQUE CLUSTERED INDEX [ind_vItemDictionary] ON [item].[v_itemDictionary]
(
	[field] ASC,
	[itemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[v_itemDictionary]') AND name = N'ind_vItemDictionary2')
CREATE UNIQUE NONCLUSTERED INDEX [ind_vItemDictionary2] ON [item].[v_itemDictionary]
(
	[field] ASC,
	[itemId] ASC
)
INCLUDE ( 	[counter]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/*
name=[item].[ItemDictionaryRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dRiq4etr5NQ07NJ59LVkjQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[ItemDictionaryRelation]') AND type in (N'U'))
BEGIN
CREATE TABLE [item].[ItemDictionaryRelation](
	[id] [uniqueidentifier] NOT NULL,
	[itemId] [uniqueidentifier] NOT NULL,
	[itemDictionaryId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ItemDictionaryRelation] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[ItemDictionaryRelation]') AND name = N'IND_ItemDictionaryRelation_itemDictionaryId')
CREATE NONCLUSTERED INDEX [IND_ItemDictionaryRelation_itemDictionaryId] ON [item].[ItemDictionaryRelation]
(
	[itemDictionaryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[ItemDictionaryRelation]') AND name = N'IND_ItemDictionaryRelations_itemId')
CREATE NONCLUSTERED INDEX [IND_ItemDictionaryRelations_itemId] ON [item].[ItemDictionaryRelation]
(
	[itemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemDictionaryRelation_Item]') AND parent_object_id = OBJECT_ID(N'[item].[ItemDictionaryRelation]'))
ALTER TABLE [item].[ItemDictionaryRelation]  WITH CHECK ADD  CONSTRAINT [FK_ItemDictionaryRelation_Item] FOREIGN KEY([itemId])
REFERENCES [item].[Item] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemDictionaryRelation_Item]') AND parent_object_id = OBJECT_ID(N'[item].[ItemDictionaryRelation]'))
ALTER TABLE [item].[ItemDictionaryRelation] CHECK CONSTRAINT [FK_ItemDictionaryRelation_Item]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemDictionaryRelation_ItemDictionary]') AND parent_object_id = OBJECT_ID(N'[item].[ItemDictionaryRelation]'))
ALTER TABLE [item].[ItemDictionaryRelation]  WITH CHECK ADD  CONSTRAINT [FK_ItemDictionaryRelation_ItemDictionary] FOREIGN KEY([itemDictionaryId])
REFERENCES [item].[ItemDictionary] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemDictionaryRelation_ItemDictionary]') AND parent_object_id = OBJECT_ID(N'[item].[ItemDictionaryRelation]'))
ALTER TABLE [item].[ItemDictionaryRelation] CHECK CONSTRAINT [FK_ItemDictionaryRelation_ItemDictionary]
GO

/*
name=[item].[ItemRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
C4gIa4AnxEpxbkdAvWR9Ng==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[ItemRelation]') AND type in (N'U'))
BEGIN
CREATE TABLE [item].[ItemRelation](
	[id] [uniqueidentifier] NOT NULL,
	[itemId] [uniqueidentifier] NOT NULL,
	[relatedObjectId] [uniqueidentifier] NOT NULL,
	[itemRelationTypeId] [uniqueidentifier] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
	[relatedObjectOrder] [int] NULL,
 CONSTRAINT [PK_ItemRelation] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[ItemRelation]') AND name = N'indItemRelation_itemId')
CREATE NONCLUSTERED INDEX [indItemRelation_itemId] ON [item].[ItemRelation]
(
	[itemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[ItemRelation]') AND name = N'indItemRelation_itemRelationTypeId')
CREATE NONCLUSTERED INDEX [indItemRelation_itemRelationTypeId] ON [item].[ItemRelation]
(
	[itemRelationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[ItemRelation]') AND name = N'indItemRelation_relatedObjectId')
CREATE NONCLUSTERED INDEX [indItemRelation_relatedObjectId] ON [item].[ItemRelation]
(
	[relatedObjectId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemRelation_Item]') AND parent_object_id = OBJECT_ID(N'[item].[ItemRelation]'))
ALTER TABLE [item].[ItemRelation]  WITH CHECK ADD  CONSTRAINT [FK_ItemRelation_Item] FOREIGN KEY([itemId])
REFERENCES [item].[Item] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemRelation_Item]') AND parent_object_id = OBJECT_ID(N'[item].[ItemRelation]'))
ALTER TABLE [item].[ItemRelation] CHECK CONSTRAINT [FK_ItemRelation_Item]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemRelation_ItemRelationType]') AND parent_object_id = OBJECT_ID(N'[item].[ItemRelation]'))
ALTER TABLE [item].[ItemRelation]  WITH CHECK ADD  CONSTRAINT [FK_ItemRelation_ItemRelationType] FOREIGN KEY([itemRelationTypeId])
REFERENCES [dictionary].[ItemRelationType] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemRelation_ItemRelationType]') AND parent_object_id = OBJECT_ID(N'[item].[ItemRelation]'))
ALTER TABLE [item].[ItemRelation] CHECK CONSTRAINT [FK_ItemRelation_ItemRelationType]
GO

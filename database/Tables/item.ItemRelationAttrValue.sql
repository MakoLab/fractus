/*
name=[item].[ItemRelationAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
03pu5a47qPudaQAAtOZarQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[ItemRelationAttrValue]') AND type in (N'U'))
BEGIN
CREATE TABLE [item].[ItemRelationAttrValue](
	[id] [uniqueidentifier] NOT NULL,
	[itemRelationId] [uniqueidentifier] NOT NULL,
	[itemRAVTypeId] [uniqueidentifier] NOT NULL,
	[decimalValue] [decimal](18, 4) NULL,
	[dateValue] [datetime] NULL,
	[textValue] [nvarchar](500) NULL,
	[xmlValue] [xml] NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
 CONSTRAINT [PK_ItemRelationAttrValue] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[ItemRelationAttrValue]') AND name = N'indItemRelationAttrValue_itemRAVTypeId')
CREATE NONCLUSTERED INDEX [indItemRelationAttrValue_itemRAVTypeId] ON [item].[ItemRelationAttrValue]
(
	[itemRAVTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[ItemRelationAttrValue]') AND name = N'indItemRelationAttrValue_itemRelationId')
CREATE NONCLUSTERED INDEX [indItemRelationAttrValue_itemRelationId] ON [item].[ItemRelationAttrValue]
(
	[itemRelationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemRelationAttrValue_ItemRelation]') AND parent_object_id = OBJECT_ID(N'[item].[ItemRelationAttrValue]'))
ALTER TABLE [item].[ItemRelationAttrValue]  WITH CHECK ADD  CONSTRAINT [FK_ItemRelationAttrValue_ItemRelation] FOREIGN KEY([itemRelationId])
REFERENCES [item].[ItemRelation] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemRelationAttrValue_ItemRelation]') AND parent_object_id = OBJECT_ID(N'[item].[ItemRelationAttrValue]'))
ALTER TABLE [item].[ItemRelationAttrValue] CHECK CONSTRAINT [FK_ItemRelationAttrValue_ItemRelation]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemRelationAttrValue_ItemRelationAttrValueType]') AND parent_object_id = OBJECT_ID(N'[item].[ItemRelationAttrValue]'))
ALTER TABLE [item].[ItemRelationAttrValue]  WITH CHECK ADD  CONSTRAINT [FK_ItemRelationAttrValue_ItemRelationAttrValueType] FOREIGN KEY([itemRAVTypeId])
REFERENCES [dictionary].[ItemRelationAttrValueType] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemRelationAttrValue_ItemRelationAttrValueType]') AND parent_object_id = OBJECT_ID(N'[item].[ItemRelationAttrValue]'))
ALTER TABLE [item].[ItemRelationAttrValue] CHECK CONSTRAINT [FK_ItemRelationAttrValue_ItemRelationAttrValueType]
GO

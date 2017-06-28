/*
name=[item].[ItemAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
wYdwTm0jU14BO55sErRDGQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[ItemAttrValue]') AND type in (N'U'))
BEGIN
CREATE TABLE [item].[ItemAttrValue](
	[id] [uniqueidentifier] NOT NULL,
	[itemId] [uniqueidentifier] NOT NULL,
	[itemFieldId] [uniqueidentifier] NOT NULL,
	[decimalValue] [decimal](18, 4) SPARSE  NULL,
	[dateValue] [datetime] SPARSE  NULL,
	[textValue] [nvarchar](500) NULL,
	[xmlValue] [xml] SPARSE  NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
 CONSTRAINT [PK_ItemAttrValue] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[ItemAttrValue]') AND name = N'indItemAttrValue_itemFieldId')
CREATE NONCLUSTERED INDEX [indItemAttrValue_itemFieldId] ON [item].[ItemAttrValue]
(
	[itemFieldId] ASC
)
INCLUDE ( 	[textValue]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[ItemAttrValue]') AND name = N'indItemAttrValue_itemId')
CREATE NONCLUSTERED INDEX [indItemAttrValue_itemId] ON [item].[ItemAttrValue]
(
	[itemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemAttrValue_Item]') AND parent_object_id = OBJECT_ID(N'[item].[ItemAttrValue]'))
ALTER TABLE [item].[ItemAttrValue]  WITH CHECK ADD  CONSTRAINT [FK_ItemAttrValue_Item] FOREIGN KEY([itemId])
REFERENCES [item].[Item] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemAttrValue_Item]') AND parent_object_id = OBJECT_ID(N'[item].[ItemAttrValue]'))
ALTER TABLE [item].[ItemAttrValue] CHECK CONSTRAINT [FK_ItemAttrValue_Item]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemAttrValue_ItemField]') AND parent_object_id = OBJECT_ID(N'[item].[ItemAttrValue]'))
ALTER TABLE [item].[ItemAttrValue]  WITH CHECK ADD  CONSTRAINT [FK_ItemAttrValue_ItemField] FOREIGN KEY([itemFieldId])
REFERENCES [dictionary].[ItemField] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemAttrValue_ItemField]') AND parent_object_id = OBJECT_ID(N'[item].[ItemAttrValue]'))
ALTER TABLE [item].[ItemAttrValue] CHECK CONSTRAINT [FK_ItemAttrValue_ItemField]
GO

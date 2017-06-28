/*
name=[item].[Item]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
rqtaOE1B/1QkOcYOHHtLDw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[Item]') AND type in (N'U'))
BEGIN
CREATE TABLE [item].[Item](
	[id] [uniqueidentifier] NOT NULL,
	[code] [varchar](50) NOT NULL,
	[itemTypeId] [uniqueidentifier] NOT NULL,
	[name] [nvarchar](200) NOT NULL,
	[defaultPrice] [decimal](16, 2) NOT NULL,
	[unitId] [uniqueidentifier] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[vatRateId] [uniqueidentifier] NOT NULL,
	[creationDate] [datetime] NULL,
	[modificationDate] [datetime] NULL,
	[modificationUserId] [uniqueidentifier] NULL,
	[creationUserId] [uniqueidentifier] NULL,
	[visible] [bit] NULL,
	[itemGroup] [nvarchar](1000) NULL,
 CONSTRAINT [PK_item.item] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[Item]') AND name = N'ind_Item_VatRate')
CREATE NONCLUSTERED INDEX [ind_Item_VatRate] ON [item].[Item]
(
	[vatRateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[Item]') AND name = N'ind_Item_version')
CREATE NONCLUSTERED INDEX [ind_Item_version] ON [item].[Item]
(
	[version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[Item]') AND name = N'indItem_codeId')
CREATE NONCLUSTERED INDEX [indItem_codeId] ON [item].[Item]
(
	[code] ASC,
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[Item]') AND name = N'indItem_itemTypeId')
CREATE NONCLUSTERED INDEX [indItem_itemTypeId] ON [item].[Item]
(
	[itemTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[Item]') AND name = N'indItem_unitId')
CREATE NONCLUSTERED INDEX [indItem_unitId] ON [item].[Item]
(
	[unitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[item].[DF__Item__visible__4C6202EE]') AND type = 'D')
BEGIN
ALTER TABLE [item].[Item] ADD  DEFAULT ((1)) FOR [visible]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_Item_ItemType]') AND parent_object_id = OBJECT_ID(N'[item].[Item]'))
ALTER TABLE [item].[Item]  WITH CHECK ADD  CONSTRAINT [FK_Item_ItemType] FOREIGN KEY([itemTypeId])
REFERENCES [dictionary].[ItemType] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_Item_ItemType]') AND parent_object_id = OBJECT_ID(N'[item].[Item]'))
ALTER TABLE [item].[Item] CHECK CONSTRAINT [FK_Item_ItemType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_Item_VatRate]') AND parent_object_id = OBJECT_ID(N'[item].[Item]'))
ALTER TABLE [item].[Item]  WITH CHECK ADD  CONSTRAINT [FK_Item_VatRate] FOREIGN KEY([vatRateId])
REFERENCES [dictionary].[VatRate] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_Item_VatRate]') AND parent_object_id = OBJECT_ID(N'[item].[Item]'))
ALTER TABLE [item].[Item] CHECK CONSTRAINT [FK_Item_VatRate]
GO

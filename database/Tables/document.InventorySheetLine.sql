/*
name=[document].[InventorySheetLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ElhvHt2pjAVUepb+s2SdXg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[InventorySheetLine]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[InventorySheetLine](
	[id] [uniqueidentifier] NOT NULL,
	[inventorySheetId] [uniqueidentifier] NOT NULL,
	[ordinalNumber] [int] NOT NULL,
	[itemId] [uniqueidentifier] NOT NULL,
	[systemQuantity] [numeric](18, 6) NOT NULL,
	[systemDate] [datetime] NOT NULL,
	[userQuantity] [numeric](18, 6) NULL,
	[userDate] [datetime] NULL,
	[description] [nvarchar](1000) NULL,
	[version] [uniqueidentifier] NOT NULL,
	[direction] [int] NOT NULL,
	[unitId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_InventorySheetLine] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[InventorySheetLine]') AND name = N'ind_InventorySheetLine_InventorySheet')
CREATE NONCLUSTERED INDEX [ind_InventorySheetLine_InventorySheet] ON [document].[InventorySheetLine]
(
	[inventorySheetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[InventorySheetLine]') AND name = N'ind_InventorySheetLine_Item')
CREATE NONCLUSTERED INDEX [ind_InventorySheetLine_Item] ON [document].[InventorySheetLine]
(
	[itemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_InventorySheetLine_InventorySheet]') AND parent_object_id = OBJECT_ID(N'[document].[InventorySheetLine]'))
ALTER TABLE [document].[InventorySheetLine]  WITH CHECK ADD  CONSTRAINT [FK_InventorySheetLine_InventorySheet] FOREIGN KEY([inventorySheetId])
REFERENCES [document].[InventorySheet] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_InventorySheetLine_InventorySheet]') AND parent_object_id = OBJECT_ID(N'[document].[InventorySheetLine]'))
ALTER TABLE [document].[InventorySheetLine] CHECK CONSTRAINT [FK_InventorySheetLine_InventorySheet]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_InventorySheetLine_Item]') AND parent_object_id = OBJECT_ID(N'[document].[InventorySheetLine]'))
ALTER TABLE [document].[InventorySheetLine]  WITH CHECK ADD  CONSTRAINT [FK_InventorySheetLine_Item] FOREIGN KEY([itemId])
REFERENCES [item].[Item] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_InventorySheetLine_Item]') AND parent_object_id = OBJECT_ID(N'[document].[InventorySheetLine]'))
ALTER TABLE [document].[InventorySheetLine] CHECK CONSTRAINT [FK_InventorySheetLine_Item]
GO

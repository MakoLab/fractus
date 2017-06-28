/*
name=[document].[InventoryDocumentHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
n+uFkwX63dxwelOy9TbQUA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[InventoryDocumentHeader]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[InventoryDocumentHeader](
	[id] [uniqueidentifier] NOT NULL,
	[number] [int] NOT NULL,
	[fullNumber] [nvarchar](50) NOT NULL,
	[seriesId] [uniqueidentifier] NOT NULL,
	[creationApplicationUserId] [uniqueidentifier] NOT NULL,
	[creationDate] [datetime] NOT NULL,
	[modificationApplicationUserId] [uniqueidentifier] NULL,
	[modificationDate] [datetime] NULL,
	[closureApplicationUserId] [uniqueidentifier] NULL,
	[closureDate] [datetime] NULL,
	[type] [nvarchar](200) NULL,
	[warehouseId] [uniqueidentifier] NULL,
	[header] [nvarchar](500) NULL,
	[footer] [nvarchar](500) NULL,
	[responsiblePersoncommission] [xml] NULL,
	[version] [uniqueidentifier] NOT NULL,
	[documentTypeId] [uniqueidentifier] NOT NULL,
	[status] [int] NOT NULL,
	[issueDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InventoryDocumentHeader] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[InventoryDocumentHeader]') AND name = N'ind_InventoryDocumentHeader_Series')
CREATE NONCLUSTERED INDEX [ind_InventoryDocumentHeader_Series] ON [document].[InventoryDocumentHeader]
(
	[seriesId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[InventoryDocumentHeader]') AND name = N'ind_InventoryDocumentHeader_Warehouse')
CREATE NONCLUSTERED INDEX [ind_InventoryDocumentHeader_Warehouse] ON [document].[InventoryDocumentHeader]
(
	[warehouseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[document].[DF__Inventory__statu__7D3A4473]') AND type = 'D')
BEGIN
ALTER TABLE [document].[InventoryDocumentHeader] ADD  DEFAULT ((0)) FOR [status]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_InventoryDocumentHeader_Series]') AND parent_object_id = OBJECT_ID(N'[document].[InventoryDocumentHeader]'))
ALTER TABLE [document].[InventoryDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_InventoryDocumentHeader_Series] FOREIGN KEY([seriesId])
REFERENCES [document].[Series] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_InventoryDocumentHeader_Series]') AND parent_object_id = OBJECT_ID(N'[document].[InventoryDocumentHeader]'))
ALTER TABLE [document].[InventoryDocumentHeader] CHECK CONSTRAINT [FK_InventoryDocumentHeader_Series]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_InventoryDocumentHeader_Warehouse]') AND parent_object_id = OBJECT_ID(N'[document].[InventoryDocumentHeader]'))
ALTER TABLE [document].[InventoryDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_InventoryDocumentHeader_Warehouse] FOREIGN KEY([warehouseId])
REFERENCES [dictionary].[Warehouse] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_InventoryDocumentHeader_Warehouse]') AND parent_object_id = OBJECT_ID(N'[document].[InventoryDocumentHeader]'))
ALTER TABLE [document].[InventoryDocumentHeader] CHECK CONSTRAINT [FK_InventoryDocumentHeader_Warehouse]
GO

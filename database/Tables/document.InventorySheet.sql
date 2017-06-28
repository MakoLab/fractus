/*
name=[document].[InventorySheet]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
TqLQP8f0Uwrtn9/KuJbhGQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[InventorySheet]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[InventorySheet](
	[id] [uniqueidentifier] NOT NULL,
	[inventoryDocumentHeaderId] [uniqueidentifier] NOT NULL,
	[ordinalNumber] [int] NOT NULL,
	[status] [int] NOT NULL,
	[creationApplicationUserId] [uniqueidentifier] NOT NULL,
	[creationDate] [datetime] NOT NULL,
	[modificationApplicationUserId] [uniqueidentifier] NULL,
	[modificationDate] [datetime] NULL,
	[closureApplicationUserId] [uniqueidentifier] NULL,
	[closureDate] [datetime] NULL,
	[version] [uniqueidentifier] NOT NULL,
	[warehouseId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_InventorySheet] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[InventorySheet]') AND name = N'ind_InventorySheet_ClosureApplicationUser')
CREATE NONCLUSTERED INDEX [ind_InventorySheet_ClosureApplicationUser] ON [document].[InventorySheet]
(
	[closureApplicationUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[InventorySheet]') AND name = N'ind_InventorySheet_CreationApplicationUser')
CREATE NONCLUSTERED INDEX [ind_InventorySheet_CreationApplicationUser] ON [document].[InventorySheet]
(
	[creationApplicationUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[InventorySheet]') AND name = N'ind_InventorySheet_InventoryDocumentHeader')
CREATE NONCLUSTERED INDEX [ind_InventorySheet_InventoryDocumentHeader] ON [document].[InventorySheet]
(
	[inventoryDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[InventorySheet]') AND name = N'ind_InventorySheet_ModificationApplicationUser')
CREATE NONCLUSTERED INDEX [ind_InventorySheet_ModificationApplicationUser] ON [document].[InventorySheet]
(
	[modificationApplicationUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_InventorySheet_ClosureApplicationUser]') AND parent_object_id = OBJECT_ID(N'[document].[InventorySheet]'))
ALTER TABLE [document].[InventorySheet]  WITH CHECK ADD  CONSTRAINT [FK_InventorySheet_ClosureApplicationUser] FOREIGN KEY([closureApplicationUserId])
REFERENCES [contractor].[ApplicationUser] ([contractorId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_InventorySheet_ClosureApplicationUser]') AND parent_object_id = OBJECT_ID(N'[document].[InventorySheet]'))
ALTER TABLE [document].[InventorySheet] CHECK CONSTRAINT [FK_InventorySheet_ClosureApplicationUser]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_InventorySheet_CreationApplicationUser]') AND parent_object_id = OBJECT_ID(N'[document].[InventorySheet]'))
ALTER TABLE [document].[InventorySheet]  WITH CHECK ADD  CONSTRAINT [FK_InventorySheet_CreationApplicationUser] FOREIGN KEY([creationApplicationUserId])
REFERENCES [contractor].[ApplicationUser] ([contractorId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_InventorySheet_CreationApplicationUser]') AND parent_object_id = OBJECT_ID(N'[document].[InventorySheet]'))
ALTER TABLE [document].[InventorySheet] CHECK CONSTRAINT [FK_InventorySheet_CreationApplicationUser]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_InventorySheet_InventoryDocumentHeader]') AND parent_object_id = OBJECT_ID(N'[document].[InventorySheet]'))
ALTER TABLE [document].[InventorySheet]  WITH CHECK ADD  CONSTRAINT [FK_InventorySheet_InventoryDocumentHeader] FOREIGN KEY([inventoryDocumentHeaderId])
REFERENCES [document].[InventoryDocumentHeader] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_InventorySheet_InventoryDocumentHeader]') AND parent_object_id = OBJECT_ID(N'[document].[InventorySheet]'))
ALTER TABLE [document].[InventorySheet] CHECK CONSTRAINT [FK_InventorySheet_InventoryDocumentHeader]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_InventorySheet_ModificationApplicationUser]') AND parent_object_id = OBJECT_ID(N'[document].[InventorySheet]'))
ALTER TABLE [document].[InventorySheet]  WITH CHECK ADD  CONSTRAINT [FK_InventorySheet_ModificationApplicationUser] FOREIGN KEY([modificationApplicationUserId])
REFERENCES [contractor].[ApplicationUser] ([contractorId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_InventorySheet_ModificationApplicationUser]') AND parent_object_id = OBJECT_ID(N'[document].[InventorySheet]'))
ALTER TABLE [document].[InventorySheet] CHECK CONSTRAINT [FK_InventorySheet_ModificationApplicationUser]
GO

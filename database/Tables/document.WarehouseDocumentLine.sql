/*
name=[document].[WarehouseDocumentLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
rDrvocbPVk8FD2lPJJpKLA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentLine]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[WarehouseDocumentLine](
	[id] [uniqueidentifier] NOT NULL,
	[warehouseDocumentHeaderId] [uniqueidentifier] NOT NULL,
	[direction] [int] NOT NULL,
	[itemId] [uniqueidentifier] NOT NULL,
	[warehouseId] [uniqueidentifier] NOT NULL,
	[unitId] [uniqueidentifier] NOT NULL,
	[quantity] [numeric](18, 6) NOT NULL,
	[price] [numeric](18, 2) NOT NULL,
	[value] [numeric](18, 2) NOT NULL,
	[incomeDate] [datetime] NULL,
	[outcomeDate] [datetime] NULL,
	[description] [nvarchar](500) SPARSE  NULL,
	[ordinalNumber] [int] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[isDistributed] [bit] NOT NULL,
	[previousIncomeWarehouseDocumentLineId] [uniqueidentifier] SPARSE  NULL,
	[correctedWarehouseDocumentLineId] [uniqueidentifier] SPARSE  NULL,
	[initialWarehouseDocumentLineId] [uniqueidentifier] SPARSE  NULL,
	[lineType] [int] NOT NULL,
 CONSTRAINT [PK_WarehouseDocumentLine] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentLine]') AND name = N'ind_WarehouseDocumentLine_correctedWarehouseDocumentLineId')
CREATE NONCLUSTERED INDEX [ind_WarehouseDocumentLine_correctedWarehouseDocumentLineId] ON [document].[WarehouseDocumentLine]
(
	[correctedWarehouseDocumentLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentLine]') AND name = N'ind_WarehouseDocumentLine_direction')
CREATE NONCLUSTERED INDEX [ind_WarehouseDocumentLine_direction] ON [document].[WarehouseDocumentLine]
(
	[direction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentLine]') AND name = N'ind_WarehouseDocumentLine_incomeDate')
CREATE NONCLUSTERED INDEX [ind_WarehouseDocumentLine_incomeDate] ON [document].[WarehouseDocumentLine]
(
	[incomeDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentLine]') AND name = N'ind_WarehouseDocumentLine_itemId')
CREATE NONCLUSTERED INDEX [ind_WarehouseDocumentLine_itemId] ON [document].[WarehouseDocumentLine]
(
	[itemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentLine]') AND name = N'ind_WarehouseDocumentLine_outcomeDate')
CREATE NONCLUSTERED INDEX [ind_WarehouseDocumentLine_outcomeDate] ON [document].[WarehouseDocumentLine]
(
	[outcomeDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentLine]') AND name = N'ind_WarehouseDocumentLine_unitId')
CREATE NONCLUSTERED INDEX [ind_WarehouseDocumentLine_unitId] ON [document].[WarehouseDocumentLine]
(
	[unitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentLine]') AND name = N'ind_WarehouseDocumentLine_warehouseDocumentHeaderId')
CREATE NONCLUSTERED INDEX [ind_WarehouseDocumentLine_warehouseDocumentHeaderId] ON [document].[WarehouseDocumentLine]
(
	[warehouseDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentLine]') AND name = N'ind_WarehouseDocumentLine_warehouseId')
CREATE NONCLUSTERED INDEX [ind_WarehouseDocumentLine_warehouseId] ON [document].[WarehouseDocumentLine]
(
	[warehouseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[document].[DF__Warehouse__lineT__0D5AD24C]') AND type = 'D')
BEGIN
ALTER TABLE [document].[WarehouseDocumentLine] ADD  CONSTRAINT [DF__Warehouse__lineT__0D5AD24C]  DEFAULT ((0)) FOR [lineType]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_WarehouseDocumentLine_WarehouseDocumentHeader]') AND parent_object_id = OBJECT_ID(N'[document].[WarehouseDocumentLine]'))
ALTER TABLE [document].[WarehouseDocumentLine]  WITH CHECK ADD  CONSTRAINT [FK_WarehouseDocumentLine_WarehouseDocumentHeader] FOREIGN KEY([warehouseDocumentHeaderId])
REFERENCES [document].[WarehouseDocumentHeader] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_WarehouseDocumentLine_WarehouseDocumentHeader]') AND parent_object_id = OBJECT_ID(N'[document].[WarehouseDocumentLine]'))
ALTER TABLE [document].[WarehouseDocumentLine] CHECK CONSTRAINT [FK_WarehouseDocumentLine_WarehouseDocumentHeader]
GO

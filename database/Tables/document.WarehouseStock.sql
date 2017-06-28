/*
name=[document].[WarehouseStock]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
eC0OLy6imnNKR/+e9wcYGw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[WarehouseStock]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[WarehouseStock](
	[id] [uniqueidentifier] NOT NULL,
	[warehouseId] [uniqueidentifier] NOT NULL,
	[itemId] [uniqueidentifier] NOT NULL,
	[unitId] [uniqueidentifier] NOT NULL,
	[quantity] [numeric](18, 6) NOT NULL,
	[reservedQuantity] [numeric](18, 6) NULL,
	[orderedQuantity] [numeric](18, 6) NULL,
	[isBlocked] [int] NULL,
	[lastPurchaseNetPrice] [numeric](18, 2) NULL,
	[lastPurchaseIssueDate] [datetime] NULL,
 CONSTRAINT [PK_WarehouseStock] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseStock]') AND name = N'ind_WarehouseStock_itemId_warehouseId')
CREATE UNIQUE NONCLUSTERED INDEX [ind_WarehouseStock_itemId_warehouseId] ON [document].[WarehouseStock]
(
	[warehouseId] ASC,
	[itemId] ASC,
	[unitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseStock]') AND name = N'indWarehouseStock_itemId')
CREATE NONCLUSTERED INDEX [indWarehouseStock_itemId] ON [document].[WarehouseStock]
(
	[itemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseStock]') AND name = N'indWarehouseStock_unitId')
CREATE NONCLUSTERED INDEX [indWarehouseStock_unitId] ON [document].[WarehouseStock]
(
	[unitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseStock]') AND name = N'indWarehouseStock_warehouseId')
CREATE NONCLUSTERED INDEX [indWarehouseStock_warehouseId] ON [document].[WarehouseStock]
(
	[warehouseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[document].[DF_WarehouseStock_id]') AND type = 'D')
BEGIN
ALTER TABLE [document].[WarehouseStock] ADD  CONSTRAINT [DF_WarehouseStock_id]  DEFAULT (newid()) FOR [id]
END

GO

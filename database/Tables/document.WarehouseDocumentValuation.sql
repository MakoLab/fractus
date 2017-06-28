/*
name=[document].[WarehouseDocumentValuation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
hO+WtYBfIsdjINiMBZzXmA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentValuation]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[WarehouseDocumentValuation](
	[id] [uniqueidentifier] NOT NULL,
	[incomeWarehouseDocumentLineId] [uniqueidentifier] NOT NULL,
	[outcomeWarehouseDocumentLineId] [uniqueidentifier] NOT NULL,
	[valuationId] [uniqueidentifier] NOT NULL,
	[quantity] [numeric](18, 2) NOT NULL,
	[incomePrice] [numeric](18, 2) NOT NULL,
	[incomeValue] [numeric](18, 2) NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_WarehouseDocumentValuation] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentValuation]') AND name = N'ind_ind_WarehouseDocumentValuation_valuationId')
CREATE NONCLUSTERED INDEX [ind_ind_WarehouseDocumentValuation_valuationId] ON [document].[WarehouseDocumentValuation]
(
	[valuationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentValuation]') AND name = N'ind_WarehouseDocumentValuation_incomeWarehouseDocumentLineId')
CREATE NONCLUSTERED INDEX [ind_WarehouseDocumentValuation_incomeWarehouseDocumentLineId] ON [document].[WarehouseDocumentValuation]
(
	[incomeWarehouseDocumentLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentValuation]') AND name = N'ind_WarehouseDocumentValuation_outcomeWarehouseDocumentLineId')
CREATE NONCLUSTERED INDEX [ind_WarehouseDocumentValuation_outcomeWarehouseDocumentLineId] ON [document].[WarehouseDocumentValuation]
(
	[outcomeWarehouseDocumentLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

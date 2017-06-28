/*
name=[document].[CommercialWarehouseValuation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
DFEbKAPTBlYZaAWIoZhrhA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[CommercialWarehouseValuation]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[CommercialWarehouseValuation](
	[id] [uniqueidentifier] NOT NULL,
	[commercialDocumentLineId] [uniqueidentifier] SPARSE  NULL,
	[warehouseDocumentLineId] [uniqueidentifier] NULL,
	[quantity] [numeric](18, 6) NOT NULL,
	[value] [numeric](18, 2) NOT NULL,
	[price] [numeric](18, 2) NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_CommercialWarehouseValuation] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialWarehouseValuation]') AND name = N'indCommercialWarehouseValuation_commercialDocumentLineId')
CREATE NONCLUSTERED INDEX [indCommercialWarehouseValuation_commercialDocumentLineId] ON [document].[CommercialWarehouseValuation]
(
	[commercialDocumentLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialWarehouseValuation]') AND name = N'indCommercialWarehouseValuation_warehouseDocumentLineId')
CREATE NONCLUSTERED INDEX [indCommercialWarehouseValuation_warehouseDocumentLineId] ON [document].[CommercialWarehouseValuation]
(
	[warehouseDocumentLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_CommercialWarehouseValuation_WarehouseDocumentLine]') AND parent_object_id = OBJECT_ID(N'[document].[CommercialWarehouseValuation]'))
ALTER TABLE [document].[CommercialWarehouseValuation]  WITH CHECK ADD  CONSTRAINT [FK_CommercialWarehouseValuation_WarehouseDocumentLine] FOREIGN KEY([warehouseDocumentLineId])
REFERENCES [document].[WarehouseDocumentLine] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_CommercialWarehouseValuation_WarehouseDocumentLine]') AND parent_object_id = OBJECT_ID(N'[document].[CommercialWarehouseValuation]'))
ALTER TABLE [document].[CommercialWarehouseValuation] CHECK CONSTRAINT [FK_CommercialWarehouseValuation_WarehouseDocumentLine]
GO

/*
name=[document].[CommercialWarehouseRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
39C9DoUk46jOw42M+IkFvw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[CommercialWarehouseRelation]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[CommercialWarehouseRelation](
	[id] [uniqueidentifier] NOT NULL,
	[commercialDocumentLineId] [uniqueidentifier] NOT NULL,
	[warehouseDocumentLineId] [uniqueidentifier] NOT NULL,
	[quantity] [numeric](18, 6) NOT NULL,
	[value] [numeric](18, 2) NOT NULL,
	[isValuated] [bit] NOT NULL,
	[isOrderRelation] [bit] NOT NULL,
	[isCommercialRelation] [bit] NOT NULL,
	[isServiceRelation] [bit] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_CommercialWarehouseRelation] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialWarehouseRelation]') AND name = N'ind_CommercialWarehouseRelation_commercialDocumentLine')
CREATE NONCLUSTERED INDEX [ind_CommercialWarehouseRelation_commercialDocumentLine] ON [document].[CommercialWarehouseRelation]
(
	[commercialDocumentLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialWarehouseRelation]') AND name = N'ind_CommercialWarehouseRelation_warehouseDocumentLine')
CREATE NONCLUSTERED INDEX [ind_CommercialWarehouseRelation_warehouseDocumentLine] ON [document].[CommercialWarehouseRelation]
(
	[warehouseDocumentLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_CommercialWarehouseRealtion_WarehouseDocumentLine]') AND parent_object_id = OBJECT_ID(N'[document].[CommercialWarehouseRelation]'))
ALTER TABLE [document].[CommercialWarehouseRelation]  WITH CHECK ADD  CONSTRAINT [FK_CommercialWarehouseRealtion_WarehouseDocumentLine] FOREIGN KEY([warehouseDocumentLineId])
REFERENCES [document].[WarehouseDocumentLine] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_CommercialWarehouseRealtion_WarehouseDocumentLine]') AND parent_object_id = OBJECT_ID(N'[document].[CommercialWarehouseRelation]'))
ALTER TABLE [document].[CommercialWarehouseRelation] CHECK CONSTRAINT [FK_CommercialWarehouseRealtion_WarehouseDocumentLine]
GO

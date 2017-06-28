/*
name=[document].[CommercialDocumentLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JdGcNN4b2ZT1J7f5xE9oXg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentLine]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[CommercialDocumentLine](
	[id] [uniqueidentifier] NOT NULL,
	[commercialDocumentHeaderId] [uniqueidentifier] NOT NULL,
	[ordinalNumber] [int] NOT NULL,
	[commercialDirection] [int] NULL,
	[orderDirection] [int] NULL,
	[unitId] [uniqueidentifier] NOT NULL,
	[itemId] [uniqueidentifier] NOT NULL,
	[warehouseId] [uniqueidentifier] NULL,
	[itemVersion] [uniqueidentifier] NOT NULL,
	[quantity] [numeric](18, 6) NOT NULL,
	[netPrice] [numeric](18, 2) NOT NULL,
	[grossPrice] [numeric](18, 2) NOT NULL,
	[initialNetPrice] [numeric](18, 2) NOT NULL,
	[initialGrossPrice] [numeric](18, 2) NOT NULL,
	[discountRate] [decimal](18, 2) NOT NULL,
	[discountNetValue] [numeric](18, 2) NOT NULL,
	[discountGrossValue] [numeric](18, 2) NOT NULL,
	[initialNetValue] [numeric](18, 2) NOT NULL,
	[initialGrossValue] [numeric](18, 2) NOT NULL,
	[netValue] [numeric](18, 2) NOT NULL,
	[grossValue] [numeric](18, 2) NOT NULL,
	[vatValue] [numeric](18, 2) NOT NULL,
	[vatRateId] [uniqueidentifier] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[correctedCommercialDocumentLineId] [uniqueidentifier] SPARSE  NULL,
	[initialCommercialDocumentLineId] [uniqueidentifier] SPARSE  NULL,
	[itemName] [nvarchar](500) NOT NULL,
	[sysNetValue] [numeric](18, 2) NULL,
	[sysGrossValue] [numeric](18, 2) NULL,
	[sysVatValue] [numeric](18, 2) NULL,
 CONSTRAINT [PK_CommercialDocumentLine] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentLine]') AND name = N'ind_CommercialDocumentLine_CorrectedCommercialDocumentLine')
CREATE NONCLUSTERED INDEX [ind_CommercialDocumentLine_CorrectedCommercialDocumentLine] ON [document].[CommercialDocumentLine]
(
	[correctedCommercialDocumentLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentLine]') AND name = N'indCommercialDocumentLine_commercialDocumentHeaderId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentLine_commercialDocumentHeaderId] ON [document].[CommercialDocumentLine]
(
	[commercialDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentLine]') AND name = N'indCommercialDocumentLine_initialCommercialDocumentLineId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentLine_initialCommercialDocumentLineId] ON [document].[CommercialDocumentLine]
(
	[initialCommercialDocumentLineId] ASC
)
INCLUDE ( 	[commercialDocumentHeaderId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentLine]') AND name = N'indCommercialDocumentLine_itemId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentLine_itemId] ON [document].[CommercialDocumentLine]
(
	[itemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentLine]') AND name = N'indCommercialDocumentLine_vatRateId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentLine_vatRateId] ON [document].[CommercialDocumentLine]
(
	[vatRateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentLine]') AND name = N'indCommercialDocumentLine_warehouseId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentLine_warehouseId] ON [document].[CommercialDocumentLine]
(
	[warehouseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_CommercialDocumentLine_CorrectedCommercialDocumentLine]') AND parent_object_id = OBJECT_ID(N'[document].[CommercialDocumentLine]'))
ALTER TABLE [document].[CommercialDocumentLine]  WITH NOCHECK ADD  CONSTRAINT [FK_CommercialDocumentLine_CorrectedCommercialDocumentLine] FOREIGN KEY([correctedCommercialDocumentLineId])
REFERENCES [document].[CommercialDocumentLine] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_CommercialDocumentLine_CorrectedCommercialDocumentLine]') AND parent_object_id = OBJECT_ID(N'[document].[CommercialDocumentLine]'))
ALTER TABLE [document].[CommercialDocumentLine] CHECK CONSTRAINT [FK_CommercialDocumentLine_CorrectedCommercialDocumentLine]
GO

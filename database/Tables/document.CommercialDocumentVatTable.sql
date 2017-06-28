/*
name=[document].[CommercialDocumentVatTable]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4luAR0bYglCVRYTyJbwtBQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentVatTable]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[CommercialDocumentVatTable](
	[id] [uniqueidentifier] NOT NULL,
	[commercialDocumentHeaderId] [uniqueidentifier] NOT NULL,
	[vatRateId] [uniqueidentifier] NOT NULL,
	[netValue] [numeric](18, 2) NOT NULL,
	[grossValue] [numeric](18, 2) NOT NULL,
	[vatValue] [numeric](18, 2) NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
 CONSTRAINT [PK_CommercialDocumentVatTable] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentVatTable]') AND name = N'indCommercialDocumentVatTable_commercialDocumentHeaderId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentVatTable_commercialDocumentHeaderId] ON [document].[CommercialDocumentVatTable]
(
	[commercialDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentVatTable]') AND name = N'indCommercialDocumentVatTable_vatRateId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentVatTable_vatRateId] ON [document].[CommercialDocumentVatTable]
(
	[vatRateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_CommercialDocumentVatTable_CommercialDocumentHeader]') AND parent_object_id = OBJECT_ID(N'[document].[CommercialDocumentVatTable]'))
ALTER TABLE [document].[CommercialDocumentVatTable]  WITH CHECK ADD  CONSTRAINT [FK_CommercialDocumentVatTable_CommercialDocumentHeader] FOREIGN KEY([commercialDocumentHeaderId])
REFERENCES [document].[CommercialDocumentHeader] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_CommercialDocumentVatTable_CommercialDocumentHeader]') AND parent_object_id = OBJECT_ID(N'[document].[CommercialDocumentVatTable]'))
ALTER TABLE [document].[CommercialDocumentVatTable] CHECK CONSTRAINT [FK_CommercialDocumentVatTable_CommercialDocumentHeader]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_CommercialDocumentVatTable_VatRate]') AND parent_object_id = OBJECT_ID(N'[document].[CommercialDocumentVatTable]'))
ALTER TABLE [document].[CommercialDocumentVatTable]  WITH CHECK ADD  CONSTRAINT [FK_CommercialDocumentVatTable_VatRate] FOREIGN KEY([vatRateId])
REFERENCES [dictionary].[VatRate] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_CommercialDocumentVatTable_VatRate]') AND parent_object_id = OBJECT_ID(N'[document].[CommercialDocumentVatTable]'))
ALTER TABLE [document].[CommercialDocumentVatTable] CHECK CONSTRAINT [FK_CommercialDocumentVatTable_VatRate]
GO

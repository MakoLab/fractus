/*
name=[document].[DocumentRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
qWV627SLKolNuzBtvzKKVw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[DocumentRelation]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[DocumentRelation](
	[id] [uniqueidentifier] NOT NULL,
	[firstCommercialDocumentHeaderId] [uniqueidentifier] NULL,
	[secondCommercialDocumentHeaderId] [uniqueidentifier] NULL,
	[firstWarehouseDocumentHeaderId] [uniqueidentifier] NULL,
	[secondWarehouseDocumentHeaderId] [uniqueidentifier] NULL,
	[firstFinancialDocumentHeaderId] [uniqueidentifier] NULL,
	[secondFinancialDocumentHeaderId] [uniqueidentifier] NULL,
	[relationType] [int] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[firstComplaintDocumentHeaderId] [uniqueidentifier] NULL,
	[secondComplaintDocumentHeaderId] [uniqueidentifier] NULL,
	[firstInventoryDocumentHeaderId] [uniqueidentifier] NULL,
	[secondInventoryDocumentHeaderId] [uniqueidentifier] NULL,
	[decimalValue] [decimal](18, 6) NULL,
	[xmlValue] [xml] NULL,
 CONSTRAINT [PK_DocumentRelation] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[DocumentRelation]') AND name = N'ind_DocumentRelation_CommercialDocumentHeader_first')
CREATE NONCLUSTERED INDEX [ind_DocumentRelation_CommercialDocumentHeader_first] ON [document].[DocumentRelation]
(
	[firstCommercialDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[DocumentRelation]') AND name = N'ind_DocumentRelation_CommercialDocumentHeader_second')
CREATE NONCLUSTERED INDEX [ind_DocumentRelation_CommercialDocumentHeader_second] ON [document].[DocumentRelation]
(
	[secondCommercialDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[DocumentRelation]') AND name = N'ind_DocumentRelation_FinancialDocumentHeader_first')
CREATE NONCLUSTERED INDEX [ind_DocumentRelation_FinancialDocumentHeader_first] ON [document].[DocumentRelation]
(
	[firstFinancialDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[DocumentRelation]') AND name = N'ind_DocumentRelation_FinancialDocumentHeader_second')
CREATE NONCLUSTERED INDEX [ind_DocumentRelation_FinancialDocumentHeader_second] ON [document].[DocumentRelation]
(
	[secondFinancialDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[DocumentRelation]') AND name = N'ind_DocumentRelation_WarehouseDocumentHeader_first')
CREATE NONCLUSTERED INDEX [ind_DocumentRelation_WarehouseDocumentHeader_first] ON [document].[DocumentRelation]
(
	[firstWarehouseDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[DocumentRelation]') AND name = N'ind_DocumentRelation_WarehouseDocumentHeader_second')
CREATE NONCLUSTERED INDEX [ind_DocumentRelation_WarehouseDocumentHeader_second] ON [document].[DocumentRelation]
(
	[secondWarehouseDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentRelation_CommercialDocumentHeader_first]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentRelation]'))
ALTER TABLE [document].[DocumentRelation]  WITH CHECK ADD  CONSTRAINT [FK_DocumentRelation_CommercialDocumentHeader_first] FOREIGN KEY([firstCommercialDocumentHeaderId])
REFERENCES [document].[CommercialDocumentHeader] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentRelation_CommercialDocumentHeader_first]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentRelation]'))
ALTER TABLE [document].[DocumentRelation] CHECK CONSTRAINT [FK_DocumentRelation_CommercialDocumentHeader_first]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentRelation_CommercialDocumentHeader_second]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentRelation]'))
ALTER TABLE [document].[DocumentRelation]  WITH CHECK ADD  CONSTRAINT [FK_DocumentRelation_CommercialDocumentHeader_second] FOREIGN KEY([secondCommercialDocumentHeaderId])
REFERENCES [document].[CommercialDocumentHeader] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentRelation_CommercialDocumentHeader_second]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentRelation]'))
ALTER TABLE [document].[DocumentRelation] CHECK CONSTRAINT [FK_DocumentRelation_CommercialDocumentHeader_second]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentRelation_FinancialDocumentHeader_first]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentRelation]'))
ALTER TABLE [document].[DocumentRelation]  WITH CHECK ADD  CONSTRAINT [FK_DocumentRelation_FinancialDocumentHeader_first] FOREIGN KEY([firstFinancialDocumentHeaderId])
REFERENCES [document].[FinancialDocumentHeader] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentRelation_FinancialDocumentHeader_first]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentRelation]'))
ALTER TABLE [document].[DocumentRelation] CHECK CONSTRAINT [FK_DocumentRelation_FinancialDocumentHeader_first]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentRelation_FinancialDocumentHeader_second]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentRelation]'))
ALTER TABLE [document].[DocumentRelation]  WITH CHECK ADD  CONSTRAINT [FK_DocumentRelation_FinancialDocumentHeader_second] FOREIGN KEY([secondFinancialDocumentHeaderId])
REFERENCES [document].[FinancialDocumentHeader] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentRelation_FinancialDocumentHeader_second]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentRelation]'))
ALTER TABLE [document].[DocumentRelation] CHECK CONSTRAINT [FK_DocumentRelation_FinancialDocumentHeader_second]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentRelation_WarehouseDocumentHeader_first]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentRelation]'))
ALTER TABLE [document].[DocumentRelation]  WITH CHECK ADD  CONSTRAINT [FK_DocumentRelation_WarehouseDocumentHeader_first] FOREIGN KEY([firstWarehouseDocumentHeaderId])
REFERENCES [document].[WarehouseDocumentHeader] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentRelation_WarehouseDocumentHeader_first]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentRelation]'))
ALTER TABLE [document].[DocumentRelation] CHECK CONSTRAINT [FK_DocumentRelation_WarehouseDocumentHeader_first]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentRelation_WarehouseDocumentHeader_second]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentRelation]'))
ALTER TABLE [document].[DocumentRelation]  WITH CHECK ADD  CONSTRAINT [FK_DocumentRelation_WarehouseDocumentHeader_second] FOREIGN KEY([secondWarehouseDocumentHeaderId])
REFERENCES [document].[WarehouseDocumentHeader] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentRelation_WarehouseDocumentHeader_second]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentRelation]'))
ALTER TABLE [document].[DocumentRelation] CHECK CONSTRAINT [FK_DocumentRelation_WarehouseDocumentHeader_second]
GO

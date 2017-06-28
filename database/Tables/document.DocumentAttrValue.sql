/*
name=[document].[DocumentAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
mK7V6Rac/Mn7ENb0ybC0IQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[DocumentAttrValue]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[DocumentAttrValue](
	[id] [uniqueidentifier] NOT NULL,
	[commercialDocumentHeaderId] [uniqueidentifier] NULL,
	[warehouseDocumentHeaderId] [uniqueidentifier] NULL,
	[documentFieldId] [uniqueidentifier] NOT NULL,
	[decimalValue] [decimal](18, 4) NULL,
	[dateValue] [datetime] NULL,
	[textValue] [nvarchar](500) NULL,
	[xmlValue] [xml] NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
	[financialDocumentHeaderId] [uniqueidentifier] NULL,
	[complaintDocumentHeaderId] [uniqueidentifier] NULL,
	[inventoryDocumentHeaderId] [uniqueidentifier] NULL,
	[offerId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_DocumentAttrValue] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[DocumentAttrValue]') AND name = N'indDocumentAttrValue_commercialDocumentHeaderId')
CREATE NONCLUSTERED INDEX [indDocumentAttrValue_commercialDocumentHeaderId] ON [document].[DocumentAttrValue]
(
	[commercialDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[DocumentAttrValue]') AND name = N'indDocumentAttrValue_documentFieldId')
CREATE NONCLUSTERED INDEX [indDocumentAttrValue_documentFieldId] ON [document].[DocumentAttrValue]
(
	[documentFieldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[DocumentAttrValue]') AND name = N'indDocumentAttrValue_financialDocumentHeaderId')
CREATE NONCLUSTERED INDEX [indDocumentAttrValue_financialDocumentHeaderId] ON [document].[DocumentAttrValue]
(
	[financialDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[DocumentAttrValue]') AND name = N'indDocumentAttrValue_textValue')
CREATE NONCLUSTERED INDEX [indDocumentAttrValue_textValue] ON [document].[DocumentAttrValue]
(
	[textValue] ASC
)
WHERE ([documentFieldId]='FABD4984-29E1-4534-8755-2E5F4DFE0A62')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[DocumentAttrValue]') AND name = N'indDocumentAttrValue_warehouseDocumentHeaderId')
CREATE NONCLUSTERED INDEX [indDocumentAttrValue_warehouseDocumentHeaderId] ON [document].[DocumentAttrValue]
(
	[warehouseDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentAttrValue_CommercialDocumentHeader]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentAttrValue]'))
ALTER TABLE [document].[DocumentAttrValue]  WITH CHECK ADD  CONSTRAINT [FK_DocumentAttrValue_CommercialDocumentHeader] FOREIGN KEY([commercialDocumentHeaderId])
REFERENCES [document].[CommercialDocumentHeader] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentAttrValue_CommercialDocumentHeader]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentAttrValue]'))
ALTER TABLE [document].[DocumentAttrValue] CHECK CONSTRAINT [FK_DocumentAttrValue_CommercialDocumentHeader]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentAttrValue_DocumentField]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentAttrValue]'))
ALTER TABLE [document].[DocumentAttrValue]  WITH CHECK ADD  CONSTRAINT [FK_DocumentAttrValue_DocumentField] FOREIGN KEY([documentFieldId])
REFERENCES [dictionary].[DocumentField] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentAttrValue_DocumentField]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentAttrValue]'))
ALTER TABLE [document].[DocumentAttrValue] CHECK CONSTRAINT [FK_DocumentAttrValue_DocumentField]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentAttrValue_FinancialDocumentHeader]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentAttrValue]'))
ALTER TABLE [document].[DocumentAttrValue]  WITH CHECK ADD  CONSTRAINT [FK_DocumentAttrValue_FinancialDocumentHeader] FOREIGN KEY([financialDocumentHeaderId])
REFERENCES [document].[FinancialDocumentHeader] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentAttrValue_FinancialDocumentHeader]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentAttrValue]'))
ALTER TABLE [document].[DocumentAttrValue] CHECK CONSTRAINT [FK_DocumentAttrValue_FinancialDocumentHeader]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentAttrValue_WarehouseDocumentHeader]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentAttrValue]'))
ALTER TABLE [document].[DocumentAttrValue]  WITH CHECK ADD  CONSTRAINT [FK_DocumentAttrValue_WarehouseDocumentHeader] FOREIGN KEY([warehouseDocumentHeaderId])
REFERENCES [document].[WarehouseDocumentHeader] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentAttrValue_WarehouseDocumentHeader]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentAttrValue]'))
ALTER TABLE [document].[DocumentAttrValue] CHECK CONSTRAINT [FK_DocumentAttrValue_WarehouseDocumentHeader]
GO

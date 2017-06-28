/*
name=[document].[DocumentLineAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
bamjLXfIqNpjXeAJakTRpA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[DocumentLineAttrValue]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[DocumentLineAttrValue](
	[id] [uniqueidentifier] NOT NULL,
	[commercialDocumentLineId] [uniqueidentifier] NULL,
	[warehouseDocumentLineId] [uniqueidentifier] NULL,
	[financialDocumentLineId] [uniqueidentifier] NULL,
	[documentFieldId] [uniqueidentifier] NOT NULL,
	[decimalValue] [decimal](18, 4) NULL,
	[dateValue] [datetime] NULL,
	[textValue] [nvarchar](500) NULL,
	[xmlValue] [xml] NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
	[guidValue] [uniqueidentifier] NULL,
	[offerLineId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_DocumentLineAttrValue] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[DocumentLineAttrValue]') AND name = N'ind_DocumentLineAttrValue_CommercialDocumentLine')
CREATE NONCLUSTERED INDEX [ind_DocumentLineAttrValue_CommercialDocumentLine] ON [document].[DocumentLineAttrValue]
(
	[commercialDocumentLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[DocumentLineAttrValue]') AND name = N'ind_DocumentLineAttrValue_DocumentField')
CREATE NONCLUSTERED INDEX [ind_DocumentLineAttrValue_DocumentField] ON [document].[DocumentLineAttrValue]
(
	[documentFieldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[DocumentLineAttrValue]') AND name = N'ind_DocumentLineAttrValue_guidValue')
CREATE NONCLUSTERED INDEX [ind_DocumentLineAttrValue_guidValue] ON [document].[DocumentLineAttrValue]
(
	[guidValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[DocumentLineAttrValue]') AND name = N'ind_DocumentLineAttrValue_WarehouseDocumentLine')
CREATE NONCLUSTERED INDEX [ind_DocumentLineAttrValue_WarehouseDocumentLine] ON [document].[DocumentLineAttrValue]
(
	[warehouseDocumentLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentLineAttrValue_CommercialDocumentLine]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentLineAttrValue]'))
ALTER TABLE [document].[DocumentLineAttrValue]  WITH CHECK ADD  CONSTRAINT [FK_DocumentLineAttrValue_CommercialDocumentLine] FOREIGN KEY([commercialDocumentLineId])
REFERENCES [document].[CommercialDocumentLine] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentLineAttrValue_CommercialDocumentLine]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentLineAttrValue]'))
ALTER TABLE [document].[DocumentLineAttrValue] CHECK CONSTRAINT [FK_DocumentLineAttrValue_CommercialDocumentLine]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentLineAttrValue_DocumentField]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentLineAttrValue]'))
ALTER TABLE [document].[DocumentLineAttrValue]  WITH CHECK ADD  CONSTRAINT [FK_DocumentLineAttrValue_DocumentField] FOREIGN KEY([documentFieldId])
REFERENCES [dictionary].[DocumentField] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentLineAttrValue_DocumentField]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentLineAttrValue]'))
ALTER TABLE [document].[DocumentLineAttrValue] CHECK CONSTRAINT [FK_DocumentLineAttrValue_DocumentField]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentLineAttrValue_WarehouseDocumentLine]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentLineAttrValue]'))
ALTER TABLE [document].[DocumentLineAttrValue]  WITH CHECK ADD  CONSTRAINT [FK_DocumentLineAttrValue_WarehouseDocumentLine] FOREIGN KEY([warehouseDocumentLineId])
REFERENCES [document].[WarehouseDocumentLine] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_DocumentLineAttrValue_WarehouseDocumentLine]') AND parent_object_id = OBJECT_ID(N'[document].[DocumentLineAttrValue]'))
ALTER TABLE [document].[DocumentLineAttrValue] CHECK CONSTRAINT [FK_DocumentLineAttrValue_WarehouseDocumentLine]
GO

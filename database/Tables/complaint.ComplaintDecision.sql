/*
name=[complaint].[ComplaintDecision]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
OvPZLqmU55PCp766HB7LAQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[ComplaintDecision]') AND type in (N'U'))
BEGIN
CREATE TABLE [complaint].[ComplaintDecision](
	[id] [uniqueidentifier] NOT NULL,
	[complaintDocumentLineId] [uniqueidentifier] NOT NULL,
	[issueDate] [datetime] NOT NULL,
	[issuingPersonContractorId] [uniqueidentifier] NOT NULL,
	[replacementItemId] [uniqueidentifier] NULL,
	[replacementItemName] [nvarchar](500) NOT NULL,
	[warehouseId] [uniqueidentifier] NULL,
	[quantity] [numeric](18, 6) NOT NULL,
	[decisionText] [nvarchar](2000) NULL,
	[decisionType] [int] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
	[realizeOption] [int] NOT NULL,
	[replacementUnitId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ComplaintDecision] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[complaint].[ComplaintDecision]') AND name = N'ind_ComplaintDecision_complaintDocumentLine')
CREATE NONCLUSTERED INDEX [ind_ComplaintDecision_complaintDocumentLine] ON [complaint].[ComplaintDecision]
(
	[complaintDocumentLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[complaint].[ComplaintDecision]') AND name = N'ind_ComplaintDecision_issuingPersonContractor')
CREATE NONCLUSTERED INDEX [ind_ComplaintDecision_issuingPersonContractor] ON [complaint].[ComplaintDecision]
(
	[issuingPersonContractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[complaint].[ComplaintDecision]') AND name = N'ind_ComplaintDecision_replacementItem')
CREATE NONCLUSTERED INDEX [ind_ComplaintDecision_replacementItem] ON [complaint].[ComplaintDecision]
(
	[replacementItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDecision_complaintDocumentLine]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDecision]'))
ALTER TABLE [complaint].[ComplaintDecision]  WITH CHECK ADD  CONSTRAINT [FK_ComplaintDecision_complaintDocumentLine] FOREIGN KEY([complaintDocumentLineId])
REFERENCES [complaint].[ComplaintDocumentLine] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDecision_complaintDocumentLine]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDecision]'))
ALTER TABLE [complaint].[ComplaintDecision] CHECK CONSTRAINT [FK_ComplaintDecision_complaintDocumentLine]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDecision_issuingPersonContractor]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDecision]'))
ALTER TABLE [complaint].[ComplaintDecision]  WITH CHECK ADD  CONSTRAINT [FK_ComplaintDecision_issuingPersonContractor] FOREIGN KEY([issuingPersonContractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDecision_issuingPersonContractor]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDecision]'))
ALTER TABLE [complaint].[ComplaintDecision] CHECK CONSTRAINT [FK_ComplaintDecision_issuingPersonContractor]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDecision_replacementItem]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDecision]'))
ALTER TABLE [complaint].[ComplaintDecision]  WITH CHECK ADD  CONSTRAINT [FK_ComplaintDecision_replacementItem] FOREIGN KEY([replacementItemId])
REFERENCES [item].[Item] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDecision_replacementItem]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDecision]'))
ALTER TABLE [complaint].[ComplaintDecision] CHECK CONSTRAINT [FK_ComplaintDecision_replacementItem]
GO

/*
name=[complaint].[ComplaintDocumentLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
CGBzGGfQUtRnOS8VKk3IQw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentLine]') AND type in (N'U'))
BEGIN
CREATE TABLE [complaint].[ComplaintDocumentLine](
	[id] [uniqueidentifier] NOT NULL,
	[complaintDocumentHeaderId] [uniqueidentifier] NOT NULL,
	[itemId] [uniqueidentifier] NOT NULL,
	[itemName] [nvarchar](500) NOT NULL,
	[quantity] [numeric](18, 6) NOT NULL,
	[remarks] [nvarchar](2000) NULL,
	[issueDate] [datetime] NOT NULL,
	[issuingPersonContractorId] [uniqueidentifier] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[ordinalNumber] [int] NOT NULL,
	[unitId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ComplaintDocumentLine] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentLine]') AND name = N'ind_ComplaintDocumentLine_complaintDocumentHeader')
CREATE NONCLUSTERED INDEX [ind_ComplaintDocumentLine_complaintDocumentHeader] ON [complaint].[ComplaintDocumentLine]
(
	[complaintDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentLine]') AND name = N'ind_ComplaintDocumentLine_issuingPersonContractor')
CREATE NONCLUSTERED INDEX [ind_ComplaintDocumentLine_issuingPersonContractor] ON [complaint].[ComplaintDocumentLine]
(
	[issuingPersonContractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentLine]') AND name = N'ind_ComplaintDocumentLine_item')
CREATE NONCLUSTERED INDEX [ind_ComplaintDocumentLine_item] ON [complaint].[ComplaintDocumentLine]
(
	[itemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[complaint].[DF__Complaint__unitI__7B51FC01]') AND type = 'D')
BEGIN
ALTER TABLE [complaint].[ComplaintDocumentLine] ADD  DEFAULT ('2EC9C7C6-C250-41A6-818A-0C1B2B7D0A6C') FOR [unitId]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDocumentLine_complaintDocumentHeader]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentLine]'))
ALTER TABLE [complaint].[ComplaintDocumentLine]  WITH CHECK ADD  CONSTRAINT [FK_ComplaintDocumentLine_complaintDocumentHeader] FOREIGN KEY([complaintDocumentHeaderId])
REFERENCES [complaint].[ComplaintDocumentHeader] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDocumentLine_complaintDocumentHeader]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentLine]'))
ALTER TABLE [complaint].[ComplaintDocumentLine] CHECK CONSTRAINT [FK_ComplaintDocumentLine_complaintDocumentHeader]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDocumentLine_issuingPersonContractor]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentLine]'))
ALTER TABLE [complaint].[ComplaintDocumentLine]  WITH CHECK ADD  CONSTRAINT [FK_ComplaintDocumentLine_issuingPersonContractor] FOREIGN KEY([issuingPersonContractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDocumentLine_issuingPersonContractor]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentLine]'))
ALTER TABLE [complaint].[ComplaintDocumentLine] CHECK CONSTRAINT [FK_ComplaintDocumentLine_issuingPersonContractor]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDocumentLine_item]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentLine]'))
ALTER TABLE [complaint].[ComplaintDocumentLine]  WITH CHECK ADD  CONSTRAINT [FK_ComplaintDocumentLine_item] FOREIGN KEY([itemId])
REFERENCES [item].[Item] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDocumentLine_item]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentLine]'))
ALTER TABLE [complaint].[ComplaintDocumentLine] CHECK CONSTRAINT [FK_ComplaintDocumentLine_item]
GO

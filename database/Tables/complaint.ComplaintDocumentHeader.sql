/*
name=[complaint].[ComplaintDocumentHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
3vav1o5DpC36w1cn2ylmgQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentHeader]') AND type in (N'U'))
BEGIN
CREATE TABLE [complaint].[ComplaintDocumentHeader](
	[id] [uniqueidentifier] NOT NULL,
	[seriesId] [uniqueidentifier] NOT NULL,
	[fullNumber] [nvarchar](50) NOT NULL,
	[number] [int] NOT NULL,
	[documentTypeId] [uniqueidentifier] NOT NULL,
	[issuerContractorId] [uniqueidentifier] NULL,
	[issuerContractorAddressId] [uniqueidentifier] NULL,
	[contractorId] [uniqueidentifier] NOT NULL,
	[contractorAddressId] [uniqueidentifier] NULL,
	[version] [uniqueidentifier] NOT NULL,
	[status] [int] NOT NULL,
 CONSTRAINT [PK_ComplaintDocumentHeader] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentHeader]') AND name = N'ind_ComplaintDocumentHeader_contractor')
CREATE NONCLUSTERED INDEX [ind_ComplaintDocumentHeader_contractor] ON [complaint].[ComplaintDocumentHeader]
(
	[contractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentHeader]') AND name = N'ind_ComplaintDocumentHeader_contractorAddress')
CREATE NONCLUSTERED INDEX [ind_ComplaintDocumentHeader_contractorAddress] ON [complaint].[ComplaintDocumentHeader]
(
	[contractorAddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentHeader]') AND name = N'ind_ComplaintDocumentHeader_issuerContractor')
CREATE NONCLUSTERED INDEX [ind_ComplaintDocumentHeader_issuerContractor] ON [complaint].[ComplaintDocumentHeader]
(
	[issuerContractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentHeader]') AND name = N'ind_ComplaintDocumentHeader_issuerContractorAddress')
CREATE NONCLUSTERED INDEX [ind_ComplaintDocumentHeader_issuerContractorAddress] ON [complaint].[ComplaintDocumentHeader]
(
	[issuerContractorAddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentHeader]') AND name = N'ind_ComplaintDocumentHeader_series')
CREATE NONCLUSTERED INDEX [ind_ComplaintDocumentHeader_series] ON [complaint].[ComplaintDocumentHeader]
(
	[seriesId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDocumentHeader_contractor]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentHeader]'))
ALTER TABLE [complaint].[ComplaintDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_ComplaintDocumentHeader_contractor] FOREIGN KEY([contractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDocumentHeader_contractor]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentHeader]'))
ALTER TABLE [complaint].[ComplaintDocumentHeader] CHECK CONSTRAINT [FK_ComplaintDocumentHeader_contractor]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDocumentHeader_contractorAddress]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentHeader]'))
ALTER TABLE [complaint].[ComplaintDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_ComplaintDocumentHeader_contractorAddress] FOREIGN KEY([contractorAddressId])
REFERENCES [contractor].[ContractorAddress] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDocumentHeader_contractorAddress]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentHeader]'))
ALTER TABLE [complaint].[ComplaintDocumentHeader] CHECK CONSTRAINT [FK_ComplaintDocumentHeader_contractorAddress]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDocumentHeader_issuerContractor]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentHeader]'))
ALTER TABLE [complaint].[ComplaintDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_ComplaintDocumentHeader_issuerContractor] FOREIGN KEY([issuerContractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDocumentHeader_issuerContractor]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentHeader]'))
ALTER TABLE [complaint].[ComplaintDocumentHeader] CHECK CONSTRAINT [FK_ComplaintDocumentHeader_issuerContractor]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDocumentHeader_issuerContractorAddress]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentHeader]'))
ALTER TABLE [complaint].[ComplaintDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_ComplaintDocumentHeader_issuerContractorAddress] FOREIGN KEY([issuerContractorAddressId])
REFERENCES [contractor].[ContractorAddress] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDocumentHeader_issuerContractorAddress]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentHeader]'))
ALTER TABLE [complaint].[ComplaintDocumentHeader] CHECK CONSTRAINT [FK_ComplaintDocumentHeader_issuerContractorAddress]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDocumentHeader_series]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentHeader]'))
ALTER TABLE [complaint].[ComplaintDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_ComplaintDocumentHeader_series] FOREIGN KEY([seriesId])
REFERENCES [document].[Series] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[complaint].[FK_ComplaintDocumentHeader_series]') AND parent_object_id = OBJECT_ID(N'[complaint].[ComplaintDocumentHeader]'))
ALTER TABLE [complaint].[ComplaintDocumentHeader] CHECK CONSTRAINT [FK_ComplaintDocumentHeader_series]
GO

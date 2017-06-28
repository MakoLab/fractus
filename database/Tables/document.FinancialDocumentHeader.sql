/*
name=[document].[FinancialDocumentHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
1ZqX/1nStqF5KHtcVxFTNg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[FinancialDocumentHeader](
	[id] [uniqueidentifier] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[status] [int] NOT NULL,
	[branchId] [uniqueidentifier] NOT NULL,
	[companyId] [uniqueidentifier] NOT NULL,
	[documentTypeId] [uniqueidentifier] NOT NULL,
	[contractorId] [uniqueidentifier] NULL,
	[contractorAddressId] [uniqueidentifier] NULL,
	[xmlConstantData] [xml] NULL,
	[financialReportId] [uniqueidentifier] NOT NULL,
	[documentCurrencyId] [uniqueidentifier] NOT NULL,
	[systemCurrencyId] [uniqueidentifier] NOT NULL,
	[number] [int] NOT NULL,
	[fullNumber] [nvarchar](50) NOT NULL,
	[seriesId] [uniqueidentifier] NULL,
	[issueDate] [datetime] NOT NULL,
	[issuingPersonContractorId] [uniqueidentifier] NOT NULL,
	[modificationDate] [datetime] NULL,
	[modificationApplicationUserId] [uniqueidentifier] NOT NULL,
	[amount] [numeric](18, 2) NOT NULL,
 CONSTRAINT [PK_FinancialDocumentHeader] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]') AND name = N'indFinancialDocumentHeader_branchId')
CREATE NONCLUSTERED INDEX [indFinancialDocumentHeader_branchId] ON [document].[FinancialDocumentHeader]
(
	[branchId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]') AND name = N'indFinancialDocumentHeader_companyId')
CREATE NONCLUSTERED INDEX [indFinancialDocumentHeader_companyId] ON [document].[FinancialDocumentHeader]
(
	[companyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]') AND name = N'indFinancialDocumentHeader_contractorAddressId')
CREATE NONCLUSTERED INDEX [indFinancialDocumentHeader_contractorAddressId] ON [document].[FinancialDocumentHeader]
(
	[contractorAddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]') AND name = N'indFinancialDocumentHeader_contractorId')
CREATE NONCLUSTERED INDEX [indFinancialDocumentHeader_contractorId] ON [document].[FinancialDocumentHeader]
(
	[contractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]') AND name = N'indFinancialDocumentHeader_documentCurrencyId')
CREATE NONCLUSTERED INDEX [indFinancialDocumentHeader_documentCurrencyId] ON [document].[FinancialDocumentHeader]
(
	[documentCurrencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]') AND name = N'indFinancialDocumentHeader_documentTypeId')
CREATE NONCLUSTERED INDEX [indFinancialDocumentHeader_documentTypeId] ON [document].[FinancialDocumentHeader]
(
	[documentTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]') AND name = N'indFinancialDocumentHeader_financialReportId')
CREATE NONCLUSTERED INDEX [indFinancialDocumentHeader_financialReportId] ON [document].[FinancialDocumentHeader]
(
	[financialReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]') AND name = N'indFinancialDocumentHeader_issuingPersonContractorId')
CREATE NONCLUSTERED INDEX [indFinancialDocumentHeader_issuingPersonContractorId] ON [document].[FinancialDocumentHeader]
(
	[issuingPersonContractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]') AND name = N'indFinancialDocumentHeader_modificationApplicationUserId')
CREATE NONCLUSTERED INDEX [indFinancialDocumentHeader_modificationApplicationUserId] ON [document].[FinancialDocumentHeader]
(
	[modificationApplicationUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]') AND name = N'indFinancialDocumentHeader_seriesId')
CREATE NONCLUSTERED INDEX [indFinancialDocumentHeader_seriesId] ON [document].[FinancialDocumentHeader]
(
	[seriesId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]') AND name = N'indFinancialDocumentHeader_status')
CREATE NONCLUSTERED INDEX [indFinancialDocumentHeader_status] ON [document].[FinancialDocumentHeader]
(
	[status] ASC
)
INCLUDE ( 	[id],
	[financialReportId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]') AND name = N'indFinancialDocumentHeader_systemCurrencyId')
CREATE NONCLUSTERED INDEX [indFinancialDocumentHeader_systemCurrencyId] ON [document].[FinancialDocumentHeader]
(
	[systemCurrencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_ApplicationUser]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_FinancialDocumentHeader_ApplicationUser] FOREIGN KEY([modificationApplicationUserId])
REFERENCES [contractor].[ApplicationUser] ([contractorId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_ApplicationUser]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader] CHECK CONSTRAINT [FK_FinancialDocumentHeader_ApplicationUser]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_Branch]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_FinancialDocumentHeader_Branch] FOREIGN KEY([branchId])
REFERENCES [dictionary].[Branch] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_Branch]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader] CHECK CONSTRAINT [FK_FinancialDocumentHeader_Branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_Company]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_FinancialDocumentHeader_Company] FOREIGN KEY([companyId])
REFERENCES [dictionary].[Company] ([contractorId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_Company]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader] CHECK CONSTRAINT [FK_FinancialDocumentHeader_Company]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_Contractor]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_FinancialDocumentHeader_Contractor] FOREIGN KEY([contractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_Contractor]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader] CHECK CONSTRAINT [FK_FinancialDocumentHeader_Contractor]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_Contractor1]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_FinancialDocumentHeader_Contractor1] FOREIGN KEY([issuingPersonContractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_Contractor1]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader] CHECK CONSTRAINT [FK_FinancialDocumentHeader_Contractor1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_ContractorAddress]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_FinancialDocumentHeader_ContractorAddress] FOREIGN KEY([contractorAddressId])
REFERENCES [contractor].[ContractorAddress] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_ContractorAddress]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader] CHECK CONSTRAINT [FK_FinancialDocumentHeader_ContractorAddress]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_Currency]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_FinancialDocumentHeader_Currency] FOREIGN KEY([documentCurrencyId])
REFERENCES [dictionary].[Currency] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_Currency]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader] CHECK CONSTRAINT [FK_FinancialDocumentHeader_Currency]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_Currency1]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_FinancialDocumentHeader_Currency1] FOREIGN KEY([systemCurrencyId])
REFERENCES [dictionary].[Currency] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_Currency1]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader] CHECK CONSTRAINT [FK_FinancialDocumentHeader_Currency1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_DocumentType]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_FinancialDocumentHeader_DocumentType] FOREIGN KEY([documentTypeId])
REFERENCES [dictionary].[DocumentType] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_DocumentType]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader] CHECK CONSTRAINT [FK_FinancialDocumentHeader_DocumentType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_Report]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_FinancialDocumentHeader_Report] FOREIGN KEY([financialReportId])
REFERENCES [finance].[FinancialReport] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_Report]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader] CHECK CONSTRAINT [FK_FinancialDocumentHeader_Report]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_Series]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader]  WITH CHECK ADD  CONSTRAINT [FK_FinancialDocumentHeader_Series] FOREIGN KEY([seriesId])
REFERENCES [document].[Series] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_FinancialDocumentHeader_Series]') AND parent_object_id = OBJECT_ID(N'[document].[FinancialDocumentHeader]'))
ALTER TABLE [document].[FinancialDocumentHeader] CHECK CONSTRAINT [FK_FinancialDocumentHeader_Series]
GO

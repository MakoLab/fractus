/*
name=[document].[CommercialDocumentHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
naV0x6ZQthGIliXlwJfvIA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[CommercialDocumentHeader](
	[id] [uniqueidentifier] NOT NULL,
	[documentTypeId] [uniqueidentifier] NOT NULL,
	[contractorId] [uniqueidentifier] NULL,
	[companyId] [uniqueidentifier] NOT NULL,
	[branchId] [uniqueidentifier] NOT NULL,
	[receivingPersonContractorId] [uniqueidentifier] NULL,
	[issuingPersonContractorId] [uniqueidentifier] NOT NULL,
	[issuerContractorId] [uniqueidentifier] NOT NULL,
	[contractorAddressId] [uniqueidentifier] NULL,
	[issuerContractorAddressId] [uniqueidentifier] NOT NULL,
	[documentCurrencyId] [uniqueidentifier] NOT NULL,
	[systemCurrencyId] [uniqueidentifier] NOT NULL,
	[exchangeDate] [datetime] NOT NULL,
	[exchangeScale] [numeric](18, 0) NOT NULL,
	[exchangeRate] [numeric](18, 6) NOT NULL,
	[number] [int] NOT NULL,
	[fullNumber] [nvarchar](50) NOT NULL,
	[issuePlaceId] [uniqueidentifier] NOT NULL,
	[issueDate] [datetime] NOT NULL,
	[eventDate] [datetime] NOT NULL,
	[netValue] [numeric](18, 2) NOT NULL,
	[grossValue] [numeric](18, 2) NOT NULL,
	[vatValue] [numeric](18, 2) NOT NULL,
	[xmlConstantData] [xml] NOT NULL,
	[printDate] [datetime] NULL,
	[isExportedForAccounting] [bit] NOT NULL,
	[netCalculationType] [bit] NOT NULL,
	[vatRatesSummationType] [bit] NOT NULL,
	[creationDate] [datetime] NOT NULL,
	[modificationDate] [datetime] NULL,
	[modificationApplicationUserId] [uniqueidentifier] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[seriesId] [uniqueidentifier] NULL,
	[status] [int] NOT NULL,
	[sysNetValue] [numeric](18, 2) NULL,
	[sysGrossValue] [numeric](18, 2) NULL,
	[sysVatValue] [numeric](18, 2) NULL,
 CONSTRAINT [PK_CommercialDocumentHeader2] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND name = N'indCommercialDocumentHeader_branchId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeader_branchId] ON [document].[CommercialDocumentHeader]
(
	[branchId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND name = N'indCommercialDocumentHeader_companyId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeader_companyId] ON [document].[CommercialDocumentHeader]
(
	[companyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND name = N'indCommercialDocumentHeader_contractorAddressId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeader_contractorAddressId] ON [document].[CommercialDocumentHeader]
(
	[contractorAddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND name = N'indCommercialDocumentHeader_contractorId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeader_contractorId] ON [document].[CommercialDocumentHeader]
(
	[contractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND name = N'indCommercialDocumentHeader_documentCurrencyId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeader_documentCurrencyId] ON [document].[CommercialDocumentHeader]
(
	[documentCurrencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND name = N'indCommercialDocumentHeader_documentTypeId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeader_documentTypeId] ON [document].[CommercialDocumentHeader]
(
	[documentTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND name = N'indCommercialDocumentHeader_issueDate')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeader_issueDate] ON [document].[CommercialDocumentHeader]
(
	[issueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND name = N'indCommercialDocumentHeader_issuerContractorAddressId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeader_issuerContractorAddressId] ON [document].[CommercialDocumentHeader]
(
	[issuerContractorAddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND name = N'indCommercialDocumentHeader_issuerContractorId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeader_issuerContractorId] ON [document].[CommercialDocumentHeader]
(
	[issuerContractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND name = N'indCommercialDocumentHeader_issuingPersonContractorId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeader_issuingPersonContractorId] ON [document].[CommercialDocumentHeader]
(
	[issuingPersonContractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND name = N'indCommercialDocumentHeader_number')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeader_number] ON [document].[CommercialDocumentHeader]
(
	[number] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND name = N'indCommercialDocumentHeader_receivingPersonContractorId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeader_receivingPersonContractorId] ON [document].[CommercialDocumentHeader]
(
	[receivingPersonContractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND name = N'indCommercialDocumentHeader_seriesId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeader_seriesId] ON [document].[CommercialDocumentHeader]
(
	[seriesId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND name = N'indCommercialDocumentHeader_status')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeader_status] ON [document].[CommercialDocumentHeader]
(
	[status] ASC
)
INCLUDE ( 	[id],
	[documentTypeId],
	[fullNumber],
	[issueDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND name = N'indCommercialDocumentHeader_systemCurrencyId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeader_systemCurrencyId] ON [document].[CommercialDocumentHeader]
(
	[systemCurrencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentHeader]') AND name = N'indCommercialDocumentHeader_version')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeader_version] ON [document].[CommercialDocumentHeader]
(
	[version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

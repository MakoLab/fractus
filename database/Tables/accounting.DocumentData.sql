/*
name=[accounting].[DocumentData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fSQylmF34WoZqqjk36wlIg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[DocumentData]') AND type in (N'U'))
BEGIN
CREATE TABLE [accounting].[DocumentData](
	[id] [uniqueidentifier] NOT NULL,
	[commercialDocumentId] [uniqueidentifier] NULL,
	[warehouseDocumentId] [uniqueidentifier] NULL,
	[financialDocumentId] [uniqueidentifier] NULL,
	[vatRegisterId] [uniqueidentifier] NULL,
	[month] [int] NULL,
	[year] [int] NULL,
	[vat7] [bit] NULL,
	[vatUe] [bit] NULL,
	[accountingRuleId] [uniqueidentifier] NULL,
	[accountingJournalId] [uniqueidentifier] NULL,
	[date] [datetime] NULL,
	[applicationUserId] [uniqueidentifier] NULL,
	[transactionType] [varchar](20) NULL,
	[entriesCreated] [bit] NOT NULL,
	[oppositionAccounting] [varchar](50) NULL,
	[externalName] [varchar](20) NULL,
 CONSTRAINT [PK_DocumentData] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[accounting].[DocumentData]') AND name = N'indDocumentData_commercialDocumentId')
CREATE NONCLUSTERED INDEX [indDocumentData_commercialDocumentId] ON [accounting].[DocumentData]
(
	[commercialDocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[accounting].[DocumentData]') AND name = N'indDocumentData_financialDocumentId')
CREATE NONCLUSTERED INDEX [indDocumentData_financialDocumentId] ON [accounting].[DocumentData]
(
	[financialDocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[accounting].[DocumentData]') AND name = N'indDocumentData_warehouseDocumentId')
CREATE NONCLUSTERED INDEX [indDocumentData_warehouseDocumentId] ON [accounting].[DocumentData]
(
	[warehouseDocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[accounting].[DF_DocumentData_id]') AND type = 'D')
BEGIN
ALTER TABLE [accounting].[DocumentData] ADD  CONSTRAINT [DF_DocumentData_id]  DEFAULT (newid()) FOR [id]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[accounting].[DF_DocumentData_entriesCreated]') AND type = 'D')
BEGIN
ALTER TABLE [accounting].[DocumentData] ADD  CONSTRAINT [DF_DocumentData_entriesCreated]  DEFAULT ((0)) FOR [entriesCreated]
END

GO

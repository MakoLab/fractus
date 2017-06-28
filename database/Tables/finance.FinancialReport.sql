/*
name=[finance].[FinancialReport]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
9V/1CJXKbu8jMVSa96GDIw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[FinancialReport]') AND type in (N'U'))
BEGIN
CREATE TABLE [finance].[FinancialReport](
	[id] [uniqueidentifier] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[financialRegisterId] [uniqueidentifier] NOT NULL,
	[number] [int] NOT NULL,
	[fullNumber] [nvarchar](50) NOT NULL,
	[seriesId] [uniqueidentifier] NULL,
	[creatingApplicationUserId] [uniqueidentifier] NOT NULL,
	[creationDate] [datetime] NOT NULL,
	[closingApplicationUserId] [uniqueidentifier] NULL,
	[closureDate] [datetime] NULL,
	[openingApplicationUserId] [uniqueidentifier] NULL,
	[openingDate] [datetime] NULL,
	[initialBalance] [numeric](18, 2) NOT NULL,
	[incomeAmount] [numeric](18, 2) NULL,
	[outcomeAmount] [numeric](18, 2) NULL,
	[isClosed] [bit] NOT NULL,
 CONSTRAINT [PK_Report] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[FinancialReport]') AND name = N'indFinancialReport_closingApplicationUserId')
CREATE NONCLUSTERED INDEX [indFinancialReport_closingApplicationUserId] ON [finance].[FinancialReport]
(
	[closingApplicationUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[FinancialReport]') AND name = N'indFinancialReport_closureDate')
CREATE NONCLUSTERED INDEX [indFinancialReport_closureDate] ON [finance].[FinancialReport]
(
	[closureDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[FinancialReport]') AND name = N'indFinancialReport_creatingApplicationUserId')
CREATE NONCLUSTERED INDEX [indFinancialReport_creatingApplicationUserId] ON [finance].[FinancialReport]
(
	[creatingApplicationUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[FinancialReport]') AND name = N'indFinancialReport_creationDate')
CREATE NONCLUSTERED INDEX [indFinancialReport_creationDate] ON [finance].[FinancialReport]
(
	[creationDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[FinancialReport]') AND name = N'indFinancialReport_FinancialRegisterId')
CREATE NONCLUSTERED INDEX [indFinancialReport_FinancialRegisterId] ON [finance].[FinancialReport]
(
	[financialRegisterId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[FinancialReport]') AND name = N'indFinancialReport_isClosed')
CREATE NONCLUSTERED INDEX [indFinancialReport_isClosed] ON [finance].[FinancialReport]
(
	[isClosed] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[FinancialReport]') AND name = N'indFinancialReport_openingApplicationUserId')
CREATE NONCLUSTERED INDEX [indFinancialReport_openingApplicationUserId] ON [finance].[FinancialReport]
(
	[openingApplicationUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[FinancialReport]') AND name = N'indFinancialReport_seriesId')
CREATE NONCLUSTERED INDEX [indFinancialReport_seriesId] ON [finance].[FinancialReport]
(
	[seriesId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_FinancialReport_Series]') AND parent_object_id = OBJECT_ID(N'[finance].[FinancialReport]'))
ALTER TABLE [finance].[FinancialReport]  WITH CHECK ADD  CONSTRAINT [FK_FinancialReport_Series] FOREIGN KEY([seriesId])
REFERENCES [document].[Series] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_FinancialReport_Series]') AND parent_object_id = OBJECT_ID(N'[finance].[FinancialReport]'))
ALTER TABLE [finance].[FinancialReport] CHECK CONSTRAINT [FK_FinancialReport_Series]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Report_ApplicationUser]') AND parent_object_id = OBJECT_ID(N'[finance].[FinancialReport]'))
ALTER TABLE [finance].[FinancialReport]  WITH CHECK ADD  CONSTRAINT [FK_Report_ApplicationUser] FOREIGN KEY([creatingApplicationUserId])
REFERENCES [contractor].[ApplicationUser] ([contractorId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Report_ApplicationUser]') AND parent_object_id = OBJECT_ID(N'[finance].[FinancialReport]'))
ALTER TABLE [finance].[FinancialReport] CHECK CONSTRAINT [FK_Report_ApplicationUser]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Report_ApplicationUser1]') AND parent_object_id = OBJECT_ID(N'[finance].[FinancialReport]'))
ALTER TABLE [finance].[FinancialReport]  WITH CHECK ADD  CONSTRAINT [FK_Report_ApplicationUser1] FOREIGN KEY([closingApplicationUserId])
REFERENCES [contractor].[ApplicationUser] ([contractorId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Report_ApplicationUser1]') AND parent_object_id = OBJECT_ID(N'[finance].[FinancialReport]'))
ALTER TABLE [finance].[FinancialReport] CHECK CONSTRAINT [FK_Report_ApplicationUser1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Report_ApplicationUser2]') AND parent_object_id = OBJECT_ID(N'[finance].[FinancialReport]'))
ALTER TABLE [finance].[FinancialReport]  WITH CHECK ADD  CONSTRAINT [FK_Report_ApplicationUser2] FOREIGN KEY([openingApplicationUserId])
REFERENCES [contractor].[ApplicationUser] ([contractorId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Report_ApplicationUser2]') AND parent_object_id = OBJECT_ID(N'[finance].[FinancialReport]'))
ALTER TABLE [finance].[FinancialReport] CHECK CONSTRAINT [FK_Report_ApplicationUser2]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Report_FinancialRegister]') AND parent_object_id = OBJECT_ID(N'[finance].[FinancialReport]'))
ALTER TABLE [finance].[FinancialReport]  WITH CHECK ADD  CONSTRAINT [FK_Report_FinancialRegister] FOREIGN KEY([financialRegisterId])
REFERENCES [dictionary].[FinancialRegister] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Report_FinancialRegister]') AND parent_object_id = OBJECT_ID(N'[finance].[FinancialReport]'))
ALTER TABLE [finance].[FinancialReport] CHECK CONSTRAINT [FK_Report_FinancialRegister]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Report_Report]') AND parent_object_id = OBJECT_ID(N'[finance].[FinancialReport]'))
ALTER TABLE [finance].[FinancialReport]  WITH CHECK ADD  CONSTRAINT [FK_Report_Report] FOREIGN KEY([id])
REFERENCES [finance].[FinancialReport] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Report_Report]') AND parent_object_id = OBJECT_ID(N'[finance].[FinancialReport]'))
ALTER TABLE [finance].[FinancialReport] CHECK CONSTRAINT [FK_Report_Report]
GO

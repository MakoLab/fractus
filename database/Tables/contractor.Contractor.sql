/*
name=[contractor].[Contractor]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
A2IBjH8RGulosRCBe2iMMw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[Contractor]') AND type in (N'U'))
BEGIN
CREATE TABLE [contractor].[Contractor](
	[id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[code] [varchar](50) NULL,
	[isSupplier] [bit] NOT NULL,
	[isReceiver] [bit] NOT NULL,
	[isBusinessEntity] [bit] NOT NULL,
	[isBank] [bit] NOT NULL,
	[isEmployee] [bit] NOT NULL,
	[isOwnCompany] [bit] NOT NULL,
	[fullName] [nvarchar](300) NOT NULL,
	[shortName] [nvarchar](40) NOT NULL,
	[nip] [nvarchar](40) NULL,
	[strippedNip] [nvarchar](50) NULL,
	[nipPrefixCountryId] [uniqueidentifier] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[creationDate] [datetime] NULL,
	[modificationDate] [datetime] NULL,
	[modificationUserId] [uniqueidentifier] NULL,
	[creationUserId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Contractor] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[Contractor]') AND name = N'indContractor_isBank')
CREATE NONCLUSTERED INDEX [indContractor_isBank] ON [contractor].[Contractor]
(
	[isBank] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[Contractor]') AND name = N'indContractor_isBusinessEntity')
CREATE NONCLUSTERED INDEX [indContractor_isBusinessEntity] ON [contractor].[Contractor]
(
	[isBusinessEntity] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[Contractor]') AND name = N'indContractor_isEmployee')
CREATE NONCLUSTERED INDEX [indContractor_isEmployee] ON [contractor].[Contractor]
(
	[isEmployee] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[Contractor]') AND name = N'indContractor_isInactive')
CREATE NONCLUSTERED INDEX [indContractor_isInactive] ON [contractor].[Contractor]
(
	[isOwnCompany] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[Contractor]') AND name = N'indContractor_isReceiver')
CREATE NONCLUSTERED INDEX [indContractor_isReceiver] ON [contractor].[Contractor]
(
	[isReceiver] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[Contractor]') AND name = N'indContractor_isSupplier')
CREATE NONCLUSTERED INDEX [indContractor_isSupplier] ON [contractor].[Contractor]
(
	[isSupplier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[Contractor]') AND name = N'indContractor_nipPrefixCountryId')
CREATE NONCLUSTERED INDEX [indContractor_nipPrefixCountryId] ON [contractor].[Contractor]
(
	[nipPrefixCountryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[Contractor]') AND name = N'indContractor_version')
CREATE NONCLUSTERED INDEX [indContractor_version] ON [contractor].[Contractor]
(
	[version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[contractor].[DF_Contractor_isSupplier]') AND type = 'D')
BEGIN
ALTER TABLE [contractor].[Contractor] ADD  CONSTRAINT [DF_Contractor_isSupplier]  DEFAULT ((0)) FOR [isSupplier]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[contractor].[DF_Contractor_isReceiver]') AND type = 'D')
BEGIN
ALTER TABLE [contractor].[Contractor] ADD  CONSTRAINT [DF_Contractor_isReceiver]  DEFAULT ((0)) FOR [isReceiver]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[contractor].[DF_Contractor_isBusinessEntity]') AND type = 'D')
BEGIN
ALTER TABLE [contractor].[Contractor] ADD  CONSTRAINT [DF_Contractor_isBusinessEntity]  DEFAULT ((0)) FOR [isBusinessEntity]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[contractor].[DF_Contractor_isBank_1]') AND type = 'D')
BEGIN
ALTER TABLE [contractor].[Contractor] ADD  CONSTRAINT [DF_Contractor_isBank_1]  DEFAULT ((0)) FOR [isBank]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[contractor].[DF_Contractor_isEmployee]') AND type = 'D')
BEGIN
ALTER TABLE [contractor].[Contractor] ADD  CONSTRAINT [DF_Contractor_isEmployee]  DEFAULT ((0)) FOR [isEmployee]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[contractor].[DF_Contractor_isBlocked]') AND type = 'D')
BEGIN
ALTER TABLE [contractor].[Contractor] ADD  CONSTRAINT [DF_Contractor_isBlocked]  DEFAULT ((0)) FOR [isOwnCompany]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_Contractor_Country]') AND parent_object_id = OBJECT_ID(N'[contractor].[Contractor]'))
ALTER TABLE [contractor].[Contractor]  WITH CHECK ADD  CONSTRAINT [FK_Contractor_Country] FOREIGN KEY([nipPrefixCountryId])
REFERENCES [dictionary].[Country] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_Contractor_Country]') AND parent_object_id = OBJECT_ID(N'[contractor].[Contractor]'))
ALTER TABLE [contractor].[Contractor] CHECK CONSTRAINT [FK_Contractor_Country]
GO

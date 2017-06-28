/*
name=[contractor].[ContractorAddress]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
FnKn5IFhBL3KJWg6/DE/VA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[ContractorAddress]') AND type in (N'U'))
BEGIN
CREATE TABLE [contractor].[ContractorAddress](
	[id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[contractorId] [uniqueidentifier] NOT NULL,
	[contractorFieldId] [uniqueidentifier] NOT NULL,
	[countryId] [uniqueidentifier] NOT NULL,
	[city] [nvarchar](50) NOT NULL,
	[postCode] [nvarchar](30) NOT NULL,
	[postOffice] [nvarchar](50) NOT NULL,
	[address] [nvarchar](300) NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
	[addressNumber] [nvarchar](10) NULL,
	[flatNumber] [nvarchar](10) NULL,
 CONSTRAINT [PK_ContractorAddress] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorAddress]') AND name = N'indContractorAddress_contractorFIeldId')
CREATE NONCLUSTERED INDEX [indContractorAddress_contractorFIeldId] ON [contractor].[ContractorAddress]
(
	[contractorFieldId] ASC
)
INCLUDE ( 	[contractorId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorAddress]') AND name = N'indContractorAddress_contractorId')
CREATE NONCLUSTERED INDEX [indContractorAddress_contractorId] ON [contractor].[ContractorAddress]
(
	[contractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorAddress]') AND name = N'indContractorAddress_countryId')
CREATE NONCLUSTERED INDEX [indContractorAddress_countryId] ON [contractor].[ContractorAddress]
(
	[countryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorAddress]') AND name = N'indContractorRelation_contractorId')
CREATE NONCLUSTERED INDEX [indContractorRelation_contractorId] ON [contractor].[ContractorAddress]
(
	[contractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorAddress_Contractor]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorAddress]'))
ALTER TABLE [contractor].[ContractorAddress]  WITH CHECK ADD  CONSTRAINT [FK_ContractorAddress_Contractor] FOREIGN KEY([contractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorAddress_Contractor]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorAddress]'))
ALTER TABLE [contractor].[ContractorAddress] CHECK CONSTRAINT [FK_ContractorAddress_Contractor]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorAddress_ContractorField]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorAddress]'))
ALTER TABLE [contractor].[ContractorAddress]  WITH CHECK ADD  CONSTRAINT [FK_ContractorAddress_ContractorField] FOREIGN KEY([contractorFieldId])
REFERENCES [dictionary].[ContractorField] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorAddress_ContractorField]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorAddress]'))
ALTER TABLE [contractor].[ContractorAddress] CHECK CONSTRAINT [FK_ContractorAddress_ContractorField]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorAddress_Country]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorAddress]'))
ALTER TABLE [contractor].[ContractorAddress]  WITH CHECK ADD  CONSTRAINT [FK_ContractorAddress_Country] FOREIGN KEY([countryId])
REFERENCES [dictionary].[Country] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorAddress_Country]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorAddress]'))
ALTER TABLE [contractor].[ContractorAddress] CHECK CONSTRAINT [FK_ContractorAddress_Country]
GO

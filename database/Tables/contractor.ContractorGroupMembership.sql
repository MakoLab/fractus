/*
name=[contractor].[ContractorGroupMembership]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
uWf9grixO/LoBZWhjKbjmg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[ContractorGroupMembership]') AND type in (N'U'))
BEGIN
CREATE TABLE [contractor].[ContractorGroupMembership](
	[id] [uniqueidentifier] NOT NULL,
	[contractorId] [uniqueidentifier] NOT NULL,
	[contractorGroupId] [uniqueidentifier] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ContractorGroupMembership] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorGroupMembership]') AND name = N'indContractorGroupMembership_contractorGroupId')
CREATE NONCLUSTERED INDEX [indContractorGroupMembership_contractorGroupId] ON [contractor].[ContractorGroupMembership]
(
	[contractorGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorGroupMembership]') AND name = N'indContractorGroupMembership_contractorId')
CREATE NONCLUSTERED INDEX [indContractorGroupMembership_contractorId] ON [contractor].[ContractorGroupMembership]
(
	[contractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorGroupMembership_Contractor]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorGroupMembership]'))
ALTER TABLE [contractor].[ContractorGroupMembership]  WITH CHECK ADD  CONSTRAINT [FK_ContractorGroupMembership_Contractor] FOREIGN KEY([contractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorGroupMembership_Contractor]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorGroupMembership]'))
ALTER TABLE [contractor].[ContractorGroupMembership] CHECK CONSTRAINT [FK_ContractorGroupMembership_Contractor]
GO

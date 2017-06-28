/*
name=[contractor].[ContractorAccount]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
6rO1h34r2HFMla2TRCTLeQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[ContractorAccount]') AND type in (N'U'))
BEGIN
CREATE TABLE [contractor].[ContractorAccount](
	[id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[contractorId] [uniqueidentifier] NOT NULL,
	[bankContractorId] [uniqueidentifier] NULL,
	[accountNumber] [varchar](40) NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
 CONSTRAINT [PK_ContractorAccount] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorAccount]') AND name = N'indContractorAccount_bankContractorId')
CREATE NONCLUSTERED INDEX [indContractorAccount_bankContractorId] ON [contractor].[ContractorAccount]
(
	[bankContractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorAccount]') AND name = N'indContractorAccount_contractorId')
CREATE NONCLUSTERED INDEX [indContractorAccount_contractorId] ON [contractor].[ContractorAccount]
(
	[contractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorAccount_Contractor]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorAccount]'))
ALTER TABLE [contractor].[ContractorAccount]  WITH CHECK ADD  CONSTRAINT [FK_ContractorAccount_Contractor] FOREIGN KEY([contractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorAccount_Contractor]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorAccount]'))
ALTER TABLE [contractor].[ContractorAccount] CHECK CONSTRAINT [FK_ContractorAccount_Contractor]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorAccount_ContractorBank]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorAccount]'))
ALTER TABLE [contractor].[ContractorAccount]  WITH CHECK ADD  CONSTRAINT [FK_ContractorAccount_ContractorBank] FOREIGN KEY([bankContractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorAccount_ContractorBank]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorAccount]'))
ALTER TABLE [contractor].[ContractorAccount] CHECK CONSTRAINT [FK_ContractorAccount_ContractorBank]
GO

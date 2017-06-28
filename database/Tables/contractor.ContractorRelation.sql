/*
name=[contractor].[ContractorRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
vBiFimahQkjZiacVa/nKbg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[ContractorRelation]') AND type in (N'U'))
BEGIN
CREATE TABLE [contractor].[ContractorRelation](
	[id] [uniqueidentifier] NOT NULL,
	[contractorId] [uniqueidentifier] NOT NULL,
	[contractorRelationTypeId] [uniqueidentifier] NOT NULL,
	[relatedContractorId] [uniqueidentifier] NOT NULL,
	[xmlAttributes] [xml] NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
	[relatedContractorOrder] [int] NULL,
 CONSTRAINT [PK_ContractorRelation] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorRelation]') AND name = N'indContractorRelation_contractorId')
CREATE NONCLUSTERED INDEX [indContractorRelation_contractorId] ON [contractor].[ContractorRelation]
(
	[contractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorRelation]') AND name = N'indContractorRelation_contractorRelationTypeId')
CREATE NONCLUSTERED INDEX [indContractorRelation_contractorRelationTypeId] ON [contractor].[ContractorRelation]
(
	[contractorRelationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorRelation]') AND name = N'indContractorRelation_relatedContractorId')
CREATE NONCLUSTERED INDEX [indContractorRelation_relatedContractorId] ON [contractor].[ContractorRelation]
(
	[relatedContractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorRelation_ContractorRelated]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorRelation]'))
ALTER TABLE [contractor].[ContractorRelation]  WITH CHECK ADD  CONSTRAINT [FK_ContractorRelation_ContractorRelated] FOREIGN KEY([relatedContractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorRelation_ContractorRelated]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorRelation]'))
ALTER TABLE [contractor].[ContractorRelation] CHECK CONSTRAINT [FK_ContractorRelation_ContractorRelated]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorRelation_ContractorRelationType]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorRelation]'))
ALTER TABLE [contractor].[ContractorRelation]  WITH CHECK ADD  CONSTRAINT [FK_ContractorRelation_ContractorRelationType] FOREIGN KEY([contractorRelationTypeId])
REFERENCES [dictionary].[ContractorRelationType] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorRelation_ContractorRelationType]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorRelation]'))
ALTER TABLE [contractor].[ContractorRelation] CHECK CONSTRAINT [FK_ContractorRelation_ContractorRelationType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorRelation_ContractorSuperior]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorRelation]'))
ALTER TABLE [contractor].[ContractorRelation]  WITH CHECK ADD  CONSTRAINT [FK_ContractorRelation_ContractorSuperior] FOREIGN KEY([contractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorRelation_ContractorSuperior]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorRelation]'))
ALTER TABLE [contractor].[ContractorRelation] CHECK CONSTRAINT [FK_ContractorRelation_ContractorSuperior]
GO

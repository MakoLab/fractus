/*
name=[contractor].[ContractorAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
mpjb7sWUG2Pes8ewV7fsPA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[ContractorAttrValue]') AND type in (N'U'))
BEGIN
CREATE TABLE [contractor].[ContractorAttrValue](
	[id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[contractorId] [uniqueidentifier] NOT NULL,
	[contractorFieldId] [uniqueidentifier] NOT NULL,
	[decimalValue] [decimal](18, 4) SPARSE  NULL,
	[dateValue] [datetime] SPARSE  NULL,
	[textValue] [nvarchar](500) NULL,
	[xmlValue] [xml] SPARSE  NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
 CONSTRAINT [PK_ContractorAttrValue] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorAttrValue]') AND name = N'indContractorAttrValue_contractorFieldId')
CREATE NONCLUSTERED INDEX [indContractorAttrValue_contractorFieldId] ON [contractor].[ContractorAttrValue]
(
	[contractorFieldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorAttrValue]') AND name = N'indContractorAttrValue_contractorId')
CREATE NONCLUSTERED INDEX [indContractorAttrValue_contractorId] ON [contractor].[ContractorAttrValue]
(
	[contractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorAttrValue]') AND name = N'indContractorAttrValue_decimalValue')
CREATE NONCLUSTERED INDEX [indContractorAttrValue_decimalValue] ON [contractor].[ContractorAttrValue]
(
	[decimalValue] ASC
)
INCLUDE ( 	[id],
	[contractorId],
	[contractorFieldId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorAttrValue_Contractor]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorAttrValue]'))
ALTER TABLE [contractor].[ContractorAttrValue]  WITH CHECK ADD  CONSTRAINT [FK_ContractorAttrValue_Contractor] FOREIGN KEY([contractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorAttrValue_Contractor]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorAttrValue]'))
ALTER TABLE [contractor].[ContractorAttrValue] CHECK CONSTRAINT [FK_ContractorAttrValue_Contractor]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorAttrValue_ContractorField]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorAttrValue]'))
ALTER TABLE [contractor].[ContractorAttrValue]  WITH CHECK ADD  CONSTRAINT [FK_ContractorAttrValue_ContractorField] FOREIGN KEY([contractorFieldId])
REFERENCES [dictionary].[ContractorField] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_ContractorAttrValue_ContractorField]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorAttrValue]'))
ALTER TABLE [contractor].[ContractorAttrValue] CHECK CONSTRAINT [FK_ContractorAttrValue_ContractorField]
GO

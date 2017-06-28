/*
name=[contractor].[ContractorDictionaryRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
yFK6MCKdbyfzWcqH5NwYjQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[ContractorDictionaryRelation]') AND type in (N'U'))
BEGIN
CREATE TABLE [contractor].[ContractorDictionaryRelation](
	[id] [uniqueidentifier] NOT NULL,
	[contractorId] [uniqueidentifier] NOT NULL,
	[contractorDictionaryId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_DictionaryRelation] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorDictionaryRelation]') AND name = N'indDictionaryRelation_dictionaryId')
CREATE NONCLUSTERED INDEX [indDictionaryRelation_dictionaryId] ON [contractor].[ContractorDictionaryRelation]
(
	[contractorDictionaryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorDictionaryRelation]') AND name = N'indDictionaryRelation_rowId')
CREATE NONCLUSTERED INDEX [indDictionaryRelation_rowId] ON [contractor].[ContractorDictionaryRelation]
(
	[contractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[fk_contractorDictionaryRelation_dictionaryId]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorDictionaryRelation]'))
ALTER TABLE [contractor].[ContractorDictionaryRelation]  WITH CHECK ADD  CONSTRAINT [fk_contractorDictionaryRelation_dictionaryId] FOREIGN KEY([contractorDictionaryId])
REFERENCES [contractor].[ContractorDictionary] ([id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[fk_contractorDictionaryRelation_dictionaryId]') AND parent_object_id = OBJECT_ID(N'[contractor].[ContractorDictionaryRelation]'))
ALTER TABLE [contractor].[ContractorDictionaryRelation] CHECK CONSTRAINT [fk_contractorDictionaryRelation_dictionaryId]
GO

/*
name=[dictionary].[DocumentFieldRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Rl+gobrq1RnDfPVCThicqw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[DocumentFieldRelation]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[DocumentFieldRelation](
	[id] [uniqueidentifier] NOT NULL,
	[documentFieldId] [uniqueidentifier] NOT NULL,
	[documentTypeId] [uniqueidentifier] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_DocumentFieldRelation] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dictionary].[DocumentFieldRelation]') AND name = N'indDocumentFieldRelation_documentFieldId')
CREATE NONCLUSTERED INDEX [indDocumentFieldRelation_documentFieldId] ON [dictionary].[DocumentFieldRelation]
(
	[documentFieldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dictionary].[DocumentFieldRelation]') AND name = N'indDocumentFieldRelation_documentTypeId')
CREATE NONCLUSTERED INDEX [indDocumentFieldRelation_documentTypeId] ON [dictionary].[DocumentFieldRelation]
(
	[documentTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dictionary].[FK_DocumentFieldRelation_DocumentField]') AND parent_object_id = OBJECT_ID(N'[dictionary].[DocumentFieldRelation]'))
ALTER TABLE [dictionary].[DocumentFieldRelation]  WITH CHECK ADD  CONSTRAINT [FK_DocumentFieldRelation_DocumentField] FOREIGN KEY([documentFieldId])
REFERENCES [dictionary].[DocumentField] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dictionary].[FK_DocumentFieldRelation_DocumentField]') AND parent_object_id = OBJECT_ID(N'[dictionary].[DocumentFieldRelation]'))
ALTER TABLE [dictionary].[DocumentFieldRelation] CHECK CONSTRAINT [FK_DocumentFieldRelation_DocumentField]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dictionary].[FK_DocumentFieldRelation_DocumentType]') AND parent_object_id = OBJECT_ID(N'[dictionary].[DocumentFieldRelation]'))
ALTER TABLE [dictionary].[DocumentFieldRelation]  WITH CHECK ADD  CONSTRAINT [FK_DocumentFieldRelation_DocumentType] FOREIGN KEY([documentTypeId])
REFERENCES [dictionary].[DocumentType] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dictionary].[FK_DocumentFieldRelation_DocumentType]') AND parent_object_id = OBJECT_ID(N'[dictionary].[DocumentFieldRelation]'))
ALTER TABLE [dictionary].[DocumentFieldRelation] CHECK CONSTRAINT [FK_DocumentFieldRelation_DocumentType]
GO

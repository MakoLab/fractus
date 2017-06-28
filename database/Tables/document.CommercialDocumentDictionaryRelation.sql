/*
name=[document].[CommercialDocumentDictionaryRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
QHYOPeJFYNjjFRQmegyWUA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentDictionaryRelation]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[CommercialDocumentDictionaryRelation](
	[id] [uniqueidentifier] NOT NULL,
	[commercialDocumentHeaderId] [uniqueidentifier] NOT NULL,
	[commercialDocumentDictionaryId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_CommercialDocumentDictionaryRelation] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentDictionaryRelation]') AND name = N'indCommercialDocumentHeaderRelation_commercialDocumentDictionaryId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeaderRelation_commercialDocumentDictionaryId] ON [document].[CommercialDocumentDictionaryRelation]
(
	[commercialDocumentDictionaryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentDictionaryRelation]') AND name = N'indCommercialDocumentHeaderRelation_commercialDocumentHeaderId')
CREATE NONCLUSTERED INDEX [indCommercialDocumentHeaderRelation_commercialDocumentHeaderId] ON [document].[CommercialDocumentDictionaryRelation]
(
	[commercialDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

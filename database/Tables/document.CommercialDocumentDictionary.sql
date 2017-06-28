/*
name=[document].[CommercialDocumentDictionary]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
yJD0eJWdp25saGVwUob/EQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentDictionary]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[CommercialDocumentDictionary](
	[id] [uniqueidentifier] NOT NULL,
	[field] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_CommercialDocumentDictionary] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unique_field] UNIQUE NONCLUSTERED 
(
	[field] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[CommercialDocumentDictionary]') AND name = N'indCommercialDocumentDictionary_field')
CREATE UNIQUE NONCLUSTERED INDEX [indCommercialDocumentDictionary_field] ON [document].[CommercialDocumentDictionary]
(
	[field] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

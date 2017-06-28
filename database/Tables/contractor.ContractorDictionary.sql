/*
name=[contractor].[ContractorDictionary]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
qmGvfBXKxpaDNWYmlbK6fQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[ContractorDictionary]') AND type in (N'U'))
BEGIN
CREATE TABLE [contractor].[ContractorDictionary](
	[id] [uniqueidentifier] NOT NULL,
	[field] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Dictionary] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ContractorDictionary]') AND name = N'indDictionary_field')
CREATE UNIQUE NONCLUSTERED INDEX [indDictionary_field] ON [contractor].[ContractorDictionary]
(
	[field] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/*
name=[dictionary].[DictionaryVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
3yCY3ci2Y93+miZo2WtMhw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[DictionaryVersion]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[DictionaryVersion](
	[id] [uniqueidentifier] NOT NULL,
	[tableName] [varchar](255) NOT NULL,
	[versionNumber] [int] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[keyString] [varchar](max) NULL,
 CONSTRAINT [PK_DictionaryVersion] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dictionary].[DictionaryVersion]') AND name = N'indDictionaryVersion_tableName')
CREATE NONCLUSTERED INDEX [indDictionaryVersion_tableName] ON [dictionary].[DictionaryVersion]
(
	[tableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

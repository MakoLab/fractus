/*
name=[accounting].[ExternalMapping]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
sJSZlysF2aXa/gmvLI3oFg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[ExternalMapping]') AND type in (N'U'))
BEGIN
CREATE TABLE [accounting].[ExternalMapping](
	[id] [uniqueidentifier] NOT NULL,
	[externalId] [varchar](50) NOT NULL,
	[objectType] [int] NOT NULL,
	[exportDate] [datetime] NOT NULL,
	[externalSystemName] [varchar](10) NOT NULL,
	[objectVersion] [uniqueidentifier] NULL,
 CONSTRAINT [PK_ExternalMapping] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

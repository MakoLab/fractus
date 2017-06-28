/*
name=[dictionary].[Currency]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Nc4iSetx9X/v49wTk29IdQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[Currency]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[Currency](
	[id] [uniqueidentifier] NOT NULL,
	[symbol] [varchar](10) NOT NULL,
	[xmlLabels] [xml] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
 CONSTRAINT [PK_currency] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

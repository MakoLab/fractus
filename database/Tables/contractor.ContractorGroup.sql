/*
name=[contractor].[ContractorGroup]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
8LeChGcBqEBee8yX8hgV3g==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[ContractorGroup]') AND type in (N'U'))
BEGIN
CREATE TABLE [contractor].[ContractorGroup](
	[id] [uniqueidentifier] NOT NULL,
	[label] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_ContractorGroup] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

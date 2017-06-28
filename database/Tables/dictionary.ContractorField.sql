/*
name=[dictionary].[ContractorField]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
C/KS5B9sPR+ZRZNcry4peA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[ContractorField]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[ContractorField](
	[id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[name] [varchar](50) NOT NULL,
	[xmlLabels] [xml] NOT NULL,
	[xmlMetadata] [xml] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
 CONSTRAINT [PK_ContractorField] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

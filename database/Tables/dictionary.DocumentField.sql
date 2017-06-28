/*
name=[dictionary].[DocumentField]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
jx+jYvfTfq9Rz8N4i+foIg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[DocumentField]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[DocumentField](
	[id] [uniqueidentifier] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[xmlLabels] [xml] NOT NULL,
	[xmlMetadata] [xml] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
 CONSTRAINT [PK_DocumentField] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
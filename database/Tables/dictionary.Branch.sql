/*
name=[dictionary].[Branch]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
oEJcibvBRCLPvT63VYZdHQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[Branch]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[Branch](
	[id] [uniqueidentifier] NOT NULL,
	[companyId] [uniqueidentifier] NOT NULL,
	[databaseId] [uniqueidentifier] NOT NULL,
	[xmlLabels] [xml] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
	[symbol] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Branch] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

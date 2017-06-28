/*
name=[dictionary].[ContainerType]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
5or+a61DZhEH67q7d+3B4g==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[ContainerType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[ContainerType](
	[id] [uniqueidentifier] NOT NULL,
	[isSlot] [bit] NOT NULL,
	[isItemContainer] [bit] NOT NULL,
	[xmlLabels] [xml] NOT NULL,
	[xmlMetadata] [xml] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
	[availability] [int] NULL,
 CONSTRAINT [PK_ContainerType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

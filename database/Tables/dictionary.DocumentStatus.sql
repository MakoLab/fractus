/*
name=[dictionary].[DocumentStatus]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
9OvowbgAKD2s8Ea/NeZBCg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[DocumentStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[DocumentStatus](
	[id] [uniqueidentifier] NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[value] [int] NOT NULL,
	[xmlLabels] [xml] NOT NULL,
	[version] [uniqueidentifier] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

/*
name=[tools].[EventCache]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
zIFJQwkTFOU4YVPIGaEJ+Q==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[EventCache]') AND type in (N'U'))
BEGIN
CREATE TABLE [tools].[EventCache](
	[cacheDate] [datetime] NULL,
	[parameter] [xml] NULL,
	[response] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

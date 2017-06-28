/*
name=[item].[ItemKeyValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4WWAqNSyWuONJTZ+1JQUQw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[ItemKeyValue]') AND type in (N'U'))
BEGIN
CREATE TABLE [item].[ItemKeyValue](
	[id] [uniqueidentifier] NOT NULL,
	[itemKeyId] [uniqueidentifier] NOT NULL,
	[keyValue] [varchar](50) NOT NULL
) ON [PRIMARY]
END
GO

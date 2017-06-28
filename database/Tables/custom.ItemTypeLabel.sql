/*
name=[custom].[ItemTypeLabel]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
8i66brPX4mHHqPkPWeM6Sg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[ItemTypeLabel]') AND type in (N'U'))
BEGIN
CREATE TABLE [custom].[ItemTypeLabel](
	[id] [uniqueidentifier] NOT NULL,
	[label] [varchar](100) NULL
) ON [PRIMARY]
END
GO

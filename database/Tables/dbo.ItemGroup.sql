/*
name=[dbo].[ItemGroup]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
bSJNtytknAex5jQqkhv5hA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ItemGroup]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ItemGroup](
	[groupId] [varchar](500) NULL,
	[megaId] [varchar](500) NULL
) ON [PRIMARY]
END
GO

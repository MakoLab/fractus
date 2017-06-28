/*
name=[translation].[BranchAttributes]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
7XEChLISem/C2RAKz8at8g==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[BranchAttributes]') AND type in (N'U'))
BEGIN
CREATE TABLE [translation].[BranchAttributes](
	[branchId] [uniqueidentifier] NOT NULL,
	[prefix] [int] NOT NULL
) ON [PRIMARY]
END
GO

/*
name=[custom].[updatelog]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
utyI6EaDhvH2cgSIKMMWGQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[updatelog]') AND type in (N'U'))
BEGIN
CREATE TABLE [custom].[updatelog](
	[edited] [datetime] NULL,
	[editor] [varchar](64) NULL,
	[appname] [varchar](50) NULL,
	[ui_list] [varchar](8000) NULL
) ON [PRIMARY]
END
GO

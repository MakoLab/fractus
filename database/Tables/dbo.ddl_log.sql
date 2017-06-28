/*
name=[dbo].[ddl_log]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
C3AHAG4y6CYd9KdK3QNgMQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ddl_log]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ddl_log](
	[PostTime] [datetime] NULL,
	[DB_User] [nvarchar](100) NULL,
	[Event] [nvarchar](100) NULL,
	[TSQL] [nvarchar](2000) NULL,
	[eventdata_] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ddl_log]') AND name = N'indDDL_log_Posttime')
CREATE CLUSTERED INDEX [indDDL_log_Posttime] ON [dbo].[ddl_log]
(
	[PostTime] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/*
name=[custom].[SalesOrderTrackerQueueEntries]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
rBZXrE0V0OsU6uyv4e+z8g==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[SalesOrderTrackerQueueEntries]') AND type in (N'U'))
BEGIN
CREATE TABLE [custom].[SalesOrderTrackerQueueEntries](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IsCompleted] [bit] NOT NULL,
	[Date] [datetime] NOT NULL,
	[SalesOrderId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_SalesOrderTrackerQueueEntries] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

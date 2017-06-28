/*
name=[communication].[Statistics]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
XYiLVPRAVe5LnlUt3FtUTg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[Statistics]') AND type in (N'U'))
BEGIN
CREATE TABLE [communication].[Statistics](
	[databaseId] [uniqueidentifier] NOT NULL,
	[lastUpdate] [datetime] NULL,
	[undeliveredPackagesQuantity] [int] NULL,
	[unprocessedPackagesQuantity] [int] NULL,
	[lastExecutionTime] [datetime] NULL,
	[lastSentMessage] [nvarchar](max) NULL,
	[sentMessageTime] [datetime] NULL,
	[lastExecutionMessage] [nvarchar](max) NULL,
	[executionMessageTime] [datetime] NULL,
	[lastReceiveMessage] [nvarchar](max) NULL,
	[receiveMessageTime] [datetime] NULL,
 CONSTRAINT [PK_Statistics] PRIMARY KEY CLUSTERED 
(
	[databaseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

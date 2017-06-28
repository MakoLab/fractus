/*
name=[custom].[Messages]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
/xJ/iD0VQp6dgeFfTcOCCg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[Messages]') AND type in (N'U'))
BEGIN
CREATE TABLE [custom].[Messages](
	[id] [uniqueidentifier] NOT NULL,
	[type] [varchar](50) NOT NULL,
	[recipient] [nvarchar](100) NOT NULL,
	[sender] [nvarchar](100) NULL,
	[message] [nvarchar](1000) NULL,
	[creationDate] [datetime] NOT NULL,
	[sendDate] [datetime] NULL,
	[errorDate] [datetime] NULL,
	[errorMessage] [nvarchar](1000) NULL,
	[subject] [nvarchar](100) NULL,
 CONSTRAINT [PK_Messages] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[custom].[DF_Messages_creationDate]') AND type = 'D')
BEGIN
ALTER TABLE [custom].[Messages] ADD  CONSTRAINT [DF_Messages_creationDate]  DEFAULT (getdate()) FOR [creationDate]
END

GO

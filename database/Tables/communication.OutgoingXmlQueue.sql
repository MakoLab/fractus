/*
name=[communication].[OutgoingXmlQueue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ULJni9HYY0bcMUdXFk29bA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[OutgoingXmlQueue]') AND type in (N'U'))
BEGIN
CREATE TABLE [communication].[OutgoingXmlQueue](
	[id] [uniqueidentifier] NOT NULL,
	[localTransactionId] [uniqueidentifier] NOT NULL,
	[deferredTransactionId] [uniqueidentifier] NOT NULL,
	[databaseId] [uniqueidentifier] NOT NULL,
	[type] [varchar](50) NOT NULL,
	[xml] [xml] NOT NULL,
	[sendDate] [datetime] NULL,
	[creationDate] [datetime] NOT NULL,
	[order] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_OutgoingXmlQueue] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[communication].[OutgoingXmlQueue]') AND name = N'indOutgoingXmlQueue_sendDate')
CREATE NONCLUSTERED INDEX [indOutgoingXmlQueue_sendDate] ON [communication].[OutgoingXmlQueue]
(
	[sendDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[communication].[OutgoingXmlQueue]') AND name = N'indOutgoingXmlQueue_transactionGuid')
CREATE NONCLUSTERED INDEX [indOutgoingXmlQueue_transactionGuid] ON [communication].[OutgoingXmlQueue]
(
	[localTransactionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[communication].[DF_OutgoingXmlQueue_databaseId]') AND type = 'D')
BEGIN
ALTER TABLE [communication].[OutgoingXmlQueue] ADD  CONSTRAINT [DF_OutgoingXmlQueue_databaseId]  DEFAULT ('76DC8FC5-F716-4AF3-A4B6-92F5FD7AC103') FOR [databaseId]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[communication].[DF_OutgoingXmlQueue_creationDate]') AND type = 'D')
BEGIN
ALTER TABLE [communication].[OutgoingXmlQueue] ADD  CONSTRAINT [DF_OutgoingXmlQueue_creationDate]  DEFAULT (getdate()) FOR [creationDate]
END

GO

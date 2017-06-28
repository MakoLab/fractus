/*
name=[communication].[IncomingXmlQueue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
bwGUu6X8KC9/7SjpkBd7vg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[IncomingXmlQueue]') AND type in (N'U'))
BEGIN
CREATE TABLE [communication].[IncomingXmlQueue](
	[id] [uniqueidentifier] NOT NULL,
	[localTransactionId] [uniqueidentifier] NOT NULL,
	[deferredTransactionId] [uniqueidentifier] NOT NULL,
	[databaseId] [uniqueidentifier] NULL,
	[isComplited] [bit] NOT NULL,
	[type] [varchar](50) NOT NULL,
	[xml] [xml] NOT NULL,
	[receiveDate] [datetime] NOT NULL,
	[executionDate] [datetime] NULL,
	[order] [int] IDENTITY(1,1) NOT NULL,
	[translationDate] [datetime] NULL,
	[executionTime] [float] NULL,
 CONSTRAINT [PK_IncomingXmlQueue] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[communication].[IncomingXmlQueue]') AND name = N'indIncomingXmlQueue_executionDate')
CREATE NONCLUSTERED INDEX [indIncomingXmlQueue_executionDate] ON [communication].[IncomingXmlQueue]
(
	[executionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[communication].[IncomingXmlQueue]') AND name = N'indIncomingXmlQueue_multi')
CREATE NONCLUSTERED INDEX [indIncomingXmlQueue_multi] ON [communication].[IncomingXmlQueue]
(
	[isComplited] ASC,
	[executionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[communication].[IncomingXmlQueue]') AND name = N'indIncomingXmlQueue_order')
CREATE NONCLUSTERED INDEX [indIncomingXmlQueue_order] ON [communication].[IncomingXmlQueue]
(
	[order] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[communication].[IncomingXmlQueue]') AND name = N'indIncomingXmlQueue_transactionGuid')
CREATE NONCLUSTERED INDEX [indIncomingXmlQueue_transactionGuid] ON [communication].[IncomingXmlQueue]
(
	[localTransactionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[communication].[DF_IncomingXmlQueue_isComplited]') AND type = 'D')
BEGIN
ALTER TABLE [communication].[IncomingXmlQueue] ADD  CONSTRAINT [DF_IncomingXmlQueue_isComplited]  DEFAULT ((0)) FOR [isComplited]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[communication].[DF_IncomingXmlQueue_receiveDate]') AND type = 'D')
BEGIN
ALTER TABLE [communication].[IncomingXmlQueue] ADD  CONSTRAINT [DF_IncomingXmlQueue_receiveDate]  DEFAULT (getdate()) FOR [receiveDate]
END

GO

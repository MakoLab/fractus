/*
name=[tools].[UserMessage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
yiMrQGuE/sdz3fXpHSfgPw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[UserMessage]') AND type in (N'U'))
BEGIN
CREATE TABLE [tools].[UserMessage](
	[id] [uniqueidentifier] NULL,
	[date] [datetime] NULL,
	[applicationUserId] [uniqueidentifier] NULL,
	[title] [varchar](200) NULL,
	[messageText] [varchar](500) NULL,
	[receiverId] [uniqueidentifier] NULL,
	[receiveDate] [datetime] NULL,
	[branchId] [uniqueidentifier] NULL,
	[receiverBranchId] [uniqueidentifier] NULL
) ON [PRIMARY]
END
GO

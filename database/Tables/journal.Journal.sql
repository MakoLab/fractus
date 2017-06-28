/*
name=[journal].[Journal]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
sI9KERmaZXi9FTki3tyUUg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[journal].[Journal]') AND type in (N'U'))
BEGIN
CREATE TABLE [journal].[Journal](
	[id] [uniqueidentifier] NOT NULL,
	[date] [datetime] NOT NULL,
	[applicationUserId] [uniqueidentifier] NULL,
	[journalActionId] [uniqueidentifier] NOT NULL,
	[firstObjectId] [uniqueidentifier] NULL,
	[secondObjectId] [uniqueidentifier] NULL,
	[thirdObjectId] [uniqueidentifier] NULL,
	[xmlParams] [xml] NULL,
	[kernelVersion] [varchar](20) NOT NULL,
 CONSTRAINT [PK_Journal] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[journal].[Journal]') AND name = N'indJournal_applicationUserId')
CREATE NONCLUSTERED INDEX [indJournal_applicationUserId] ON [journal].[Journal]
(
	[applicationUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[journal].[Journal]') AND name = N'indJournal_firstObjectId')
CREATE NONCLUSTERED INDEX [indJournal_firstObjectId] ON [journal].[Journal]
(
	[firstObjectId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[journal].[Journal]') AND name = N'indJournal_journalActionId')
CREATE NONCLUSTERED INDEX [indJournal_journalActionId] ON [journal].[Journal]
(
	[journalActionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[journal].[Journal]') AND name = N'indJournal_secondObjectId')
CREATE NONCLUSTERED INDEX [indJournal_secondObjectId] ON [journal].[Journal]
(
	[secondObjectId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[journal].[DF_Journal_date]') AND type = 'D')
BEGIN
ALTER TABLE [journal].[Journal] ADD  CONSTRAINT [DF_Journal_date]  DEFAULT (getdate()) FOR [date]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[journal].[FK_Journal_ApplicationUser]') AND parent_object_id = OBJECT_ID(N'[journal].[Journal]'))
ALTER TABLE [journal].[Journal]  WITH CHECK ADD  CONSTRAINT [FK_Journal_ApplicationUser] FOREIGN KEY([applicationUserId])
REFERENCES [contractor].[ApplicationUser] ([contractorId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[journal].[FK_Journal_ApplicationUser]') AND parent_object_id = OBJECT_ID(N'[journal].[Journal]'))
ALTER TABLE [journal].[Journal] CHECK CONSTRAINT [FK_Journal_ApplicationUser]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[journal].[FK_Journal_JournalAction]') AND parent_object_id = OBJECT_ID(N'[journal].[Journal]'))
ALTER TABLE [journal].[Journal]  WITH CHECK ADD  CONSTRAINT [FK_Journal_JournalAction] FOREIGN KEY([journalActionId])
REFERENCES [journal].[JournalAction] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[journal].[FK_Journal_JournalAction]') AND parent_object_id = OBJECT_ID(N'[journal].[Journal]'))
ALTER TABLE [journal].[Journal] CHECK CONSTRAINT [FK_Journal_JournalAction]
GO

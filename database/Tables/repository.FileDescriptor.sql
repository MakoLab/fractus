/*
name=[repository].[FileDescriptor]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4FUQULoiRM6JTFKN0GNqNA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[repository].[FileDescriptor]') AND type in (N'U'))
BEGIN
CREATE TABLE [repository].[FileDescriptor](
	[id] [uniqueidentifier] NOT NULL,
	[repositoryId] [uniqueidentifier] NOT NULL,
	[mimeTypeId] [uniqueidentifier] NOT NULL,
	[modificationDate] [datetime] NOT NULL,
	[modificationApplicationUserId] [uniqueidentifier] NOT NULL,
	[originalFilename] [nvarchar](256) NOT NULL,
	[tag] [nvarchar](500) NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_FileDescriptor] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[repository].[FileDescriptor]') AND name = N'indFileDescriptor_mimeTypeId')
CREATE NONCLUSTERED INDEX [indFileDescriptor_mimeTypeId] ON [repository].[FileDescriptor]
(
	[mimeTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[repository].[FileDescriptor]') AND name = N'indFileDescriptor_modificationApplicationUserId')
CREATE NONCLUSTERED INDEX [indFileDescriptor_modificationApplicationUserId] ON [repository].[FileDescriptor]
(
	[modificationApplicationUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[repository].[FileDescriptor]') AND name = N'indFileDescriptor_repositoryId')
CREATE NONCLUSTERED INDEX [indFileDescriptor_repositoryId] ON [repository].[FileDescriptor]
(
	[repositoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[repository].[FK_FileDescriptor_ApplicationUser]') AND parent_object_id = OBJECT_ID(N'[repository].[FileDescriptor]'))
ALTER TABLE [repository].[FileDescriptor]  WITH CHECK ADD  CONSTRAINT [FK_FileDescriptor_ApplicationUser] FOREIGN KEY([modificationApplicationUserId])
REFERENCES [contractor].[ApplicationUser] ([contractorId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[repository].[FK_FileDescriptor_ApplicationUser]') AND parent_object_id = OBJECT_ID(N'[repository].[FileDescriptor]'))
ALTER TABLE [repository].[FileDescriptor] CHECK CONSTRAINT [FK_FileDescriptor_ApplicationUser]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[repository].[FK_FileDescriptor_MimeType]') AND parent_object_id = OBJECT_ID(N'[repository].[FileDescriptor]'))
ALTER TABLE [repository].[FileDescriptor]  WITH CHECK ADD  CONSTRAINT [FK_FileDescriptor_MimeType] FOREIGN KEY([mimeTypeId])
REFERENCES [dictionary].[MimeType] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[repository].[FK_FileDescriptor_MimeType]') AND parent_object_id = OBJECT_ID(N'[repository].[FileDescriptor]'))
ALTER TABLE [repository].[FileDescriptor] CHECK CONSTRAINT [FK_FileDescriptor_MimeType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[repository].[FK_FileDescriptor_Repository]') AND parent_object_id = OBJECT_ID(N'[repository].[FileDescriptor]'))
ALTER TABLE [repository].[FileDescriptor]  WITH CHECK ADD  CONSTRAINT [FK_FileDescriptor_Repository] FOREIGN KEY([repositoryId])
REFERENCES [dictionary].[Repository] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[repository].[FK_FileDescriptor_Repository]') AND parent_object_id = OBJECT_ID(N'[repository].[FileDescriptor]'))
ALTER TABLE [repository].[FileDescriptor] CHECK CONSTRAINT [FK_FileDescriptor_Repository]
GO

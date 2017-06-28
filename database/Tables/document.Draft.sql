/*
name=[document].[Draft]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
qI71WvTl1llucJ1oZc/PlA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[Draft]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[Draft](
	[id] [uniqueidentifier] NOT NULL,
	[documentTypeId] [uniqueidentifier] NOT NULL,
	[date] [datetime] NOT NULL,
	[applicationUserId] [uniqueidentifier] NOT NULL,
	[contractorId] [uniqueidentifier] NULL,
	[dataXml] [xml] NOT NULL,
 CONSTRAINT [PK_Draft] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_Draft_ApplicationUser]') AND parent_object_id = OBJECT_ID(N'[document].[Draft]'))
ALTER TABLE [document].[Draft]  WITH CHECK ADD  CONSTRAINT [FK_Draft_ApplicationUser] FOREIGN KEY([applicationUserId])
REFERENCES [contractor].[ApplicationUser] ([contractorId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_Draft_ApplicationUser]') AND parent_object_id = OBJECT_ID(N'[document].[Draft]'))
ALTER TABLE [document].[Draft] CHECK CONSTRAINT [FK_Draft_ApplicationUser]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_Draft_Contractor]') AND parent_object_id = OBJECT_ID(N'[document].[Draft]'))
ALTER TABLE [document].[Draft]  WITH CHECK ADD  CONSTRAINT [FK_Draft_Contractor] FOREIGN KEY([contractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_Draft_Contractor]') AND parent_object_id = OBJECT_ID(N'[document].[Draft]'))
ALTER TABLE [document].[Draft] CHECK CONSTRAINT [FK_Draft_Contractor]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_Draft_DocumentType]') AND parent_object_id = OBJECT_ID(N'[document].[Draft]'))
ALTER TABLE [document].[Draft]  WITH CHECK ADD  CONSTRAINT [FK_Draft_DocumentType] FOREIGN KEY([documentTypeId])
REFERENCES [dictionary].[DocumentType] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_Draft_DocumentType]') AND parent_object_id = OBJECT_ID(N'[document].[Draft]'))
ALTER TABLE [document].[Draft] CHECK CONSTRAINT [FK_Draft_DocumentType]
GO

/*
name=[contractor].[ApplicationUser]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
amd1+Ctq2XnfQ2rzpi7+7Q==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[ApplicationUser]') AND type in (N'U'))
BEGIN
CREATE TABLE [contractor].[ApplicationUser](
	[contractorId] [uniqueidentifier] NOT NULL,
	[login] [nvarchar](50) NOT NULL,
	[password] [varchar](64) NULL,
	[version] [uniqueidentifier] NOT NULL,
	[permissionProfile] [varchar](100) NOT NULL,
	[restrictDatabaseId] [uniqueidentifier] NULL,
	[isActive] [bit] NULL,
 CONSTRAINT [PK_User_1] PRIMARY KEY CLUSTERED 
(
	[contractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[ApplicationUser]') AND name = N'indUser_login')
CREATE NONCLUSTERED INDEX [indUser_login] ON [contractor].[ApplicationUser]
(
	[login] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_User_Contractor]') AND parent_object_id = OBJECT_ID(N'[contractor].[ApplicationUser]'))
ALTER TABLE [contractor].[ApplicationUser]  WITH CHECK ADD  CONSTRAINT [FK_User_Contractor] FOREIGN KEY([contractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_User_Contractor]') AND parent_object_id = OBJECT_ID(N'[contractor].[ApplicationUser]'))
ALTER TABLE [contractor].[ApplicationUser] CHECK CONSTRAINT [FK_User_Contractor]
GO

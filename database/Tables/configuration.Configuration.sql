/*
name=[configuration].[Configuration]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
C4LES2eOGi840KoDv+iicw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[Configuration]') AND type in (N'U'))
BEGIN
CREATE TABLE [configuration].[Configuration](
	[id] [uniqueidentifier] NOT NULL,
	[key] [varchar](100) NULL,
	[companyContractorId] [uniqueidentifier] NULL,
	[branchId] [uniqueidentifier] NULL,
	[userProfileId] [uniqueidentifier] NULL,
	[workstationId] [uniqueidentifier] NULL,
	[applicationUserId] [uniqueidentifier] NULL,
	[textValue] [nvarchar](1000) NULL,
	[xmlValue] [xml] NULL,
	[version] [uniqueidentifier] NOT NULL,
	[modificationDate] [datetime] NULL,
	[modificationUserName] [nvarchar](300) NULL,
 CONSTRAINT [PK_Configuration] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[configuration].[Configuration]') AND name = N'ind_Configuration_key')
CREATE NONCLUSTERED INDEX [ind_Configuration_key] ON [configuration].[Configuration]
(
	[key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[configuration].[Configuration]') AND name = N'indConfiguration_applicationUserId')
CREATE NONCLUSTERED INDEX [indConfiguration_applicationUserId] ON [configuration].[Configuration]
(
	[applicationUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[configuration].[Configuration]') AND name = N'indConfiguration_companyContractorId')
CREATE NONCLUSTERED INDEX [indConfiguration_companyContractorId] ON [configuration].[Configuration]
(
	[companyContractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[configuration].[Configuration]') AND name = N'indConfiguration_pointId')
CREATE NONCLUSTERED INDEX [indConfiguration_pointId] ON [configuration].[Configuration]
(
	[branchId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[configuration].[Configuration]') AND name = N'indConfiguration_userProfileId')
CREATE NONCLUSTERED INDEX [indConfiguration_userProfileId] ON [configuration].[Configuration]
(
	[userProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[configuration].[Configuration]') AND name = N'indConfiguration_workstationId')
CREATE NONCLUSTERED INDEX [indConfiguration_workstationId] ON [configuration].[Configuration]
(
	[workstationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[configuration].[DF_Configuration_id]') AND type = 'D')
BEGIN
ALTER TABLE [configuration].[Configuration] ADD  CONSTRAINT [DF_Configuration_id]  DEFAULT (newid()) FOR [id]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[configuration].[FK_Configuration_ApplicationUser]') AND parent_object_id = OBJECT_ID(N'[configuration].[Configuration]'))
ALTER TABLE [configuration].[Configuration]  WITH CHECK ADD  CONSTRAINT [FK_Configuration_ApplicationUser] FOREIGN KEY([applicationUserId])
REFERENCES [contractor].[ApplicationUser] ([contractorId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[configuration].[FK_Configuration_ApplicationUser]') AND parent_object_id = OBJECT_ID(N'[configuration].[Configuration]'))
ALTER TABLE [configuration].[Configuration] CHECK CONSTRAINT [FK_Configuration_ApplicationUser]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[configuration].[FK_Configuration_Contractor]') AND parent_object_id = OBJECT_ID(N'[configuration].[Configuration]'))
ALTER TABLE [configuration].[Configuration]  WITH CHECK ADD  CONSTRAINT [FK_Configuration_Contractor] FOREIGN KEY([companyContractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[configuration].[FK_Configuration_Contractor]') AND parent_object_id = OBJECT_ID(N'[configuration].[Configuration]'))
ALTER TABLE [configuration].[Configuration] CHECK CONSTRAINT [FK_Configuration_Contractor]
GO

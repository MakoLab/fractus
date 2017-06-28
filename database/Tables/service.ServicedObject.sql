/*
name=[service].[ServicedObject]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fgv4KDjEtUNegCX81SaQ5g==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[ServicedObject]') AND type in (N'U'))
BEGIN
CREATE TABLE [service].[ServicedObject](
	[id] [uniqueidentifier] NOT NULL,
	[identifier] [nvarchar](50) NOT NULL,
	[servicedObjectTypeId] [uniqueidentifier] NULL,
	[ownerContractorId] [uniqueidentifier] NULL,
	[creationDate] [datetime] NOT NULL,
	[modificationDate] [datetime] NULL,
	[version] [uniqueidentifier] NOT NULL,
	[remarks] [nvarchar](500) NULL,
	[description] [nvarchar](500) NULL,
 CONSTRAINT [PK_ServicedObject] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[service].[ServicedObject]') AND name = N'ind_ServicedObject_contractor')
CREATE NONCLUSTERED INDEX [ind_ServicedObject_contractor] ON [service].[ServicedObject]
(
	[ownerContractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[service].[DF_ServicedObject_creationDate]') AND type = 'D')
BEGIN
ALTER TABLE [service].[ServicedObject] ADD  CONSTRAINT [DF_ServicedObject_creationDate]  DEFAULT (getdate()) FOR [creationDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[service].[FK_ServicedObject_contractor]') AND parent_object_id = OBJECT_ID(N'[service].[ServicedObject]'))
ALTER TABLE [service].[ServicedObject]  WITH CHECK ADD  CONSTRAINT [FK_ServicedObject_contractor] FOREIGN KEY([ownerContractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[service].[FK_ServicedObject_contractor]') AND parent_object_id = OBJECT_ID(N'[service].[ServicedObject]'))
ALTER TABLE [service].[ServicedObject] CHECK CONSTRAINT [FK_ServicedObject_contractor]
GO

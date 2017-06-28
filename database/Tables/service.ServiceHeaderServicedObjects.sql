/*
name=[service].[ServiceHeaderServicedObjects]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
aSLWQMeDveueg43E/cfRPg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[ServiceHeaderServicedObjects]') AND type in (N'U'))
BEGIN
CREATE TABLE [service].[ServiceHeaderServicedObjects](
	[id] [uniqueidentifier] NOT NULL,
	[serviceHeaderId] [uniqueidentifier] NOT NULL,
	[servicedObjectId] [uniqueidentifier] NULL,
	[incomeDate] [datetime] NULL,
	[outcomeDate] [datetime] NULL,
	[plannedEndDate] [datetime] NULL,
	[creationDate] [datetime] NULL,
	[description] [nvarchar](max) NULL,
	[ordinalNumber] [int] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ServiceHeaderServicedObjects] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[service].[ServiceHeaderServicedObjects]') AND name = N'ind_ServiceHeaderServicedObjects_ServicedObject')
CREATE NONCLUSTERED INDEX [ind_ServiceHeaderServicedObjects_ServicedObject] ON [service].[ServiceHeaderServicedObjects]
(
	[servicedObjectId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[service].[ServiceHeaderServicedObjects]') AND name = N'ind_ServiceHeaderServicedObjects_serviceHeader')
CREATE NONCLUSTERED INDEX [ind_ServiceHeaderServicedObjects_serviceHeader] ON [service].[ServiceHeaderServicedObjects]
(
	[serviceHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[service].[DF_ServiceHeaderServicedObjects_1_creationDate]') AND type = 'D')
BEGIN
ALTER TABLE [service].[ServiceHeaderServicedObjects] ADD  CONSTRAINT [DF_ServiceHeaderServicedObjects_1_creationDate]  DEFAULT (getdate()) FOR [creationDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[service].[FK_ServiceHeaderServicedObjects_ServicedObject]') AND parent_object_id = OBJECT_ID(N'[service].[ServiceHeaderServicedObjects]'))
ALTER TABLE [service].[ServiceHeaderServicedObjects]  WITH CHECK ADD  CONSTRAINT [FK_ServiceHeaderServicedObjects_ServicedObject] FOREIGN KEY([servicedObjectId])
REFERENCES [service].[ServicedObject] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[service].[FK_ServiceHeaderServicedObjects_ServicedObject]') AND parent_object_id = OBJECT_ID(N'[service].[ServiceHeaderServicedObjects]'))
ALTER TABLE [service].[ServiceHeaderServicedObjects] CHECK CONSTRAINT [FK_ServiceHeaderServicedObjects_ServicedObject]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[service].[FK_ServiceHeaderServicedObjects_serviceHeader]') AND parent_object_id = OBJECT_ID(N'[service].[ServiceHeaderServicedObjects]'))
ALTER TABLE [service].[ServiceHeaderServicedObjects]  WITH CHECK ADD  CONSTRAINT [FK_ServiceHeaderServicedObjects_serviceHeader] FOREIGN KEY([serviceHeaderId])
REFERENCES [service].[ServiceHeader] ([commercialDocumentHeaderId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[service].[FK_ServiceHeaderServicedObjects_serviceHeader]') AND parent_object_id = OBJECT_ID(N'[service].[ServiceHeaderServicedObjects]'))
ALTER TABLE [service].[ServiceHeaderServicedObjects] CHECK CONSTRAINT [FK_ServiceHeaderServicedObjects_serviceHeader]
GO

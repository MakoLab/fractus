/*
name=[service].[ServiceHeaderServicePlace]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
VdhAZD3gLQDZ/n2CxYiOBw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[ServiceHeaderServicePlace]') AND type in (N'U'))
BEGIN
CREATE TABLE [service].[ServiceHeaderServicePlace](
	[id] [uniqueidentifier] NOT NULL,
	[serviceHeaderId] [uniqueidentifier] NOT NULL,
	[servicePlaceId] [uniqueidentifier] NOT NULL,
	[workTime] [numeric](18, 6) NULL,
	[timeFraction] [numeric](18, 6) NULL,
	[plannedStartDate] [datetime] NULL,
	[plannedEndDate] [datetime] NULL,
	[creationDate] [datetime] NOT NULL,
	[description] [nvarchar](max) NULL,
	[ordinalNumber] [int] NOT NULL,
	[version] [uniqueidentifier] NULL,
 CONSTRAINT [PK_ServiceHeaderServicePlace] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[service].[ServiceHeaderServicePlace]') AND name = N'ind_ServiceHeaderServicePlace_serviceHeader')
CREATE NONCLUSTERED INDEX [ind_ServiceHeaderServicePlace_serviceHeader] ON [service].[ServiceHeaderServicePlace]
(
	[serviceHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[service].[ServiceHeaderServicePlace]') AND name = N'ind_ServiceHeaderServicePlace_ServicePlace')
CREATE NONCLUSTERED INDEX [ind_ServiceHeaderServicePlace_ServicePlace] ON [service].[ServiceHeaderServicePlace]
(
	[servicePlaceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[service].[DF_ServiceHeaderServicePlace_1_creationDate]') AND type = 'D')
BEGIN
ALTER TABLE [service].[ServiceHeaderServicePlace] ADD  CONSTRAINT [DF_ServiceHeaderServicePlace_1_creationDate]  DEFAULT (getdate()) FOR [creationDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[service].[FK_ServiceHeaderServicePlace_serviceHeader]') AND parent_object_id = OBJECT_ID(N'[service].[ServiceHeaderServicePlace]'))
ALTER TABLE [service].[ServiceHeaderServicePlace]  WITH CHECK ADD  CONSTRAINT [FK_ServiceHeaderServicePlace_serviceHeader] FOREIGN KEY([serviceHeaderId])
REFERENCES [service].[ServiceHeader] ([commercialDocumentHeaderId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[service].[FK_ServiceHeaderServicePlace_serviceHeader]') AND parent_object_id = OBJECT_ID(N'[service].[ServiceHeaderServicePlace]'))
ALTER TABLE [service].[ServiceHeaderServicePlace] CHECK CONSTRAINT [FK_ServiceHeaderServicePlace_serviceHeader]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[service].[FK_ServiceHeaderServicePlace_ServicePlace]') AND parent_object_id = OBJECT_ID(N'[service].[ServiceHeaderServicePlace]'))
ALTER TABLE [service].[ServiceHeaderServicePlace]  WITH CHECK ADD  CONSTRAINT [FK_ServiceHeaderServicePlace_ServicePlace] FOREIGN KEY([servicePlaceId])
REFERENCES [dictionary].[ServicePlace] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[service].[FK_ServiceHeaderServicePlace_ServicePlace]') AND parent_object_id = OBJECT_ID(N'[service].[ServiceHeaderServicePlace]'))
ALTER TABLE [service].[ServiceHeaderServicePlace] CHECK CONSTRAINT [FK_ServiceHeaderServicePlace_ServicePlace]
GO

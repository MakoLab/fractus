/*
name=[service].[ServiceHeaderEmployees]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
5TjAyMFLCliOLII3QThYzA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[ServiceHeaderEmployees]') AND type in (N'U'))
BEGIN
CREATE TABLE [service].[ServiceHeaderEmployees](
	[id] [uniqueidentifier] NOT NULL,
	[serviceHeaderId] [uniqueidentifier] NOT NULL,
	[employeeId] [uniqueidentifier] NOT NULL,
	[workTime] [numeric](18, 6) NULL,
	[timeFraction] [numeric](18, 6) NULL,
	[plannedStartDate] [datetime] NULL,
	[plannedEndDate] [datetime] NULL,
	[creationDate] [datetime] NOT NULL,
	[description] [nvarchar](max) NULL,
	[ordinalNumber] [int] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ServiceHeaderEmployees] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[service].[ServiceHeaderEmployees]') AND name = N'ind_serviceHeaderEmployee_serviceHeader')
CREATE NONCLUSTERED INDEX [ind_serviceHeaderEmployee_serviceHeader] ON [service].[ServiceHeaderEmployees]
(
	[serviceHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[service].[ServiceHeaderEmployees]') AND name = N'ind_ServiceHeaderEmployees_Employee')
CREATE NONCLUSTERED INDEX [ind_ServiceHeaderEmployees_Employee] ON [service].[ServiceHeaderEmployees]
(
	[employeeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[service].[DF_ServiceHeaderEmployees_1_creationDate]') AND type = 'D')
BEGIN
ALTER TABLE [service].[ServiceHeaderEmployees] ADD  CONSTRAINT [DF_ServiceHeaderEmployees_1_creationDate]  DEFAULT (getdate()) FOR [creationDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[service].[FK_serviceHeaderEmployee_serviceHeader]') AND parent_object_id = OBJECT_ID(N'[service].[ServiceHeaderEmployees]'))
ALTER TABLE [service].[ServiceHeaderEmployees]  WITH CHECK ADD  CONSTRAINT [FK_serviceHeaderEmployee_serviceHeader] FOREIGN KEY([serviceHeaderId])
REFERENCES [service].[ServiceHeader] ([commercialDocumentHeaderId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[service].[FK_serviceHeaderEmployee_serviceHeader]') AND parent_object_id = OBJECT_ID(N'[service].[ServiceHeaderEmployees]'))
ALTER TABLE [service].[ServiceHeaderEmployees] CHECK CONSTRAINT [FK_serviceHeaderEmployee_serviceHeader]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[service].[FK_ServiceHeaderEmployees_Employee]') AND parent_object_id = OBJECT_ID(N'[service].[ServiceHeaderEmployees]'))
ALTER TABLE [service].[ServiceHeaderEmployees]  WITH CHECK ADD  CONSTRAINT [FK_ServiceHeaderEmployees_Employee] FOREIGN KEY([employeeId])
REFERENCES [contractor].[Employee] ([contractorId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[service].[FK_ServiceHeaderEmployees_Employee]') AND parent_object_id = OBJECT_ID(N'[service].[ServiceHeaderEmployees]'))
ALTER TABLE [service].[ServiceHeaderEmployees] CHECK CONSTRAINT [FK_ServiceHeaderEmployees_Employee]
GO

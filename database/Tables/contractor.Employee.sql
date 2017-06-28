/*
name=[contractor].[Employee]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
9no+I2QS3SULawT9eZyf/w==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[Employee]') AND type in (N'U'))
BEGIN
CREATE TABLE [contractor].[Employee](
	[contractorId] [uniqueidentifier] NOT NULL,
	[jobPositionId] [uniqueidentifier] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Employee_1] PRIMARY KEY CLUSTERED 
(
	[contractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[contractor].[Employee]') AND name = N'indEmployee_jobPositionId')
CREATE NONCLUSTERED INDEX [indEmployee_jobPositionId] ON [contractor].[Employee]
(
	[jobPositionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_Employee_Contractor]') AND parent_object_id = OBJECT_ID(N'[contractor].[Employee]'))
ALTER TABLE [contractor].[Employee]  WITH CHECK ADD  CONSTRAINT [FK_Employee_Contractor] FOREIGN KEY([contractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_Employee_Contractor]') AND parent_object_id = OBJECT_ID(N'[contractor].[Employee]'))
ALTER TABLE [contractor].[Employee] CHECK CONSTRAINT [FK_Employee_Contractor]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_Employee_JobPosition]') AND parent_object_id = OBJECT_ID(N'[contractor].[Employee]'))
ALTER TABLE [contractor].[Employee]  WITH CHECK ADD  CONSTRAINT [FK_Employee_JobPosition] FOREIGN KEY([jobPositionId])
REFERENCES [dictionary].[JobPosition] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_Employee_JobPosition]') AND parent_object_id = OBJECT_ID(N'[contractor].[Employee]'))
ALTER TABLE [contractor].[Employee] CHECK CONSTRAINT [FK_Employee_JobPosition]
GO

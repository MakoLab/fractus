/*
name=[dictionary].[Unit]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
jm4k4SjwhgvhQ6PLIBs0RQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[Unit]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[Unit](
	[id] [uniqueidentifier] NOT NULL,
	[unitTypeId] [uniqueidentifier] NOT NULL,
	[conversionRate] [numeric](16, 8) NOT NULL,
	[xmlLabels] [xml] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
 CONSTRAINT [PK_Unit] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dictionary].[Unit]') AND name = N'ind_Unit_UnitType')
CREATE NONCLUSTERED INDEX [ind_Unit_UnitType] ON [dictionary].[Unit]
(
	[unitTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dictionary].[FK_Unit_UnitType]') AND parent_object_id = OBJECT_ID(N'[dictionary].[Unit]'))
ALTER TABLE [dictionary].[Unit]  WITH CHECK ADD  CONSTRAINT [FK_Unit_UnitType] FOREIGN KEY([unitTypeId])
REFERENCES [dictionary].[UnitType] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dictionary].[FK_Unit_UnitType]') AND parent_object_id = OBJECT_ID(N'[dictionary].[Unit]'))
ALTER TABLE [dictionary].[Unit] CHECK CONSTRAINT [FK_Unit_UnitType]
GO

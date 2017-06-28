/*
name=[dictionary].[UnitType]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
O/FBaH1tMxPjuKsskka3vw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[UnitType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[UnitType](
	[id] [uniqueidentifier] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[baseUnitId] [uniqueidentifier] NULL,
	[xmlLabels] [xml] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
 CONSTRAINT [PK_UnitType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dictionary].[UnitType]') AND name = N'ind_UnitType_Unit')
CREATE NONCLUSTERED INDEX [ind_UnitType_Unit] ON [dictionary].[UnitType]
(
	[baseUnitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dictionary].[FK_UnitType_Unit]') AND parent_object_id = OBJECT_ID(N'[dictionary].[UnitType]'))
ALTER TABLE [dictionary].[UnitType]  WITH CHECK ADD  CONSTRAINT [FK_UnitType_Unit] FOREIGN KEY([baseUnitId])
REFERENCES [dictionary].[Unit] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dictionary].[FK_UnitType_Unit]') AND parent_object_id = OBJECT_ID(N'[dictionary].[UnitType]'))
ALTER TABLE [dictionary].[UnitType] CHECK CONSTRAINT [FK_UnitType_Unit]
GO

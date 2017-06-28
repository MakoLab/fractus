/*
name=[warehouse].[ContainerShift]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
BZcCEO9cuppxmphttT6vlA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[ContainerShift]') AND type in (N'U'))
BEGIN
CREATE TABLE [warehouse].[ContainerShift](
	[id] [uniqueidentifier] NOT NULL,
	[containerId] [uniqueidentifier] NOT NULL,
	[parentContainerId] [uniqueidentifier] NOT NULL,
	[slotContainerId] [uniqueidentifier] NULL,
	[shiftTransactionId] [uniqueidentifier] NOT NULL,
	[ordinalNumber] [int] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ContainerShift] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[warehouse].[ContainerShift]') AND name = N'ind_ContainerShift_Container')
CREATE NONCLUSTERED INDEX [ind_ContainerShift_Container] ON [warehouse].[ContainerShift]
(
	[containerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[warehouse].[ContainerShift]') AND name = N'ind_ContainerShift_ShiftTransaction')
CREATE NONCLUSTERED INDEX [ind_ContainerShift_ShiftTransaction] ON [warehouse].[ContainerShift]
(
	[shiftTransactionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[warehouse].[FK_ContainerShift_Container]') AND parent_object_id = OBJECT_ID(N'[warehouse].[ContainerShift]'))
ALTER TABLE [warehouse].[ContainerShift]  WITH CHECK ADD  CONSTRAINT [FK_ContainerShift_Container] FOREIGN KEY([containerId])
REFERENCES [warehouse].[Container] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[warehouse].[FK_ContainerShift_Container]') AND parent_object_id = OBJECT_ID(N'[warehouse].[ContainerShift]'))
ALTER TABLE [warehouse].[ContainerShift] CHECK CONSTRAINT [FK_ContainerShift_Container]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[warehouse].[FK_ContainerShift_ShiftTransaction]') AND parent_object_id = OBJECT_ID(N'[warehouse].[ContainerShift]'))
ALTER TABLE [warehouse].[ContainerShift]  WITH CHECK ADD  CONSTRAINT [FK_ContainerShift_ShiftTransaction] FOREIGN KEY([shiftTransactionId])
REFERENCES [warehouse].[ShiftTransaction] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[warehouse].[FK_ContainerShift_ShiftTransaction]') AND parent_object_id = OBJECT_ID(N'[warehouse].[ContainerShift]'))
ALTER TABLE [warehouse].[ContainerShift] CHECK CONSTRAINT [FK_ContainerShift_ShiftTransaction]
GO

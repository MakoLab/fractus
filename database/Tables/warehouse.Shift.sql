/*
name=[warehouse].[Shift]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
BCWUMsnucD7fyqfQLRHP+Q==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[Shift]') AND type in (N'U'))
BEGIN
CREATE TABLE [warehouse].[Shift](
	[id] [uniqueidentifier] NOT NULL,
	[shiftTransactionId] [uniqueidentifier] NOT NULL,
	[incomeWarehouseDocumentLineId] [uniqueidentifier] NOT NULL,
	[warehouseId] [uniqueidentifier] NOT NULL,
	[containerId] [uniqueidentifier] NULL,
	[quantity] [numeric](18, 6) NOT NULL,
	[warehouseDocumentLineId] [uniqueidentifier] NULL,
	[sourceShiftId] [uniqueidentifier] NULL,
	[status] [int] NOT NULL,
	[ordinalNumber] [int] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Shifts] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[warehouse].[Shift]') AND name = N'ind_Shift_Container')
CREATE NONCLUSTERED INDEX [ind_Shift_Container] ON [warehouse].[Shift]
(
	[containerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[warehouse].[Shift]') AND name = N'ind_Shift_IncomeWarehouseDocumentLine')
CREATE NONCLUSTERED INDEX [ind_Shift_IncomeWarehouseDocumentLine] ON [warehouse].[Shift]
(
	[incomeWarehouseDocumentLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[warehouse].[Shift]') AND name = N'ind_Shift_Shift')
CREATE NONCLUSTERED INDEX [ind_Shift_Shift] ON [warehouse].[Shift]
(
	[sourceShiftId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[warehouse].[Shift]') AND name = N'ind_Shift_ShiftTransaction')
CREATE NONCLUSTERED INDEX [ind_Shift_ShiftTransaction] ON [warehouse].[Shift]
(
	[shiftTransactionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[warehouse].[Shift]') AND name = N'ind_Shift_WarehouseDocumentLine')
CREATE NONCLUSTERED INDEX [ind_Shift_WarehouseDocumentLine] ON [warehouse].[Shift]
(
	[warehouseDocumentLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[warehouse].[FK_Shift_Container]') AND parent_object_id = OBJECT_ID(N'[warehouse].[Shift]'))
ALTER TABLE [warehouse].[Shift]  WITH CHECK ADD  CONSTRAINT [FK_Shift_Container] FOREIGN KEY([containerId])
REFERENCES [warehouse].[Container] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[warehouse].[FK_Shift_Container]') AND parent_object_id = OBJECT_ID(N'[warehouse].[Shift]'))
ALTER TABLE [warehouse].[Shift] CHECK CONSTRAINT [FK_Shift_Container]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[warehouse].[FK_Shift_IncomeWarehouseDocumentLine]') AND parent_object_id = OBJECT_ID(N'[warehouse].[Shift]'))
ALTER TABLE [warehouse].[Shift]  WITH CHECK ADD  CONSTRAINT [FK_Shift_IncomeWarehouseDocumentLine] FOREIGN KEY([incomeWarehouseDocumentLineId])
REFERENCES [document].[WarehouseDocumentLine] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[warehouse].[FK_Shift_IncomeWarehouseDocumentLine]') AND parent_object_id = OBJECT_ID(N'[warehouse].[Shift]'))
ALTER TABLE [warehouse].[Shift] CHECK CONSTRAINT [FK_Shift_IncomeWarehouseDocumentLine]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[warehouse].[FK_Shift_Shift]') AND parent_object_id = OBJECT_ID(N'[warehouse].[Shift]'))
ALTER TABLE [warehouse].[Shift]  WITH CHECK ADD  CONSTRAINT [FK_Shift_Shift] FOREIGN KEY([sourceShiftId])
REFERENCES [warehouse].[Shift] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[warehouse].[FK_Shift_Shift]') AND parent_object_id = OBJECT_ID(N'[warehouse].[Shift]'))
ALTER TABLE [warehouse].[Shift] CHECK CONSTRAINT [FK_Shift_Shift]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[warehouse].[FK_Shift_ShiftTransaction]') AND parent_object_id = OBJECT_ID(N'[warehouse].[Shift]'))
ALTER TABLE [warehouse].[Shift]  WITH CHECK ADD  CONSTRAINT [FK_Shift_ShiftTransaction] FOREIGN KEY([shiftTransactionId])
REFERENCES [warehouse].[ShiftTransaction] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[warehouse].[FK_Shift_ShiftTransaction]') AND parent_object_id = OBJECT_ID(N'[warehouse].[Shift]'))
ALTER TABLE [warehouse].[Shift] CHECK CONSTRAINT [FK_Shift_ShiftTransaction]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[warehouse].[FK_Shift_WarehouseDocumentLine]') AND parent_object_id = OBJECT_ID(N'[warehouse].[Shift]'))
ALTER TABLE [warehouse].[Shift]  WITH CHECK ADD  CONSTRAINT [FK_Shift_WarehouseDocumentLine] FOREIGN KEY([warehouseDocumentLineId])
REFERENCES [document].[WarehouseDocumentLine] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[warehouse].[FK_Shift_WarehouseDocumentLine]') AND parent_object_id = OBJECT_ID(N'[warehouse].[Shift]'))
ALTER TABLE [warehouse].[Shift] CHECK CONSTRAINT [FK_Shift_WarehouseDocumentLine]
GO

/*
name=[document].[IncomeOutcomeRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
sFCpVrqzZDXNkpyShuEv/w==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[IncomeOutcomeRelation]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[IncomeOutcomeRelation](
	[id] [uniqueidentifier] NOT NULL,
	[incomeWarehouseDocumentLineId] [uniqueidentifier] NOT NULL,
	[outcomeWarehouseDocumentLineId] [uniqueidentifier] NOT NULL,
	[incomeDate] [datetime] NOT NULL,
	[quantity] [numeric](18, 6) NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_IncomeOutcomeRelation] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[IncomeOutcomeRelation]') AND name = N'ind_IncomeOutcomeRelation_incomeWarehouseDocumentLineId')
CREATE NONCLUSTERED INDEX [ind_IncomeOutcomeRelation_incomeWarehouseDocumentLineId] ON [document].[IncomeOutcomeRelation]
(
	[incomeWarehouseDocumentLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[IncomeOutcomeRelation]') AND name = N'ind_IncomeOutcomeRelation_outcomeWarehouseDocumentLineId')
CREATE NONCLUSTERED INDEX [ind_IncomeOutcomeRelation_outcomeWarehouseDocumentLineId] ON [document].[IncomeOutcomeRelation]
(
	[outcomeWarehouseDocumentLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_IncomeOutcomeRelation_WarehouseDocumentLine_income]') AND parent_object_id = OBJECT_ID(N'[document].[IncomeOutcomeRelation]'))
ALTER TABLE [document].[IncomeOutcomeRelation]  WITH CHECK ADD  CONSTRAINT [FK_IncomeOutcomeRelation_WarehouseDocumentLine_income] FOREIGN KEY([incomeWarehouseDocumentLineId])
REFERENCES [document].[WarehouseDocumentLine] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_IncomeOutcomeRelation_WarehouseDocumentLine_income]') AND parent_object_id = OBJECT_ID(N'[document].[IncomeOutcomeRelation]'))
ALTER TABLE [document].[IncomeOutcomeRelation] CHECK CONSTRAINT [FK_IncomeOutcomeRelation_WarehouseDocumentLine_income]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_IncomeOutcomeRelation_WarehouseDocumentLine_outcome]') AND parent_object_id = OBJECT_ID(N'[document].[IncomeOutcomeRelation]'))
ALTER TABLE [document].[IncomeOutcomeRelation]  WITH CHECK ADD  CONSTRAINT [FK_IncomeOutcomeRelation_WarehouseDocumentLine_outcome] FOREIGN KEY([outcomeWarehouseDocumentLineId])
REFERENCES [document].[WarehouseDocumentLine] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_IncomeOutcomeRelation_WarehouseDocumentLine_outcome]') AND parent_object_id = OBJECT_ID(N'[document].[IncomeOutcomeRelation]'))
ALTER TABLE [document].[IncomeOutcomeRelation] CHECK CONSTRAINT [FK_IncomeOutcomeRelation_WarehouseDocumentLine_outcome]
GO

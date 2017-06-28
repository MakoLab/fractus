/*
name=[item].[ItemUnitRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
/Cr8plygaTtHajFucaXJxQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[ItemUnitRelation]') AND type in (N'U'))
BEGIN
CREATE TABLE [item].[ItemUnitRelation](
	[id] [uniqueidentifier] NOT NULL,
	[itemId] [uniqueidentifier] NOT NULL,
	[unitId] [uniqueidentifier] NOT NULL,
	[precision] [decimal](16, 8) NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ItemUnit] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[ItemUnitRelation]') AND name = N'indItemUnitRelation_itemId')
CREATE NONCLUSTERED INDEX [indItemUnitRelation_itemId] ON [item].[ItemUnitRelation]
(
	[itemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[ItemUnitRelation]') AND name = N'indItemUnitRelation_unitId')
CREATE NONCLUSTERED INDEX [indItemUnitRelation_unitId] ON [item].[ItemUnitRelation]
(
	[unitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemUnit_Item]') AND parent_object_id = OBJECT_ID(N'[item].[ItemUnitRelation]'))
ALTER TABLE [item].[ItemUnitRelation]  WITH CHECK ADD  CONSTRAINT [FK_ItemUnit_Item] FOREIGN KEY([itemId])
REFERENCES [item].[Item] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemUnit_Item]') AND parent_object_id = OBJECT_ID(N'[item].[ItemUnitRelation]'))
ALTER TABLE [item].[ItemUnitRelation] CHECK CONSTRAINT [FK_ItemUnit_Item]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemUnit_Unit]') AND parent_object_id = OBJECT_ID(N'[item].[ItemUnitRelation]'))
ALTER TABLE [item].[ItemUnitRelation]  WITH CHECK ADD  CONSTRAINT [FK_ItemUnit_Unit] FOREIGN KEY([unitId])
REFERENCES [dictionary].[Unit] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemUnit_Unit]') AND parent_object_id = OBJECT_ID(N'[item].[ItemUnitRelation]'))
ALTER TABLE [item].[ItemUnitRelation] CHECK CONSTRAINT [FK_ItemUnit_Unit]
GO

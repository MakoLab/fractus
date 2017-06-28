/*
name=[dictionary].[Warehouse]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
9sdgiY9xeSskE/EtoJ20EA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[Warehouse]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[Warehouse](
	[id] [uniqueidentifier] NOT NULL,
	[symbol] [varchar](5) NOT NULL,
	[branchId] [uniqueidentifier] NOT NULL,
	[isActive] [bit] NOT NULL,
	[xmlLabels] [xml] NOT NULL,
	[xmlMetadata] [xml] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
	[valuationMethod] [int] NOT NULL,
	[issuePlaceId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Warehouse] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dictionary].[Warehouse]') AND name = N'ind_Warehouse_IssuePlace')
CREATE NONCLUSTERED INDEX [ind_Warehouse_IssuePlace] ON [dictionary].[Warehouse]
(
	[issuePlaceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dictionary].[DF_Warehouse_valuationMethod]') AND type = 'D')
BEGIN
ALTER TABLE [dictionary].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_valuationMethod]  DEFAULT ((0)) FOR [valuationMethod]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dictionary].[FK_Warehouse_IssuePlace]') AND parent_object_id = OBJECT_ID(N'[dictionary].[Warehouse]'))
ALTER TABLE [dictionary].[Warehouse]  WITH CHECK ADD  CONSTRAINT [FK_Warehouse_IssuePlace] FOREIGN KEY([issuePlaceId])
REFERENCES [dictionary].[IssuePlace] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dictionary].[FK_Warehouse_IssuePlace]') AND parent_object_id = OBJECT_ID(N'[dictionary].[Warehouse]'))
ALTER TABLE [dictionary].[Warehouse] CHECK CONSTRAINT [FK_Warehouse_IssuePlace]
GO

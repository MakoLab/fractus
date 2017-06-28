/*
name=[dataWarehouse].[salesOrdersRelated]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
p3WvbgsyX7uK2JQ2jHtyMg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dataWarehouse].[salesOrdersRelated]') AND type in (N'U'))
BEGIN
CREATE TABLE [dataWarehouse].[salesOrdersRelated](
	[firstCommercialDocumentHeaderId] [uniqueidentifier] NULL,
	[id] [uniqueidentifier] NOT NULL,
	[documentType] [varchar](50) NOT NULL,
	[category] [varchar](11) NOT NULL,
	[fullNumber] [nvarchar](50) NOT NULL,
	[issueDate] [char](10) NULL,
	[documentCategory] [tinyint] NOT NULL,
	[warehouseValue] [numeric](18, 2) NULL,
	[netValue] [numeric](18, 2) NULL,
	[grossValue] [numeric](18, 2) NULL,
	[z_netValue] [numeric](18, 2) NULL,
	[z_grossValue] [numeric](18, 2) NULL,
	[r_netValue] [numeric](18, 2) NULL,
	[r_grossValue] [numeric](18, 2) NULL,
	[m_grossValue] [decimal](18, 6) NULL,
	[m_flag] [int] NOT NULL,
	[hash] [varchar](50) NULL
) ON [PRIMARY]
END
GO

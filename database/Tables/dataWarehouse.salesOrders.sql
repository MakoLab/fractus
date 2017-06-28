/*
name=[dataWarehouse].[salesOrders]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
wtWm0XNazzT8DcboCgrYnw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dataWarehouse].[salesOrders]') AND type in (N'U'))
BEGIN
CREATE TABLE [dataWarehouse].[salesOrders](
	[id] [uniqueidentifier] NOT NULL,
	[fullNumber] [nvarchar](50) NOT NULL,
	[status] [int] NOT NULL,
	[issueDate] [datetime] NOT NULL,
	[shortIssueDate] [varchar](10) NULL,
	[year] [int] NULL,
	[fullName] [nvarchar](500) NOT NULL,
	[symbol] [nvarchar](50) NOT NULL,
	[code] [varchar](50) NULL,
	[grossValue] [numeric](18, 2) NOT NULL,
	[netValue] [numeric](18, 2) NOT NULL,
	[salesType] [varchar](50) NULL,
	[settlementDate] [datetime] NULL,
	[settled] [varchar](50) NULL,
	[salesmanName] [nvarchar](500) NULL,
	[salesmanCode] [varchar](50) NULL,
	[relatedOutcome] [datetime] NULL,
	[hash] [varchar](50) NULL
) ON [PRIMARY]
END
GO

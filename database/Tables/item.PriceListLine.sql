/*
name=[item].[PriceListLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
wKLDQNdr15dOXMJI+iLNgA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[PriceListLine]') AND type in (N'U'))
BEGIN
CREATE TABLE [item].[PriceListLine](
	[id] [uniqueidentifier] NOT NULL,
	[priceListHeaderId] [uniqueidentifier] NOT NULL,
	[ordinalNumber] [int] NOT NULL,
	[itemId] [uniqueidentifier] NOT NULL,
	[price] [decimal](18, 2) NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_PriceListLine] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

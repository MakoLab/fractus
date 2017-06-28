/*
name=[item].[PriceListHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ZTUE1MFyNNuW9Nznq7qoSQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[PriceListHeader]') AND type in (N'U'))
BEGIN
CREATE TABLE [item].[PriceListHeader](
	[id] [uniqueidentifier] NOT NULL,
	[name] [nvarchar](200) NULL,
	[description] [nvarchar](500) NULL,
	[creationApplicationUserId] [uniqueidentifier] NOT NULL,
	[creationDate] [datetime] NOT NULL,
	[modificationDate] [datetime] NULL,
	[modificationApplicationUserId] [uniqueidentifier] NULL,
	[priceType] [int] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[label] [nvarchar](500) NULL,
 CONSTRAINT [PK_PriceListHeader] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

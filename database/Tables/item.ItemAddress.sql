/*
name=[item].[ItemAddress]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
FWXjzhRfZj0Z6XnTufi6aw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[ItemAddress]') AND type in (N'U'))
BEGIN
CREATE TABLE [item].[ItemAddress](
	[id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[itemId] [uniqueidentifier] NOT NULL,
	[countryId] [uniqueidentifier] NOT NULL,
	[city] [nvarchar](50) NOT NULL,
	[postCode] [nvarchar](30) NOT NULL,
	[postOffice] [nvarchar](50) NOT NULL,
	[address] [nvarchar](300) NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
	[addressNumber] [nvarchar](10) NULL,
	[flatNumber] [nvarchar](10) NULL,
 CONSTRAINT [PK_ItemAddress] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

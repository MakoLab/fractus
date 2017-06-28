/*
name=[crm].[OfferLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
RlXSm5e2mmf4fmboM+4jbA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[OfferLine]') AND type in (N'U'))
BEGIN
CREATE TABLE [crm].[OfferLine](
	[id] [uniqueidentifier] NOT NULL,
	[offerId] [uniqueidentifier] NOT NULL,
	[ordinalNumber] [int] NOT NULL,
	[itemId] [uniqueidentifier] NOT NULL,
	[itemVersion] [uniqueidentifier] NOT NULL,
	[quantity] [numeric](18, 6) NOT NULL,
	[grossValue] [numeric](18, 2) NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[itemName] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_CommercialDocumentLine] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

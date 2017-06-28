/*
name=[finance].[ExchangeRate]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
/yAzBVonrlVzAk/H4wtH3w==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[ExchangeRate]') AND type in (N'U'))
BEGIN
CREATE TABLE [finance].[ExchangeRate](
	[id] [uniqueidentifier] NOT NULL,
	[exchangeRateTypeId] [uniqueidentifier] NOT NULL,
	[date] [datetime] NOT NULL,
	[currencyId] [uniqueidentifier] NOT NULL,
	[scale] [numeric](18, 0) NOT NULL,
	[rate] [numeric](18, 6) NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ExchangeRate] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[ExchangeRate]') AND name = N'indExchangeRate_currencyId')
CREATE NONCLUSTERED INDEX [indExchangeRate_currencyId] ON [finance].[ExchangeRate]
(
	[currencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_ExchangeRate_Currency]') AND parent_object_id = OBJECT_ID(N'[finance].[ExchangeRate]'))
ALTER TABLE [finance].[ExchangeRate]  WITH CHECK ADD  CONSTRAINT [FK_ExchangeRate_Currency] FOREIGN KEY([currencyId])
REFERENCES [dictionary].[Currency] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_ExchangeRate_Currency]') AND parent_object_id = OBJECT_ID(N'[finance].[ExchangeRate]'))
ALTER TABLE [finance].[ExchangeRate] CHECK CONSTRAINT [FK_ExchangeRate_Currency]
GO

/*
name=[dictionary].[ExchangeRateType]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
x8TiCNsUf7Q3Wzn+X882lw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[ExchangeRateType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[ExchangeRateType](
	[id] [uniqueidentifier] NOT NULL,
	[xmlLabels] [xml] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

/*
name=[dbo].[BankList]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
SzaUElQTl/GpQ0a7r+iRnw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BankList]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BankList](
	[NrRozl] [varchar](10) NULL,
	[NrBank] [varchar](10) NULL,
	[Nazwa] [varchar](10) NULL,
	[Symbol] [varchar](10) NULL,
	[SymbolZ] [varchar](10) NULL
) ON [PRIMARY]
END
GO

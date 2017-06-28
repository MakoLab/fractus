/*
name=[dbo].[tempv_allDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
mPHjvBEeVNAa6QyLhTdo8g==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tempv_allDocuments]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tempv_allDocuments](
	[Kategoria dokumentu] [varchar](22) NOT NULL,
	[Typ dokumentu] [varchar](20) NOT NULL,
	[Typ dokumentu nazwa] [varchar](max) NULL,
	[Numer oddziału] [nvarchar](50) NOT NULL,
	[Nazwa oddziału] [varchar](max) NULL,
	[Numer dokumentu] [nvarchar](50) NOT NULL,
	[Data wystawienia] [varchar](10) NULL,
	[Rok] [varchar](4) NULL,
	[Rok-Miesiąc] [varchar](7) NULL,
	[Dzień miesiaca] [int] NULL,
	[Dzień tygodnia] [int] NULL,
	[Godzina:Minuta] [varchar](5) NULL,
	[Godzina] [varchar](2) NULL,
	[Wartość netto] [numeric](18, 2) NULL,
	[Wartość VAT] [numeric](18, 2) NULL,
	[Wartość brutto] [numeric](18, 2) NULL,
	[Koszt dokumentu] [numeric](38, 6) NULL,
	[Marża netto dokumentu] [numeric](38, 6) NULL,
	[Marża brutto dokumentu] [numeric](38, 6) NULL,
	[Marża % dokumentu] [numeric](38, 6) NULL,
	[Data i godzina] [datetime] NOT NULL,
	[Kod kontrahenta] [varchar](50) NULL,
	[Nazwa kontrahenta] [nvarchar](40) NULL,
	[NIP] [nvarchar](40) NULL,
	[Adres] [nvarchar](max) NULL,
	[Telefon/y] [nvarchar](4000) NOT NULL,
	[Grupa kontrahenta] [varchar](1000) NULL,
	[Typ towaru] [varchar](max) NULL,
	[Grupa towarowa] [varchar](1000) NULL,
	[Producent] [nvarchar](500) NULL,
	[Nazwa Towaru] [nvarchar](200) NULL,
	[Ilość] [numeric](18, 6) NULL,
	[Wartość netto pozycji] [numeric](18, 2) NULL,
	[Wartość brutto pozycji] [numeric](18, 2) NULL,
	[Koszt pozycji] [numeric](38, 6) NULL,
	[Marża netto pozycji] [numeric](38, 6) NULL,
	[Marża brutto pozycji] [numeric](38, 6) NULL,
	[Marża % pozycji] [numeric](38, 6) NULL,
	[Maksymalna wartość kredytu] [decimal](18, 4) NULL,
	[Maksymalna wartość dokumentu kredytowanego] [decimal](18, 4) NULL,
	[Maksymalna ilość przeterminowanych dni] [decimal](18, 4) NULL,
	[Zawsze zezwalaj na płacenie gotówką] [nvarchar](500) NULL,
	[Forma Płatności] [nvarchar](4000) NULL,
	[Termin płatności data] [datetime] NULL,
	[Termin płatności dnI] [int] NULL,
	[Rozliczone] [varchar](3) NULL,
	[Pozostało do rozliczenia] [numeric](38, 2) NULL,
	[Dni po terminie] [int] NULL,
	[Przeterminowane] [varchar](3) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

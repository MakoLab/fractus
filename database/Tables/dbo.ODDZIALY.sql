/*
name=[dbo].[ODDZIALY]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
UP/+E9MVBQqCtvcQWEhecg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ODDZIALY]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ODDZIALY](
	[NRODDZIALU] [nvarchar](255) NULL,
	[NRBANKU] [nvarchar](255) NULL,
	[ID_BANKU] [nvarchar](255) NULL,
	[NAZWA_JED1] [nvarchar](255) NULL,
	[NAZWA_JED2] [nvarchar](255) NULL,
	[BRIR] [nvarchar](255) NULL,
	[ULICA] [nvarchar](255) NULL,
	[KOD] [nvarchar](255) NULL,
	[MIASTO] [nvarchar](255) NULL,
	[OD_PROW_EE] [nvarchar](255) NULL,
	[REG] [nvarchar](255) NULL,
	[OD_PROW_EL] [nvarchar](255) NULL,
	[DD] [nvarchar](255) NULL,
	[IBAN] [nvarchar](255) NULL,
	[CZEKI] [nvarchar](255) NULL,
	[GOBI] [nvarchar](255) NULL,
	[MPS] [nvarchar](255) NULL,
	[TOD_EE] [nvarchar](255) NULL
) ON [PRIMARY]
END
GO

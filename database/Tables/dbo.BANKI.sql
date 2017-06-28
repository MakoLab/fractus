/*
name=[dbo].[BANKI]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ri0p/VwL1wgDErg+1ghYIg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BANKI]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BANKI](
	[NRBANKU] [nvarchar](255) NULL,
	[NRCENTRALI] [nvarchar](255) NULL,
	[ID_BANKU] [nvarchar](255) NULL,
	[BA_PR_EL] [nvarchar](255) NULL,
	[BA_PR_EE] [nvarchar](255) NULL,
	[NAZWA_BA1] [nvarchar](255) NULL,
	[NAZWA_BA2] [nvarchar](255) NULL,
	[ULICA] [nvarchar](255) NULL,
	[KOD] [nvarchar](255) NULL,
	[MIASTO] [nvarchar](255) NULL,
	[CZEKI] [nvarchar](255) NULL
) ON [PRIMARY]
END
GO

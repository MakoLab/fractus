/*
name=[translation].[Dok_Naglowek]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
r8dS6RXA4gsnOKFAVujxtw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[Dok_Naglowek]') AND type in (N'U'))
BEGIN
CREATE TABLE [translation].[Dok_Naglowek](
	[id] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[megaId] [nvarchar](50) NULL,
	[fractus2Id] [uniqueidentifier] NULL,
	[megaGID] [numeric](18, 0) NULL
) ON [PRIMARY]
END
GO

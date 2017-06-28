/*
name=[dbo].[trace]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
teZOPzOkINzlPzlI6vIonQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[trace]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[trace](
	[datetime] [datetime] NULL,
	[xmlxml] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

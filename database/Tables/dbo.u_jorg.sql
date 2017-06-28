/*
name=[dbo].[u_jorg]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
+L68/5muxsz0UxIJLS2ZBQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[u_jorg]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[u_jorg](
	[Column 0] [nvarchar](8) NULL,
	[Column 1] [nvarchar](8) NULL,
	[Column 2] [nvarchar](140) NULL,
	[Column 3] [nvarchar](15) NULL,
	[Column 4] [nvarchar](22) NULL,
	[Column 5] [nvarchar](25) NULL,
	[Column 6] [nvarchar](30) NULL,
	[Column 7] [nvarchar](6) NULL,
	[Column 8] [nvarchar](30) NULL,
	[Column 9] [nvarchar](40) NULL,
	[Column 10] [nvarchar](6) NULL,
	[Column 11] [nvarchar](6) NULL,
	[Column 12] [nvarchar](20) NULL,
	[Column 13] [nvarchar](20) NULL,
	[Column 14] [nvarchar](20) NULL,
	[Column 15] [nvarchar](20) NULL,
	[Column 16] [nvarchar](17) NULL,
	[Column 17] [nvarchar](12) NULL,
	[Column 18] [datetime] NULL
) ON [PRIMARY]
END
GO

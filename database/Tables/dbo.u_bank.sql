/*
name=[dbo].[u_bank]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
599AWCO+Bl99fJlmpg3J0w==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[u_bank]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[u_bank](
	[Column 0] [nvarchar](8) NULL,
	[Column 1] [nvarchar](4) NULL,
	[Column 2] [nvarchar](140) NULL,
	[Column 3] [nvarchar](6) NULL,
	[Column 4] [nvarchar](6) NULL,
	[Column 5] [nvarchar](25) NULL,
	[Column 6] [nvarchar](20) NULL
) ON [PRIMARY]
END
GO

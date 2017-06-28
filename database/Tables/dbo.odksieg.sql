/*
name=[dbo].[odksieg]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
XdgiBuSe28p5BmXw9N0seg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[odksieg]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[odksieg](
	[id] [uniqueidentifier] NULL
) ON [PRIMARY]
END
GO

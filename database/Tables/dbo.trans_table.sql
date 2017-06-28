/*
name=[dbo].[trans_table]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
UfD8yjHB/eEUiK7+Aek2Jw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[trans_table]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[trans_table](
	[row_number] [smallint] NULL,
	[description] [varchar](35) NULL
) ON [PRIMARY]
END
GO

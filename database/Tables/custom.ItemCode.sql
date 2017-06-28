/*
name=[custom].[ItemCode]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ew4QjpLGbxygRyp9La7pCA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[ItemCode]') AND type in (N'U'))
BEGIN
CREATE TABLE [custom].[ItemCode](
	[id] [uniqueidentifier] NOT NULL,
	[itemId] [uniqueidentifier] NULL,
	[ean] [varchar](50) NULL,
	[itemNumber] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

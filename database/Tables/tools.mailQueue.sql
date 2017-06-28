/*
name=[tools].[mailQueue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
llvGLqzetIhq+xQtYJ45rA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[mailQueue]') AND type in (N'U'))
BEGIN
CREATE TABLE [tools].[mailQueue](
	[id] [uniqueidentifier] NULL,
	[recipients] [nvarchar](4000) NULL,
	[subject] [nvarchar](4000) NULL,
	[from] [nvarchar](4000) NULL,
	[body] [nvarchar](max) NULL,
	[order] [int] IDENTITY(1,1) NOT NULL,
	[status] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

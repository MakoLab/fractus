/*
name=[dbo].[Liczebniki]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
J9mbP4513hYPwsPFuz1Q1A==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Liczebniki]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Liczebniki](
	[Rzad] [char](1) NOT NULL,
	[Value] [int] NOT NULL,
	[Liczebnik] [nvarchar](20) NULL,
 CONSTRAINT [PK_RzadValue] PRIMARY KEY CLUSTERED 
(
	[Rzad] ASC,
	[Value] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

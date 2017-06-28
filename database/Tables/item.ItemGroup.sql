/*
name=[item].[ItemGroup]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Ya2toaa/kgJ7AfYU59bXgg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[ItemGroup]') AND type in (N'U'))
BEGIN
CREATE TABLE [item].[ItemGroup](
	[id] [uniqueidentifier] NOT NULL,
	[label] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_ItemGroup] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

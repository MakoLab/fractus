/*
name=[dbo].[ItemImportRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ex2sdY7qV2Z2tXMZhwUlSA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ItemImportRelation]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ItemImportRelation](
	[id] [uniqueidentifier] NOT NULL,
	[f1Id] [int] NULL,
	[f2Id] [uniqueidentifier] NULL,
 CONSTRAINT [PK_ItemImportRelation] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

/*
name=[dbo].[ItemKeyRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
lQARocR5aybOq29DPuRA2g==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ItemKeyRelation]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ItemKeyRelation](
	[id] [uniqueidentifier] NOT NULL,
	[itemId] [uniqueidentifier] NOT NULL,
	[itemKeyValueId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ItemKeyRelation] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

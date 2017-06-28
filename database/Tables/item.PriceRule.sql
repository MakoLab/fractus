/*
name=[item].[PriceRule]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
C93VqLlWFjNet5bBcWT0EQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[PriceRule]') AND type in (N'U'))
BEGIN
CREATE TABLE [item].[PriceRule](
	[id] [uniqueidentifier] NOT NULL,
	[name] [nvarchar](500) NOT NULL,
	[definition] [xml] NOT NULL,
	[procedure] [nvarchar](500) NULL,
	[status] [int] NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
 CONSTRAINT [PK_PriceRule] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

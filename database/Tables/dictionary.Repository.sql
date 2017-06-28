/*
name=[dictionary].[Repository]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
9NZ5yyJ15pw30xwd3BllhA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[Repository]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[Repository](
	[id] [uniqueidentifier] NOT NULL,
	[url] [varchar](300) NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Repository] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [uniqueRepository_url] UNIQUE NONCLUSTERED 
(
	[url] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

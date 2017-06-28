/*
name=[accounting].[Pattern]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
pn/OP80Bs9XwGOSFq7/H2A==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[Pattern]') AND type in (N'U'))
BEGIN
CREATE TABLE [accounting].[Pattern](
	[id] [uniqueidentifier] NOT NULL,
	[source] [int] NULL,
	[namePattern] [varchar](50) NULL,
	[codeSql] [varchar](max) NULL,
 CONSTRAINT [PK_Pattern] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[accounting].[DF_accounting.pattern_id]') AND type = 'D')
BEGIN
ALTER TABLE [accounting].[Pattern] ADD  CONSTRAINT [DF_accounting.pattern_id]  DEFAULT (newid()) FOR [id]
END

GO

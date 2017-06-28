/*
name=[dbo].[kalendarz]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
1YpiTsPXSNDR/6mkA+QueQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[kalendarz]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[kalendarz](
	[data] [datetime] NOT NULL,
	[gdzie] [nvarchar](40) NOT NULL,
	[z kim] [nvarchar](20) NOT NULL,
 CONSTRAINT [kalendarz2] PRIMARY KEY CLUSTERED 
(
	[data] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

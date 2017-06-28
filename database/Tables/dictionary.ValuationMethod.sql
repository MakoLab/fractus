/*
name=[dictionary].[ValuationMethod]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
c7CA9DaRUJdsv3ccRtvyAA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[ValuationMethod]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[ValuationMethod](
	[id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[symbol] [varchar](50) NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[xmlLabels] [xml] NOT NULL,
	[xmlMetadata] [xml] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ValuationMethod] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dictionary].[DF_ValuationMethod_id]') AND type = 'D')
BEGIN
ALTER TABLE [dictionary].[ValuationMethod] ADD  CONSTRAINT [DF_ValuationMethod_id]  DEFAULT (newid()) FOR [id]
END

GO

/*
name=[dictionary].[DocumentNumberComponent]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
3NzBDpV2fapmZX6GkTokaw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[DocumentNumberComponent]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[DocumentNumberComponent](
	[id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[symbol] [nvarchar](50) NOT NULL,
	[xmlMetadata] [xml] NOT NULL,
	[xmlLabels] [xml] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
 CONSTRAINT [PK_DocumentNumberComponent] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dictionary].[DF_DocumentNumberComponent_id]') AND type = 'D')
BEGIN
ALTER TABLE [dictionary].[DocumentNumberComponent] ADD  CONSTRAINT [DF_DocumentNumberComponent_id]  DEFAULT (newid()) FOR [id]
END

GO

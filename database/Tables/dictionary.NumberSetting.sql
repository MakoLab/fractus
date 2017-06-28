/*
name=[dictionary].[NumberSetting]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
eFtMW3FvJQw74Eb4LjV9og==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[NumberSetting]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[NumberSetting](
	[id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[numberFormat] [nvarchar](300) NOT NULL,
	[seriesFormat] [nvarchar](300) NOT NULL,
	[xmlLabels] [xml] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
 CONSTRAINT [PK_numberSettings] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dictionary].[DF_numberSettings_id]') AND type = 'D')
BEGIN
ALTER TABLE [dictionary].[NumberSetting] ADD  CONSTRAINT [DF_numberSettings_id]  DEFAULT (newid()) FOR [id]
END

GO

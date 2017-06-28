/*
name=[document].[Series]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Bz5FyFOaHhq3ukOMRIeS0Q==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[Series]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[Series](
	[id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[numberSettingId] [uniqueidentifier] NOT NULL,
	[seriesValue] [nvarchar](100) NOT NULL,
	[lastNumber] [int] NOT NULL,
 CONSTRAINT [PK_SeriesValue] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[Series]') AND name = N'indSeries_id_numberSetting_seriesValue')
CREATE UNIQUE NONCLUSTERED INDEX [indSeries_id_numberSetting_seriesValue] ON [document].[Series]
(
	[numberSettingId] ASC,
	[seriesValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[Series]') AND name = N'indSeries_id_value')
CREATE UNIQUE NONCLUSTERED INDEX [indSeries_id_value] ON [document].[Series]
(
	[id] ASC,
	[seriesValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[Series]') AND name = N'indSeries_lastNumber')
CREATE NONCLUSTERED INDEX [indSeries_lastNumber] ON [document].[Series]
(
	[lastNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[Series]') AND name = N'indSeries_NumberSettingsId')
CREATE NONCLUSTERED INDEX [indSeries_NumberSettingsId] ON [document].[Series]
(
	[numberSettingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[Series]') AND name = N'indSeries_seriesValue')
CREATE NONCLUSTERED INDEX [indSeries_seriesValue] ON [document].[Series]
(
	[seriesValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[document].[DF_SeriesValue_id]') AND type = 'D')
BEGIN
ALTER TABLE [document].[Series] ADD  CONSTRAINT [DF_SeriesValue_id]  DEFAULT (newid()) FOR [id]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_Series_NumberSetting]') AND parent_object_id = OBJECT_ID(N'[document].[Series]'))
ALTER TABLE [document].[Series]  WITH CHECK ADD  CONSTRAINT [FK_Series_NumberSetting] FOREIGN KEY([numberSettingId])
REFERENCES [dictionary].[NumberSetting] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[document].[FK_Series_NumberSetting]') AND parent_object_id = OBJECT_ID(N'[document].[Series]'))
ALTER TABLE [document].[Series] CHECK CONSTRAINT [FK_Series_NumberSetting]
GO

/*
name=[document].[ExportStatus]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
hMv0ed+9NjYyWgpsBOR86w==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[ExportStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[ExportStatus](
	[documentId] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[ExportStatus]') AND name = N'indExportStatus_docId')
CREATE NONCLUSTERED INDEX [indExportStatus_docId] ON [document].[ExportStatus]
(
	[documentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

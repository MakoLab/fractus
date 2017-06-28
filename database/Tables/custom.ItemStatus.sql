/*
name=[custom].[ItemStatus]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Q1A13tNLq/Q4iZOEprod0g==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[ItemStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [custom].[ItemStatus](
	[id] [uniqueidentifier] NOT NULL,
	[itemCodeId] [uniqueidentifier] NULL,
	[itemId] [uniqueidentifier] NULL,
	[status] [varchar](50) NULL,
	[commercialDocumentLineId] [uniqueidentifier] NULL,
	[warehouseDocumentLineId] [uniqueidentifier] NULL,
	[quantity] [int] NULL
) ON [PRIMARY]
END
GO

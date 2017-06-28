/*
name=[custom].[portaCompleteItemDetails]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
L4BVfWfmFvwZd4Ocijb7tQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[portaCompleteItemDetails]') AND type in (N'U'))
BEGIN
CREATE TABLE [custom].[portaCompleteItemDetails](
	[ean] [char](13) NULL,
	[itemGroupFamilyCode] [varchar](50) NULL,
	[code] [varchar](100) NOT NULL,
	[name] [varchar](200) NULL,
	[price] [numeric](16, 2) NULL,
	[field1] [numeric](16, 2) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_portaCompleteItemDetails] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[custom].[portaCompleteItemDetails]') AND name = N'indPortaComplete_code')
CREATE NONCLUSTERED INDEX [indPortaComplete_code] ON [custom].[portaCompleteItemDetails]
(
	[code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

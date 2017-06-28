/*
name=[item].[ItemGroupAttributes]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
I+78gANPjKvQwL9WFuGHDA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[ItemGroupAttributes]') AND type in (N'U'))
BEGIN
CREATE TABLE [item].[ItemGroupAttributes](
	[itemGroupId] [uniqueidentifier] NOT NULL,
	[value] [nvarchar](500) NULL,
	[type] [varchar](50) NULL,
	[name] [nvarchar](500) NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[ItemGroupAttributes]') AND name = N'ClusteredIndex-ItemGroupAttributes')
CREATE UNIQUE CLUSTERED INDEX [ClusteredIndex-ItemGroupAttributes] ON [item].[ItemGroupAttributes]
(
	[itemGroupId] ASC,
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

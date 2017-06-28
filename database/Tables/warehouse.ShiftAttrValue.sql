/*
name=[warehouse].[ShiftAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
+Sh5QYA3VvIRlxPy1E6S9Q==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[ShiftAttrValue]') AND type in (N'U'))
BEGIN
CREATE TABLE [warehouse].[ShiftAttrValue](
	[id] [uniqueidentifier] NOT NULL,
	[shiftId] [uniqueidentifier] NOT NULL,
	[shiftFieldId] [uniqueidentifier] NOT NULL,
	[decimalValue] [decimal](18, 4) NULL,
	[textValue] [nvarchar](500) NULL,
	[xmlValue] [xml] NULL,
	[version] [uniqueidentifier] NOT NULL,
	[dateValue] [datetime] NULL,
 CONSTRAINT [PK_ShiftAttrValue] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

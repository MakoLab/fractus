/*
name=[crm].[EventAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
AY0c2kt+LgZwfQi+FZnhIA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[EventAttrValue]') AND type in (N'U'))
BEGIN
CREATE TABLE [crm].[EventAttrValue](
	[id] [uniqueidentifier] NOT NULL,
	[eventId] [uniqueidentifier] NULL,
	[eventFieldId] [uniqueidentifier] NOT NULL,
	[decimalValue] [decimal](18, 4) NULL,
	[dateValue] [datetime] NULL,
	[textValue] [nvarchar](4000) NULL,
	[xmlValue] [xml] NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
 CONSTRAINT [PK_EventAttrValue] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

/*
name=[crm].[Offer]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
GK0E98T6tixfGkh0i0NMzw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[Offer]') AND type in (N'U'))
BEGIN
CREATE TABLE [crm].[Offer](
	[id] [uniqueidentifier] NOT NULL,
	[documentTypeId] [uniqueidentifier] NOT NULL,
	[contractorId] [uniqueidentifier] NULL,
	[number] [int] NOT NULL,
	[fullNumber] [nvarchar](50) NOT NULL,
	[seriesId] [uniqueidentifier] NOT NULL,
	[statusId] [uniqueidentifier] NOT NULL,
	[issueDate] [datetime] NOT NULL,
	[title] [varchar](4000) NULL,
	[creationDate] [datetime] NOT NULL,
	[modificationDate] [datetime] NOT NULL,
	[modificationApplicationUserId] [uniqueidentifier] NULL,
	[creationApplicationUserId] [uniqueidentifier] NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_WarehouseDocumentHeader] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

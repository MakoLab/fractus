/*
name=[crm].[Event]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
8TARV7i8vPJcFbTVeyFyaw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[Event]') AND type in (N'U'))
BEGIN
CREATE TABLE [crm].[Event](
	[id] [uniqueidentifier] NOT NULL,
	[eventTypeId] [uniqueidentifier] NOT NULL,
	[contractorId] [uniqueidentifier] NULL,
	[number] [int] NOT NULL,
	[fullNumber] [nvarchar](50) NOT NULL,
	[issueDate] [datetime] NOT NULL,
	[seriesId] [uniqueidentifier] NOT NULL,
	[issuingPersonContractorId] [uniqueidentifier] NULL,
	[modificationDate] [datetime] NULL,
	[modificationApplicationUserId] [uniqueidentifier] NULL,
	[version] [uniqueidentifier] NOT NULL,
	[status] [int] NOT NULL,
	[companyId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Event] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

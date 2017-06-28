/*
name=[service].[ServiceHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
BeQeqPWb9Lj2F5QW9PFceg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[ServiceHeader]') AND type in (N'U'))
BEGIN
CREATE TABLE [service].[ServiceHeader](
	[commercialDocumentHeaderId] [uniqueidentifier] NOT NULL,
	[plannedEndDate] [datetime] NOT NULL,
	[creationDate] [datetime] NOT NULL,
	[description] [nvarchar](max) NULL,
	[version] [uniqueidentifier] NULL,
	[closureDate] [datetime] NULL,
 CONSTRAINT [PK_ServiceHeader] PRIMARY KEY CLUSTERED 
(
	[commercialDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[service].[DF_Service_1_creatinDate]') AND type = 'D')
BEGIN
ALTER TABLE [service].[ServiceHeader] ADD  CONSTRAINT [DF_Service_1_creatinDate]  DEFAULT (getdate()) FOR [creationDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[service].[FK_serviceHeader_commercialDocumentHeader]') AND parent_object_id = OBJECT_ID(N'[service].[ServiceHeader]'))
ALTER TABLE [service].[ServiceHeader]  WITH CHECK ADD  CONSTRAINT [FK_serviceHeader_commercialDocumentHeader] FOREIGN KEY([commercialDocumentHeaderId])
REFERENCES [document].[CommercialDocumentHeader] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[service].[FK_serviceHeader_commercialDocumentHeader]') AND parent_object_id = OBJECT_ID(N'[service].[ServiceHeader]'))
ALTER TABLE [service].[ServiceHeader] CHECK CONSTRAINT [FK_serviceHeader_commercialDocumentHeader]
GO

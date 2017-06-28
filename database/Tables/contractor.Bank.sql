/*
name=[contractor].[Bank]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Hh2hzx5OrVW5O5ycd6z4IA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[Bank]') AND type in (N'U'))
BEGIN
CREATE TABLE [contractor].[Bank](
	[contractorId] [uniqueidentifier] NOT NULL,
	[bankNumber] [varchar](100) NULL,
	[swiftNumber] [varchar](20) NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Bank_1] PRIMARY KEY CLUSTERED 
(
	[contractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_Bank_Contractor]') AND parent_object_id = OBJECT_ID(N'[contractor].[Bank]'))
ALTER TABLE [contractor].[Bank]  WITH CHECK ADD  CONSTRAINT [FK_Bank_Contractor] FOREIGN KEY([contractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[contractor].[FK_Bank_Contractor]') AND parent_object_id = OBJECT_ID(N'[contractor].[Bank]'))
ALTER TABLE [contractor].[Bank] CHECK CONSTRAINT [FK_Bank_Contractor]
GO

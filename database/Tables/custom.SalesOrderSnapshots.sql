/*
name=[custom].[SalesOrderSnapshots]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ngrTkNT3Q7FGd5yQCklJew==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[SalesOrderSnapshots]') AND type in (N'U'))
BEGIN
CREATE TABLE [custom].[SalesOrderSnapshots](
	[Id] [uniqueidentifier] NOT NULL,
	[Number] [nvarchar](max) NULL,
	[Status] [int] NOT NULL,
	[RegistrationDate] [datetime] NOT NULL,
	[Value] [decimal](18, 0) NOT NULL,
	[FittingDate] [datetime] NULL,
	[Remarks] [nvarchar](max) NULL,
	[Contractor_FullName] [nvarchar](max) NOT NULL,
	[Contractor_Address] [nvarchar](max) NULL,
	[Contractor_City] [nvarchar](max) NULL,
	[Contractor_Email] [nvarchar](max) NULL,
	[Contractor_Phone] [nvarchar](max) NULL,
	[Contractor_IsAps] [bit] NOT NULL,
	[Contractor_Login] [nvarchar](max) NULL,
	[Contractor_Password] [nvarchar](max) NULL,
	[Contractor_Type] [int] NOT NULL,
	[SalesType] [int] NOT NULL,
	[ProductionOrderNumber] [nvarchar](max) NULL,
 CONSTRAINT [PK_SalesOrderSnapshots] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

/*
name=[dictionary].[FinancialRegister]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
s97M57HKt6QLNcjc99AFRw==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[FinancialRegister]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[FinancialRegister](
	[id] [uniqueidentifier] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[symbol] [nvarchar](10) NOT NULL,
	[xmlLabels] [xml] NOT NULL,
	[currencyId] [uniqueidentifier] NOT NULL,
	[accountingAccount] [nvarchar](50) NOT NULL,
	[bankContractorId] [uniqueidentifier] NULL,
	[bankAccountNumber] [varchar](40) NULL,
	[registerCategory] [int] NOT NULL,
	[xmlOptions] [xml] NOT NULL,
	[order] [int] NOT NULL,
	[branchId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Register] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dictionary].[FinancialRegister]') AND name = N'ind_Register_Contractor')
CREATE NONCLUSTERED INDEX [ind_Register_Contractor] ON [dictionary].[FinancialRegister]
(
	[bankContractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dictionary].[FinancialRegister]') AND name = N'ind_Register_Currency')
CREATE NONCLUSTERED INDEX [ind_Register_Currency] ON [dictionary].[FinancialRegister]
(
	[currencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dictionary].[FK_Register_Contractor]') AND parent_object_id = OBJECT_ID(N'[dictionary].[FinancialRegister]'))
ALTER TABLE [dictionary].[FinancialRegister]  WITH CHECK ADD  CONSTRAINT [FK_Register_Contractor] FOREIGN KEY([bankContractorId])
REFERENCES [contractor].[Bank] ([contractorId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dictionary].[FK_Register_Contractor]') AND parent_object_id = OBJECT_ID(N'[dictionary].[FinancialRegister]'))
ALTER TABLE [dictionary].[FinancialRegister] CHECK CONSTRAINT [FK_Register_Contractor]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dictionary].[FK_Register_Currency]') AND parent_object_id = OBJECT_ID(N'[dictionary].[FinancialRegister]'))
ALTER TABLE [dictionary].[FinancialRegister]  WITH CHECK ADD  CONSTRAINT [FK_Register_Currency] FOREIGN KEY([currencyId])
REFERENCES [dictionary].[Currency] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dictionary].[FK_Register_Currency]') AND parent_object_id = OBJECT_ID(N'[dictionary].[FinancialRegister]'))
ALTER TABLE [dictionary].[FinancialRegister] CHECK CONSTRAINT [FK_Register_Currency]
GO

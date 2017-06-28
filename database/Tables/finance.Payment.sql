/*
name=[finance].[Payment]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
s8YhYSkdLGZRdMuEXAl5qg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[Payment]') AND type in (N'U'))
BEGIN
CREATE TABLE [finance].[Payment](
	[id] [uniqueidentifier] NOT NULL,
	[date] [datetime] NOT NULL,
	[dueDate] [datetime] NOT NULL,
	[contractorId] [uniqueidentifier] NULL,
	[contractorAddressId] [uniqueidentifier] NULL,
	[paymentMethodId] [uniqueidentifier] NULL,
	[commercialDocumentHeaderId] [uniqueidentifier] NULL,
	[financialDocumentHeaderId] [uniqueidentifier] NULL,
	[amount] [numeric](18, 2) NOT NULL,
	[paymentCurrencyId] [uniqueidentifier] NOT NULL,
	[systemCurrencyId] [uniqueidentifier] NOT NULL,
	[exchangeDate] [datetime] NOT NULL,
	[exchangeScale] [numeric](18, 0) NOT NULL,
	[exchangeRate] [numeric](18, 6) NOT NULL,
	[isSettled] [bit] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[ordinalNumber] [int] NOT NULL,
	[description] [nvarchar](500) NULL,
	[documentInfo] [nvarchar](100) NULL,
	[direction] [int] NOT NULL,
	[requireSettlement] [bit] NULL,
	[unsettledAmount] [numeric](18, 2) NULL,
	[sysAmount] [numeric](18, 2) NULL,
	[branchId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Payment] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[Payment]') AND name = N'indPayment_commercialDocumentId')
CREATE NONCLUSTERED INDEX [indPayment_commercialDocumentId] ON [finance].[Payment]
(
	[commercialDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[Payment]') AND name = N'indPayment_contractorId')
CREATE NONCLUSTERED INDEX [indPayment_contractorId] ON [finance].[Payment]
(
	[contractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[Payment]') AND name = N'indPayment_financialDocumentId')
CREATE NONCLUSTERED INDEX [indPayment_financialDocumentId] ON [finance].[Payment]
(
	[financialDocumentHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[Payment]') AND name = N'indPayment_financialMulti')
CREATE NONCLUSTERED INDEX [indPayment_financialMulti] ON [finance].[Payment]
(
	[financialDocumentHeaderId] ASC
)
INCLUDE ( 	[id],
	[commercialDocumentHeaderId],
	[documentInfo]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[Payment]') AND name = N'indPayment_paymentCurrencyId')
CREATE NONCLUSTERED INDEX [indPayment_paymentCurrencyId] ON [finance].[Payment]
(
	[paymentCurrencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[Payment]') AND name = N'indPayment_paymentMethodId')
CREATE NONCLUSTERED INDEX [indPayment_paymentMethodId] ON [finance].[Payment]
(
	[paymentMethodId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[Payment]') AND name = N'indPayment_systemCurrencyId')
CREATE NONCLUSTERED INDEX [indPayment_systemCurrencyId] ON [finance].[Payment]
(
	[systemCurrencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[finance].[Payment]') AND name = N'indPayment_unsettledAmount')
CREATE NONCLUSTERED INDEX [indPayment_unsettledAmount] ON [finance].[Payment]
(
	[unsettledAmount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Payment_Contractor]') AND parent_object_id = OBJECT_ID(N'[finance].[Payment]'))
ALTER TABLE [finance].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_Contractor] FOREIGN KEY([contractorId])
REFERENCES [contractor].[Contractor] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Payment_Contractor]') AND parent_object_id = OBJECT_ID(N'[finance].[Payment]'))
ALTER TABLE [finance].[Payment] CHECK CONSTRAINT [FK_Payment_Contractor]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Payment_Currency]') AND parent_object_id = OBJECT_ID(N'[finance].[Payment]'))
ALTER TABLE [finance].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_Currency] FOREIGN KEY([paymentCurrencyId])
REFERENCES [dictionary].[Currency] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Payment_Currency]') AND parent_object_id = OBJECT_ID(N'[finance].[Payment]'))
ALTER TABLE [finance].[Payment] CHECK CONSTRAINT [FK_Payment_Currency]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Payment_Currency1]') AND parent_object_id = OBJECT_ID(N'[finance].[Payment]'))
ALTER TABLE [finance].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_Currency1] FOREIGN KEY([systemCurrencyId])
REFERENCES [dictionary].[Currency] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Payment_Currency1]') AND parent_object_id = OBJECT_ID(N'[finance].[Payment]'))
ALTER TABLE [finance].[Payment] CHECK CONSTRAINT [FK_Payment_Currency1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Payment_PaymentMethod]') AND parent_object_id = OBJECT_ID(N'[finance].[Payment]'))
ALTER TABLE [finance].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_PaymentMethod] FOREIGN KEY([paymentMethodId])
REFERENCES [dictionary].[PaymentMethod] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[finance].[FK_Payment_PaymentMethod]') AND parent_object_id = OBJECT_ID(N'[finance].[Payment]'))
ALTER TABLE [finance].[Payment] CHECK CONSTRAINT [FK_Payment_PaymentMethod]
GO

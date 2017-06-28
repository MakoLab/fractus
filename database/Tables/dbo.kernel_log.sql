/*
name=[dbo].[kernel_log]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
htYtZfqIgmsySoDd7KVMRg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[kernel_log]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[kernel_log](
	[incomeOrdinalNumber] [int] NULL,
	[outcomeOrdinalNumber] [int] NULL,
	[commercialDocumentLineId] [uniqueidentifier] NULL,
	[id] [uniqueidentifier] NULL,
	[warehouseDocumentHeaderId] [uniqueidentifier] NULL,
	[outcomeCorrectionDocumentHeaderId] [uniqueidentifier] NULL,
	[data] [datetime] NULL,
	[quantity] [numeric](18, 6) NULL,
	[value] [numeric](18, 2) NULL,
	[localTransactionId] [uniqueidentifier] NULL,
	[deferredTransactionId] [uniqueidentifier] NULL,
	[databaseId] [uniqueidentifier] NULL,
	[incompleteIncome] [bit] NULL
) ON [PRIMARY]
END
GO

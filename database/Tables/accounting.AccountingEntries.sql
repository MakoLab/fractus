/*
name=[accounting].[AccountingEntries]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
w6afjPhDmC3/TSZJZtKAtg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[AccountingEntries]') AND type in (N'U'))
BEGIN
CREATE TABLE [accounting].[AccountingEntries](
	[order] [int] NULL,
	[documentHeaderId] [uniqueidentifier] NULL,
	[debitAccount] [varchar](50) NULL,
	[debitAmount] [numeric](18, 2) NULL,
	[creditAccount] [varchar](50) NULL,
	[creditAmount] [numeric](18, 2) NULL,
	[description] [nvarchar](255) NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[accounting].[DF_accounting.accountingEntries_id]') AND type = 'D')
BEGIN
ALTER TABLE [accounting].[AccountingEntries] ADD  CONSTRAINT [DF_accounting.accountingEntries_id]  DEFAULT (newid()) FOR [documentHeaderId]
END

GO

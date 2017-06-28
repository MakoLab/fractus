/*
name=[accounting].[ExternalPayment]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
F2wf7N4iLlu+lY/1grHmyA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[ExternalPayment]') AND type in (N'U'))
BEGIN
CREATE TABLE [accounting].[ExternalPayment](
	[id] [uniqueidentifier] NOT NULL,
	[amount] [numeric](18, 2) NOT NULL,
 CONSTRAINT [PK_ExternalPayment] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[accounting].[DF_accounting.ExternalPayment_id]') AND type = 'D')
BEGIN
ALTER TABLE [accounting].[ExternalPayment] ADD  CONSTRAINT [DF_accounting.ExternalPayment_id]  DEFAULT (newid()) FOR [id]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[accounting].[DF_ExternalPayment_amount]') AND type = 'D')
BEGIN
ALTER TABLE [accounting].[ExternalPayment] ADD  CONSTRAINT [DF_ExternalPayment_amount]  DEFAULT ((0)) FOR [amount]
END

GO

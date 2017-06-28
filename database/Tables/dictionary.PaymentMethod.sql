/*
name=[dictionary].[PaymentMethod]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
We5eMC7ngCf/kd6lNUDKFg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[PaymentMethod]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[PaymentMethod](
	[id] [uniqueidentifier] NOT NULL,
	[xmlLabels] [xml] NOT NULL,
	[dueDays] [int] NOT NULL,
	[isGeneratingCashierDocument] [bit] NOT NULL,
	[isIncrementingDueAmount] [bit] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
	[isRequireSettlement] [bit] NULL,
	[dueDateChange] [bit] NULL,
 CONSTRAINT [PK_PaymentMethod] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

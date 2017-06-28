/*
name=[custom].[SalesOrderEvents]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
O2H+rYlwURznPTknrDdYBQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[SalesOrderEvents]') AND type in (N'U'))
BEGIN
CREATE TABLE [custom].[SalesOrderEvents](
	[Id] [uniqueidentifier] NOT NULL,
	[SalesOrderDetailsId] [uniqueidentifier] NOT NULL,
	[Type] [int] NOT NULL,
	[Date] [datetime] NULL,
	[Number] [nvarchar](max) NULL,
	[Value] [decimal](18, 0) NULL,
	[ContractNumber] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_SalesOrderEvents] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[custom].[SalesOrderEvents]') AND name = N'IX_FK_SalesOrderDetailsSalesOrderEvent')
CREATE NONCLUSTERED INDEX [IX_FK_SalesOrderDetailsSalesOrderEvent] ON [custom].[SalesOrderEvents]
(
	[SalesOrderDetailsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[custom].[FK_SalesOrderDetailsSalesOrderEvent]') AND parent_object_id = OBJECT_ID(N'[custom].[SalesOrderEvents]'))
ALTER TABLE [custom].[SalesOrderEvents]  WITH CHECK ADD  CONSTRAINT [FK_SalesOrderDetailsSalesOrderEvent] FOREIGN KEY([SalesOrderDetailsId])
REFERENCES [custom].[SalesOrderSnapshots] ([Id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[custom].[FK_SalesOrderDetailsSalesOrderEvent]') AND parent_object_id = OBJECT_ID(N'[custom].[SalesOrderEvents]'))
ALTER TABLE [custom].[SalesOrderEvents] CHECK CONSTRAINT [FK_SalesOrderDetailsSalesOrderEvent]
GO

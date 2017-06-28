/*
name=[custom].[MessageReferences]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
5VAY9tI3XHq9Z7TPpyEnYQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[MessageReferences]') AND type in (N'U'))
BEGIN
CREATE TABLE [custom].[MessageReferences](
	[Id] [uniqueidentifier] NOT NULL,
	[MessageId] [uniqueidentifier] NOT NULL,
	[SalesOrderId] [uniqueidentifier] NOT NULL,
	[SalesOrderDetailsId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_MessageReferences] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[custom].[MessageReferences]') AND name = N'IX_FK_MessageReferenceSalesOrderDetails')
CREATE NONCLUSTERED INDEX [IX_FK_MessageReferenceSalesOrderDetails] ON [custom].[MessageReferences]
(
	[SalesOrderDetailsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[custom].[FK_MessageReferenceSalesOrderDetails]') AND parent_object_id = OBJECT_ID(N'[custom].[MessageReferences]'))
ALTER TABLE [custom].[MessageReferences]  WITH CHECK ADD  CONSTRAINT [FK_MessageReferenceSalesOrderDetails] FOREIGN KEY([SalesOrderDetailsId])
REFERENCES [custom].[SalesOrderSnapshots] ([Id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[custom].[FK_MessageReferenceSalesOrderDetails]') AND parent_object_id = OBJECT_ID(N'[custom].[MessageReferences]'))
ALTER TABLE [custom].[MessageReferences] CHECK CONSTRAINT [FK_MessageReferenceSalesOrderDetails]
GO

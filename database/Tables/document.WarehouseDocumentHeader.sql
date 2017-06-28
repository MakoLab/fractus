/*
name=[document].[WarehouseDocumentHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
atXryVJKXJN801dHjWhXQQ==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentHeader]') AND type in (N'U'))
BEGIN
CREATE TABLE [document].[WarehouseDocumentHeader](
	[id] [uniqueidentifier] NOT NULL,
	[documentTypeId] [uniqueidentifier] NOT NULL,
	[contractorId] [uniqueidentifier] NULL,
	[warehouseId] [uniqueidentifier] NOT NULL,
	[documentCurrencyId] [uniqueidentifier] NOT NULL,
	[systemCurrencyId] [uniqueidentifier] NOT NULL,
	[number] [int] NOT NULL,
	[fullNumber] [nvarchar](50) NOT NULL,
	[issueDate] [datetime] NOT NULL,
	[value] [numeric](18, 2) NOT NULL,
	[seriesId] [uniqueidentifier] NOT NULL,
	[modificationDate] [datetime] NULL,
	[modificationApplicationUserId] [uniqueidentifier] NULL,
	[version] [uniqueidentifier] NOT NULL,
	[status] [int] NOT NULL,
	[branchId] [uniqueidentifier] NOT NULL,
	[companyId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_WarehouseDocumentHeader] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentHeader]') AND name = N'ind_WarehouseDocumentHeader_contractorId')
CREATE NONCLUSTERED INDEX [ind_WarehouseDocumentHeader_contractorId] ON [document].[WarehouseDocumentHeader]
(
	[contractorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentHeader]') AND name = N'ind_WarehouseDocumentHeader_documentTypeId')
CREATE NONCLUSTERED INDEX [ind_WarehouseDocumentHeader_documentTypeId] ON [document].[WarehouseDocumentHeader]
(
	[documentTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentHeader]') AND name = N'ind_WarehouseDocumentHeader_seriesId')
CREATE NONCLUSTERED INDEX [ind_WarehouseDocumentHeader_seriesId] ON [document].[WarehouseDocumentHeader]
(
	[seriesId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentHeader]') AND name = N'ind_WarehouseDocumentHeader_warehouseId')
CREATE NONCLUSTERED INDEX [ind_WarehouseDocumentHeader_warehouseId] ON [document].[WarehouseDocumentHeader]
(
	[warehouseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[WarehouseDocumentHeader]') AND name = N'indWarehouseDocumentHeader_status')
CREATE NONCLUSTERED INDEX [indWarehouseDocumentHeader_status] ON [document].[WarehouseDocumentHeader]
(
	[status] ASC
)
INCLUDE ( 	[id],
	[documentTypeId],
	[fullNumber],
	[issueDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

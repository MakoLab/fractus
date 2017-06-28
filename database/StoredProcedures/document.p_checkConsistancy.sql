/*
name=[document].[p_checkConsistancy]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Al9d+kwXkt8Ag256waM60Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkConsistancy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_checkConsistancy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkConsistancy]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_checkConsistancy]
AS
BEGIN
IF EXISTS(	SELECT r.id 
			FROM [document].[CommercialWarehouseRelation] r
				LEFT JOIN  [document].[CommercialDocumentLine] l ON r.commercialDocumentLineId = l.id
			WHERE l.id IS NULL)
PRINT ''BUU [document].[CommercialWarehouseRelation].commercialDocumentLineId <> [document].[CommercialDocumentLine].id''

IF EXISTS(	SELECT r.id 
			FROM [document].[CommercialWarehouseRelation] r
				LEFT JOIN  [document].[WarehouseDocumentLine] l ON r.warehouseDocumentLineId = l.id
			WHERE l.id IS NULL)
PRINT ''BUU [document].[CommercialWarehouseRelation].warehouseDocumentLineId <> [document].[WarehouseDocumentLine].id''			
			
IF EXISTS(	SELECT r.id 
			FROM [document].[CommercialWarehouseValuation] r
				LEFT JOIN  [document].[WarehouseDocumentLine] l ON r.warehouseDocumentLineId = l.id
			WHERE l.id IS NULL)			
PRINT ''BUU [document].[CommercialWarehouseValuation].warehouseDocumentLineId <> [document].[WarehouseDocumentLine].id''
			
IF EXISTS(	SELECT r.id 
			FROM [document].[WarehouseDocumentValuation] r
				LEFT JOIN  [document].[WarehouseDocumentLine] l ON r.outcomeWarehouseDocumentLineId = l.id
			WHERE l.id IS NULL)			
PRINT ''BUU [document].[WarehouseDocumentValuation].outcomeWarehouseDocumentLineId <> [document].[WarehouseDocumentLine].id''			
		
			
IF EXISTS(	SELECT r.id 
			FROM [document].[IncomeOutcomeRelation] r
				LEFT JOIN  [document].[WarehouseDocumentLine] l ON r.incomeWarehouseDocumentLineId = l.id
			WHERE l.id IS NULL)			
PRINT ''BUU [document].[IncomeOutcomeRelation].incomeWarehouseDocumentLineId <> [document].[WarehouseDocumentLine].id''			
			
IF EXISTS(	SELECT r.id 
			FROM [document].[IncomeOutcomeRelation] r
				LEFT JOIN  [document].[WarehouseDocumentLine] l ON r.outcomeWarehouseDocumentLineId = l.id
			WHERE l.id IS NULL)	
PRINT ''BUU [document].[IncomeOutcomeRelation].outcomeWarehouseDocumentLineId <> [document].[CommercialDocumentLine].id''			
			
END
' 
END
GO

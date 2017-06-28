/*
name=[tools].[p_czyscBazeDlaTestow]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dxfXFNouLJHLf1+Bd4GF5g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_czyscBazeDlaTestow]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_czyscBazeDlaTestow]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_czyscBazeDlaTestow]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [tools].[p_czyscBazeDlaTestow]
AS
BEGIN
--return 0;
	delete from warehouse.Shift
	delete from warehouse.ShiftTransaction
	delete from warehouse.ContainerShift

	delete from document.CommercialDocumentDictionaryRelation
	delete from document.CommercialDocumentDictionary
	delete from document.DocumentAttrValue
	delete from document.DocumentLineAttrValue
	delete from document.DocumentRelation
	delete from document.CommercialWarehouseRelation
	delete from document.CommercialWarehouseValuation
	delete from document.CommercialDocumentVatTable
	delete from document.IncomeOutcomeRelation
	delete from finance.PaymentSettlement
	delete from finance.Payment
	delete from document.CommercialDocumentLine
	delete from service.ServiceHeaderEmployees
	delete from service.ServiceHeaderServicedObjects
	delete from service.ServiceHeaderServicePlace
	delete from service.ServiceHeader
	delete from service.ServicedObject
	delete from document.CommercialDocumentHeader
	delete from document.Draft
	
	delete from document.InventorySheetLine
	delete from document.InventorySheet
	delete from document.InventoryDocumentHeader

	delete from document.WarehouseDocumentValuation
	delete from document.WarehouseStock
	delete from document.WarehouseDocumentLine
	delete from document.WarehouseDocumentHeader

	delete from document.FinancialDocumentHeader
	delete from finance.FinancialReport
	
	delete from complaint.ComplaintDecision
	delete from complaint.ComplaintDocumentLine
	delete from complaint.ComplaintDocumentHeader

	delete from document.Series

	delete from repository.FileDescriptor

	delete from communication.OutgoingXmlQueue
	delete from communication.IncomingXmlQueue
	
	/*delete from dictionary.Warehouse
	exec dictionary.p_updateVersion ''Warehouse''
	delete from dictionary.Branch
	exec dictionary.p_updateVersion ''Branch''
	delete from dictionary.Repository
	exec dictionary.p_updateVersion ''Repository''
	delete from dictionary.FinancialRegister
	exec dictionary.p_updateVersion ''FinancialRegister''
	delete from journal.Journal

	delete from item.ItemRelationAttrValue
	delete from item.ItemRelation*/
END

select * from dictionary.Warehouse
' 
END
GO

/*
name=[accounting].[p_deleteAccountingDocumentData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
OVVxnjr5oIhidpXgPoujKg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_deleteAccountingDocumentData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_deleteAccountingDocumentData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_deleteAccountingDocumentData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [accounting].[p_deleteAccountingDocumentData] 
@xmlVar  XML
AS
BEGIN

DECLARE 
	@commercialDocumentHeaderId UNIQUEIDENTIFIER,
	@financialDocumentHeaderId UNIQUEIDENTIFIER,
	@warehouseDocumentHeaderId UNIQUEIDENTIFIER


SELECT	@commercialDocumentHeaderId = NULLIF(@xmlVar.query(''root/commercialDocumentHeaderId'').value(''.'',''char(36)''),''''),
		@financialDocumentHeaderId = NULLIF(@xmlVar.query(''root/financialDocumentHeaderId'').value(''.'',''char(36)''),''''),
		@warehouseDocumentHeaderId = NULLIF(@xmlVar.query(''root/warehouseDocumentHeaderId'').value(''.'',''char(36)''),'''')
		
IF @commercialDocumentHeaderId IS NOT NULL
	BEGIN
		DELETE FROM accounting.AccountingEntries WHERE documentHeaderId = @commercialDocumentHeaderId
		DELETE FROM accounting.DocumentData WHERE commercialDocumentId = @commercialDocumentHeaderId
	END
IF @financialDocumentHeaderId IS NOT NULL
	BEGIN
		DELETE FROM accounting.AccountingEntries WHERE documentHeaderId = @financialDocumentHeaderId
		DELETE FROM accounting.DocumentData WHERE financialDocumentId = @financialDocumentHeaderId
	END
IF @warehouseDocumentHeaderId IS NOT NULL
	BEGIN
		DELETE FROM accounting.AccountingEntries WHERE documentHeaderId = @warehouseDocumentHeaderId
		DELETE FROM accounting.DocumentData WHERE warehouseDocumentId = @warehouseDocumentHeaderId
	END				
END
' 
END
GO

/*
name=[document].[p_getPrepaymentDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dHDGE7NWEsbxC8UNQI9XAw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getPrepaymentDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getPrepaymentDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getPrepaymentDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE document.p_getPrepaymentDocuments
 @xmlVar XML
 AS
 BEGIN
 
 DECLARE @id char(36)
 
 
 SELECT @id = @xmlVar.value(''(root/salesOrderId)[1]'', ''char(36)'')
 
	SELECT ( 
	 SELECT id ''@id'' , issueDate ''@issueDate'',  fullNumber ''@fullNumber'' 
	 FROM (
		 SELECT id , issueDate ,  fullNumber
		 FROM document.CommercialDocumentHeader 
		 WHERE id IN (
						SELECT NULLIF(ISNULL(NULLIF(firstCommercialDOcumentHeaderId, @id) ,secondCommercialDOcumentHeaderId),@id) 
						FROM document.DocumentRelation WHERE @id IN (firstCommercialDOcumentHeaderId,secondCommercialDOcumentHeaderId) AND relationType = 9
					)
		 UNION
		 SELECT id , issueDate ,  fullNumber
		 FROM document.WarehouseDocumentHeader 
		 WHERE id IN (
						SELECT ISNULL(firstWarehouseDOcumentHeaderId ,secondWarehouseDOcumentHeaderId)
						FROM document.DocumentRelation WHERE @id IN (firstCommercialDOcumentHeaderId,secondCommercialDOcumentHeaderId) AND relationType = 9
					)	
					
		 UNION
		 SELECT id , issueDate ,  fullNumber
		 FROM document.FinancialDocumentHeader 
		 WHERE id IN (
						SELECT ISNULL(firstFinancialDOcumentHeaderId ,secondFinancialDOcumentHeaderId)
						FROM document.DocumentRelation WHERE @id IN (firstCommercialDOcumentHeaderId,secondCommercialDOcumentHeaderId) AND relationType = 9
					)							
		) x
		ORDER BY issueDate
		FOR XML PATH(''document''), TYPE
		)
	FOR XML PATH(''root''), TYPE
 END
 ' 
END
GO

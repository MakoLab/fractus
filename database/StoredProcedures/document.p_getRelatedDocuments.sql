/*
name=[document].[p_getRelatedDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
s12i8pRfQbDJo31maY1sVw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getRelatedDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getRelatedDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getRelatedDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getRelatedDocuments]
@xmlVar XML 
AS

BEGIN

DECLARE 
	@commercialDocumentHeaderId UNIQUEIDENTIFIER,
	@financialDocumentHeaderId UNIQUEIDENTIFIER,
	@warehouseDocumentHeaderId UNIQUEIDENTIFIER,
	@complaintDocumentHeaderId UNIQUEIDENTIFIER,
	@inventoryDocumentHeaderId UNIQUEIDENTIFIER

/*Pobranie danych z XML*/
SELECT	@commercialDocumentHeaderId = NULLIF(@xmlVar.query(''root/commercialDocumentHeaderId'').value(''.'',''char(36)''),''''),
		@financialDocumentHeaderId = NULLIF(@xmlVar.query(''root/financialDocumentHeaderId'').value(''.'',''char(36)''),''''),
		@warehouseDocumentHeaderId = NULLIF(@xmlVar.query(''root/warehouseDocumentHeaderId'').value(''.'',''char(36)''),''''),
		@complaintDocumentHeaderId = NULLIF(@xmlVar.query(''root/complaintDocumentHeaderId'').value(''.'',''char(36)''),''''),
		@inventoryDocumentHeaderId = NULLIF(@xmlVar.query(''root/inventoryDocumentHeaderId'').value(''.'',''char(36)''),'''')

IF @commercialDocumentHeaderId IS NOT NULL
	BEGIN
	SELECT (
		SELECT fullNumber as ''@fullNumber'', id as ''@id'', issueDate as ''@issueDate'', documentTypeId as ''@documentTypeId'', relationType  AS ''@relationType''
		FROM 
			(
			SELECT fullNumber, ch.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.CommercialDocumentHeader ch WITH(NOLOCK) ON ch.id  IN (dr.firstCommercialDocumentHeaderId,dr.secondCommercialDocumentHeaderId)
			WHERE 	ch.id <> @commercialDocumentHeaderId AND @commercialDocumentHeaderId IN (dr.firstCommercialDocumentHeaderId,dr.secondCommercialDocumentHeaderId)
			UNION ALL		
			SELECT fullNumber, wh.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.WarehouseDocumentHeader wh WITH(NOLOCK) ON (wh.id = dr.firstWarehouseDocumentHeaderId AND dr.secondCommercialDocumentHeaderId = @commercialDocumentHeaderId)  OR (wh.id = dr.secondWarehouseDocumentHeaderId AND dr.firstCommercialDocumentHeaderId = @commercialDocumentHeaderId ) 
			UNION ALL			
			SELECT fullNumber, fh.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.FinancialDocumentHeader fh WITH(NOLOCK) ON (fh.id = dr.firstFinancialDocumentHeaderId AND dr.secondCommercialDocumentHeaderId = @commercialDocumentHeaderId )  OR (fh.id = dr.secondFinancialDocumentHeaderId AND dr.firstCommercialDocumentHeaderId = @commercialDocumentHeaderId )	
			UNION ALL			
			SELECT fullNumber, fh.id, NULL issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN complaint.ComplaintDocumentHeader fh WITH(NOLOCK) ON (fh.id = dr.firstComplaintDocumentHeaderId AND dr.secondCommercialDocumentHeaderId = @commercialDocumentHeaderId )  OR (fh.id = dr.secondComplaintDocumentHeaderId AND dr.firstCommercialDocumentHeaderId = @commercialDocumentHeaderId )	
			UNION ALL			
			SELECT fullNumber, fh.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.InventoryDocumentHeader fh WITH(NOLOCK) ON (fh.id = dr.firstInventoryDocumentHeaderId AND dr.secondCommercialDocumentHeaderId = @commercialDocumentHeaderId )  OR (fh.id = dr.secondInventoryDocumentHeaderId AND dr.firstCommercialDocumentHeaderId = @commercialDocumentHeaderId )	
			/* Te unie są od zamówień ZS wg. powiązań atrybutami */	
			UNION ALL			
			SELECT fullNumber, fh.id, fh. issueDate, fh.documentTypeId, 9 relationType
			FROM document.CommercialDocumentLine c WITH(NOLOCK) 
				JOIN document.DocumentLineAttrValue dr WITH(NOLOCK) ON dr.commercialDocumentLineId = c.id OR dr.guidValue = c.id
				JOIN dictionary.DocumentField df WITH(NOLOCK) ON dr.documentFieldId = df.id
				JOIN document.CommercialDocumentLine cl WITH(NOLOCK) ON dr.commercialDocumentLineId = cl.id OR dr.guidValue = cl.id
				JOIN document.CommercialDocumentHeader fh WITH(NOLOCK) ON fh.id = cl.commercialDocumentHeaderId
				--JOIN dictionary.DocumentType dt WITH(NOLOCK) ON fh.documentTypeId = dt.id
			WHERE df.name = ''LineAttribute_RealizedSalesOrderLineId'' 
				AND	c.commercialDocumentHeaderId = @commercialDocumentHeaderId 
				AND fh.id <> @commercialDocumentHeaderId

			) x 
			ORDER BY issueDate DESC
			FOR XML PATH(''document''), TYPE
		) FOR XML PATH(''relatedDocuments''), TYPE	
	END
ELSE IF @financialDocumentHeaderId IS NOT NULL
	BEGIN
	SELECT (
		SELECT fullNumber as ''@fullNumber'', id as ''@id'', issueDate as ''@issueDate'', documentTypeId as ''@documentTypeId'', relationType  AS ''@relationType''
		FROM 
			(
			SELECT fullNumber, fh.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.FinancialDocumentHeader fh WITH(NOLOCK) ON fh.id  IN (dr.firstFinancialDocumentHeaderId, dr.secondFinancialDocumentHeaderId)
			WHERE fh.id <> @financialDocumentHeaderId AND @financialDocumentHeaderId IN (dr.firstFinancialDocumentHeaderId, dr.secondFinancialDocumentHeaderId) 			
			UNION ALL		
			SELECT fullNumber, wh.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.WarehouseDocumentHeader wh WITH(NOLOCK) ON (wh.id = dr.firstWarehouseDocumentHeaderId AND dr.secondFinancialDocumentHeaderId = @financialDocumentHeaderId) OR (wh.id = dr.secondWarehouseDocumentHeaderId AND dr.firstFinancialDocumentHeaderId = @financialDocumentHeaderId)  
			UNION ALL			
			SELECT fullNumber, ch.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.CommercialDocumentHeader ch WITH(NOLOCK) ON (ch.id = dr.firstCommercialDocumentHeaderId AND dr.secondFinancialDocumentHeaderId = @financialDocumentHeaderId)  OR (ch.id = dr.secondFinancialDocumentHeaderId AND dr.firstFinancialDocumentHeaderId = @financialDocumentHeaderId)	
			UNION ALL			
			SELECT fullNumber, ch.id,NULL issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN complaint.ComplaintDocumentHeader ch WITH(NOLOCK) ON (ch.id = dr.firstComplaintDocumentHeaderId AND dr.secondFinancialDocumentHeaderId = @financialDocumentHeaderId)  OR (ch.id = dr.secondComplaintDocumentHeaderId AND dr.firstFinancialDocumentHeaderId = @financialDocumentHeaderId)					
			UNION ALL			
			SELECT fullNumber, fh.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.InventoryDocumentHeader fh WITH(NOLOCK) ON (fh.id = dr.firstInventoryDocumentHeaderId AND dr.secondFinancialDocumentHeaderId = @financialDocumentHeaderId )  OR (fh.id = dr.secondInventoryDocumentHeaderId AND dr.firstFinancialDocumentHeaderId = @financialDocumentHeaderId )	
				
			) x 
			ORDER BY issueDate DESC
			FOR XML PATH(''document''), TYPE
		) FOR XML PATH(''relatedDocuments''), TYPE	
	END
ELSE IF @warehouseDocumentHeaderId IS NOT NULL
	BEGIN
	SELECT (
		SELECT fullNumber as ''@fullNumber'', id as ''@id'', issueDate as ''@issueDate'', documentTypeId as ''@documentTypeId'', relationType  AS ''@relationType''
		FROM 
			(
			SELECT fullNumber, wh.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.WarehouseDocumentHeader wh WITH(NOLOCK) ON wh.id  IN (dr.firstWarehouseDocumentHeaderId,dr.secondWarehouseDocumentHeaderId) 
			WHERE wh.id <> @warehouseDocumentHeaderId  AND @warehouseDocumentHeaderId	IN (dr.firstWarehouseDocumentHeaderId,dr.secondWarehouseDocumentHeaderId) 
			UNION ALL		
			SELECT fullNumber, ch.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.CommercialDocumentHeader ch WITH(NOLOCK) ON ( ch.id = dr.firstCommercialDocumentHeaderId AND dr.secondWarehouseDocumentHeaderId = @warehouseDocumentHeaderId ) OR ( ch.id = dr.secondCommercialDocumentHeaderId AND dr.firstWarehouseDocumentHeaderId = @warehouseDocumentHeaderId)  
			UNION ALL			
			SELECT fullNumber, fh.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.FinancialDocumentHeader fh WITH(NOLOCK) ON ( fh.id = dr.firstFinancialDocumentHeaderId AND dr.secondWarehouseDocumentHeaderId = @warehouseDocumentHeaderId ) OR ( fh.id = dr.secondFinancialDocumentHeaderId AND dr.firstWarehouseDocumentHeaderId = @warehouseDocumentHeaderId)	
			UNION ALL			
			SELECT fullNumber, fh.id,NULL issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN complaint.ComplaintDocumentHeader fh WITH(NOLOCK) ON ( fh.id = dr.firstComplaintDocumentHeaderId AND dr.secondWarehouseDocumentHeaderId = @warehouseDocumentHeaderId ) OR ( fh.id = dr.secondComplaintDocumentHeaderId AND dr.firstWarehouseDocumentHeaderId = @warehouseDocumentHeaderId)					
			UNION ALL			
			SELECT fullNumber, fh.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.InventoryDocumentHeader fh WITH(NOLOCK) ON (fh.id = dr.firstInventoryDocumentHeaderId AND dr.secondWarehouseDocumentHeaderId = @warehouseDocumentHeaderId )  OR (fh.id = dr.secondInventoryDocumentHeaderId AND dr.firstWarehouseDocumentHeaderId = @warehouseDocumentHeaderId )	
								
			) x 
			ORDER BY issueDate DESC
			
			FOR XML PATH(''document''), TYPE
		) FOR XML PATH(''relatedDocuments''), TYPE	
	END
ELSE IF @complaintDocumentHeaderId IS NOT NULL
	BEGIN
	SELECT (
		SELECT fullNumber as ''@fullNumber'', id as ''@id'', issueDate as ''@issueDate'', documentTypeId as ''@documentTypeId'', relationType  AS ''@relationType''
		FROM 
			(
			SELECT fullNumber, wh.id, NULL issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN complaint.ComplaintDocumentHeader wh WITH(NOLOCK) ON wh.id  IN (dr.firstComplaintDocumentHeaderId,dr.secondComplaintDocumentHeaderId) 
			WHERE @complaintDocumentHeaderId	IN (NULLIF(dr.firstComplaintDocumentHeaderId,@complaintDocumentHeaderId),NULLIF(dr.secondComplaintDocumentHeaderId,@complaintDocumentHeaderId)) 
			UNION ALL		
			SELECT fullNumber, ch.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.CommercialDocumentHeader ch WITH(NOLOCK) ON ( ch.id = dr.firstCommercialDocumentHeaderId AND dr.secondComplaintDocumentHeaderId = @complaintDocumentHeaderId ) OR ( ch.id = dr.secondCommercialDocumentHeaderId AND dr.firstComplaintDocumentHeaderId = @complaintDocumentHeaderId)  
			UNION ALL			
			SELECT fullNumber, fh.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.FinancialDocumentHeader fh WITH(NOLOCK) ON ( fh.id = dr.firstFinancialDocumentHeaderId AND dr.secondComplaintDocumentHeaderId = @complaintDocumentHeaderId ) OR ( fh.id = dr.secondFinancialDocumentHeaderId AND dr.firstComplaintDocumentHeaderId = @complaintDocumentHeaderId)	
			UNION ALL			
			SELECT fullNumber, fh.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.WarehouseDocumentHeader fh WITH(NOLOCK) ON ( fh.id = dr.firstWarehouseDocumentHeaderId AND dr.secondComplaintDocumentHeaderId = @complaintDocumentHeaderId ) OR ( fh.id = dr.secondWarehouseDocumentHeaderId AND dr.firstComplaintDocumentHeaderId = @complaintDocumentHeaderId)	
			UNION ALL			
			SELECT fullNumber, fh.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.InventoryDocumentHeader fh WITH(NOLOCK) ON (fh.id = dr.firstInventoryDocumentHeaderId AND dr.secondComplaintDocumentHeaderId = @complaintDocumentHeaderId )  OR (fh.id = dr.secondInventoryDocumentHeaderId AND dr.firstComplaintDocumentHeaderId = @complaintDocumentHeaderId )	
						
			) x 
			ORDER BY issueDate DESC
			FOR XML PATH(''document''), TYPE
		) FOR XML PATH(''relatedDocuments''), TYPE	
	END
ELSE IF @inventoryDocumentHeaderId IS NOT NULL
	BEGIN
	SELECT (
		SELECT fullNumber as ''@fullNumber'', id as ''@id'', issueDate as ''@issueDate'', documentTypeId as ''@documentTypeId'', relationType  AS ''@relationType''
		FROM 
			(
			SELECT fullNumber, wh.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.InventoryDocumentHeader wh WITH(NOLOCK) ON wh.id  IN (dr.firstInventoryDocumentHeaderId,dr.secondInventoryDocumentHeaderId) 
			WHERE wh.id <> @inventoryDocumentHeaderId AND @inventoryDocumentHeaderId IN (dr.firstInventoryDocumentHeaderId,dr.secondInventoryDocumentHeaderId) 
			UNION ALL		
			SELECT fullNumber, ch.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.CommercialDocumentHeader ch WITH(NOLOCK) ON ( ch.id = dr.firstCommercialDocumentHeaderId AND dr.secondInventoryDocumentHeaderId = @inventoryDocumentHeaderId ) OR ( ch.id = dr.secondCommercialDocumentHeaderId AND dr.firstInventoryDocumentHeaderId = @inventoryDocumentHeaderId)  
			UNION ALL			
			SELECT fullNumber, fh.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.FinancialDocumentHeader fh WITH(NOLOCK) ON ( fh.id = dr.firstFinancialDocumentHeaderId AND dr.secondInventoryDocumentHeaderId = @inventoryDocumentHeaderId ) OR ( fh.id = dr.secondFinancialDocumentHeaderId AND dr.firstInventoryDocumentHeaderId = @inventoryDocumentHeaderId)	
			UNION ALL			
			SELECT fullNumber, fh.id, issueDate, documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN document.WarehouseDocumentHeader fh WITH(NOLOCK) ON ( fh.id = dr.firstWarehouseDocumentHeaderId AND dr.secondInventoryDocumentHeaderId = @inventoryDocumentHeaderId ) OR ( fh.id = dr.secondWarehouseDocumentHeaderId AND dr.firstInventoryDocumentHeaderId = @inventoryDocumentHeaderId)	
			UNION ALL			
			SELECT fullNumber, fh.id, NULL issueDate,  documentTypeId, relationType
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN complaint.ComplaintDocumentHeader fh WITH(NOLOCK) ON (fh.id = dr.firstComplaintDocumentHeaderId AND dr.secondInventoryDocumentHeaderId = @inventoryDocumentHeaderId )  OR (fh.id = dr.secondComplaintDocumentHeaderId AND dr.firstInventoryDocumentHeaderId = @inventoryDocumentHeaderId )	

			) x 
			ORDER BY issueDate DESC
			FOR XML PATH(''document''), TYPE
		) FOR XML PATH(''relatedDocuments''), TYPE	
	END
END
' 
END
GO

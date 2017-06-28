/*
name=[document].[p_cancelWarehouseDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
UOUwxRd/Bh3ysCGNjmXA9g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_cancelWarehouseDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_cancelWarehouseDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_cancelWarehouseDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_cancelWarehouseDocument] 
@warehouseDocumentHeaderId UNIQUEIDENTIFIER
AS
BEGIN 

DECLARE @xml XML,
		@xml_doc XML,
		@xml_package XML, 
		@databaseId uniqueidentifier,
		@previousVersion UNIQUEIDENTIFIER


	SELECT @databaseId =  CAST( textValue as uniqueidentifier) 
	FROM configuration.Configuration WHERE [key] = ''communication.databaseId''

/*Sprawdzenie czy dokument ma powiązany dokument handlowy
IF EXISTS (	SELECT wl.id 
			FROM document.CommercialWarehouseRelation cr 
				JOIN document.WarehouseDocumentLine wl ON cr.warehouseDocumentLineId = wl.id 
			WHERE warehouseDocumentHeaderId = @warehouseDocumentHeaderId )
	BEGIN

		SELECT (
			SELECT  DISTINCT ch.fullNumber, ch.creationDate date, c.fullName
			FROM document.CommercialWarehouseRelation cr 
				JOIN document.WarehouseDocumentLine wl ON cr.warehouseDocumentLineId = wl.id
				JOIN document.CommercialDocumentLine cl ON cr.commercialDocumentLineId = cl.id
				JOIN document.CommercialDocumentHeader ch ON cl.commercialDocumentHeaderId = ch.id
				JOIN contractor.Contractor c ON ch.modificationApplicationUserId = c.id
			WHERE warehouseDocumentHeaderId = @warehouseDocumentHeaderId
			FOR XML PATH(''entry''), TYPE
		) FOR XML PATH(''relatedCommercialDocuments''), ROOT(''root'')
		
		RETURN 0;
	END
	*/
/*Test na korektę
IF EXISTS (	SELECT id 
			FROM document.WarehouseDocumentLine 
			WHERE correctedWarehouseDocumentLineId IN (
					SELECT  id
					FROM document.WarehouseDocumentLine 
					WHERE  warehouseDocumentHeaderId = @warehouseDocumentHeaderId
					)
			)
	BEGIN
		SELECT (
			SELECT  DISTINCT ch.fullNumber, ch.issueDate date, c.fullName
			FROM document.WarehouseDocumentLine wl 
				JOIN document.WarehouseDocumentLine cl ON cl.correctedWarehouseDocumentLineId = wl.id
				JOIN document.WarehouseDocumentHeader ch ON cl.warehouseDocumentHeaderId = ch.id
				JOIN contractor.Contractor c ON ch.modificationApplicationUserId = c.id
			WHERE wl.warehouseDocumentHeaderId = @warehouseDocumentHeaderId
			FOR XML PATH(''entry''), TYPE
		) FOR XML PATH(''correctiveWarehouseDocuments''), ROOT(''root'')
		RETURN 0;		
	END
	*/
	/*Kasowanie powiązań nagłówkowch*/
	DELETE FROM document.DocumentRelation
	WHERE firstWarehouseDocumentHeaderId = @warehouseDocumentHeaderId
		OR secondWarehouseDocumentHeaderId = @warehouseDocumentHeaderId
	
	SELECT @xml_package	=
		(SELECT newid() ''@localTransactionId'' ,newid() ''@deferredTransactionId'', @databaseId ''@databaseId'', 
			(	SELECT DISTINCT r.id as ''@id'', ''delete'' as ''@action'', r.[version] as ''@previousVersion''
				FROM document.WarehouseDocumentLine l
					JOIN document.IncomeOutcomeRelation r ON l.id = r.incomeWarehouseDocumentLineId  OR l.id = r.outcomeWarehouseDocumentLineId
				WHERE r.id IS NOT NULL AND  l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId 
			FOR XML PATH(''entry'') ,TYPE)		
		FOR XML PATH(''root'') ,TYPE)
		
	EXEC communication.p_createIncomeOutcomeRelationPackage @xml_package
	
	/*Kasowanie powiązań dokumentu magazynowego*/
	EXEC [document].[p_deleteWarehouseDocumentRelationsForOutcome]  @warehouseDocumentHeaderId


	/*Test na powiązanie z rozchodem
	IF EXISTS (
			SELECT r.id
			FROM document.WarehouseDocumentLine l
				JOIN document.IncomeOutcomeRelation r ON l.id = r.incomeWarehouseDocumentLineId 
			WHERE r.id IS NOT NULL AND  l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId 
			) 
		BEGIN
			RAISERROR ( 50015, 16, 1 )
			RETURN 0;
		END
		*/
	EXEC [document].[p_deleteWarehouseDocumentRelationsForIncome]   @warehouseDocumentHeaderId

	SELECT @previousVersion = version 
	FROM  document.WarehouseDocumentHeader 
	WHERE id = @warehouseDocumentHeaderId

	/*Aktualizacja statusu dokumentu magazynowego*/
	UPDATE document.WarehouseDocumentHeader 
	SET status = - 20, version = newid()
	WHERE id = @warehouseDocumentHeaderId

	/*Aktualizacja kierunku rozchodu na liniach dok. magazynowego*/
	UPDATE document.WarehouseDocumentLine
	SET direction = 0 , version = newid()
	WHERE warehouseDocumentHeaderId = @warehouseDocumentHeaderId


	/*Aktualizacja stanu magazynu*/
	UPDATE  [document].WarehouseStock  WITH(ROWLOCK)
    SET quantity = x.quantity
    FROM    [document].WarehouseStock ws 
		JOIN	(SELECT SUM(l.quantity * l.direction) quantity,  l.itemId, l.warehouseId
					FROM document.WarehouseDocumentLine l 
						JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id
						JOIN (	SELECT distinct itemId, warehouseId 
								FROM document.WarehouseDocumentLine 
								WHERE warehouseDocumentHeaderId = @warehouseDocumentHeaderId) a on a.itemId = l.itemId AND a.warehouseId = l.warehouseId
				WHERE h.status >= 40
				GROUP BY l.itemId, l.warehouseId ) x ON ws.itemId = x.itemId AND ws.warehouseId = x.warehouseId



	/*Wysłanie dokumentu*/
	SELECT @xml_doc = (SELECT  @warehouseDocumentHeaderId ''@businessObjectId'' , @previousVersion ''@previousVersion'', newid() ''@localTransactionId'', newid() ''@deferredTransactionId'', @databaseId ''@databaseId''
						FOR XML PATH(''root''), TYPE )

	EXEC [communication].[p_createWarehouseDocumentPackage] @xml_doc
	
	/*Wysłanie stanów mgazynowych*/
	SELECT @xml_doc = (
		SELECT  @warehouseDocumentHeaderId ''@businessObjectId'' , @previousVersion ''@previousVersion'', newid() ''@localTransactionId'', newid() ''@deferredTransactionId'', @databaseId ''@databaseId'',
			(	
			SELECT itemId, warehouseId 
			FROM document.WarehouseDocumentLine 
			WHERE warehouseDocumentHeaderId = @warehouseDocumentHeaderId
			GROUP BY itemId, warehouseId						
			FOR XML PATH(''entry''), TYPE	
			)
		FOR XML PATH(''root''), TYPE	
					)
					
	EXEC [communication].[p_createWarehouseStockPackage] @xml_doc
	
	/*Zwrot danych*/							
	SELECT CAST( ''<root></root>'' AS XML) returnXml

END

/*
begin tran

exec [document].[p_cancelWarehouseDocument]  ''4C9A0200-B671-4B62-8D39-56CD855CF5BB''
select top 13 * from communication.OutgoingXmlQueue order by [order] desc

rollback tran

select * from document.WarehouseDocumentHeader WHERE id = ''4C9A0200-B671-4B62-8D39-56CD855CF5BB''
select * from communication.OutgoingXmlQueue with(nolock) where xml.value(''(root/warehouseDocumentHeader/entry/id)[1]'',''char(36)'') = ''4C9A0200-B671-4B62-8D39-56CD855CF5BB''
*/
' 
END
GO

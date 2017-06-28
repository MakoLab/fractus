/*
name=[custom].[p_makolab_validateDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
+kI17AZSmm9w6UUztG/9rQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_makolab_validateDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_makolab_validateDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_makolab_validateDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE procedure [custom].[p_makolab_validateDocument] @xmlVar XML
as 
BEGIN


   DECLARE  @action varchar(10), @documentId uniqueidentifier, @id uniqueidentifier, @documentTypeId uniqueidentifier, @documentTypeSymbol varchar(10), @x XML
       DECLARE @message TABLE (error varchar(max))
       

    SELECT  
            @action = x.value(''@action[1]'', ''varchar(10)''),
                    @documentId = x.value(''id[1]'', ''uniqueidentifier''),
                    @documentTypeId = x.value(''documentTypeId[1]'', ''uniqueidentifier''),
                    @documentTypeSymbol = x.value(''symbol[1]'', ''varchar(10)'')
    FROM    @xmlVar.nodes(''/*'') a(x)

     IF (@documentTypeId = ''0DDBD270-2D84-45F3-9CA7-91F535252327'' ) AND (EXISTS (SELECT ID FROM document.WarehouseDocumentLine where direction = -1 and quantity < 0  AND warehouseDocumentHeaderId = @documentId))
	 BEGIN
			
			UPDATE document.WarehouseDocumentLine SET direction = 1 , quantity = quantity * -1 WHERE direction = -1 and quantity < 0   AND warehouseDocumentHeaderId = @documentId
	 END
	  IF EXISTS( SELECT * FROM dictionary.DocumentType where symbol = ''PA'' and id = @documentTypeId )
	  BEGIN
			UPDATE document.CommercialDocumentLine 
			set grossValue = ROUND(ROUND(grossPrice,2) * quantity ,2)
			WHERE commercialDocumentHeaderId = @documentId

			UPDATE x
			SET x.grossValue = y.grossValue
			FROM document.CommercialDocumentHeader x
				JOIN (SELECT SUM(grossValue) grossValue , commercialDocumentHeaderId  id FROM document.CommercialDocumentLine GROUP BY commercialDocumentHeaderId) y ON x.id = y.id
			WHERE x.id = @documentId

	  END
	   
	IF EXISTS( SELECT * FROM dictionary.DocumentType where documentCategory = 2 and id = @documentTypeId )
		BEGIN
			
					SELECT TOP 1  @id = w.id 
					FROM document.CommercialDocumentHeader h 
						JOIN document.DocumentAttrValue v ON h.id = v.commercialDocumentHeaderId
						JOIN (select l.commercialDocumentHeaderId, wl.warehouseDocumentHeaderId from document.CommercialDocumentLine l JOIN document.CommercialWarehouseRelation r ON l.id = r.commercialDocumentLineId JOIN document.WarehouseDocumentLine wl ON r.warehouseDocumentLineId = wl.id GROUP BY l.commercialDocumentHeaderId, wl.warehouseDocumentHeaderId ) x ON h.id = x.commercialDocumentHeaderId
						JOIN document.WarehouseDocumentHeader w ON x.warehouseDocumentHeaderId = w.id
						LEFT JOIN document.DocumentAttrValue vw ON w.id = vw.warehouseDocumentHeaderId AND v.documentFieldId = vw.documentFieldId
					WHERE h.id = @documentId 
						AND v.documentFieldId in (''2320488F-FAFE-48B5-A7F6-4F064413D9EA'',''52FF43B8-E7FC-48FF-94F9-C44E289AF612'')
						AND vw.id is null
			IF @id is not null
				BEGIN
				 
					INSERT INTO document.DocumentAttrValue
					SELECT newid(), null, w.id,v.documentFieldId, null,v.dateValue, v.textValue, null, newid(), v.[order], null, null, null, null 
					FROM document.CommercialDocumentHeader h 
						JOIN document.DocumentAttrValue v ON h.id = v.commercialDocumentHeaderId
						JOIN (select l.commercialDocumentHeaderId, wl.warehouseDocumentHeaderId from document.CommercialDocumentLine l JOIN document.CommercialWarehouseRelation r ON l.id = r.commercialDocumentLineId JOIN document.WarehouseDocumentLine wl ON r.warehouseDocumentLineId = wl.id GROUP BY l.commercialDocumentHeaderId, wl.warehouseDocumentHeaderId ) x ON h.id = x.commercialDocumentHeaderId
						JOIN document.WarehouseDocumentHeader w ON x.warehouseDocumentHeaderId = w.id
						LEFT JOIN document.DocumentAttrValue vw ON w.id = vw.warehouseDocumentHeaderId AND v.documentFieldId = vw.documentFieldId
					WHERE h.id = @documentId 
						AND v.documentFieldId in (''2320488F-FAFE-48B5-A7F6-4F064413D9EA'',''52FF43B8-E7FC-48FF-94F9-C44E289AF612'')
						AND vw.id is null
			
			
					SELECT @x = CAST( ''<root businessObjectId="'' + CAST( @id AS char(36)) + ''" deferredTransactionId="'' + CAST( newid() AS char(36)) + ''" localTransactionId="'' + CAST( newid() AS char(36)) + ''"  databaseId="76DC8FC5-F716-4AF3-A4B6-92F5FD7AC103" />'' AS XML)
				 
					EXEC  [communication].[p_createWarehouseDocumentPackage] @x
				END
		END

SELECT CAST(''<root>OK</root>'' as XML)
END' 
END
GO

/*
name=[custom].[p_createWarehouseDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
miJ7rVpo4vb3WqxW9vmphA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_createWarehouseDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_createWarehouseDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_createWarehouseDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [custom].[p_createWarehouseDocument] 
	@id uniqueidentifier,
	@documentTypeId uniqueidentifier,
	@warehouseId uniqueidentifier,
	@sourceCommercialDocument uniqueidentifier,
	@direction int,
	@documentSymbol varchar(50),
	@localTransactionId uniqueidentifier,
	@deferredTransactionId uniqueidentifier,
	@databaseId uniqueidentifier,
	@modelPosition int
AS
BEGIN
DECLARE @x XML, @warehouseSymbol varchar(50)

			SELECT @warehouseSymbol = symbol FROM dictionary.Warehouse WHERE id = @warehouseId

		/*Budowa nowego dokumentu na magazyn rozliczenia dostawcy*/
		SELECT @x = (SELECT @localTransactionId ''@localTransactionId'',@deferredTransactionId ''@deferredTransactionId'',@databaseId ''@databaseId'',
						''D1F80960-EC30-48E4-979B-F7A5D33C25B3'' ''@applicationUserId'',
							( SELECT    (	SELECT  @id id, 
													@documentTypeId documentTypeId,
													h.contractorId,
													@warehouseId warehouseId,
													h.documentCurrencyId,
													h.systemCurrencyId,
													(SELECT @warehouseSymbol +''/[SequentialNumber]/''+ CAST(YEAR(GETDATE()) as varchar(50))) fullNumber,
													h.issueDate,
													h.netValue value,
													h.modificationDate,
													h.modificationApplicationUserId,
													newid() [version],
													40 [status],
													h.branchId,
													h.companyId,
													s.[numberSettingId],
													(SELECT @documentSymbol+''/''+@warehouseSymbol+''/'' + CAST(YEAR(GETDATE()) as varchar(50))) seriesValue
											FROM      [document].CommercialDocumentHeader h 
												LEFT JOIN document.Series s ON h.seriesId = s.id
											WHERE     h.id = @sourceCommercialDocument
											FOR XML PATH(''entry''),  TYPE
											)
								FOR XML PATH(''warehouseDocumentHeader''), TYPE
							) FOR XML PATH(''root''),TYPE)

			exec document.p_insertWarehouseDocumentHeader @xmlVar=@x
	
	
			/*Linie dokumentu*/
			SELECT @x = ( SELECT
						( SELECT ( 
										SELECT  newid() id,
												@id warehouseDocumentHeaderId,
												@direction direction,
												CASE WHEN @modelPosition = 1 THEN (
																					SELECT top 1 iav.textValue FROM item.ItemAttrValue iav WHERE i.id = iav.itemId AND iav.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE name like ''Attribute_ModelId'')
																					) ELSE l.itemId END itemId,
												@warehouseId warehouseId ,
												l.unitId ,
												l.quantity ,
												l.netPrice price,
												l.netValue value ,
												getdate() incomeDate ,
												null outcomeDate ,
												null description ,
												l.ordinalNumber ,
												newid() [version] ,
												0 isDistributed ,
												null previousIncomeWarehouseDocumentLineId ,
												null correctedWarehouseDocumentLineId ,
												null initialWarehouseDocumentLineId ,
												0 lineType ,
												i.name itemName, 
												i.code itemCode, 
												i.itemTypeId itemTypeId
                                        FROM      [document].CommercialDocumentLine  l
											JOIN item.Item i ON  l.itemId = i.id
											
                                        WHERE     commercialDocumentHeaderId = @sourceCommercialDocument
                                        FOR XML PATH(''entry''), TYPE
                                  )FOR XML PATH(''warehouseDocumentLine''), TYPE
                            )FOR XML PATH(''root''),TYPE)	
             	
        exec document.p_insertWarehouseDocumentLine @xmlVar=@x
        
        /*Atrybuty nagłówka*/
         SELECT @x = (SELECT   ( SELECT    (SELECT  newid() id,  
													commercialDocumentHeaderId,
													@id warehouseDocumentHeaderId,
													documentFieldId,
													decimalValue,
													dateValue,
													textValue,
													xmlValue,
													newid() [version],
													[order],
													financialDocumentHeaderId,
													complaintDocumentHeaderId,
													inventoryDocumentHeaderId,
													offerId
											FROM      [document].DocumentAttrValue
											WHERE     CommercialDocumentHeaderId = @sourceCommercialDocument
											FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''documentAttrValue''), TYPE
                            )    FOR XML PATH(''root''),TYPE)	
           IF EXISTS(SELECT id FROM [document].DocumentAttrValue WHERE warehouseDocumentHeaderId = @id)

			exec document.p_insertDocumentAttrValue @xmlVar=@x  
           
           /*Atrybuty linii*/
				SELECT @x = (SELECT
                        ( SELECT   ( 
							  SELECT    newid() id,
										v.commercialDocumentLineId,
										new.id warehouseDocumentLineId,
										v.financialDocumentLineId,
										v.documentFieldId,
										v.decimalValue,
										v.dateValue,
										v.textValue,
										v.xmlValue,
										newid() [version],
										v.[order],
										v.guidValue,
										v.offerLineId
                              FROM      [document].DocumentLineAttrValue v
								JOIN [document].CommercialDocumentLine old ON v.commercialDocumentLineId = old.id
								JOIN [document].WarehouseDocumentLine new ON old.ordinalNumber = new.ordinalNumber
                              WHERE     old.commercialDocumentHeaderId = @sourceCommercialDocument AND new.warehouseDocumentHeaderId = @id			
                              FOR XML PATH(''entry''), TYPE )
						FOR XML PATH(''documentLineAttrValue''), TYPE		
					) FOR XML PATH(''root''),TYPE )
					
					IF EXISTS(SELECT x.value(''.'',''varchar(50)'') FROM @x.nodes(''root/documentLineAttrValue/entry/id'') as a(x) )
						exec document.p_insertDocumentLineAttrValue @xmlVar=@x
		
	END
' 
END
GO

/*
name=[custom].[p_cloneWarehouseDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4ZXTY8gNuDSxeErFFvpe4w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_cloneWarehouseDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_cloneWarehouseDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_cloneWarehouseDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [custom].[p_cloneWarehouseDocument]
	@id uniqueidentifier,
	@documentId uniqueidentifier,
	@localTransactionId uniqueidentifier,
	@deferredTransactionId uniqueidentifier,
	@databaseId uniqueidentifier,
	@direction int,
	@warehouseId uniqueidentifier = ''3EEE2100-BA90-4455-8120-2CB0FC677364'',
	@documentTypeId uniqueidentifier =''CE3CBCD2-4636-402C-9A2F-DF0EB6191B3C'',
	@modelPosition int
	
AS
BEGIN	


DECLARE @x XML, @typeSymbol varchar(50), @warehouseSymbol varchar(50)

	SELECT @warehouseSymbol = symbol FROM dictionary.Warehouse where id = @warehouseId
	SELECT @typeSymbol = symbol FROM dictionary.DocumentType where id = @documentTypeId
			/*Budowa nowego dokumentu na magazyn rozliczenia dostawcy*/
			SELECT @x = (SELECT @localTransactionId ''@localTransactionId'',@deferredTransactionId ''@deferredTransactionId'',@databaseId ''@databaseId'',
						''D1F80960-EC30-48E4-979B-F7A5D33C25B3'' ''@applicationUserId'',
							( SELECT    (	SELECT  @id id, 
													@documentTypeId documentTypeId,
													h.contractorId,
													@warehouseId warehouseId,
													h.documentCurrencyId,
													h.systemCurrencyId,
													(SELECT @warehouseSymbol + ''/[SequentialNumber]/''+ CAST(YEAR(GETDATE()) as varchar(50))) fullNumber,
													h.issueDate,
													h.value,
													h.modificationDate,
													h.modificationApplicationUserId,
													newid() [version],
													h.[status],
													h.branchId,
													h.companyId,
													s.[numberSettingId],
													(SELECT @typeSymbol + ''/''+@warehouseSymbol+''/'' + CAST(YEAR(GETDATE()) as varchar(50))) seriesValue
											FROM      [document].WarehouseDocumentHeader h 
												LEFT JOIN document.Series s ON h.seriesId = s.id
											WHERE     h.id = @documentId
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
												@direction ,
												CASE WHEN @modelPosition = 1 THEN (
																					SELECT top 1 iav.textValue FROM item.ItemAttrValue iav WHERE i.id = iav.itemId AND iav.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE name like ''Attribute_ModelId'')
																					) ELSE l.itemId END itemId,
												@warehouseId warehouseId ,
												l.unitId ,
												l.quantity ,
												l.price ,
												l.value ,
												l.incomeDate ,
												l.outcomeDate ,
												l.description ,
												l.ordinalNumber ,
												newid() [version] ,
												l.isDistributed ,
												@direction direction,
												l.previousIncomeWarehouseDocumentLineId ,
												l.correctedWarehouseDocumentLineId ,
												l.initialWarehouseDocumentLineId ,
												l.lineType ,
												i.name itemName, 
												i.code itemCode, 
												i.itemTypeId itemTypeId
                                        FROM      [document].WarehouseDocumentLine  l
											JOIN item.Item i ON  l.itemId = i.id
                                        WHERE     warehouseDocumentHeaderId = @documentId
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
											WHERE     warehouseDocumentHeaderId = @documentId
											FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''documentAttrValue''), TYPE
                            )    FOR XML PATH(''root''),TYPE)	
           IF EXISTS(SELECT id FROM [document].DocumentAttrValue WHERE warehouseDocumentHeaderId = @documentId)
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
								JOIN [document].WarehouseDocumentLine old ON v.warehouseDocumentLineId = old.id
								JOIN [document].WarehouseDocumentLine new ON old.ordinalNumber = new.ordinalNumber
                              WHERE     old.warehouseDocumentHeaderId = @documentId AND new.warehouseDocumentHeaderId = @id			
                              FOR XML PATH(''entry''), TYPE )
						FOR XML PATH(''documentLineAttrValue''), TYPE		
					) FOR XML PATH(''root''),TYPE )
					IF EXISTS(SELECT x.value(''.'',''varchar(50)'') FROM @x.nodes(''root/documentLineAttrValue/entry/id'') as a(x) )
						exec document.p_insertDocumentLineAttrValue @xmlVar=@x
					
			SELECT @x = (SELECT
							( SELECT    ( SELECT    newid() id,
													v.commercialDocumentLineId,
													new.id warehouseDocumentLineId,
													v.quantity,
													v.value,
													v.price,
													newid() [version]
                                          FROM      [document].CommercialWarehouseValuation v
                                          	JOIN [document].WarehouseDocumentLine old ON v.warehouseDocumentLineId = old.id
											JOIN [document].WarehouseDocumentLine new ON old.ordinalNumber = new.ordinalNumber
										  WHERE     old.warehouseDocumentHeaderId = @documentId AND new.warehouseDocumentHeaderId = @id
	                                      FOR XML PATH(''entry''), TYPE )
                             FOR XML PATH(''commercialWarehouseValuation''), TYPE
                            ) FOR XML PATH(''root''),TYPE )		
			IF EXISTS(SELECT x.value(''.'',''varchar(50)'') FROM @x.nodes(''root/commercialWarehouseValuation/entry/id'') as a(x) )                            
				exec document.p_insertCommercialWarehouseValuation @xmlVar=@x

		
END
' 
END
GO

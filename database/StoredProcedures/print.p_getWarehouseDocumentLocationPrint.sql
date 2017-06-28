/*
name=[print].[p_getWarehouseDocumentLocationPrint]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
+s4FP1eUT7BdS+P9XITkzg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[print].[p_getWarehouseDocumentLocationPrint]') AND type in (N'P', N'PC'))
DROP PROCEDURE [print].[p_getWarehouseDocumentLocationPrint]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[print].[p_getWarehouseDocumentLocationPrint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [print].[p_getWarehouseDocumentLocationPrint]
@documentHeaderId UNIQUEIDENTIFIER
AS
BEGIN


	DECLARE @contractorXML XML 

	SELECT @contractorXML =
						(		SELECT 
									isSupplier,
									isReceiver,
									isBusinessEntity,
									isBank,
									isEmployee,
									isOwnCompany,
									fullName,
									shortName,
									(SELECT (	SELECT
													*
												FROM contractor.ContractorAddress ca 
												WHERE ca.contractorId = c.id
												FOR XML PATH(''address''), TYPE )
											FOR XML PATH(''addresses''), TYPE
									)
								FROM contractor.Contractor c 
								WHERE c.id = ( SELECT contractorId FROM document.WarehouseDocumentHeader WHERE id = @documentHeaderId )

								FOR XML PATH(''contractor''), ROOT(''contractor'') )


		/*Budowanie XML z kompletem informacji o dokumencie*/
        SELECT  (
			SELECT getdate() as ''@currentDateTime'',  ( 
				  SELECT    
						CDL.id,
						CDL.documentTypeId,
						CDL.warehouseId,
						CDL.documentCurrencyId,
						CDL.systemCurrencyId,
						CDL.issueDate,
						CDL.value,	
						CDL.status,
						CDL.number AS ''number/number'',
						CDL.fullNumber AS ''number/fullNumber'',
						s.[numberSettingId] AS ''number/numberSettingId'',

					(	SELECT (
							SELECT 
								ISNULL(documentFieldId, '''') documentFieldId,
								ISNULL(ISNULL(CAST(xmlValue AS VARCHAR(max)),ISNULL(textValue,ISNULL(CONVERT(char(10),dateValue,120),decimalValue))),'''') value
							FROM document.DocumentAttrValue a 
							WHERE a.warehouseDocumentHeaderId = @documentHeaderId
							FOR XML PATH(''attribute''), TYPE )
						FOR XML PATH(''attributes''), TYPE ),
						@contractorXML ,

						(SELECT (
								SELECT 
									isSupplier,
									isReceiver,
									isBusinessEntity,
									isBank,
									isEmployee,
									isOwnCompany,
									fullName,
									shortName,
									(SELECT (	SELECT
													*
												FROM contractor.ContractorAddress ca 
												WHERE ca.contractorId = c.id
												FOR XML PATH(''address''), TYPE )
											FOR XML PATH(''addresses''), TYPE
									)
								FROM contractor.Contractor c 
								WHERE c.id = CDL.modificationApplicationUserId
								FOR XML PATH(''contractor''), TYPE
						) FOR XML PATH(''issuingPerson''), TYPE ),


						(SELECT (
								SELECT 
									isSupplier,
									isReceiver,
									isBusinessEntity,
									isBank,
									isEmployee,
									isOwnCompany,
									fullName,
									shortName,
									(SELECT (	SELECT
													*
												FROM contractor.ContractorAddress ca 
												WHERE ca.contractorId = c.id
												FOR XML PATH(''address''), TYPE )
											FOR XML PATH(''addresses''), TYPE
									)
								FROM contractor.Contractor c 
								WHERE c.id = CDL.companyId
								FOR XML PATH(''contractor''), TYPE
						) FOR XML PATH(''issuer''), TYPE ),


				  (SELECT (
					SELECT * FROM (
							SELECT 
								l.ordinalNumber,
								l.itemId,
								l.direction,
								l.warehouseId,
								l.unitId,
								x.quantity,
								l.value,
								l.price,
								ISNULL((SELECT TOP 1 lc.itemName FROM document.CommercialDocumentLine lc JOIN document.CommercialWarehouseRelation clc ON lc.id =clc.commercialDocumentLineId WHERE clc.warehouseDocumentLineId = l.id AND clc.isCommercialRelation = 1 ) ,i.name) itemName,
								( SELECT ia.textValue
								  FROM item.ItemAttrValue ia
								  WHERE ia.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_Barcode'') AND ia.itemId = l.itemId
								 ) barCode,
								 i.code itemCode ,
								 x.quantity shiftQuantity,
								 x.symbol,
								 x.[order]

							FROM [document].WarehouseDocumentLine l 
								JOIN item.Item i ON l.itemId = i.id
								JOIN (  SELECT quantity , c.[name] AS symbol, warehouseDocumentLineId, c.[order]
										FROM warehouse.Shift s 
											LEFT JOIN warehouse.Container c ON ISNULL(s.containerId, ( SELECT containerId FROM warehouse.Shift WHERE s.sourceShiftId = id ) ) = c.id
										WHERE s.[status] > 0
										) x  ON x.warehouseDocumentLineId = l.id
							WHERE l.warehouseDocumentHeaderId = @documentHeaderId
						UNION ALL
							SELECT 
								l.ordinalNumber,
								l.itemId,
								l.direction,
								l.warehouseId,
								l.unitId,
								l.quantity - ISNULL((  SELECT SUM (quantity) quantity FROM warehouse.Shift s WHERE warehouseDocumentLineId = l.id ) ,0) quantity,
								l.value,
								l.price,
								i.name itemName,
								( SELECT ia.textValue
								  FROM item.ItemAttrValue ia
								  WHERE ia.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_Barcode'') AND ia.itemId = l.itemId
								 ) barCode,
								 i.code itemCode ,
								 null shiftQuantity,
								 null symbol,
								 1000000 [order]
									FROM [document].WarehouseDocumentLine l 
								JOIN item.Item i ON l.itemId = i.id
							WHERE l.warehouseDocumentHeaderId = @documentHeaderId
								AND l.quantity > ISNULL( (  SELECT SUM (quantity) quantity FROM warehouse.Shift s WHERE warehouseDocumentLineId = l.id ) , 0)
							
							) xxx
							ORDER BY xxx.[order]

							FOR XML PATH(''line''), TYPE
							) FOR XML PATH(''lines''), TYPE)				
                  FROM      [document].WarehouseDocumentHeader CDL 
					LEFT JOIN document.Series s ON CDL.seriesId = s.id
                  WHERE     CDL.id = @documentHeaderId
                  FOR XML PATH(''warehouseDocument''), TYPE
            ) FOR XML PATH(''root''),TYPE
          ) AS returnsXML

    END
' 
END
GO

/*
name=[print].[p_getWarehouseDocumentPrint]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
n9Z0E7OUrqNCpxBG/I6r8w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[print].[p_getWarehouseDocumentPrint]') AND type in (N'P', N'PC'))
DROP PROCEDURE [print].[p_getWarehouseDocumentPrint]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[print].[p_getWarehouseDocumentPrint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N' 

CREATE PROCEDURE [print].[p_getWarehouseDocumentPrint]
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
												FROM contractor.ContractorAddress ca  WITH (NOLOCK)
												WHERE ca.contractorId = c.id
												FOR XML PATH(''address''), TYPE )
											FOR XML PATH(''addresses''), TYPE
									)
								FROM contractor.Contractor c  WITH (NOLOCK)
								WHERE c.id = ( SELECT contractorId FROM document.WarehouseDocumentHeader  WITH (NOLOCK) WHERE id = @documentHeaderId )

								FOR XML PATH(''contractor''), ROOT(''contractor'') )


		/*Budowanie XML z kompletem informacji o dokumencie*/
        SELECT  (
			SELECT ( 
				  SELECT    
						CDL.id,
						CDL.documentTypeId,
						CDL.warehouseId,
						CDL.documentCurrencyId,
						CDL.systemCurrencyId,
						CDL.issueDate,
						CDL.value,	
					
						ISNULL( (SELECT SUM( ABS((ll.sysGrossValue/NULLIF(ll.quantity, 0)) * ll.commercialDirection)  * cr.quantity * SIGN(ll.quantity) ) FROM document.CommercialDocumentLine ll WITH (NOLOCK) JOIN document.CommercialWarehouseRelation cr WITH (NOLOCK) ON ll.id = cr.commercialDocumentLineId  WHERE cr.warehouseDocumentLineId IN ( SELECT h.id FROM document.WarehouseDocumentLine h WHERE h.warehouseDOcumentHeaderId = CDL.id ) AND cr.isCommercialRelation = 1), 
							 ( SELECT SUM( round(( i.defaultPrice * 1.23),2) * ABS(h.quantity) ) FROM document.WarehouseDocumentLine h  join item.Item i on h.itemId = i.id WHERE h.warehouseDOcumentHeaderId = CDL.id ) ) salesGrossValue,
						ISNULL( (SELECT SUM( ABS((ll.sysNetValue/NULLIF(ll.quantity, 0)) * ll.commercialDirection ) * cr.quantity * SIGN(ll.quantity) ) FROM document.CommercialDocumentLine ll WITH (NOLOCK) JOIN document.CommercialWarehouseRelation cr WITH (NOLOCK) ON ll.id = cr.commercialDocumentLineId  WHERE cr.warehouseDocumentLineId IN ( SELECT h.id FROM document.WarehouseDocumentLine h WHERE h.warehouseDOcumentHeaderId = CDL.id ) AND cr.isCommercialRelation = 1), 0.0) salesNetValue ,
			
						CDL.status,
						CDL.number AS ''number/number'',
						REPLACE(CDL.fullNumber,'' '',char(160)) AS ''number/fullNumber'',
						s.[numberSettingId] AS ''number/numberSettingId'',

					(	SELECT (
							SELECT 
								ISNULL(documentFieldId, '''') documentFieldId,
								ISNULL(ISNULL(CAST(xmlValue AS VARCHAR(max)),ISNULL(textValue,ISNULL(CONVERT(char(10),dateValue,120),decimalValue))),'''') value
							FROM document.DocumentAttrValue a  WITH (NOLOCK)
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
												FROM contractor.ContractorAddress ca  WITH (NOLOCK)
												WHERE ca.contractorId = c.id
												FOR XML PATH(''address''), TYPE )
											FOR XML PATH(''addresses''), TYPE
									)
								FROM contractor.Contractor c  WITH (NOLOCK)
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
												FROM contractor.ContractorAddress ca  WITH (NOLOCK)
												WHERE ca.contractorId = c.id
												FOR XML PATH(''address''), TYPE )
											FOR XML PATH(''addresses''), TYPE
									)
								FROM contractor.Contractor c  WITH (NOLOCK)
								WHERE c.id = CDL.companyId
								FOR XML PATH(''contractor''), TYPE
						) FOR XML PATH(''issuer''), TYPE ),


				  (SELECT (
							SELECT 
								l.ordinalNumber,
								l.itemId,
								l.direction,
								l.warehouseId,
								l.unitId,
								l.quantity,
								l.value,
								l.price,
								i.name itemName,
								i.code itemCode,
								i.vatRateId ,
								ISNULL( (SELECT SUM( ll.quantity * ll.direction) FROM document.WarehouseDocumentHeader hh WITH (NOLOCK) JOIN document.WarehouseDocumentLine ll WITH (NOLOCK) ON hh.id = ll.warehouseDocumentHeaderId WHERE ll.itemId = l.itemId AND ll.warehouseId = l.warehouseId AND hh.issueDate < CDL.issueDate), 0.0) beforeStock,
								ISNULL( (SELECT  SUM(ll.sysNetValue) / SUM(NULLIF(ll.quantity, 0))  FROM document.CommercialDocumentLine ll WITH (NOLOCK) JOIN document.CommercialWarehouseRelation cr WITH (NOLOCK) ON ll.id = cr.commercialDocumentLineId  WHERE cr.warehouseDocumentLineId = l.id AND cr.isCommercialRelation = 1), 0.0) salesNetPrice ,
								ISNULL( (SELECT  SUM(ll.sysGrossValue)/SUM(NULLIF(ll.quantity, 0)) FROM document.CommercialDocumentLine ll WITH (NOLOCK) JOIN document.CommercialWarehouseRelation cr WITH (NOLOCK) ON ll.id = cr.commercialDocumentLineId  WHERE cr.warehouseDocumentLineId = l.id AND cr.isCommercialRelation = 1), round(( i.defaultPrice * 1.23),2)) salesGrossPrice ,
								ISNULL( (SELECT SUM( ll.sysNetValue ) * SIGN(l.quantity )  FROM document.CommercialDocumentLine ll WITH (NOLOCK) JOIN document.CommercialWarehouseRelation cr WITH (NOLOCK) ON ll.id = cr.commercialDocumentLineId  WHERE cr.warehouseDocumentLineId = l.id AND cr.isCommercialRelation = 1), 0.0) salesNetValue ,
								ISNULL( (SELECT SUM( ll.sysGrossValue) FROM document.CommercialDocumentLine ll WITH (NOLOCK) JOIN document.CommercialWarehouseRelation cr WITH (NOLOCK) ON ll.id = cr.commercialDocumentLineId  WHERE cr.warehouseDocumentLineId = l.id AND cr.isCommercialRelation = 1),  round(( i.defaultPrice * 1.23),2) * ABS(l.quantity) ) salesGrossValue,
								( SELECT TOP 1 ia.textValue
								  FROM item.ItemAttrValue ia
								  WHERE ia.itemFieldId = ( SELECT id FROM dictionary.ItemField  WITH (NOLOCK) WHERE [name] = ''Attribute_Barcode'') AND ia.itemId = l.itemId
								 ) barCode,
								(
									SELECT (
										SELECT quantity , c.[name] AS symbol
										FROM warehouse.Shift s  WITH (NOLOCK)
											LEFT JOIN warehouse.Container c  WITH (NOLOCK) ON ISNULL(s.containerId, ( SELECT containerId FROM warehouse.Shift  WITH (NOLOCK) WHERE s.sourceShiftId = id ) ) = c.id
										WHERE s.warehouseDocumentLineId = l.id AND s.[status] > 0
										FOR XML PATH(''entry''), TYPE )
									FOR XML PATH(''shift''), TYPE
								)
		
							FROM [document].WarehouseDocumentLine l  WITH (NOLOCK)
								JOIN item.Item i  WITH (NOLOCK) ON l.itemId = i.id
							WHERE l.warehouseDocumentHeaderId = @documentHeaderId
							ORDER BY l.ordinalNumber
							FOR XML PATH(''line''), TYPE
							) FOR XML PATH(''lines''), TYPE)				
                  FROM      [document].WarehouseDocumentHeader CDL  WITH (NOLOCK)
					LEFT JOIN document.Series s  WITH (NOLOCK) ON CDL.seriesId = s.id
					
                  WHERE     CDL.id = @documentHeaderId
                  FOR XML PATH(''warehouseDocument''), TYPE
            ) FOR XML PATH(''root''),TYPE
          ) AS returnsXML
    END
' 
END
GO

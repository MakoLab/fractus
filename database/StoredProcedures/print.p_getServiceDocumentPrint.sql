/*
name=[print].[p_getServiceDocumentPrint]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
IIpvDEKUByQAVOyhvwuNJQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[print].[p_getServiceDocumentPrint]') AND type in (N'P', N'PC'))
DROP PROCEDURE [print].[p_getServiceDocumentPrint]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[print].[p_getServiceDocumentPrint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [print].[p_getServiceDocumentPrint]
@documentHeaderId UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @commercialDocumentId UNIQUEIDENTIFIER, @warehouseDocuments XML

	SELECT @commercialDocumentId = ISNULL( NULLIF(firstCommercialDocumentHeaderId,@documentHeaderId) , secondCommercialDocumentHeaderId)
	FROM document.DocumentRelation WITH(NOLOCK)
	WHERE @documentHeaderId IN (firstCommercialDocumentHeaderId, secondCommercialDocumentHeaderId)


	IF @commercialDocumentId IS NOT NULL
		SELECT @warehouseDocuments = 
											(	SELECT w.fullNumber  AS ''@fullNumber''
												FROM document.WarehouseDocumentHeader w WITH(NOLOCK)
													JOIN document.WarehouseDocumentLine l WITH(NOLOCK) ON w.id = l.warehouseDocumentHeaderId
													JOIN document.CommercialWarehouseRelation wr  WITH(NOLOCK) ON l.id = wr.warehouseDocumentLineId
													JOIN document.CommercialDocumentLine cl  WITH(NOLOCK) ON wr.commercialDocumentLineId = cl.id
												WHERE cl.commercialDocumentHeaderId = @commercialDocumentId
												FOR XML PATH(''document''), TYPE
												)
									

		/*Budowanie XML z kompletem informacji o dokumencie*/
        SELECT  (
			SELECT ( 
				  SELECT
						CDL.version,    
						CDL.id,
						CDL.number AS ''number/number'',
						REPLACE(CDL.fullNumber,'' '',char(160)) AS ''number/fullNumber'',
						s.[numberSettingId] AS ''number/numberSettingId'',
						CDL.branchId,
						CDL.companyId,
						CDL.documentCurrencyId,
						CDL.systemCurrencyId,
						CDL.status,
						CDL.issueDate,
						CDL.documentTypeId,
						CDL.vatRatesSummationType,
						CDL.netCalculationType,
						CDL.isExportedForAccounting,
						CDL.printDate,
						CDL.vatValue,
						CDL.grossValue,
						CDL.netValue,
						CDL.eventDate,
						CDL.issuePlaceId,
						CDL.exchangeRate,
						CDL.exchangeScale,
						CDL.exchangeDate,
						CDL.contractorAddressId,
						CDL.issuerContractorAddressId,
						SH.plannedEndDate,
						SH.creationDate,
						SH.description,
						SH.closureDate,
						(SELECT (SELECT vc.xmlValue
								FROM [contractor].[v_contractorPrintData] vc WITH (NOLOCK)
								WHERE vc.id = CDL.issuingPersonContractorId)
						 FOR XML PATH(''issuingPerson''), TYPE ),
						(SELECT (SELECT vc.xmlValue
								FROM [contractor].[v_contractorPrintData] vc WITH (NOLOCK)
								WHERE vc.id = CDL.issuerContractorId )
						FOR XML PATH(''issuer''), TYPE ),
						(SELECT (SELECT vc.xmlValue
								FROM [contractor].[v_contractorPrintData] vc WITH (NOLOCK)
								WHERE vc.id = CDL.receivingPersonContractorId)
						FOR XML PATH(''receivingPerson''), TYPE ),
						(SELECT (SELECT vc.xmlValue
								FROM [contractor].[v_contractorPrintData] vc WITH (NOLOCK)
								WHERE vc.id = CDL.contractorId)
						 FOR XML PATH(''contractor''), TYPE ),					
				  (SELECT (
							SELECT 
							  l.[id],
							  l.[commercialDocumentHeaderId],
							  l.[ordinalNumber],
							  l.[commercialDirection],
							  l.[orderDirection],
							  l.[unitId],
							  l.[itemId],
							  l.[warehouseId],
							  l.[itemVersion],
							  l.[itemName],
							  l.[quantity],
							  l.[netPrice],
							  l.[grossPrice],
							  l.[initialNetPrice],
							  l.[initialGrossPrice],
							  l.[discountRate],
							  l.[discountNetValue],
							  l.[discountGrossValue],
							  l.[initialNetValue],
							  l.[initialGrossValue],
							  l.[netValue],
							  l.[grossValue],
							  l.[vatValue],
							  l.[vatRateId],
							  l.[version],
							  l.[correctedCommercialDocumentLineId],
							  l.[initialCommercialDocumentLineId],
							  i.name itemName,
							  i.[version] itemVersion,
							  i.id itemId,
							  i.code itemCode,
							  ( SELECT
									(SELECT 
										  la.[id],
										  la.[commercialDocumentLineId],
										  la.[warehouseDocumentLineId],
										  la.[financialDocumentLineId],
										  la.[documentFieldId],
										  la.[decimalValue],
										  la.[dateValue],
										  la.[textValue],
										  la.[xmlValue],
										  la.[version],
										  la.[order]
									 FROM document.DocumentLineAttrValue la WITH(NOLOCK)
									 WHERE la.[commercialDocumentLineId] = l.id
									 FOR XML PATH(''attribute''), TYPE )
							   FOR XML PATH(''attributes''), TYPE )
							FROM [document].CommercialDocumentLine l  WITH (NOLOCK)
								JOIN item.Item i  WITH (NOLOCK) ON l.itemId = i.id
							WHERE l.commercialDocumentHeaderId = @documentHeaderId
							ORDER BY l.ordinalNumber
							FOR XML PATH(''line''), TYPE
						) FOR XML PATH(''lines''), TYPE),
				( SELECT
						(SELECT 
							  ha.[id],
							  ha.[commercialDocumentHeaderId],
							  ha.[warehouseDocumentHeaderId],
							  ha.[financialDocumentHeaderId],
							  ha.[documentFieldId],
							  ha.[decimalValue],
							  ha.[dateValue],
							  ha.[textValue],
							  ha.[xmlValue],
							  ha.[version],
							  ha.[order]
						 FROM document.DocumentAttrValue ha WITH(NOLOCK)
						 WHERE ha.[commercialDocumentHeaderId] = CDL.id
						 FOR XML PATH(''attribute''), TYPE )
				   FOR XML PATH(''attributes''), TYPE ),		
				( SELECT
						(SELECT 
							  SHE.[id],
							  SHE.[serviceHeaderId],
							  CAST( (SELECT  ''<employeeId label="'' + Contractor.shortName +''">'' +CAST( SHE.[employeeId] AS VARCHAR(36)) + ''</employeeId>''  ) AS XML),
							  SHE.[workTime],
							  SHE.[timeFraction],
							  SHE.[plannedStartDate],
							  SHE.[plannedEndDate],
							  SHE.[creationDate],
							  SHE.[description],
							  SHE.[ordinalNumber],
							  SHE.[version],
							  Contractor.fullName [fullName]
						 FROM service.ServiceHeaderEmployees SHE WITH(NOLOCK)
							LEFT JOIN contractor.Contractor  WITH(NOLOCK) ON Contractor.id = SHE.[employeeId]
						 WHERE SHE.[serviceHeaderId] = CDL.id
						 FOR XML PATH(''serviceDocumentEmployee''), TYPE )
				   FOR XML PATH(''serviceDocumentEmployees''), TYPE ),
				( SELECT
						(SELECT 
							  SHSO.[id],
							  SHSO.[serviceHeaderId],
							  CAST( (SELECT  ''<servicedObjectId label="'' + s.identifier +''">'' +CAST( SHSO.[servicedObjectId] AS VARCHAR(36)) + ''</servicedObjectId>''  ) AS XML),
							  SHSO.[incomeDate],
							  SHSO.[outcomeDate],
							  SHSO.[plannedEndDate],
							  SHSO.[creationDate],
							  SHSO.[description],
							  SHSO.[ordinalNumber],
							  SHSO.[version],
							  s.[description] servicedObjectDescription 
						 FROM service.ServiceHeaderServicedObjects SHSO WITH(NOLOCK)
							LEFT JOIN service.ServicedObject s  WITH(NOLOCK) ON SHSO.[servicedObjectId] = s.id
						 WHERE SHSO.[serviceHeaderId] = CDL.id
						 FOR XML PATH(''serviceDocumentServicedObject''), TYPE )
				   FOR XML PATH(''serviceDocumentServicedObjects''), TYPE ),
				( SELECT
						(SELECT 
							  SHSP.[id],
							  SHSP.[serviceHeaderId],
							  SHSP.[servicePlaceId],
							  SHSP.[workTime],
							  SHSP.[timeFraction],
							  SHSP.[plannedEndDate],
							  SHSP.[creationDate],
							  SHSP.[description],
							  SHSP.[ordinalNumber],
							  SHSP.[version]
						 FROM service.ServiceHeaderServicePlace SHSP WITH(NOLOCK)
						 WHERE SHSP.[serviceHeaderId] = CDL.id
						 FOR XML PATH(''serviceDocumentServicePlace''), TYPE )
				   FOR XML PATH(''serviceDocumentServicePlaces''), TYPE ),
				   					   				   
				( SELECT
						(SELECT 
							  vt.[id],
							  vt.[commercialDocumentHeaderId],
							  vt.[vatRateId],
							  vt.[netValue],
							  vt.[grossValue],
							  vt.[vatValue],
							  vt.[version],
							  vt.[order]
						 FROM document.CommercialDocumentVatTable vt WITH(NOLOCK)
						 WHERE vt.[commercialDocumentHeaderId] = CDL.id
						 FOR XML PATH(''vatEntry''), TYPE )
				   FOR XML PATH(''vatTable''), TYPE ),
				      
				   							
				( SELECT
						(SELECT 
							  vt.[id],
							  vt.[firstCommercialDocumentHeaderId],
							  vt.[secondCommercialDocumentHeaderId],
							  vt.[firstWarehouseDocumentHeaderId],
							  vt.[secondWarehouseDocumentHeaderId],
							  vt.[firstFinancialDocumentHeaderId],
							  vt.[secondFinancialDocumentHeaderId],
							  vt.[relationType],
							  vt.[version],
							  ( SELECT 
								(	SELECT 
										cm.version,    
										cm.id,
										cm.number AS ''number/number'',
										REPLACE(cm.fullNumber,'' '',char(160)) AS ''number/fullNumber'',
										sm.[numberSettingId] AS ''number/numberSettingId'',
										cm.branchId,
										cm.companyId,
										cm.documentCurrencyId,
										cm.systemCurrencyId,
										cm.status,
										cm.issueDate,
										cm.documentTypeId,
										cm.vatRatesSummationType,
										cm.netCalculationType,
										cm.isExportedForAccounting,
										cm.printDate,
										cm.vatValue,
										cm.grossValue,
										cm.netValue,
										cm.eventDate,
										cm.issuePlaceId,
										cm.exchangeRate,
										cm.exchangeScale,
										cm.exchangeDate,
										(SELECT (SELECT vc.xmlValue
												FROM [finance].[v_paymentPrintData] vc WITH (NOLOCK)
												WHERE vc.commercialDocumentHeaderId = @commercialDocumentId)
										 FOR XML PATH(''payments''), TYPE ),
										 (SELECT @warehouseDocuments FOR XML PATH(''warehouseDocuments''), TYPE )
									FROM [document].CommercialDocumentHeader cm  WITH (NOLOCK)
										LEFT JOIN document.Series sm  WITH (NOLOCK) ON cm.seriesId = sm.id
									WHERE cm.id = @commercialDocumentId
									FOR XML PATH(''commercialDocument''),TYPE	),
								(	SELECT 
										  f.number AS ''number/number'',
										  REPLACE(f.fullNumber,'' '',char(160)) AS ''number/fullNumber'',
										  sm.[numberSettingId] AS ''number/numberSettingId'',
										  f.[version],
										  f.[status],
										  f.[branchId],
										  f.[companyId],
										  f.[documentTypeId],
										  f.[contractorId],
										  f.[contractorAddressId],
										  f.[xmlConstantData],
										  f.[financialReportId],
										  f.[documentCurrencyId],
										  f.[systemCurrencyId],
										  f.[number],
										  f.[fullNumber],
										  f.[seriesId],
										  f.[issueDate],
										  f.[issuingPersonContractorId],
										  f.[modificationDate],
										  f.[modificationApplicationUserId],
										  f.[amount]
									FROM [document].FinancialDocumentHeader f  WITH (NOLOCK)
										LEFT JOIN document.Series sm  WITH (NOLOCK) ON f.seriesId = sm.id
									WHERE f.id in ( vt.[firstFinancialDocumentHeaderId], vt.[secondFinancialDocumentHeaderId])
									FOR XML PATH(''financialDocument''),TYPE	),									
								 ( SELECT
										  w.number AS ''number/number'',
										  REPLACE(w.fullNumber,'' '',char(160)) AS ''number/fullNumber'',
										  sm.[numberSettingId] AS ''number/numberSettingId'',
										  w.[id],
										  w.[documentTypeId],
										  w.[contractorId],
										  w.[warehouseId],
										  w.[documentCurrencyId],
										  w.[systemCurrencyId],
										  w.[number],
										  w.[fullNumber],
										  w.[issueDate],
										  w.[value],
										  w.[seriesId],
										  w.[modificationDate],
										  w.[modificationApplicationUserId],
										  w.[version],
										  w.[status],
										  w.[branchId],
										  w.[companyId]
									FROM [document].WarehouseDocumentHeader w  WITH (NOLOCK)
										LEFT JOIN document.Series sm  WITH (NOLOCK) ON w.seriesId = sm.id
									WHERE w.id in ( vt.[firstWarehouseDocumentHeaderId], vt.[secondWarehouseDocumentHeaderId])
									FOR XML PATH(''warehouseDocument''),TYPE	)									
								FOR XML PATH(''relatedDocument''),TYPE )										
						 FROM document.DocumentRelation vt WITH(NOLOCK)
						 WHERE CDL.id IN ( vt.[firstCommercialDocumentHeaderId], vt.[secondCommercialDocumentHeaderId] )
						 FOR XML PATH(''relation''), TYPE )
				   FOR XML PATH(''relations''), TYPE )											
                  FROM      [document].CommercialDocumentHeader CDL  WITH (NOLOCK)
					LEFT JOIN document.Series s  WITH (NOLOCK) ON CDL.seriesId = s.id
					LEFT JOIN [service].[ServiceHeader] SH WITH (NOLOCK) ON CDL.id = SH.commercialDocumentHeaderId
                  WHERE     CDL.id = @documentHeaderId
                  FOR XML PATH(''serviceDocument''), TYPE
            ) FOR XML PATH(''root''),TYPE
          ) AS returnsXML
    END
' 
END
GO

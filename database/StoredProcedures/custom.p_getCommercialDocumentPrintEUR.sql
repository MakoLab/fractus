/*
name=[custom].[p_getCommercialDocumentPrintEUR]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
BNFtsA+PBR5JxyRSM1LK8g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getCommercialDocumentPrintEUR]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_getCommercialDocumentPrintEUR]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getCommercialDocumentPrintEUR]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [custom].[p_getCommercialDocumentPrintEUR] 
@documentHeaderId UNIQUEIDENTIFIER
AS
BEGIN

	DECLARE @x XML, @i int, @c int, @id uniqueidentifier, @itemId uniqueidentifier, @value varchar(500)
	DECLARE @tmp TABLE ( f_id uniqueidentifier, fullNumber varchar(500),grossValue decimal(18,2), issueDate datetime, number int, ordinalNumber int identity(1,1))
	DECLARE @tmp_ TABLE (i int identity(1,1), id uniqueidentifier, itemId uniqueidentifier)
	
	
declare @paymentXml xml

select @paymentxml = 	(SELECT (SELECT vc.xmlValue.query(''payment/*'')
								FROM [finance].[v_paymentPrintData] vc WITH (NOLOCK)
								WHERE vc.commercialDocumentHeaderId = @documentHeaderId FOR XML PATH(''payment''), TYPE)
						 FOR XML PATH(''payments''), TYPE )					

set @paymentxml = replace(cast(@paymentxml as varchar(max)), ''F01007BF-1ADA-4218-AE77-52C106DA4105'', ''CBABCD4A-5FC2-4E41-A833-A895C78A2CBF'')

IF EXISTS( SELECT * FROM document.DocumentRelation WHERE secondCommercialDocumentHeaderId = @documentHeaderId)
	INSERT INTO @tmp ( f_id, fullNumber, grossValue, issueDate, number)
	SELECT  h2.id,dt.symbol + '' '' + h2.fullNumber , h2.grossValue, h2.issueDate, h2.number
	FROM document.DocumentRelation dr WITH(NOLOCK)
		LEFT JOIN document.CommercialDocumentHeader h1  WITH(NOLOCK) ON h1.id = dr.firstCommercialDocumentHeaderId -- ZS
		LEFT JOIN document.DocumentRelation dr2  WITH(NOLOCK) ON dr2.firstCommercialDocumentHeaderId = h1.id --powiązane z ZS doki 
		LEFT JOIN document.CommercialDocumentHeader h2  WITH(NOLOCK) ON h2.id = dr2.secondCommercialDocumentHeaderId  
		LEFT JOIN dictionary.DocumentType dt WITH(NOLOCK) ON dt.id = h2.documentTypeId
	WHERE dr.secondCommercialDocumentHeaderId = @documentHeaderId AND dr2.relationType = 9 
			AND h2.id IS NOT NULL 
			AND h2.id <> @documentHeaderId
	ORDER BY h2.issueDate
	
		/*Budowanie XML z kompletem informacji o dokumencie*/
SELECT @x = (		
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
						''CBABCD4A-5FC2-4E41-A833-A895C78A2CBF'' as documentCurrencyId,--CDL.documentCurrencyId,
						CDL.systemCurrencyId,
						CDL.status,
						CDL.contractorAddressId,
						CDL.issuerContractorAddressId,
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
						CDL.xmlConstantData,
						(SELECT (
							SELECT DISTINCT h.documentTypeId  ''@documentTypeId'', h.fullNumber ''@fullNumber'', dt.symbol ''@symbol''
							FROM document.WarehouseDocumentHeader h
								JOIN dictionary.DocumentType dt ON h.documentTypeId = dt.id
								JOIN document.WarehouseDocumentLine l ON h.id = l.warehouseDocumentHeaderId
								JOIN document.CommercialWarehouseRelation cwr ON l.id = cwr.warehouseDocumentLineId
								JOIN document.CommercialDocumentLine cl ON cwr.commercialDocumentLineId = cl.id
							WHERE cl.commercialDocumentHeaderId = CDL.id AND h.status > 0	
							FOR XML PATH(''outcomes''),TYPE
								)
						 FOR XML PATH(''outcomes''),TYPE
						),
						(SELECT
							(SELECT ordinalNumber as ''@ordinalNumber'',fullNumber as ''@fullNumber'', issueDate as ''@issueDate'', grossValue as ''@grossValue'',
									CASE WHEN tmp.issueDate <= CDL.issueDate THEN 0 ELSE 1 END ''@isLater'',
								(	SELECT dt2.symbol + '' '' + f.fullNumber as ''@fullNumber''
									FROM finance.Payment p WITH(NOLOCK)
										JOIN finance.PaymentSettlement ps ON ps.incomePaymentId = p.id OR ps.outcomePaymentId = p.id
										JOIN finance.Payment p2 WITH(NOLOCK) ON NULLIF(ps.incomePaymentId ,p.id) = p2.id OR NULLIF(ps.outcomePaymentId,p.id) = p2.id
										JOIN document.FinancialDocumentHeader f WITH(NOLOCK) ON f.id = p2.financialDocumentHeaderId
										JOIN dictionary.DocumentType dt2 ON f.documentTypeId = dt2.id
									WHERE p.commercialDocumentHeaderId = tmp.f_id 
									ORDER BY f.number
									FOR XML PATH(''financialDocument''),TYPE
								)
							 FROM @tmp tmp 
							 WHERE tmp.f_id is NOT NULL
							 ORDER BY tmp.number
							 FOR XML PATH(''document''),TYPE)
						 FOR XML PATH(''prepayments''),TYPE	 
						),
						ISNULL( (SELECT (SELECT x.query(''contractor'') FROM CDL.XmlConstantData.nodes(''constant'') as a(x)) FOR XML PATH(''contractor''), TYPE)
						,(SELECT (SELECT vc.xmlValue
								FROM [contractor].[v_contractorPrintData] vc WITH (NOLOCK)
								WHERE vc.id = CDL.contractorId)
						 FOR XML PATH(''contractor''), TYPE )),
						 
						ISNULL( (SELECT (SELECT (SELECT x.query(''issuingPerson/*'') FROM CDL.XmlConstantData.nodes(''constant'') as a(x)) FOR XML PATH(''contractor''), TYPE) FOR XML PATH(''issuingPerson''), TYPE),
								(SELECT (SELECT vc.xmlValue
										FROM [contractor].[v_contractorPrintData] vc WITH (NOLOCK)
										WHERE vc.id = CDL.issuingPersonContractorId)
								 FOR XML PATH(''issuingPerson''), TYPE )), 
						ISNULL(	(SELECT (SELECT (SELECT x.query(''issuer/*'') FROM CDL.XmlConstantData.nodes(''constant'') as a(x)) FOR XML PATH(''contractor''), TYPE) FOR XML PATH(''issuer''), TYPE),	 
								(SELECT (SELECT vc.xmlValue
										FROM [contractor].[v_contractorPrintData] vc WITH (NOLOCK)
										WHERE vc.id = CDL.issuerContractorId )
								FOR XML PATH(''issuer''), TYPE )),
						ISNULL(	(SELECT (SELECT (SELECT x.query(''receivingPerson/*'') FROM CDL.XmlConstantData.nodes(''constant'') as a(x)) FOR XML PATH(''contractor''), TYPE) FOR XML PATH(''receivingPerson''), TYPE),	 		
						(SELECT (SELECT vc.xmlValue
								FROM [contractor].[v_contractorPrintData] vc WITH (NOLOCK)
								WHERE vc.id = CDL.receivingPersonContractorId)
						FOR XML PATH(''receivingPerson''), TYPE )),
						@paymentXml,
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
							  (SELECT textValue FROM item.ItemAttrValue WHERE itemId = l.itemId AND itemFieldId = (SELECT top 1 id FROM dictionary.ItemField WHERE name = ''Attribute_PKWIU'')) pkwiu,
							  (SELECT textValue FROM item.ItemAttrValue WHERE itemId = l.itemId AND itemFieldId = (SELECT id FROM dictionary.ItemField WHERE name = ''Attribute_Manufacturer'')) manufacturer,
							  (SELECT textValue FROM item.ItemAttrValue WHERE itemId = l.itemId AND itemFieldId = (SELECT id FROM dictionary.ItemField WHERE name = ''Attribute_ManufacturerCode'')) manufacturerCode,
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
							  df.name ''@name'',
							  CASE WHEN df.name = ''Attribute_SalesmanId'' THEN (SELECT fullName FROM contractor.Contractor WHERE id = CAST(ha.textValue  as uniqueidentifier)) ELSE null END ''@fullName'',
							  ha.[id],
							  ha.[commercialDocumentHeaderId],
							  ha.[warehouseDocumentHeaderId],
							  ha.[financialDocumentHeaderId],
							  ha.[documentFieldId],
							  ha.[decimalValue] [value],
							  ha.[dateValue] [value],
							  ha.[textValue] [value],
							  ha.[xmlValue] [value],
							  ha.[version],
							  ha.[order]
						 FROM document.DocumentAttrValue ha WITH(NOLOCK)
							JOIN dictionary.DocumentField df WITH(NOLOCK) ON ha.documentFieldId = df.id
						 WHERE ha.[commercialDocumentHeaderId] = CDL.id
						 FOR XML PATH(''attribute''), TYPE )
				   FOR XML PATH(''attributes''), TYPE ),		
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
						 FOR XML PATH(''vtEntry''), TYPE )
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
										''CBABCD4A-5FC2-4E41-A833-A895C78A2CBF'' as documentCurrencyId,--cm.documentCurrencyId,
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
										cm.exchangeDate
									FROM [document].CommercialDocumentHeader cm  WITH (NOLOCK)
										LEFT JOIN document.Series sm  WITH (NOLOCK) ON cm.seriesId = sm.id
									WHERE cm.id in ( vt.[firstCommercialDocumentHeaderId], vt.[secondCommercialDocumentHeaderId])
										AND cm.id <> @documentHeaderId
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
										  ''CBABCD4A-5FC2-4E41-A833-A895C78A2CBF'' as documentCurrencyId,--f.[documentCurrencyId],
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
										  ''CBABCD4A-5FC2-4E41-A833-A895C78A2CBF'' as documentCurrencyId,--w.[documentCurrencyId],
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
                  WHERE     CDL.id = @documentHeaderId
                  FOR XML PATH(''commercialDocument''), TYPE
            ) FOR XML PATH(''root''),TYPE
          ) )


          INSERT INTO @tmp_(id, itemId)
          SELECT x.value(''(id)[1]'',''char(36)''), x.value(''(itemId)[1]'',''char(36)'')
          FROM @x.nodes(''root/commercialDocument/attributes/attribute[@name="Attribute_SalesOrderXml"]/value/commercialDocument/lines/line'') AS a(x)
      
		  SELECT @i = 1 , @c = @@rowcount
 

          WHILE @i <= @c 
			BEGIN 
			SELECT @value = ia.textValue, @id = t.id
			FROM @tmp_ t 
				JOIN item.ItemAttrValue ia ON t.itemId = ia.itemId 
					AND ia.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_PKWIU'')
			WHERE i = @i
			
			SET @x.modify(''insert <pkwiu>(fn:string(sql:variable("@value")))</pkwiu> as last into (/root/commercialDocument/attributes/attribute[@name="Attribute_SalesOrderXml"]/value/commercialDocument/lines/line[id=sql:variable("@id")])[1]'')
			SET @x.modify(''replace value of (/root/commercialDocument/attributes/attribute[@name="Attribute_SalesOrderXml"]/value/commercialDocument/lines/line[id=sql:variable("@id")]/pkwiu/text())[1] with (fn:string(sql:variable("@value"))) '')
			
			SELECT @i = @i + 1
			END
		
		declare @xData varchar(8000)
	
	SELECT @xData =  CAST((SELECT (	SELECT
						ca.id,
						ca.contractorId,
						ca.bankContractorId,
						ca.accountNumber,
						ca.[version],
						ca.[order]
					FROM contractor.ContractorAccount ca  WITH (NOLOCK)
					WHERE ca.contractorId = (SELECT contractorId FROM document.CommercialDocumentHeader WHERE id = @documentHeaderId)
					FOR XML PATH(''account''), TYPE )
				FOR XML PATH(''accounts''), TYPE ) as varchar(8000))

	SELECT CAST(REPLACE(CAST(@x AS varchar(max)), ''</contractor></contractor>'',@xData+''</contractor></contractor>'') AS xml)
    END
' 
END
GO

/*
name=[print].[p_getFinancialDocumentPrint]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
1ZS0gfeU829LXqkrV3oCKg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[print].[p_getFinancialDocumentPrint]') AND type in (N'P', N'PC'))
DROP PROCEDURE [print].[p_getFinancialDocumentPrint]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[print].[p_getFinancialDocumentPrint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [print].[p_getFinancialDocumentPrint]
    @documentHeaderId UNIQUEIDENTIFIER
AS
    BEGIN
		/*Budowanie XML z kompletem informacji o dokumencie*/
        SELECT  (
			SELECT ( 
				  SELECT    
						CDL.version,
						CDL.id,
						CDL.number AS ''number/number'',
						CDL.fullNumber AS ''number/fullNumber'',
						s.[numberSettingId] AS ''number/numberSettingId'',
						CDL.branchId,
						CDL.companyId,
						CDL.documentCurrencyId,
						CDL.systemCurrencyId,
						CDL.status,
						CDL.issueDate,
						CDL.documentTypeId,
						CDL.amount,
						CDL.contractorAddressId,
						(	SELECT (
								SELECT 
									ISNULL(documentFieldId, '''') documentFieldId,
									ISNULL(ISNULL(CAST(xmlValue AS VARCHAR(max)),ISNULL(textValue,ISNULL(dateValue,decimalValue))),'''') value
								FROM document.DocumentAttrValue a 
								WHERE a.financialDocumentHeaderId = @documentHeaderId
								FOR XML PATH(''attribute''), TYPE )
							FOR XML PATH(''attributes''), TYPE ),

						(SELECT (
								SELECT
									fr.version, 
									fr.id,
									fr.financialRegisterId,
									fr.number AS ''number/number'',
									fr.fullNumber AS ''number/fullNumber'',
									fr.isClosed,
									fr.initialBalance,
									fr.incomeAmount,
									fr.outcomeAmount,
									fr.creationDate,
									fr.openingDate
								FROM finance.FinancialReport fr 
								WHERE fr.id = CDL.financialReportId
								FOR XML PATH(''financialReport''), TYPE
						) FOR XML PATH(''financialReport''), TYPE ),

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
								WHERE c.id = CDL.contractorId
								FOR XML PATH(''contractor''), TYPE
						) FOR XML PATH(''contractor''), TYPE ),



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
								WHERE c.id = CDL.issuingPersonContractorId
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
								WHERE c.id = CDL.modificationApplicationUserId
								FOR XML PATH(''contractor''), TYPE
						) FOR XML PATH(''modificationApplicationUser''), TYPE ),

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
							SELECT 
								p.version,
								p.id,
								p.direction,
								p.financialDocumentHeaderId,
								p.description,
								p.isSettled,
								p.exchangeRate,
								p.exchangeScale,
								p.exchangeDate,
								p.amount,
								p.dueDate,
								p.date,
								p.ordinalNumber
							FROM [finance].payment p 
							WHERE p.financialDocumentHeaderId = @documentHeaderId
								
								AND p.amount >= 0
							ORDER BY p.ordinalNumber
							FOR XML PATH(''payment''), TYPE
							) FOR XML PATH(''payments''), TYPE)
				
                  FROM      [document].FinancialDocumentHeader CDL 
					LEFT JOIN document.Series s ON CDL.seriesId = s.id
                  WHERE     CDL.id = @documentHeaderId
			
                  FOR XML PATH(''financialDocument''), TYPE
            ) FOR XML PATH(''root''),TYPE
          ) AS returnsXML
    END
' 
END
GO

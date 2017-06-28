/*
name=[print].[p_getFinancialReportPrint]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
FrjFdf/3lYL2BaoseoXgIQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[print].[p_getFinancialReportPrint]') AND type in (N'P', N'PC'))
DROP PROCEDURE [print].[p_getFinancialReportPrint]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[print].[p_getFinancialReportPrint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [print].[p_getFinancialReportPrint] 
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
						CDL.isClosed,
						CDL.initialBalance,
						CDL.incomeAmount,
						CDL.outcomeAmount,
						CDL.creationDate,
						CDL.closureDate,
						CDL.financialRegisterId,

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
												FROM contractor.ContractorAddress ca  WITH(NOLOCK)
												WHERE ca.contractorId = c.id
												FOR XML PATH(''address''), TYPE )
											FOR XML PATH(''addresses''), TYPE
									)
								FROM dictionary.FinancialRegister r WITH(NOLOCK) 
									JOIN dictionary.branch b WITH(NOLOCK) ON r.branchId = b.id 
									JOIN contractor.Contractor c WITH(NOLOCK) ON b.companyId = c.id
								WHERE r.id = CDL.financialRegisterId
								FOR XML PATH(''contractor''), TYPE
						) FOR XML PATH(''issuer''), TYPE ),

				  (SELECT (
							SELECT 
								p.issueDate AS ''@issueDate'',
								p.fullNumber AS ''@fullNumber'',
								(	SELECT SUM( py.amount * py.direction ) amount 
									FROM finance.Payment py WITH(NOLOCK) 
									WHERE py.financialDocumentHeaderId = p.id 
										AND py.amount > 0 
									) AS ''@amount'',
								ISNULL(c.shortName,'''') as ''@contractor''  
							FROM [document].FinancialDocumentHeader p  WITH(NOLOCK)
	
								LEFT JOIN contractor.Contractor c WITH(NOLOCK) ON p.contractorId = c.id
							WHERE p.financialReportId = @documentHeaderId AND p.status > 20
							ORDER BY p.issueDate, p.fullNumber
							FOR XML PATH(''document''), TYPE
							) FOR XML PATH(''documents''), TYPE),

					(SELECT (
							SELECT 
								t.symbol AS ''@symbol'',
								COUNT(p.id) AS ''@amount'' 
							FROM [document].FinancialDocumentHeader p  WITH(NOLOCK)
								JOIN dictionary.DocumentType t ON p.documentTypeId = t.id
							WHERE p.financialReportId = @documentHeaderId
							GROUP BY t.symbol
							FOR XML PATH(''documents''), TYPE
							) FOR XML PATH(''statistics''), TYPE)

				
                  FROM      [finance].FinancialReport CDL  WITH(NOLOCK)
					LEFT JOIN document.Series s  WITH(NOLOCK) ON CDL.seriesId = s.id
                  WHERE     CDL.id = @documentHeaderId
			
                  FOR XML PATH(''financialReport''), TYPE
            ) FOR XML PATH(''root''),TYPE
          ) AS returnsXML
    END
' 
END
GO

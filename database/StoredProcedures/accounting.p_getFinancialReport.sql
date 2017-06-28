/*
name=[accounting].[p_getFinancialReport]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
CRL5ARY38t54B0vddr+hJw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getFinancialReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_getFinancialReport]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getFinancialReport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [accounting].[p_getFinancialReport]
@financialReportId  UNIQUEIDENTIFIER
AS

INSERT INTO document.ExportStatus (documentId) VALUES (@financialReportId)
INSERT INTO document.ExportStatus (documentId) 
SELECT id FROM document.FinancialDocumentHeader
WHERE financialReportId = @financialReportId AND [status] >= 0

IF NOT EXISTS (SELECT f.id
			   FROM finance.financialReport f
			   JOIN dictionary.FinancialRegister r ON f.financialRegisterId=r.id
			   JOIN dictionary.documentType t ON t.id=CAST(r.xmlOptions.query(''root/register/incomeDocument/documentTypeId'').value(''.'',''varchar(100)'') AS uniqueidentifier)
			   WHERE (t.xmlOptions.exist(''root[1]/financialDocument[1]/@payerId'') = 1) AND (f.id=@financialReportId)
			  )
BEGIN
	SELECT 
		(SELECT newid()  FOR XML PATH(''requestId''), TYPE),
		(SELECT ''FinancialReport''   FOR XML PATH(''method''), TYPE ),
		(SELECT 
			(SELECT 
				CDL.id foreignId,
				(SELECT externalId FROM accounting.ExternalMapping EM WHERE EM.id = CDL.id ) id ,
				ISNULL(accounting.f_getExternalMapping(fr.symbol, ''accounting.externalMapping.FinancialRegister'') ,'''') financialRegisterSymbol,
				CDL.number number,
				CDL.fullNumber fullNumber,
				s.seriesValue series,
				CDL.creationDate creationDate,
				CDL.closureDate closureDate,
				CDL.initialBalance initialBalance,
				CDL.incomeAmount incomeAmount,
				CDL.outcomeAmount outcomeAmount,
				c.symbol currency,
				''PLN'' systemCurrency,
				(SELECT
					row_number()over (order by dt.id) [order],
					h.id foreignId, 
					(SELECT externalId FROM accounting.ExternalMapping WHERE id = h.id ) id ,
					dt.symbol documentType,

					CASE WHEN h.contractorId IS NULL THEN accounting.f_getExternalMapping(bb.symbol, ''accounting.externalMapping.AnonymousAcronym'')
						ELSE ISNULL((SELECT externalId FROM accounting.ExternalMapping WHERE id = h.contractorId ),'''')
					END contractorId,

					(SELECT
						h.xmlConstantData.query(''/constant/contractor/version''),
						h.xmlConstantData.query(''/constant/contractor/fullName''),
						h.xmlConstantData.query(''/constant/contractor/nip''),

						(CASE WHEN ISNULL(h.xmlConstantData.query(''/constant/contractor/addresses/address/countryId'').value(''.'',''varchar(36)''),'''') <> '''' THEN
							(SELECT dc.symbol FROM dictionary.country dc WHERE dc.id=h.xmlConstantData.query(''/constant/contractor/addresses/address/countryId'').value(''.'',''uniqueidentifier''))
						 END) country,

						h.xmlConstantData.query(''/constant/contractor/addresses/address/postOffice''),
						h.xmlConstantData.query(''/constant/contractor/addresses/address/city''),
						h.xmlConstantData.query(''/constant/contractor/addresses/address/address'')
					 FOR XML PATH(''contractor''), TYPE),

					(SUBSTRING( CAST( (SELECT '';'' + RTRIM(ISNULL( py.description,'''')) FROM finance.Payment py WHERE h.id = py.financialDocumentHeaderId FOR XML PATH(''''), TYPE ) AS NVARCHAR(4000)), 2,255 )) [description], 
					h.number number,
					h.fullNumber,
					ss.seriesValue series,
					h.issueDate issueDate,
					h.amount,
					ISNULL((SELECT DA.oppositionAccounting FROM [accounting].[DocumentData] DA WHERE DA.financialDocumentId=h.id),'''') oppositionAccounting,
					ISNULL((SELECT DA.externalName FROM [accounting].[DocumentData] DA WHERE DA.financialDocumentId=h.id),'''') operationType,
					(SELECT 
						(SELECT 
							row_number()over (order by p.id) [order],


							(SELECT externalId FROM accounting.ExternalMapping em 
								WHERE em.id =  
									CASE WHEN pst.incomePaymentId = p.id THEN
										(SELECT CASE WHEN p1.financialDocumentHeaderId IS NOT NULL 
												THEN 
													CASE WHEN (SELECT COUNT(*) FROM finance.payment p2 WHERE p2.financialDocumentHeaderId=p1.financialDocumentHeaderId) = 2
													THEN pst.outcomePaymentId ELSE p1.financialDocumentHeaderId
													END
												ELSE pst.outcomePaymentId 
												END
										FROM finance.payment p1 WHERE p1.id = pst.outcomePaymentId)
							  		WHEN pst.outcomePaymentId = p.id THEN
										(SELECT CASE WHEN p1.financialDocumentHeaderId IS NOT NULL  
												THEN
													CASE WHEN (SELECT COUNT(*) FROM finance.payment p2 WHERE p2.financialDocumentHeaderId=p1.financialDocumentHeaderId) = 2
													THEN pst.incomePaymentId ELSE p1.financialDocumentHeaderId
													END
												ELSE pst.incomePaymentId 
												END
										FROM finance.payment p1 WHERE id = pst.incomePaymentId)
									ELSE
										NULL
									END 
							) id,


						    pst.amount amount,
							pst.date date
					     FROM finance.payment p 
						   JOIN finance.paymentSettlement pst ON pst.incomePaymentId = p.id  OR pst.outcomePaymentId = p.id
					     WHERE h.id  = p.financialDocumentHeaderId  AND  (p.commercialDocumentHeaderId IS NULL)
					     FOR XML PATH(''settlement''), TYPE		
					    ) 
			         FOR XML PATH(''settlements''), TYPE
			        )	
				FROM document.FinancialDocumentHeader h
					JOIN dictionary.documentType dt ON h.documentTypeId = dt.id		
					JOIN document.Series ss ON h.seriesId = ss.id
					JOIN dictionary.Branch bb ON h.branchId = bb.id
				WHERE (h.financialReportId = CDL.id) and (h.status >= 0)
				FOR XML PATH(''financialDocument''), TYPE
				)

			FROM finance.FinancialReport CDL
				JOIN dictionary.FinancialRegister fr ON CDL.financialRegisterId = fr.id 
				JOIN dictionary.Currency c ON fr.currencyId = c.id
				LEFT JOIN document.Series s ON CDL.seriesId = s.id
			WHERE CDL.id = @financialReportId
			FOR XML PATH(''financialReport''), TYPE
			) 
		FOR XML PATH(''document''), TYPE
		) 
	FOR XML PATH(''request''), TYPE
END
ELSE
BEGIN

	SELECT	/* request */
		(SELECT newid()  FOR XML PATH(''requestId''), TYPE),
		(SELECT ''FinancialReportCard''   FOR XML PATH(''method''), TYPE ),
		(SELECT  /* document */
			(SELECT /* financialReport */
				CDL.id foreignId,
				(SELECT externalId FROM accounting.ExternalMapping EM WHERE EM.id = CDL.id ) id ,
				ISNULL(accounting.f_getExternalMapping(fr.symbol, ''accounting.externalMapping.FinancialRegister'') ,'''') financialRegisterSymbol,
				CDL.number number,
				CDL.fullNumber fullNumber,
				s.seriesValue series,
				CDL.creationDate creationDate,
				CDL.closureDate closureDate,
				CDL.initialBalance initialBalance,
				CDL.incomeAmount incomeAmount,
				CDL.outcomeAmount outcomeAmount,
				c.symbol currency,
				''PLN'' systemCurrency,
				(SELECT /*financialDocument */
					row_number()over (order by dt.id) [order],
					h.id foreignId, 
					(SELECT externalId FROM accounting.ExternalMapping WHERE id = h.id ) id ,
					dt.symbol documentType,

					(SUBSTRING( CAST( (SELECT '';'' + RTRIM(ISNULL( py.description,'''')) FROM finance.Payment py WHERE h.id = py.financialDocumentHeaderId FOR XML PATH(''''), TYPE ) AS NVARCHAR(4000)), 2,255 )) [description], 
					h.number number,
					h.fullNumber,
					ss.seriesValue series,
					h.issueDate issueDate,
					(SELECT /* documentPayment */
						(SELECT /* Payment */
							row_number()over (order by fp.id) [order],
							fp.id [foreignId],
							fp.amount [amount],

							CASE WHEN fp.contractorId IS NULL 
							THEN 
								accounting.f_getExternalMapping(bb.symbol, ''accounting.externalMapping.AnonymousAcronym'')
							ELSE 
								ISNULL((SELECT externalId FROM accounting.ExternalMapping WHERE id = fp.contractorId ),'''')
							END contractorId,

							CASE WHEN fp.contractorId IS NULL 
							THEN 
								''200-''+accounting.f_getExternalMapping(bb.symbol, ''accounting.externalMapping.AnonymousAcronym'')
							ELSE 
								(SELECT ''200-''+externalId FROM accounting.ExternalMapping WHERE id = fp.contractorId )
							END [accounting],

							(SELECT /* settlements */
								(SELECT /* settlement */
									row_number()over (order by p.id) [order],
									(SELECT externalId FROM accounting.ExternalMapping em 
									 WHERE em.id =  
										CASE WHEN pst.incomePaymentId = p.id THEN
												(SELECT CASE WHEN p1.financialDocumentHeaderId IS NOT NULL 
														THEN 
															CASE WHEN (SELECT COUNT(*) FROM finance.payment p2 WHERE p2.financialDocumentHeaderId=p1.financialDocumentHeaderId) = 2
															THEN pst.outcomePaymentId ELSE p1.financialDocumentHeaderId
															END
														ELSE pst.outcomePaymentId 
														END
												FROM finance.payment p1 WHERE p1.id = pst.outcomePaymentId)
											 WHEN pst.outcomePaymentId = p.id THEN
												(SELECT CASE WHEN p1.financialDocumentHeaderId IS NOT NULL 
														THEN
															CASE WHEN (SELECT COUNT(*) FROM finance.payment p2 WHERE p2.financialDocumentHeaderId=p1.financialDocumentHeaderId) = 2
															THEN pst.incomePaymentId ELSE p1.financialDocumentHeaderId
															END
														ELSE pst.incomePaymentId 
														END
												FROM finance.payment p1 WHERE id = pst.incomePaymentId)
											 ELSE
												NULL
										END 
									) id,
	
									pst.amount amount,
									pst.date date
								FROM finance.payment p 
								JOIN finance.paymentSettlement pst ON pst.incomePaymentId = p.id  OR pst.outcomePaymentId = p.id
								WHERE fp.id  = p.id 
								FOR XML PATH(''settlement''), TYPE		
								) 
							FOR XML PATH(''settlements''), TYPE
							)	
						FROM finance.payment fp
						WHERE fp.financialDocumentHeaderId = h.id
						FOR XML PATH(''Payment''), TYPE
						)
					FOR XML PATH(''documentPayments''), TYPE
					)
				FROM document.FinancialDocumentHeader h
					JOIN dictionary.documentType dt ON h.documentTypeId = dt.id		
					JOIN document.Series ss ON h.seriesId = ss.id
					JOIN dictionary.Branch bb ON h.branchId = bb.id
				WHERE (h.financialReportId = CDL.id) and (h.status >= 0)
				FOR XML PATH(''financialDocument''), TYPE
			)

			FROM finance.FinancialReport CDL
				JOIN dictionary.FinancialRegister fr ON CDL.financialRegisterId = fr.id 
				JOIN dictionary.Currency c ON fr.currencyId = c.id
				LEFT JOIN document.Series s ON CDL.seriesId = s.id
			WHERE CDL.id = @financialReportId
			FOR XML PATH(''financialReport''), TYPE
			) 
		FOR XML PATH(''document''), TYPE
		) 
	FOR XML PATH(''request''), TYPE

END

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
' 
END
GO

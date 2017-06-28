/*
name=[accounting].[p_getCommercialDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4UElAELy76gkEVosvWh2/w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getCommercialDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_getCommercialDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getCommercialDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [accounting].[p_getCommercialDocument]
    @commercialDocumentHeaderId UNIQUEIDENTIFIER
AS 
BEGIN

IF EXISTS( SELECT contractorId FROM document.WarehouseDocumentHeader WHERE id = @commercialDocumentHeaderId) 
			AND  NOT EXISTS (SELECT externalId FROM accounting.ExternalMapping WHERE id = ( SELECT contractorId FROM document.WarehouseDocumentHeader WHERE id = @commercialDocumentHeaderId))
BEGIN
	RAISERROR ( ''Brak mapowania kontrahenta'', 16, 1 )
	return 0
END

INSERT INTO document.ExportStatus (documentId) VALUES (@commercialDocumentHeaderId)

SELECT 
(SELECT newid()  FOR XML PATH(''requestId''), TYPE),
(SELECT ''CommercialDocument''   FOR XML PATH(''method''), TYPE ),
(	SELECT
		h.id foreignId,
		(SELECT externalId FROM accounting.ExternalMapping EM WHERE EM.id = h.id) id, 
		ISNULL(accounting.f_getExternalMapping(dt.symbol, ''accounting.externalMapping.DocumentType'') ,'''') type,
		ISNULL(accounting.f_getExternalMapping(dt.symbol, ''accounting.externalMapping.DocumentTypeAbbreviation'') ,'''') typeAbbreviation,
		ISNULL(h.number ,'''') documentSequentialNumber,
		ISNULL((SELECT br.symbol FROM dictionary.Branch br WHERE br.id=h.branchId),'''') documentSeries,

		ISNULL((SELECT TOP 1 DAV.textValue FROM [document].DocumentAttrValue AS DAV INNER JOIN
                dictionary.DocumentField AS DF ON DAV.documentFieldId = DF.id 
                WHERE ((DF.name = ''Attribute_SupplierDocumentNumber'') OR (DF.name = ''Attribute_SupplierCorrectiveDocumentNumber'')) AND 
                      (commercialDocumentHeaderId = @commercialDocumentHeaderId) 
                ),'''') AS supplierDocumentNumber,

		ISNULL(dd.[year],'''') documentYear,
		(dt.symbol+'' ''+ISNULL(h.fullNumber,'''')) documentNumber,
		ISNULL((SELECT STUFF(
		   (SELECT 
				'','' + h_.fullNumber AS ''data()''
			FROM document.CommercialDocumentLine l_
				JOIN document.CommercialDocumentLine l_cor ON l_.correctedCommercialDocumentLineId = l_cor.id
				JOIN document.CommercialDocumentHeader h_ ON h_.id = l_cor.commercialDocumentHeaderId
			WHERE l_.commercialDocumentHeaderId = @commercialDocumentHeaderId
			FOR XML PATH('''')),1,1,'''')
		) ,'''') correctedNumber,

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

			h.xmlConstantData.query(''/constant/contractor/addresses/address/postCode''),
			h.xmlConstantData.query(''/constant/contractor/addresses/address/postOffice''),
			h.xmlConstantData.query(''/constant/contractor/addresses/address/city''),
			h.xmlConstantData.query(''/constant/contractor/addresses/address/address'')
		 FOR XML PATH(''contractor''), TYPE),

		ISNULL(h.grossValue,'''') gross,
		ISNULL(h.grossValue,'''') grossInCurrency,
		ISNULL(c.symbol,'''') currency,
		ISNULL(h.exchangeRate,'''') exchangeRate,
		'''' exchangeRateType,
		ISNULL(h.issueDate,'''') date,
		(SELECT TOP 1 CONVERT(char(10),h_.issueDate,21)
		 FROM document.CommercialDocumentLine l_
			JOIN document.CommercialDocumentLine l_cor ON l_.correctedCommercialDocumentLineId = l_cor.id
			JOIN document.CommercialDocumentHeader h_ ON h_.id = l_cor.commercialDocumentHeaderId
		 WHERE l_.commercialDocumentHeaderId = @commercialDocumentHeaderId
		) correctedDate,

		ISNULL((SELECT TOP 1 DAV.dateValue FROM [document].DocumentAttrValue AS DAV INNER JOIN
                dictionary.DocumentField AS DF ON DAV.documentFieldId = DF.id 
                WHERE ((DF.name = ''Attribute_SupplierDocumentDate'') OR (DF.name = ''Attribute_SupplierCorrectiveDocumentDate'')) AND 
                      (commercialDocumentHeaderId = @commercialDocumentHeaderId) 
                ),h.issueDate) AS operationDate,

		ISNULL(h.issueDate,'''') periodDate,
		ISNULL(h.issueDate,'''') incomeDate,
		ISNULL(h.eventDate,'''') registrationDate,
		ISNULL((select textValue from document.documentAttrValue DAV 
					INNER JOIN  dictionary.DocumentField DF ON DAV.documentFieldId=DF.id
					WHERE DF.name = ''Attribute_Remarks'' and commercialDocumentHeaderId=@commercialDocumentHeaderId),''''
			  ) description,
		ISNULL(ar.symbol,'''') accountingRule,
		ISNULL(vr.symbol,'''') vatRegister,

		CASE WHEN h.contractorId IS NULL THEN 
			''PL'' 
		ELSE
			(SELECT dc.symbol FROM dictionary.Country dc JOIN contractor.Contractor cc ON dc.id=cc.nipPrefixCountryId
			 WHERE cc.id=h.contractorId)
		END sendingCountry,


		(SELECT 
			(SELECT
				row_number()over (order by p.id) [order],
				p.id foreignId,
				(SELECT externalId FROM accounting.ExternalMapping EM WHERE EM.id = p.id) id,
				h.fullNumber documentNumber,
				p.amount totalAmount,
				p.amount totalAmountInCurrency,
				0 amount,
				0 amountInCurrencyInCurrency,
				(SELECT symbol FROM dictionary.Currency WHERE id = p.paymentCurrencyId ) currency,
				p.exchangeRate,
				dpmx.symbol paymentForm,
				accounting.f_getExternalMapping(dpmx.symbol, ''accounting.externalMapping.PaymentForm'') paymentFormNo,
				accounting.f_getContractorPayment(dpmx.symbol, ''accounting.externalMapping.PaymentForm'') contractorPayment,
				p.dueDate paymentDate,
				(SELECT 
					(SELECT 
						row_number()over (order by p.id) [order],

						(SELECT externalId FROM accounting.ExternalMapping em WHERE em.id =
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
					 WHERE h.id  = p.commercialDocumentHeaderId AND  (p.financialDocumentHeaderId IS NULL)
					 FOR XML PATH(''settlement''), TYPE	
					) 
                 FOR XML PATH(''settlements''), TYPE
				)
			 FROM finance.Payment p
			  JOIN dictionary.PaymentMethod dpm ON p.paymentMethodId = dpm.id
			  LEFT JOIN ( SELECT xmlLabels.value(''(labels/label[@lang = "pl"])[1]'',''varchar(50)'') symbol, id
								FROM  dictionary.PaymentMethod 
						 ) dpmx ON dpmx.id = dpm.id
			  LEFT JOIN finance.PaymentSettlement ps ON ( p.id = ps.incomePaymentId OR p.id = ps.outcomePaymentId)
			 WHERE p.commercialDocumentHeaderId = @commercialDocumentHeaderId
			 FOR XML PATH(''documentPayment''), TYPE
			) 
		 FOR XML PATH(''documentPayments''), TYPE
		),

		(SELECT (	SELECT
					row_number()over (order by v.symbol) orderNumber,
					v.symbol,
					1 periodType,
					dd.date periodDate,
					accounting.f_getExternalMapping(v.symbol, ''accounting.externalMapping.VatRate'') vatRate,
					vat.netValue net,
					vat.vatValue vat,
					vat.grossValue gross
				FROM document.CommercialDocumentVatTable vat
					JOIN dictionary.VatRate v ON vat.vatRateId = v.id
				WHERE vat.commercialDocumentHeaderId = @commercialDocumentHeaderId
				FOR XML PATH(''vatEntry''), TYPE
			) FOR XML PATH(''vatEntries''), TYPE
		),

		(SELECT (	SELECT
					e.[order] [order],
					e.debitAmount grossDebet,
					e.debitAmount grossInCurrencyDebet,
					e.debitAccount syntheticAccountDebet,
					'''' analyticAccountDebet,
					e.creditAmount grossCredit,
					e.creditAmount grossInCurrencyCredit,
					e.creditAccount syntheticAccountCredit,
					'''' analyticAccountCredit,
					''PLN'' currency,
					1 exchangeRate,
					'''' exchangeRateType,
					e.description description
				FROM accounting.AccountingEntries e
				WHERE (e.documentHeaderId = @commercialDocumentHeaderId) AND 
					((ISNULL(debitAmount,0) <> 0) OR (ISNULL(creditAmount,0) <> 0))
				ORDER BY e.[order]
				FOR XML PATH(''entry''), TYPE
			) FOR XML PATH(''entries''), TYPE
		)

	FROM document.CommercialDocumentHeader h
		LEFT JOIN accounting.DocumentData dd ON h.id = dd.commercialDocumentId
		LEFT JOIN dictionary.AccountingRule ar ON dd.accountingRuleId = ar.id
		LEFT JOIN dictionary.VatRegister vr ON dd.vatRegisterId = vr.id
		JOIN dictionary.DocumentType dt ON h.documentTypeId = dt.id
		JOIN dictionary.Currency c ON h.documentCurrencyId = c.id
		JOIN dictionary.Branch bb ON h.branchId = bb.id
	WHERE h.id = @commercialDocumentHeaderId
	FOR XML PATH(''document''), TYPE
) FOR XML PATH(''request''), TYPE

END


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON



set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
' 
END
GO

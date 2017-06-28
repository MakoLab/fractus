/*
name=[accounting].[p_getWarehouseDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
rs8TdY6cmyeaiHybwrRLxw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getWarehouseDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_getWarehouseDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getWarehouseDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [accounting].[p_getWarehouseDocument]
    @warehouseDocumentHeaderId UNIQUEIDENTIFIER
AS
BEGIN

DECLARE	@contractorsId UNIQUEIDENTIFIER

SELECT @contractorsId = contractorId FROM document.WarehouseDocumentHeader WHERE id = @warehouseDocumentHeaderId


SELECT  
(SELECT newid()  FOR XML PATH(''requestId''), TYPE),
(SELECT ''WarehouseDocument''   FOR XML PATH(''method''), TYPE ),
 (
	SELECT
		h.id foreignId,
		ISNULL(accounting.f_getExternalMapping(dt.symbol, ''accounting.externalMapping.DocumentType'') ,'''') type,
		ISNULL(dt.symbol,'''') typeAbbreviation,
		ISNULL(h.number,'''') documentSequentialNumber,
		ISNULL(dd.[year],'''') documentYear,
		ISNULL(dt.Symbol+'' ''+h.fullNumber,'''') documentNumber,
		ISNULL((SELECT STUFF(
		   (SELECT 
				'','' + h_.fullNumber AS ''data()''
			FROM document.WarehouseDocumentLine l_
				JOIN document.WarehouseDocumentLine l_cor ON l_.correctedWarehouseDocumentLineId = l_cor.id
				JOIN document.WarehouseDocumentHeader h_ ON h_.id = l_cor.warehouseDocumentHeaderId
			WHERE l_.warehouseDocumentHeaderId = @warehouseDocumentHeaderId
			FOR XML PATH('''')),1,1,'''')
		),'''') correctedNumber,
		CASE WHEN @contractorsId IS NULL THEN (select textValue from configuration.configuration where [key] = ''accounting.externalMapping.AnonymousAcronym'')
		ELSE ISNULL((SELECT externalId FROM accounting.ExternalMapping WHERE id = @contractorsId ) ,'''') 
		END	contractorId,
		ISNULL(h.value,'''') gross,
		ISNULL(h.value,'''') grossInCurrency,
		''PLN'' currency,
		1 exchangeRate,
		'''' exchangeRateType,
		ISNULL(h.issueDate,'''') date,
		(	
			SELECT TOP 1 CONVERT(char(10),h_.issueDate,21)
			FROM document.WarehouseDocumentLine l_
				JOIN document.WarehouseDocumentLine l_cor ON l_.correctedWarehouseDocumentLineId = l_cor.id
				JOIN document.WarehouseDocumentHeader h_ ON h_.id = l_cor.warehouseDocumentHeaderId
			WHERE l_.warehouseDocumentHeaderId = @warehouseDocumentHeaderId
		) correctedDate,
		ISNULL(h.issueDate,'''') operationDate,
		ISNULL(dd.date,'''') periodDate,
		ISNULL(h.issueDate,'''') incomeDate,
		ISNULL(h.issueDate,'''') registrationDate,
		(dt.symbol+'' ''+ISNULL(h.fullNumber,'''')) description,
		ISNULL(ar.symbol,'''') accountingRule,
		ISNULL(vr.symbol,'''') vatRegister,
		ISNULL(aj.symbol,'''') accountingJournal,
		
		''PL'' sendingCountry,
		(SELECT (	SELECT
					e.[order] foreignId,
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
				WHERE e.documentHeaderId = @warehouseDocumentHeaderId
				ORDER BY e.[order]
				FOR XML PATH(''entry''), TYPE
			) FOR XML PATH(''entries''), TYPE
		)

	FROM document.WarehouseDocumentHeader h
		LEFT JOIN accounting.DocumentData dd ON h.id = dd.warehouseDocumentId
		LEFT JOIN dictionary.AccountingRule ar ON dd.accountingRuleId = ar.id
		LEFT JOIN dictionary.AccountingJournal aj ON dd.accountingJournalId = aj.id
		LEFT JOIN dictionary.VatRegister vr ON dd.vatRegisterId = vr.id
		JOIN dictionary.DocumentType dt ON h.documentTypeId = dt.id
	WHERE h.id = @warehouseDocumentHeaderId
	FOR XML PATH(''document''), TYPE
) FOR XML PATH(''request''), TYPE
END


/****** Object:  StoredProcedure [accounting].[p_parsingPattern]    Script Date: 02/25/2010 15:25:27 ******/
SET ANSI_NULLS ON
' 
END
GO

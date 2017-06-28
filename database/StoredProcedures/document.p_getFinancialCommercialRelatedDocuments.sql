/*
name=[document].[p_getFinancialCommercialRelatedDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fcmQw39Ml49jTbfTR/9QPg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getFinancialCommercialRelatedDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getFinancialCommercialRelatedDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getFinancialCommercialRelatedDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_getFinancialCommercialRelatedDocuments]
@xmlVar XML 
AS
BEGIN

DECLARE 
	@commercialDocumentHeaderId CHAR(36), 
	@financialDocumentHeaderId CHAR(36),
	@direction int


SELECT	@commercialDocumentHeaderId = NULLIF(x.query(''commercialDocumentId'').value(''.'',''char(36)''), ''''),
		@financialDocumentHeaderId = NULLIF(x.query(''financialDocumentId'').value(''.'',''char(36)'') , '''')
FROM @xmlVar.nodes(''*'') as a(x)



IF (@commercialDocumentHeaderId <> '''')
	BEGIN
		SELECT @direction = (direction * amount) FROM finance.Payment p WHERE p.commercialDocumentHeaderId = CAST(@commercialDocumentHeaderId AS uniqueidentifier) 
		IF @direction > 0
		BEGIN
			SELECT (
					SELECT * FROM (
						SELECT DISTINCT
							ISNULL(WH2.fullNumber,CH2.fullNumber) AS ''@fullNumber'', ISNULL(WH2.id,CH2.id) AS ''@id'', ISNULL(WH2.issueDate,CH2.issueDate) AS ''@issueDate'', ISNULL(WH2.documentTypeId ,CH2.documentTypeId) AS ''@documentTypeId'', p2.documentInfo AS ''@documentInfo''
						FROM finance.Payment p WITH (NOLOCK) 
							JOIN finance.PaymentSettlement ps WITH (NOLOCK) ON ps.incomePaymentId = p.id 
							JOIN finance.Payment p2 WITH (NOLOCK) ON  ps.outcomePaymentId  = p2.id  
							LEFT JOIN document.FinancialDocumentHeader WH2 WITH (NOLOCK) ON p2.financialDocumentHeaderId IS NOT NULL AND  p2.financialDocumentHeaderId  = WH2.id
							LEFT JOIN document.CommercialDocumentHeader CH2 WITH (NOLOCK) ON p2.commercialDocumentHeaderId IS NOT NULL AND  p2.commercialDocumentHeaderId  = CH2.id
						WHERE p.commercialDocumentHeaderId = CAST(@commercialDocumentHeaderId AS uniqueidentifier) AND ISNULL(WH2.status, CH2.status) >= 40 
					) x
				FOR XML PATH(''document'') , TYPE 
			) FOR XML PATH(''relatedDocuments''), TYPE

		END
		ELSE 
		BEGIN 
			SELECT (
						SELECT * FROM (
							SELECT DISTINCT
								ISNULL(WH2.fullNumber,CH2.fullNumber) AS ''@fullNumber'', ISNULL(WH2.id,CH2.id) AS ''@id'', ISNULL(WH2.issueDate,CH2.issueDate) AS ''@issueDate'', ISNULL(WH2.documentTypeId ,CH2.documentTypeId) AS ''@documentTypeId'', p2.documentInfo AS ''@documentInfo''
							FROM finance.Payment p WITH (NOLOCK) 
								JOIN finance.PaymentSettlement ps WITH (NOLOCK) ON  ps.outcomePaymentId   = p.id   --p.id = ps.incomePaymentId OR p.id = ps.outcomePaymentId
								JOIN finance.Payment p2 WITH (NOLOCK) ON  ps.incomePaymentId  = p2.id    --ps.incomePaymentId = p2.id OR ps.outcomePaymentId = p2.id
								LEFT JOIN document.FinancialDocumentHeader WH2 WITH (NOLOCK) ON p2.financialDocumentHeaderId IS NOT NULL AND  p2.financialDocumentHeaderId  = WH2.id
								LEFT JOIN document.CommercialDocumentHeader CH2 WITH (NOLOCK) ON p2.commercialDocumentHeaderId IS NOT NULL AND  p2.commercialDocumentHeaderId  = CH2.id
							WHERE p.commercialDocumentHeaderId = CAST(@commercialDocumentHeaderId AS uniqueidentifier) AND ISNULL(WH2.status, CH2.status) >= 40
						) x
					FOR XML PATH(''document'') , TYPE 
				) FOR XML PATH(''relatedDocuments''), TYPE
		END
	END
ELSE IF (@financialDocumentHeaderId <> '''')
	BEGIN
		
			SELECT (
						SELECT * FROM (
							SELECT DISTINCT
								ISNULL(WH2.fullNumber,CH2.fullNumber) AS ''@fullNumber'', ISNULL(WH2.id,CH2.id) AS ''@id'', ISNULL(WH2.issueDate,CH2.issueDate) AS ''@issueDate'', ISNULL(WH2.documentTypeId ,CH2.documentTypeId) AS ''@documentTypeId'', p2.documentInfo AS ''@documentInfo''
							FROM finance.Payment p WITH (NOLOCK) 
								JOIN finance.PaymentSettlement ps WITH (NOLOCK) ON  ps.outcomePaymentId = p.id   OR  ps.incomePaymentId = p.id
								JOIN finance.Payment p2 WITH (NOLOCK) ON  ps.incomePaymentId  = p2.id OR ps.outcomePaymentId  = p2.id
								LEFT JOIN document.FinancialDocumentHeader WH2 WITH (NOLOCK) ON p2.financialDocumentHeaderId IS NOT NULL AND  p2.financialDocumentHeaderId  = WH2.id AND WH2.id <> CAST(@financialDocumentHeaderId AS uniqueidentifier)
								LEFT JOIN document.CommercialDocumentHeader CH2 WITH (NOLOCK) ON p2.commercialDocumentHeaderId IS NOT NULL AND  p2.commercialDocumentHeaderId  = CH2.id
							WHERE p.financialDocumentHeaderId = CAST(@financialDocumentHeaderId AS uniqueidentifier) 
								AND ISNULL(WH2.status, CH2.status) >= 40
								
						) x
					FOR XML PATH(''document'') , TYPE 
				) FOR XML PATH(''relatedDocuments''), TYPE
		
	END
END
' 
END
GO

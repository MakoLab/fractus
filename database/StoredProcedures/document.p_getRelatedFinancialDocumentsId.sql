/*
name=[document].[p_getRelatedFinancialDocumentsId]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
59VF2gbuXYH+FkMA/k0rHA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getRelatedFinancialDocumentsId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getRelatedFinancialDocumentsId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getRelatedFinancialDocumentsId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_getRelatedFinancialDocumentsId]
@xmlVar XML 
AS

BEGIN
DECLARE @commercialDocumentHeaderId UNIQUEIDENTIFIER

SELECT @commercialDocumentHeaderId = @xmlVar.query(''root/commercialDocumentHeaderId'').value(''.'',''char(36)'')
SELECT (
	SELECT DISTINCT p2.financialDocumentHeaderId id
	FROM finance.Payment p 
		JOIN finance.PaymentSettlement ps ON p.id = ps.incomePaymentId OR p.id = ps.outcomePaymentId
		JOIN finance.Payment p2 ON (CASE WHEN (p.direction * p.amount) < 0 THEN ps.incomePaymentId  WHEN  (p.direction * p.amount) > 0 THEN ps.outcomePaymentId   END) = p2.id
	WHERE p.commercialDocumentHeaderId = @commercialDocumentHeaderId
	FOR XML PATH(''''), TYPE
) FOR XML PATH(''root''), TYPE

END
' 
END
GO

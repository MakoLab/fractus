/*
name=[document].[p_getDocumentPayments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
pCcQYIsxvU0yu9Wpo+zDHg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDocumentPayments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getDocumentPayments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDocumentPayments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getDocumentPayments]
@xmlVar XML
AS 
BEGIN
	DECLARE 
	@commercialDocumentHeaderId uniqueidentifier,
	@financialDocumentHeaderId uniqueidentifier


	/*Pobranie parametrów z XML*/
	SELECT 
	@commercialDocumentHeaderId = NULLIF(x.query(''commercialDocumentHeaderId'').value(''.'',''char(36)''),''''),
	@financialDocumentHeaderId = NULLIF(x.query(''financialDocumentHeaderId'').value(''.'',''char(36)''),'''')
	FROM @xmlVar.nodes(''root'') AS a(x)

	
	IF @commercialDocumentHeaderId IS NOT NULL
	
		SELECT ( 
						SELECT  pp.id AS ''id'', pp.paymentMethodId ''paymentMethodId'', pp.direction ''direction'',pp.amount ''paymentAmount'', pp.paymentCurrencyId ''paymentCurrencyId'',  
							ps.amount ''paymentSettlement/amount'',  p.documentInfo ''paymentSettlement/documentInfo'' ,p.paymentCurrencyId ''paymentSettlement/paymentCurrencyId'',
							p.amount ''paymentSettlement/paymentAmount'', p.direction ''paymentSettlement/direction''
						FROM finance.Payment pp 
							LEFT JOIN finance.PaymentSettlement ps ON ps.incomePaymentId = pp.id OR ps.outcomePaymentId = pp.id
							LEFT JOIN finance.Payment p ON (ps.incomePaymentId = p.id ) --AND  NULLIF(p.commercialDocumentHeaderId, @commercialDocumentHeaderId) IS NULL) 
								OR (ps.outcomePaymentId = p.id ) --AND NULLIF(p.commercialDocumentHeaderId, @commercialDocumentHeaderId) IS NULL)
						WHERE pp.commercialDocumentHeaderId = @commercialDocumentHeaderId AND p.commercialDocumentHeaderId IS NULL
						GROUP BY  pp.id , pp.paymentMethodId , pp.direction  ,pp.amount  , pp.paymentCurrencyId ,  
							ps.amount  ,  p.documentInfo   ,p.paymentCurrencyId  ,
							p.amount  , p.direction
						FOR XML PATH(''payment''),TYPE
				) FOR XML PATH(''root''), TYPE
	ELSE
		SELECT ( 
					
						SELECT distinct pp.id AS ''id'', pp.paymentMethodId ''paymentMethodId'', pp.amount ''paymentAmount'',pp.direction ''direction'', pp.paymentCurrencyId ''paymentCurrencyId'',  
							ps.amount ''paymentSettlement/amount'',  p.documentInfo ''paymentSettlement/documentInfo'' ,p.paymentCurrencyId ''paymentSettlement/paymentCurrencyId'',
							p.amount ''paymentSettlement/paymentAmount'', p.direction ''paymentSettlement/direction''
						FROM finance.Payment pp 
							LEFT JOIN finance.PaymentSettlement ps ON ps.incomePaymentId = pp.id OR ps.outcomePaymentId = pp.id
							LEFT JOIN finance.Payment p ON (ps.incomePaymentId = p.id AND NULLIF(p.financialDocumentHeaderId, @financialDocumentHeaderId) IS NULL) 
								OR (ps.outcomePaymentId = p.id AND NULLIF(p.financialDocumentHeaderId, @financialDocumentHeaderId) IS NULL)
						WHERE pp.financialDocumentHeaderId = @financialDocumentHeaderId 
						GROUP BY  pp.id , pp.paymentMethodId , pp.direction  ,pp.amount  , pp.paymentCurrencyId ,  
							ps.amount  ,  p.documentInfo   ,p.paymentCurrencyId  ,
							p.amount  , p.direction
						FOR XML PATH(''payment''),TYPE
				) FOR XML PATH(''root''), TYPE

END
' 
END
GO

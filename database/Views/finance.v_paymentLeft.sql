/*
name=[finance].[v_paymentLeft]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
wkKb+Ai1M9EGKcdb0WtsJw==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[finance].[v_paymentLeft]'))
DROP VIEW [finance].[v_paymentLeft]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[finance].[v_paymentLeft]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW finance.v_paymentLeft
AS
SELECT SUM(paymentLeft) paymentLeft, contractorId ,branchId, documentDocumentHeaderId, id, direction
FROM (
	SELECT ABS((px.amount * px.direction)) - (ISNULL(psx.amount,0)) paymentLeft, (px.amount * px.direction) direction,
			ISNULL(hx.branchId,cx.branchId) branchId, ISNULL(px.commercialDocumentHeaderId, px.financialDocumentHeaderId) documentDocumentHeaderId, 
			ISNULL(hx.id, cx.id) id,
			ISNULL(px.contractorId, cx.contractorId) contractorId
	FROM finance.payment px WITH(NOLOCK) 
		LEFT JOIN document.FinancialDocumentHeader hx WITH(NOLOCK) ON px.financialDocumentHeaderId = hx.id
		LEFT JOIN document.CommercialDocumentHeader cx WITH(NOLOCK) ON px.CommercialDocumentHeaderId = cx.id
		LEFT JOIN finance.PaymentSettlement psx WITH(NOLOCK) ON px.id IN (psx.incomePaymentId, psx.outcomePaymentId )
	) x 
GROUP BY  contractorId ,branchId, documentDocumentHeaderId, id, direction
' 
GO

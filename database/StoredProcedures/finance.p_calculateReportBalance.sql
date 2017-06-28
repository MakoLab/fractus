/*
name=[finance].[p_calculateReportBalance]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ZBZqF8yeXqX7OHt2zW+4Ow==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_calculateReportBalance]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_calculateReportBalance]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_calculateReportBalance]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [finance].[p_calculateReportBalance]
@xmlVar XML
AS
BEGIN
	DECLARE @financialReportId uniqueidentifier,
	@incomeAmount NUMERIC(18,2),
	@outcomeAmount NUMERIC(18,2)

	/*Parametr wejściowy*/
	SELECT @financialReportId = @xmlVar.query(''root/financialReportId'').value(''.'',''char(36)'')

	/*Suma przychodowych płatności*/
	SELECT @incomeAmount = SUM(p.direction * ISNULL(p.amount,0))
	FROM finance.Payment p 
		JOIN document.FinancialDocumentHeader h ON p.financialDocumentHeaderId = h.id
	WHERE (p.amount * p.direction) >= 0 AND h.financialReportId = @financialReportId

	/*Suma rozchodowych płatności*/
	SELECT @outcomeAmount = SUM(p.direction * ISNULL(p.amount,0))
	FROM finance.Payment p 
		JOIN document.FinancialDocumentHeader h ON p.financialDocumentHeaderId = h.id
	WHERE (p.amount * p.direction) < 0 AND h.financialReportId = @financialReportId

	SELECT ISNULL(@incomeAmount,0) incomeAmount , ISNULL(@outcomeAmount,0) outcomeAmount
	FOR XML PATH(''root''), TYPE

END
' 
END
GO

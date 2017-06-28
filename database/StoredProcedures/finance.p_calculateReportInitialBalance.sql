/*
name=[finance].[p_calculateReportInitialBalance]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fyFKeJYqlNg6rvxwSfo4tQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_calculateReportInitialBalance]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_calculateReportInitialBalance]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_calculateReportInitialBalance]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [finance].[p_calculateReportInitialBalance]
@xmlVar XML
AS
BEGIN
	DECLARE @financialRegisterId uniqueidentifier,
	@financialReportId uniqueidentifier,
	@initialAmount NUMERIC(18,2)

	/*Parametr wejściowy*/
	SELECT @financialRegisterId = @xmlVar.query(''root/financialRegisterId'').value(''.'',''char(36)'')


	SELECT TOP 1 @financialReportId = id
	FROM finance.FinancialReport
	WHERE financialRegisterId = @financialRegisterId
	ORDER BY creationDate DESC



	/*Suma */
	SELECT @initialAmount = ISNULL(initialBalance,0) + ISNULL(incomeAmount,0) + ISNULL(outcomeAmount,0)
	FROM finance.FinancialReport
	WHERE id = @financialReportId

	SELECT @initialAmount 
	FOR XML PATH(''root''), TYPE

END
' 
END
GO

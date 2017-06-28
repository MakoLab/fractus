/*
name=[finance].[p_getNextFinancialReportId]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dRdona56WbmFV0z+LMS9zg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getNextFinancialReportId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_getNextFinancialReportId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getNextFinancialReportId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [finance].[p_getNextFinancialReportId]
@xmlVar XML
AS
BEGIN
	DECLARE @financialReportId uniqueidentifier,
	@nextfinancialReportId char(36),
	@date datetime,
	@registerId uniqueidentifier

	SELECT @financialReportId = @xmlVar.query(''root/financialReportId'').value(''.'',''char(36)'')

	SELECT @registerId = financialRegisterId ,@date = creationDate 
	FROM finance.FinancialReport 
	WHERE id = @financialReportId

	SELECT TOP 1 @nextfinancialReportId = r.id 
	FROM finance.FinancialReport r 
	WHERE r.creationDate > @date AND r.financialRegisterId = @registerId
	ORDER BY r.creationDate ASC

	SELECT CAST(''<root>'' + ISNULL(@nextfinancialReportId, '''') + ''</root>'' AS XML)
		
--w tym samym rejestrze
END
' 
END
GO

/*
name=[finance].[p_getFinancialReportsDate]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
d/bhW0KvXZEiNiEkdiV1kQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getFinancialReportsDate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_getFinancialReportsDate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getFinancialReportsDate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [finance].[p_getFinancialReportsDate]
@xmlVar XML
AS
BEGIN

	DECLARE @financialRegisterId uniqueidentifier,
		@openedReportCreationDate datetime,
		@nextReportCreationDate datetime

	SELECT @financialRegisterId = @xmlVar.query(''root/financialRegisterId'').value(''.'',''char(36)'')


	SELECT @openedReportCreationDate = creationDate 
	FROM finance.FinancialReport
	WHERE isClosed = 0 AND financialRegisterId = @financialRegisterId

	SELECT TOP 1 @nextReportCreationDate = r.creationDate 
	FROM finance.FinancialReport r 
	WHERE r.creationDate > @openedReportCreationDate AND r.financialRegisterId = @financialRegisterId
	ORDER BY r.creationDate ASC

SELECT @openedReportCreationDate openedReportCreationDate, @nextReportCreationDate nextReportCreationDate
FOR XML PATH(''root''), TYPE

END
' 
END
GO

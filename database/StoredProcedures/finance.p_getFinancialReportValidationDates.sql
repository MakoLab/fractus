/*
name=[finance].[p_getFinancialReportValidationDates]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
6b5axwK4HnT+05ZBHoXW6A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getFinancialReportValidationDates]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_getFinancialReportValidationDates]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getFinancialReportValidationDates]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [finance].[p_getFinancialReportValidationDates]
@xmlVar XML
AS
BEGIN
	DECLARE 
		@financialReportId uniqueidentifier,
		@registerId uniqueidentifier,
		@previousFinancialReportClosureDate datetime,
		@date datetime,
		@nextFinancialReportOpeningDate datetime,
		@greatestIssueDateOnFinancialDocument datetime,
		@isNew int


	SELECT @registerId = @xmlVar.query(''root/financialRegisterId'').value(''.'',''char(36)''),
		   @financialReportId = @xmlVar.query(''root/financialReportId'').value(''.'',''char(36)''),
		   @date = @xmlVar.query(''root/creationDate'').value(''.'',''datetime''),
		   @isNew = @xmlVar.value(''root[1]/@isNew'',''int'')

	SELECT TOP 1 @previousFinancialReportClosureDate = r.closureDate 
	FROM finance.FinancialReport r 
	WHERE (r.creationDate < @date OR @isNew = 1 ) AND r.financialRegisterId = @registerId
	ORDER BY r.creationDate DESC

	SELECT TOP 1 @nextFinancialReportOpeningDate = r.creationDate
	FROM finance.FinancialReport r 
	WHERE r.creationDate > @date AND r.financialRegisterId = @registerId
	ORDER BY r.creationDate ASC

	-- gdereck - walidacja daty zamkniecia na podstawie daty ostatniego dokumentu cofnietej
	-- o 1s (by dalo sie zamknac raport tego samego dnia)
	SELECT TOP 1 @greatestIssueDateOnFinancialDocument = DATEADD(ss, -1, r.issueDate)
	FROM document.FinancialDocumentHeader r 
	WHERE
		r.financialReportId = @financialReportId
		and status >= 40
	ORDER BY r.issueDate DESC

SELECT  @previousFinancialReportClosureDate previousFinancialReportClosureDate, 
		@nextFinancialReportOpeningDate nextFinancialReportOpeningDate,
		@greatestIssueDateOnFinancialDocument greatestIssueDateOnFinancialDocument
FOR XML PATH(''root''), TYPE

END' 
END
GO

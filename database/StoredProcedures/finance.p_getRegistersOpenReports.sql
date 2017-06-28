/*
name=[finance].[p_getRegistersOpenReports]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
y2bD/M474jM/5VIWoVHD7Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getRegistersOpenReports]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_getRegistersOpenReports]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getRegistersOpenReports]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [finance].[p_getRegistersOpenReports] 
@xmlVar XML
AS
BEGIN
	DECLARE @branchId uniqueidentifier
	SELECT @branchId = @xmlVar.value(''(*/branchId)[1]'',''uniqueidentifier'')

			SELECT (
				SELECT  r.id ''@financialRegisterId'',fr.id ''@financialReportId'',fr.fullNumber ''@reportNumber'',fr.creationDate ''@creationDate'',fr.creatingApplicationUserId ''@creatingUserId'',
					-- ISNULL( (	x.amount), 0 ) ''@balance'',
					 ( SELECT TOP 1 ISNULL(f.initialBalance,0) + ISNULL(f.incomeAmount,0) + ISNULL(f.outcomeAmount,0) 
						FROM finance.FinancialReport f WITH(NOLOCK) 
						WHERE r.id = f.financialRegisterId 
						ORDER BY ISNULL(closureDate,openingDate) DESC
						) as ''@balance''
				FROM dictionary.FinancialRegister r WITH(NOLOCK)
					LEFT JOIN finance.FinancialReport fr WITH(NOLOCK) ON r.id = fr.financialRegisterId AND  isClosed = 0
				WHERE r.branchId = @branchId  
				FOR XML PATH(''financialRegister''), TYPE
			) FOR XML PATH(''root''),TYPE
			
	
END' 
END
GO

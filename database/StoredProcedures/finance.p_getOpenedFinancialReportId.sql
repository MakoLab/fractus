/*
name=[finance].[p_getOpenedFinancialReportId]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
cdtIi2U+zjJJ2+BmeSHXsw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getOpenedFinancialReportId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_getOpenedFinancialReportId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getOpenedFinancialReportId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [finance].[p_getOpenedFinancialReportId]
@xmlVar XML
AS
BEGIN

DECLARE 
@financialRegisterId UNIQUEIDENTIFIER,
@id UNIQUEIDENTIFIER

SELECT @financialRegisterId = x.query(''financialRegisterId'').value(''.'',''char(36)'')
FROM @xmlVar.nodes(''root'') AS a(x)

SELECT  @id = f.id 
FROM 	finance.FinancialReport f 
WHERE f.financialRegisterId = @financialRegisterId AND f.isClosed = 0

SELECT ISNULL(CAST(@id AS VARCHAR(50)) ,'''')  
FOR XML PATH(''root''), TYPE

END
' 
END
GO

/*
name=[finance].[p_checkReportExistence]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
jsM+CsBp01i1v8q+0ToJMQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_checkReportExistence]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_checkReportExistence]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_checkReportExistence]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [finance].[p_checkReportExistence] @xmlVar XML
AS
BEGIN
	DECLARE @financialRegisterId uniqueidentifier


	/*Parametr wejściowy*/
	SELECT @financialRegisterId = @xmlVar.query(''root/financialRegisterId'').value(''.'',''char(36)'')

	IF EXISTS ( SELECT id FROM finance.FinancialReport WHERE financialRegisterId = @financialRegisterId)
		SELECT CAST(''<root>true</root>'' AS XML)
	ELSE
		SELECT CAST(''<root>false</root>'' AS XML)
END
' 
END
GO

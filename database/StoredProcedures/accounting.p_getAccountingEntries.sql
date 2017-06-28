/*
name=[accounting].[p_getAccountingEntries]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fbO1zaFE2wArwHuu25SLRQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getAccountingEntries]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_getAccountingEntries]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getAccountingEntries]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [accounting].[p_getAccountingEntries]
	@xmlVar xml
AS
BEGIN
	

	DECLARE
		@documentId uniqueidentifier

	SELECT
		@documentId = @xmlVar.query(''/*/documentId'').value(''.'',''char(36)'')
		
		SELECT (
			SELECT [order],debitAccount,debitAmount,creditAccount,creditAmount,description
			FROM accounting.AccountingEntries 
			WHERE documentHeaderId = @documentId
			FOR XML PATH(''accountingEntry''), TYPE
				)
		FOR XML PATH(''accountingEntries''), TYPE

END



/****** Object:  StoredProcedure [accounting].[p_getCommercialDocument]    Script Date: 11/19/2009 11:15:23 ******/
SET ANSI_NULLS ON



/****** Object:  StoredProcedure [accounting].[p_getCommercialDocument]    Script Date: 02/25/2010 15:24:11 ******/
SET ANSI_NULLS ON
' 
END
GO

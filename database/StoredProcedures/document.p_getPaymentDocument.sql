/*
name=[document].[p_getPaymentDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
mMQo2qKoklYOF/4GJwTMLw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getPaymentDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getPaymentDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getPaymentDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getPaymentDocument]
@xmlVar XML
AS 
BEGIN
	DECLARE @paymentId uniqueidentifier

	/*Pobranie parametrów z XML*/
	SELECT 	@paymentId = @xmlVar.query(''root'').value(''.'',''char(36)'')
	
	SELECT (
		SELECT commercialDocumentHeaderId , financialDocumentHeaderId
		FROM finance.payment p 
		WHERE id = @paymentId
		FOR XML PATH(''''), TYPE 
			)
	FOR XML PATH(''root''), TYPE
END
' 
END
GO

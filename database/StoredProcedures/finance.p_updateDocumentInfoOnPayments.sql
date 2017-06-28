/*
name=[finance].[p_updateDocumentInfoOnPayments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
XMr9UeM/KxHNDsEXVtzQow==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_updateDocumentInfoOnPayments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_updateDocumentInfoOnPayments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_updateDocumentInfoOnPayments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [finance].[p_updateDocumentInfoOnPayments]
@xmlVar XML
AS
BEGIN

DECLARE 
@commercialDocumentHeaderId uniqueidentifier,
@financialDocumentHeaderId uniqueidentifier,
@documentInfo varchar(200),
@description nvarchar(200),
@fullNumber varchar(100),
@relatedFullNumber varchar(100),
@relatedCommercialDocumentHeaderId uniqueidentifier,
@idoc int,
@symbol nvarchar(10)

	DECLARE @tmp TABLE (id UNIQUEIDENTIFIER)


	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

	INSERT INTO @tmp ( id )
	SELECT id
	FROM OPENXML(@idoc, ''/root/payments/id'')
		WITH (
				id char(36) ''.''
			)

	EXEC sp_xml_removedocument @idoc


	/*Pobranie parametrów z XML*/
	SELECT 
	@commercialDocumentHeaderId = NULLIF(x.value(''(commercialDocumentHeaderId)[1]'',''char(36)''),''''),
	@financialDocumentHeaderId = NULLIF(x.value(''(financialDocumentHeaderId)[1]'',''char(36)''),''''),
	@documentInfo = x.value(''(documentInfo)[1]'',''varchar(200)''),
	@relatedCommercialDocumentHeaderId = NULLIF(x.value(''(relatedCommercialDocumentHeaderId)[1]'',''char(36)''),''''),
	@description = NULLIF(x.value(''(description)[1]'',''varchar(200)''), '''')
	FROM @xmlVar.nodes(''root'') AS a(x)

	/* Pobranie numeru pełnego z dokumentu */
	IF @commercialDocumentHeaderId IS NOT NULL
		SELECT @fullNumber = fullNumber, @symbol = DocumentType.symbol FROM document.CommercialDocumentHeader WITH(ROWLOCK) JOIN dictionary.DocumentType WITH(NOLOCK) ON documentTypeId = DocumentType.id WHERE CommercialDocumentHeader.id = @commercialDocumentHeaderId
	ELSE 
		SELECT @fullNumber = fullNumber , @symbol = DocumentType.symbol FROM document.FinancialDocumentHeader WITH(ROWLOCK) JOIN dictionary.DocumentType WITH(NOLOCK) ON documentTypeId = DocumentType.id  WHERE FinancialDocumentHeader.id = @financialDocumentHeaderId

	IF @description IS NOT NULL
	BEGIN
		SELECT @relatedFullNumber = fullNumber , @symbol = DocumentType.symbol 
		FROM document.CommercialDocumentHeader WITH(ROWLOCK)
			JOIN dictionary.DocumentType WITH(NOLOCK) ON documentTypeId = DocumentType.id 
		WHERE CommercialDocumentHeader.id = @relatedCommercialDocumentHeaderId
		

		UPDATE finance.Payment WITH(ROWLOCK) 
		SET [description]  = REPLACE( replace(@description,''[fullNumber]'',@relatedFullNumber),''[documentType]'',@symbol)
		WHERE id IN (SELECT id FROM @tmp)

	END

	/*Aktualizacja informacji na paymentach*/
	UPDATE finance.Payment WITH(ROWLOCK) 
	SET documentInfo  = REPLACE( replace(@documentInfo,''[fullNumber]'',@fullNumber), ''[documentType]'',@symbol) 
	WHERE id IN (SELECT id FROM @tmp)

END
' 
END
GO

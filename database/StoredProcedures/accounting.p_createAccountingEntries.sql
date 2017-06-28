/*
name=[accounting].[p_createAccountingEntries]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
WIPktZ1v0tfdbTin0O+1vw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_createAccountingEntries]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_createAccountingEntries]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_createAccountingEntries]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [accounting].[p_createAccountingEntries]
	@xmlVar xml
AS
BEGIN
	

	insert into dbo.trace VALUES(getdate(),@xmlVar)

	DECLARE	@documentId			uniqueidentifier
	DECLARE	@documentCategory	varchar(20)			
	DECLARE	@ruleId				uniqueidentifier
	DECLARE @accountingRuleId	CHAR(36)
	DECLARE	@rule				xml
	DECLARE	@mess				varchar(2000)
	DECLARE @strId				CHAR(36)
	DECLARE @id					uniqueidentifier
	DECLARE @fullNumber			varchar(50)
	DECLARE @number				INT

	SET @mess = ''''
		
	SELECT	@documentId = @xmlVar.query(''/*/documentId'').value(''.'',''char(36)''),
			@documentCategory = @xmlVar.query(''/*/documentCategory'').value(''.'',''char(20)''),
			@accountingRuleId = @xmlVar.query(''/*/accountingRuleId'').value(''.'',''char(36)'')
	SET @ruleId = NULL

	IF( @documentCategory = ''WarehouseDocument'' )
	BEGIN
		SELECT @ruleId = D.accountingRuleId 
		FROM accounting.DocumentData D
		WHERE D.warehouseDocumentId = @documentId
	END
	ELSE
	IF( @documentCategory = ''CommercialDocument'' )
	BEGIN
		SELECT @ruleId = D.accountingRuleId 
		FROM accounting.DocumentData D
		WHERE D.commercialDocumentId = @documentId
	END
	ELSE
	IF( @documentCategory = ''FinancialDocument'' )
	BEGIN
		SELECT @ruleId = D.accountingRuleId 
		FROM accounting.DocumentData D
		WHERE D.financialDocumentId = @documentId
	END
	ELSE
	IF( @documentCategory = ''FinancialReport'')
		SET @mess = ''''
	ELSE
		SET @mess = ''documentCategory musi byc: WarehouseDocument/CommercialDocument/FinancialDocument/FinancialReport''

	IF (ISNULL(@accountingRuleId,'''') <> '''')
		SET @ruleId = CAST(@accountingRuleId AS UNIQUEIDENTIFIER)

	IF (@mess = '''')
	BEGIN
		IF (@ruleId IS NULL)
			SET @mess = ''Brak schematu księgowania dla dokumentu!''
		ELSE
		BEGIN
			SELECT @rule = ruleXml FROM accounting.AccountingRuleExt WHERE accountingRuleId = @ruleId

			IF (@@ROWCOUNT = 0)
				SET @mess = ''Brak definicji schematu''
			ELSE
			IF(@documentCategory = ''FinancialReport'')
			BEGIN
				SET @strId = ''''
				WHILE ((@strId IS NOT NULL) AND (@mess = ''''))
				BEGIN
					SET @id = NULL
					SELECT TOP 1 @strId = CAST(FDH.id AS CHAR(36)), @id = FDH.id, @fullNumber = fullNumber 
					FROM [document].[financialDocumentHeader] FDH
					WHERE (FDH.financialReportId = @documentId) AND (CAST(FDH.id AS CHAR(36)) > @strId)
					ORDER BY CAST(FDH.id AS CHAR(36))

					IF (@id IS NOT NULL)
					BEGIN
						EXEC [accounting].[p_createAccountingEntriesRule]
							''FinancialDocument'',	
							@id,
							@ruleId,	
							@rule,
							@mess OUT,
							1

						IF (@mess <> '''')
							IF (@mess <> ''ANULOWANY'')
								SET @mess = ''(DOK:''+@fullNumber+'')''+@mess
							ELSE
								SET @mess = ''''
					END
					ELSE
						SET @strId = NULL
				END
			END
			ELSE
			BEGIN
				EXEC [accounting].[p_createAccountingEntriesRule]
						@documentCategory,	
						@documentId,
						@ruleId,	
						@rule,
						@mess OUT,
						1
				DELETE FROM accounting.AccountingEntries 
				WHERE (documentHeaderId = @documentId) AND (debitAmount) = 0 AND (creditAmount = 0)
				SET @number=0
				UPDATE accounting.AccountingEntries SET @number=@number+1, [order]=@number
				WHERE (documentHeaderId = @documentId)
				
			END
		END
	END

	SELECT 
		@mess
	FOR XML PATH(''result'')
END




/****** Object:  StoredProcedure [accounting].[p_createAccountingEntriesRule]    Script Date: 11/19/2009 11:14:12 ******/
SET ANSI_NULLS ON




set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
' 
END
GO

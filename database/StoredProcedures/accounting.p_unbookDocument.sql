/*
name=[accounting].[p_unbookDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
G0DDW+uPy5sjvZlsXPyWNw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_unbookDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_unbookDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_unbookDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [accounting].[p_unbookDocument] 
@xmlVar XML
AS 
BEGIN

DECLARE 
	@commercialDocumentHeaderId UNIQUEIDENTIFIER,
	@financialDocumentHeaderId UNIQUEIDENTIFIER,
	@warehouseDocumentHeaderId UNIQUEIDENTIFIER,
	@financialReportId UNIQUEIDENTIFIER,
	@version UNIQUEIDENTIFIER,
	@previousVersion char(36),
	@databaseId char(36),
	@localTransactionId char(36),
	@deferredTransactionId char(36),
	@i int,
	@x XML,
	@count int,
	@id UNIQUEIDENTIFIER

DECLARE @tmp TABLE (i int identity(1,1), financialDocumentHeaderId uniqueidentifier, financialReportId uniqueidentifier)

INSERT INTO dbo.trace VALUES(getdate(),@xmlVar)


/*Pobranie danych z XML*/
SELECT	@commercialDocumentHeaderId = NULLIF(@xmlVar.query(''root/commercialDocumentId'').value(''.'',''char(36)''),''''),
		@financialDocumentHeaderId = NULLIF(@xmlVar.query(''root/financialDocumentId'').value(''.'',''char(36)''),''''),
		@warehouseDocumentHeaderId = NULLIF(@xmlVar.query(''root/warehouseDocumentId'').value(''.'',''char(36)''),''''),
		@financialReportId = NULLIF(@xmlVar.query(''root/financialReportId'').value(''.'',''char(36)''),''''),
		@localTransactionId = CAST(newid() as char(36)),
		@deferredTransactionId = CAST(newid() as char(36))
		
		
IF @commercialDocumentHeaderId IS NOT NULL
	BEGIN
		IF EXISTS (	SELECT * 
					FROM document.CommercialDocumentHeader h
					WHERE (h.id = @commercialDocumentHeaderId) AND [status] <> 60
					)
		BEGIN
			Raiserror(''Dokument niewyeksportowany-nie kasujemy!!'',12,1)
		END

		SELECT  @previousVersion = h.[version],
				@version = newid(), 
				@databaseId = b.databaseId
		FROM document.CommercialDocumentHeader h 
			JOIN dictionary.Branch b ON h.branchId = b.id
		WHERE h.id = @commercialDocumentHeaderId
		
		UPDATE  document.CommercialDocumentHeader
		SET [status] = 40, [version] = @version
		WHERE id = @commercialDocumentHeaderId
			AND [status] = 60
		
		DELETE FROM accounting.ExternalMapping
		WHERE id = @commercialDocumentHeaderId

		DELETE FROM accounting.ExternalMapping WHERE id in 
			(SELECT p.id FROM finance.Payment p WHERE p.commercialDocumentHeaderid=@commercialDocumentHeaderId)
		
		SELECT @x = ''<root businessObjectId="'' + CAST(@commercialDocumentHeaderId AS char(36)) + ''" databaseId="'' + CAST(@databaseId AS char(36)) + ''" previousVersion="'' + CAST(@previousVersion AS char(36)) + ''" localTransactionId="'' + CAST(@localTransactionId AS char(36)) + ''" deferredTransactionId="'' + CAST(@deferredTransactionId AS char(36)) + ''" />''
		EXEC communication.p_createCommercialDocumentPackage @x
		
	END
			
IF @warehouseDocumentHeaderId IS NOT NULL
	BEGIN
		IF EXISTS (	SELECT * 
					FROM document.WarehouseDocumentHeader  h
					WHERE (h.id = @warehouseDocumentHeaderId) AND (h.[status] <> 60)
					)
		BEGIN
			Raiserror(''Dokument niewyeksportowany-nie kasujemy!!'',12,1)
		END

		SELECT  @previousVersion = h.[version],
				@version = newid(), 
				@databaseId = b.databaseId
		FROM document.WarehouseDocumentHeader h 
			JOIN dictionary.Branch b ON h.branchId = b.id
		WHERE h.id = @warehouseDocumentHeaderId
		
		
		UPDATE  document.WarehouseDocumentHeader
		SET [status] = 40, [version] = @version
		WHERE id = @warehouseDocumentHeaderId
		
		
		DELETE FROM accounting.ExternalMapping
		WHERE id = @warehouseDocumentHeaderId
		
		SELECT @x = ''<root businessObjectId="'' + CAST(@warehouseDocumentHeaderId AS char(36)) + ''" databaseId="'' + CAST(@databaseId AS char(36)) + ''" previousVersion="'' + CAST(@previousVersion AS char(36)) + ''" localTransactionId="'' + CAST(@localTransactionId AS char(36)) + ''" deferredTransactionId="'' + CAST(@deferredTransactionId AS char(36)) + ''" />''
		EXEC communication.p_createWarehouseDocumentPackage @x
	END
	
	
IF @financialReportId IS NOT NULL
	BEGIN
		IF EXISTS (	SELECT * 
					FROM finance.FinancialReport fr 
						JOIN document.FinancialDocumentHeader fdh ON fr.id = fdh.financialReportId
					WHERE fdh.[status] <> 60 AND fr.id = @financialReportId 
					)
		BEGIN
			Raiserror(''Dokument niewyeksportowany-nie kasujemy!!'',12,1)
		END
					
					
		SELECT @i = 1, @count = 0	

		INSERT INTO @tmp (	financialDocumentHeaderId, financialReportId)
		SELECT fdh.id , fr.id
		FROM finance.FinancialReport fr 
			JOIN document.FinancialDocumentHeader fdh ON fr.id = fdh.financialReportId
		WHERE fr.id = @financialReportId
		SELECT @count = @@rowcount

		BEGIN TRAN
		
		WHILE @i <= @count
			BEGIN 
												
				SELECT  @previousVersion = h.[version],
						@version = newid(), 
						@databaseId = b.databaseId,
						@id = h.id
				FROM @tmp t
					JOIN document.FinancialDocumentHeader h ON t.financialDocumentHeaderId = h.id
					JOIN dictionary.Branch b ON h.branchId = b.id
				WHERE t.i = @i
		
				UPDATE  document.FinancialDocumentHeader
				SET [status] = 40, [version] = @version
				WHERE id = @id	
				
				DELETE FROM accounting.ExternalMapping
				WHERE id = @id
				
				SELECT @x = ''<root businessObjectId="'' + CAST(@id AS char(36)) + ''" databaseId="'' + CAST(@databaseId AS char(36)) + ''" previousVersion="'' + CAST(@previousVersion AS char(36)) + ''" localTransactionId="'' + CAST(@localTransactionId AS char(36)) + ''" deferredTransactionId="'' + CAST(@deferredTransactionId AS char(36)) + ''" />''
				EXEC communication.[p_createFinancialDocumentPackage] @x
				
				SELECT @i = @i + 1
				
			END	
		DELETE FROM accounting.ExternalMapping WHERE id = @financialReportId

		COMMIT TRAN

	END

SELECT CAST(''<root/>'' AS XML)
	
	
	
	
END
' 
END
GO

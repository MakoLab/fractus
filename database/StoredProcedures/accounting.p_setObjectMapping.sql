/*
name=[accounting].[p_setObjectMapping]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
43FgK+R8fxv19k7afGzMUA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_setObjectMapping]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_setObjectMapping]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_setObjectMapping]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [accounting].[p_setObjectMapping]
@xmlVar XML
AS
BEGIN


	SET ARITHABORT ON

	DECLARE @foreignId			CHAR(36),
			@systemName			VARCHAR(10),
			@id					VARCHAR(50),
			@ordA				INT,
			@ordB				INT,
			@cnt				INT,
			@rowcount			INT,
			@objectType			INT,
			@objectTypeDetail	INT,
			@previousVersion	UNIQUEIDENTIFIER, 
			@cpXml				XML,
			@objectVersion		UNIQUEIDENTIFIER,
			@newVersion			UNIQUEIDENTIFIER,
			@communicationXml	XML,
			@payments			XML,
            @paymentForeignId	CHAR(36),
            @paymentId			VARCHAR(50)
				
	insert into dbo.trace VALUES(getdate(),@xmlVar)

	SELECT
		@systemName = ISNULL(con.query(''systemName'').value(''.'',''CHAR(10)''),'''')
	FROM @xmlVar.nodes(''/ROOT/response'') AS C ( con )

	SELECT
		@foreignId = ISNULL(con.query(''foreignId'').value(''.'',''CHAR(36)''),''''),
		@id = ISNULL(con.query(''id'').value(''.'',''VARCHAR(50)''),'''')
	FROM @xmlVar.nodes(''/ROOT/response/document'') AS C ( con )

	IF (@foreignId IS NULL)
		SELECT
			@foreignId = ISNULL(con.query(''foreignId'').value(''.'',''CHAR(36)''),''''),
			@id = ISNULL(con.query(''id'').value(''.'',''VARCHAR(50)''),'''')
		FROM @xmlVar.nodes(''/ROOT/response/contractor'') AS C ( con )


	IF (@systemName = '''')
		RAISERROR ( ''Brak nazwy systemu zewnętrznego exportu!'', 16, 1 )
	IF (@id = '''')
		RAISERROR ( ''Brak zewnętrznego identyfikatora wyeksportowanego dokumentu!!'', 16, 1 )

	IF EXISTS (SELECT * FROM document.CommercialDocumentHeader WHERE id = @foreignId)
		SELECT @objectVersion = version , @objectType = 1
		FROM document.CommercialDocumentHeader 
		WHERE id = @foreignId
	ELSE
	IF EXISTS (SELECT * FROM document.WarehouseDocumentHeader WHERE id = @foreignId)
		SELECT @objectVersion = version , @objectType = 2
		FROM document.WarehouseDocumentHeader 
		WHERE id = @foreignId
	ELSE
	IF EXISTS (SELECT * FROM finance.FinancialReport WHERE id = @foreignId)
		IF EXISTS (SELECT f.id
					FROM finance.financialReport f
					JOIN dictionary.FinancialRegister r ON f.financialRegisterId=r.id
					JOIN dictionary.documentType t ON t.id=CAST(r.xmlOptions.query(''root/register/incomeDocument/documentTypeId'').value(''.'',''varchar(100)'') AS uniqueidentifier)
					WHERE (t.xmlOptions.exist(''root[1]/financialDocument[1]/@payerId'') = 1) AND (f.id=@foreignId)
				  )
			SELECT @objectVersion = version , @objectType = 6
			FROM finance.FinancialReport 
			WHERE id = @foreignId			
		ELSE
			SELECT @objectVersion = version , @objectType = 3
			FROM finance.FinancialReport 
			WHERE id = @foreignId
	ELSE
	IF EXISTS (SELECT * FROM contractor.Contractor  WHERE id = @foreignId)
		SELECT @objectVersion = version , @objectType = 4
		FROM contractor.Contractor 
		WHERE id = @foreignId
	ELSE
		RAISERROR ( ''Nie można określić typu dokumentu!!'', 16, 1 )

	IF EXISTS (
				SELECT id FROM accounting.ExternalMapping 
				WHERE id = @foreignId AND externalSystemName = @systemName AND 
					  externalId <> @id
			  ) RAISERROR ( ''Mapowanie juz istnieje w bazie z innym id systemu ksiegowego'', 16, 1 )
	ELSE
	BEGIN
				
		DELETE FROM document.ExportStatus
		WHERE documentId = @foreignId
		
		UPDATE accounting.ExternalMapping 
			SET exportDate = getdate() , objectVersion = @objectVersion
		WHERE id = @foreignId AND externalSystemName = @systemName AND externalId = @id
		
		IF (@@ROWCOUNT = 0)
			INSERT INTO accounting.ExternalMapping 
			(id, externalId, objectType, exportDate, externalSystemName, objectVersion)
			VALUES (@foreignId, @id, @objectType, getdate(), @systemName, @objectVersion)
		/*Obsługa mapowania kontrahenta*/
		IF (@objectType = 4) 
			BEGIN	

				SELECT @newVersion = newid()
				/*Zmiana kodu kontrahenta na id z XL*/
				UPDATE contractor.Contractor 
				SET [code] = @id, [version] = @newVersion
				WHERE id = @foreignId
				
				UPDATE accounting.ExternalMapping 
					SET exportDate = getdate() , objectVersion = @newVersion
				WHERE id = @foreignId AND externalSystemName = @systemName AND externalId = @id
				
				/*Rozesłanie kontrahentów ze zmianą wersji i kodu*/
		        SELECT  @communicationXml = CAST( ''<root businessObjectId="''+ CAST(@foreignId AS char(36)) +''" 
															previousVersion="''+ CAST(@newVersion AS char(36)) + ''" 
															localTransactionId="'' + CAST(newid() AS char(36)) + ''" 
															deferredTransactionId="'' + CAST(newid() AS char(36)) + ''"  
															databaseId="'' + (SELECT textValue FROM configuration.Configuration WHERE [key] LIKE ''communication.databaseId'') + ''" />'' AS XML)

				EXEC communication.p_createContractorPackage @communicationXml
			END
		IF (@objectType = 1) 
		BEGIN
			SELECT @previousVersion = version FROM document.CommercialDocumentHeader WHERE id = @foreignId

			UPDATE document.CommercialDocumentHeader 
			SET status = CASE WHEN status = 40 THEN 60 ELSE status END, version = newid() 
			WHERE id = @foreignId AND status = 40
			
			IF (@@rowcount > 0 )
				BEGIN
				
					SELECT @objectVersion = version 
					FROM document.CommercialDocumentHeader 
					WHERE id = @foreignId
				
					UPDATE accounting.ExternalMapping 
						SET objectVersion = @objectVersion
					WHERE id = @foreignId 
						AND externalSystemName = @systemName 
						AND externalId = @id

					SELECT @cpXml = CAST(
						''<root '' + 
						''databaseId="'' + cast(b.databaseId as char(36)) + ''" '' +
						''businessObjectId="'' + cast(@foreignId as char(36)) + ''" '' +
						''previousVersion="'' + cast(@previousVersion as char(36)) + ''" '' +
						''localTransactionId="'' + cast(newid() as char(36)) + ''" '' +
						''deferredTransactionId="'' + cast(newid() as char(36)) + ''" '' +
						''/>''
						AS XML)
					FROM document.CommercialDocumentHeader h 
						JOIN dictionary.Branch b ON h.branchId = b.id
					WHERE h.id = @foreignId

					EXEC communication.p_createCommercialDocumentPackage @xmlVar = @cpXml
				END	
		END
		ELSE 
		IF (@objectType = 2) 
		BEGIN
			SELECT @previousVersion = version FROM document.WarehouseDocumentHeader WHERE id = @foreignId

			UPDATE document.WarehouseDocumentHeader 
			SET status = CASE WHEN status = 40 THEN 60 ELSE status END, version = newid() 
			WHERE id = @foreignId AND status = 40
			IF (@@rowcount > 0 )
				BEGIN
				
					SELECT @objectVersion = version 
					FROM document.WarehouseDocumentHeader
					WHERE id = @foreignId
				
					UPDATE accounting.ExternalMapping 
						SET objectVersion = @objectVersion
					WHERE id = @foreignId 
						AND externalSystemName = @systemName 
						AND externalId = @id
						
					SELECT @cpXml = CAST(
						''<root '' + 
						''databaseId="'' + cast(b.databaseId as char(36)) + ''" '' +
						''businessObjectId="'' + cast(@foreignId as char(36)) + ''" '' +
						''previousVersion="'' + cast(@previousVersion as char(36)) + ''" '' +
						''localTransactionId="'' + cast(newid() as char(36)) + ''" '' +
						''deferredTransactionId="'' + cast(newid() as char(36)) + ''" '' +
						''/>''
						AS XML)
					FROM document.WarehouseDocumentHeader h 
						JOIN dictionary.Branch b ON h.branchId = b.id
					WHERE h.id = @foreignId

					EXEC communication.p_createWarehouseDocumentPackage @xmlVar = @cpXml
				END	
		END
		ELSE 
		IF ((@objectType = 3) OR (@objectType = 6)) 
		BEGIN
			SELECT @previousVersion = version FROM finance.FinancialReport WHERE id = @foreignId

			UPDATE document.FinancialDocumentHeader 
			SET status = CASE WHEN status = 40 THEN 60 ELSE status END, version = newid() 
			WHERE financialReportId = @foreignId AND status = 40
		
			IF (@@rowcount > 0 )
				BEGIN
				
					SELECT @objectVersion = version 
					FROM document.FinancialDocumentHeader
					WHERE id = @foreignId
				
					UPDATE accounting.ExternalMapping 
						SET objectVersion = @objectVersion
					WHERE id = @foreignId 
						AND externalSystemName = @systemName 
						AND externalId = @id
										
					SELECT @cpXml = CAST(
						''<root '' + 
						''databaseId="'' + cast(b.databaseId as char(36)) + ''" '' +
						''businessObjectId="'' + cast(@foreignId as char(36)) + ''" '' +
						''previousVersion="'' + cast(@previousVersion as char(36)) + ''" '' +
						''localTransactionId="'' + cast(newid() as char(36)) + ''" '' +
						''deferredTransactionId="'' + cast(newid() as char(36)) + ''" '' +
						''/>''
						AS XML)
					FROM finance.FinancialReport h 
						JOIN dictionary.FinancialRegister fr ON h.FinancialRegisterId = fr.id
						JOIN dictionary.Branch b ON fr.branchId = b.id
					WHERE h.id = @foreignId

					EXEC communication.p_createFinancialReportPackage @xmlVar = @cpXml
				END	
		END

		SET @ordB = 0
		SET @ordA = 0
		WHILE (@ordA >= 0)
		BEGIN
			SELECT TOP 1
				@ordB = ISNULL(con.query(''order'').value(''.'', ''int''),0),
				@foreignId = ISNULL(con.query(''foreignId'').value(''.'',''CHAR(36)''),''''),
				@id = ISNULL(con.query(''id'').value(''.'',''VARCHAR(50)''),''''),
				@payments = con.query(''payments'')
			FROM @xmlVar.nodes(''/ROOT/response/document/details/detail'') AS C ( con )
			WHERE ISNULL(con.query(''order'').value(''.'', ''int''),0) > @ordA

			IF (@ordB <> @ordA)
			BEGIN
				SET @ordA = @ordB

				IF (@objectType = 1)
					--SET @objectTypeDetail = 11
					SELECT @objectVersion = version, @objectTypeDetail = 11
					FROM finance.Payment 
					WHERE id = @foreignId
				ELSE
				IF (@objectType = 3)
					--SET @objectTypeDetail = 31
					SELECT @objectVersion = version, @objectTypeDetail = 31
					FROM document.FinancialDocumentHeader
					WHERE id = @foreignId
				ELSE
				IF (@objectType = 6)
					SELECT @objectVersion = version, @objectTypeDetail = 61
					FROM document.FinancialDocumentHeader
					WHERE id = @foreignId
				ELSE
					RAISERROR ( ''Brak typu podtypów elementów dla tego dokumentu'', 16, 1 )

				UPDATE accounting.ExternalMapping 
					SET exportDate = getdate() ,objectVersion = @objectVersion
				WHERE id = @foreignId AND externalSystemName = @systemName AND externalId = @id
				SET @rowcount = @@ROWCOUNT		
				
				IF (@rowcount = 0) 
					INSERT INTO accounting.ExternalMapping 
					(id, externalId, objectType, exportDate, externalSystemName, objectVersion)
					VALUES (@foreignId, @id, @objectTypeDetail, getdate(), @systemName, @objectVersion)
					
				DELETE FROM document.ExportStatus
		        WHERE documentId = @foreignId

				IF (@objectType = 6)
				BEGIN
					SET @cnt=0
					WHILE (@cnt < 2)
					BEGIN
						SET @cnt = @cnt + 1
						SELECT 
							@paymentForeignId = ISNULL(con.query(''paymentForeignId'').value(''.'',''CHAR(36)''),''''),
							@paymentId = ISNULL(con.query(''paymentId'').value(''.'',''VARCHAR(50)''),'''')
						FROM @payments.nodes(''/payments/payment'') AS C ( con )
						WHERE ISNULL(con.query(''order'').value(''.'', ''int''),0) = @cnt

						SET @rowcount = @@ROWCOUNT
						IF (@rowcount > 0)
						BEGIN
							SELECT @objectVersion = version, @objectTypeDetail = 61
							FROM finance.Payment
							WHERE id = CAST(@paymentForeignId AS UNIQUEIDENTIFIER)

							UPDATE accounting.ExternalMapping 
								SET exportDate = getdate() ,objectVersion = @objectVersion
							WHERE id = CAST(@paymentForeignId AS UNIQUEIDENTIFIER) AND 
							      externalSystemName = @systemName AND 
								  externalId = @paymentId

							SET @rowcount = @@ROWCOUNT		
							IF (@rowcount = 0) 
								INSERT INTO accounting.ExternalMapping 
								(id, externalId, objectType, exportDate, externalSystemName, objectVersion)
								VALUES (CAST(@paymentForeignId AS UNIQUEIDENTIFIER), @paymentId, 
										@objectTypeDetail, getdate(), @systemName, @objectVersion)

						END

					END
				END

			END
			ELSE
				SET @ordA = -1
		END

	END
END

' 
END
GO

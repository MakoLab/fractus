/*
name=[accounting].[p_createAccountingEntriesRule]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
B3c4lJF7agfZv18n6jmSKg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_createAccountingEntriesRule]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_createAccountingEntriesRule]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_createAccountingEntriesRule]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [accounting].[p_createAccountingEntriesRule] 

	@documentCategory VARCHAR(20),		
	@id UNIQUEIDENTIFIER,				
	@accountingRuleId UNIQUEIDENTIFIER,	
	@xmlVar XML,						
	@errors VARCHAR(2000) OUT,			
	@sumAccounting smallint = 0			



AS 

	DECLARE @number					INT
    DECLARE @accountingDate			VARCHAR(100)
    DECLARE @accountingJournal		VARCHAR(100)
	DECLARE @vatRegister			VARCHAR(100)
	DECLARE @vatYear				VARCHAR(100)
	DECLARE @vatMonth				VARCHAR(100)
	DECLARE @vat7					VARCHAR(100)
	DECLARE @vatUE					VARCHAR(100)
	DECLARE @transactionType		VARCHAR(100)
	DECLARE @uvatRegister			UNIQUEIDENTIFIER
	DECLARE @uaccountingJournal		UNIQUEIDENTIFIER
	DECLARE @oppositionAccounting	VARCHAR(100)
	DECLARE @externalName			VARCHAR(100)

	DECLARE @source					INT
	DECLARE @debitAccount			VARCHAR(100)
	DECLARE @debitAmount			VARCHAR(100)
	DECLARE @creditAccount			VARCHAR(100)
	DECLARE @creditAmount			VARCHAR(100)
	DECLARE @description			VARCHAR(255)
	DECLARE @condition				VARCHAR(100)

	DECLARE @result					VARCHAR(100)
	DECLARE @message				VARCHAR(300)
	DECLARE @field					VARCHAR(20)
	DECLARE @typDoc					VARCHAR(15)
	DECLARE @idLine					UNIQUEIDENTIFIER

	DECLARE @oNa					int
	DECLARE @oNb					int
	DECLARE @oNDa					int
	DECLARE @oNDb					int
	DECLARE @no						int
	DECLARE @indA					VARCHAR(36)
	DECLARE @indB					VARCHAr(36)

	DECLARE @ivatYear				INT
	DECLARE @ivatMonth				INT
	DECLARE @daccountingDate		DATETIME
	DECLARE @ivat7					INT
	DECLARE @ivatUE					INT

	DECLARE @indexOrder				INT

    BEGIN
		SET @source = 1
		SET @message = ''''

	
		DELETE FROM [accounting].[AccountingEntries] WHERE documentHeaderId = @id

	
		IF (EXISTS (SELECT * FROM tempdb.sys.sysobjects WHERE xtype=''u'' AND name=''##ExchangeTemp'') )
			DROP TABLE ##ExchangeTemp

		
		CREATE TABLE ##ExchangeTemp(field varchar (255))
		INSERT INTO ##ExchangeTemp (field) VALUES('''')
			
		
        SELECT  @accountingDate = NULLIF(con.query(''accountingDate'').value(''.'', ''varchar(100)''), ''''),
                @accountingJournal = NULLIF(con.query(''accountingJournal'').value(''.'', ''varchar(100)''),''''),
				@vatRegister = NULLIF(con.query(''vatRegister'').value(''.'', ''varchar(100)''),''''),
				@vatYear = NULLIF(con.query(''vatYear'').value(''.'', ''varchar(100)''),''''),
				@vatMonth = NULLIF(con.query(''vatMonth'').value(''.'', ''varchar(100)''),''''),
				@accountingDate = NULLIF(con.query(''accountingDate'').value(''.'', ''varchar(100)''),''''),
				@vat7 = NULLIF(con.query(''vat7'').value(''.'', ''varchar(100)''),''''),
				@vatUE = NULLIF(con.query(''vatUE'').value(''.'', ''varchar(100)''),''''),
				@oppositionAccounting = NULLIF(con.query(''oppositionAccounting'').value(''.'', ''varchar(100)''),''''),
				@externalName = NULLIF(con.query(''externalName'').value(''.'', ''varchar(100)''),''''),
				@transactionType = NULLIF(con.query(''transactionType'').value(''.'', ''varchar(100)''),''''),
				@condition = NULLIF(con.query(''condition'').value(''.'', ''varchar(100)''),'''')
        FROM @xmlVar.nodes(''/accountingRule'') AS C ( con )



		IF (@message = '''')
		BEGIN
			EXEC accounting.p_parsingPattern @condition, @source, @id, @result OUT, @message OUT
			IF (@message = '''')
			BEGIN
				SET @condition = @result
				IF (@condition <> '''')
					SET @message = ''nie można dekretować:''+@condition
			END
		END
		IF (@message = '''')
		BEGIN
			EXEC accounting.p_parsingPattern @accountingDate, @source, @id, @result OUT, @message OUT
			IF (@message = '''')
				SET @accountingDate = @result
		END
		IF (@message = '''')
		BEGIN
			EXEC accounting.p_parsingPattern @accountingJournal, @source, @id, @result OUT, @message OUT
			IF (@message = '''')
				SET @accountingJournal = @result
		END
		IF (@message = '''')
		BEGIN
			EXEC accounting.p_parsingPattern @vatRegister, @source, @id, @result OUT, @message OUT
			IF (@message = '''')
				SET @vatRegister = @result
		END
		IF (@message = '''')
		BEGIN
			EXEC accounting.p_parsingPattern @vatYear, @source, @id, @result OUT, @message OUT
			IF (@message = '''')
				SET @vatYear = @result
		END
		IF (@message = '''')
		BEGIN
			EXEC accounting.p_parsingPattern @vatMonth, @source, @id, @result OUT, @message OUT
			IF (@message = '''')
				SET @vatMonth = @result
		END
		IF (@message = '''')
		BEGIN
			EXEC accounting.p_parsingPattern @vat7, @source, @id, @result OUT, @message OUT
			IF (@message = '''')
				SET @vat7 = @result
		END
		IF (@message = '''')
		BEGIN
			EXEC accounting.p_parsingPattern @vatUE, @source, @id, @result OUT, @message OUT
			IF (@message = '''')
				SET @vatUE = @result
		END
		IF (@message = '''')
		BEGIN
			EXEC accounting.p_parsingPattern @oppositionAccounting, @source, @id, @result OUT, @message OUT
			IF (@message = '''')
				SET @oppositionAccounting = @result
		END
		IF (@message = '''')
		BEGIN
			EXEC accounting.p_parsingPattern @externalName, @source, @id, @result OUT, @message OUT
			IF (@message = '''')
				SET @externalName = @result
		END


		IF (@message = '''') AND (@documentCategory = ''CommercialDocument'')
		BEGIN
			SELECT @uvatRegister = id FROM dictionary.VatRegister WHERE symbol = @vatRegister
			IF (@@ROWCOUNT = 0)
				SET @message = ''Brak rejestru Vat:''+@vatRegister
		END

		IF (@message = '''')
		BEGIN
			SELECT @uaccountingJournal = id FROM dictionary.AccountingJournal WHERE symbol = @accountingJournal
			IF (@@ROWCOUNT = 0)
				SET @message = ''Brak dziennika księgowania:''+@accountingJournal
		END
			
		IF (@message = '''')
			IF (NOT(
			   (@transactionType = ''domestic'') OR
			   (@transactionType = ''euSupply'') OR
			   (@transactionType = ''trilateralEuSupply'') OR
			   (@transactionType = ''foreignTaxSupply'') OR
			   (@transactionType = ''euPurchase'') OR
			   (@transactionType = ''trilateralEuPurchase'') OR
			   (@transactionType = ''import'')
			   ))		
				SET @message = ''Błędny tryb transakcji:''+@transactionType



		IF (@message = '''')
		BEGIN
			BEGIN TRY
				SET @field = ''rok VAT''
				SET @ivatYear = CAST(@vatYear AS INT) 
				SET @field = ''miesiac VAT''
				SET @ivatMonth = CAST(@vatMonth AS INT)
				SET @field = ''data ksiegowania''
				SET @daccountingDate = CAST(@accountingDate AS DATETIME)
				SET @field = ''VAT7''
				SET @ivat7 = CAST(@vat7 AS INT)
				SET @field = ''VATUe''
				SET @ivatUE	= CAST(@vatUE AS INT)
			END TRY
			BEGIN CATCH
				Set @message = ''Błąd pola:'' + @field + ''! ('' + ERROR_MESSAGE() +'')''
			END CATCH
		END



		IF (@message = '''')
		BEGIN
			IF (NOT EXISTS (SELECT * FROM accounting.DocumentData 
							WHERE (commercialDocumentId = @id) OR (warehouseDocumentId = @id) OR (financialDocumentId = @id) )
			    )
				INSERT INTO accounting.DocumentData 
					(
						commercialDocumentId,
						warehouseDocumentId,
						financialDocumentId
					)
				VALUES
					( 
						CASE WHEN @documentCategory = ''CommercialDocument'' THEN @id ELSE NULL END,
						CASE WHEN @documentCategory = ''WarehouseDocument'' THEN @id ELSE NULL END,
						CASE WHEN @documentCategory = ''FinancialDocument'' THEN @id ELSE NULL END
					)

			UPDATE accounting.DocumentData SET
				vatRegisterId = @uvatRegister,
				[month] = @ivatMonth,
				[year] = @ivatYear,
				vat7 = @ivat7,
				vatUE = @ivatUe,
				accountingRuleId = @accountingRuleId,
				accountingJournalId = @uaccountingJournal,
				date = CONVERT(DATETIME,CONVERT(VARCHAR(10),@daccountingDate,102),102),
				oppositionAccounting = substring(@oppositionAccounting,1,50),
				externalName = substring(@externalName,1,20),
--				applicationUserId = 
				transactionType = @transactionType,
				entriesCreated = 1
			WHERE (commercialDocumentId = @id) OR (warehouseDocumentId = @id) OR (financialDocumentId = @id)
		END



		IF (@message = '''')
		BEGIN
			SET @no = 0
			SET @oNa = 0 
			SET @oNb = 0
			WHILE (@oNa >= 0) AND (@message = '''')
			BEGIN
	
				SELECT  top 1 
						@oNa = NULLIF(con.query(''ordinalNumber'').value(''.'', ''int''), ''''),
						@source = NULLIF(con.query(''source'').value(''.'', ''int''), 0),
						@debitAccount = NULLIF(con.query(''debitAccount'').value(''.'', ''varchar(100)''),''''),
						@debitAmount = NULLIF(con.query(''debitAmount'').value(''.'', ''varchar(100)''),''''),
						@creditAccount = NULLIF(con.query(''creditAccount'').value(''.'', ''varchar(100)''),''''),
						@creditAmount = NULLIF(con.query(''creditAmount'').value(''.'', ''varchar(100)''),''''),
						@description = NULLIF(con.query(''description'').value(''.'', ''varchar(255)''),''''),
						@condition  = NULLIF(con.query(''condition'').value(''.'', ''varchar(100)''),'''')
				FROM @xmlVar.nodes(''/accountingRule/lines/line'') AS C ( con )
				WHERE ISNULL(con.query(''ordinalNumber'').value(''.'', ''int''),0) > @oNb 
				ORDER BY ISNULL(con.query(''ordinalNumber'').value(''.'', ''int''),0)				
		
				IF (@oNa <> @oNb)
				BEGIN
					SET @oNb = @oNa
					IF (@source = 1)	
					BEGIN
						EXEC accounting.p_parsingPattern @condition, @source, @id, @result OUT, @message OUT

						IF (@message = '''') 
							IF (@result = '''')
							BEGIN	
								SET @no = @no + 1
								EXEC accounting.p_createAccountingEntry 
										@source,
										@id ,
										@id ,
										@no ,
										@debitAccount ,
										@debitAmount ,
										@creditAccount ,
										@creditAmount ,
										@description ,
										@sumAccounting ,
										@message OUT
							END
					END
					ELSE 
					IF (@source = 2)	
					BEGIN

						SELECT @idLine = id FROM document.CommercialDocumentLine WHERE commercialDocumentHeaderId = @id
						IF (@@ROWCOUNT > 0)
							SET @typDoc = ''commercial''
						ELSE
						BEGIN
							SELECT @idLine = id FROM document.WarehouseDocumentLine WHERE warehouseDocumentHeaderId = @id
							IF (@@ROWCOUNT > 0)
								SET @typDoc = ''warehouse''
							ELSE
								SET @message = ''Brak dokumentu id:'' + CAST(@id AS VARCHAR(40))
						END
						IF (@message = '''')
						BEGIN
							SET @indA = ''''
							WHILE (@indA <> ''FINISH'') AND (@message = '''')
							BEGIN
								IF (@typDoc = ''commercial'')
									SELECT Top 1 @idLine = id, @indB = CAST(id AS VARCHAR(36))
									FROM document.CommercialDocumentLine 
									WHERE (commercialDocumentHeaderId = @id) AND (CAST(id AS VARCHAR(36)) > @indA)
									ORDER BY CAST(id AS VARCHAR(36))
								ELSE
									SELECT Top 1 @idLine = id, @indB = CAST(id AS VARCHAR(36))
									FROM document.WarehouseDocumentLine 
									WHERE (warehouseDocumentHeaderId = @id) AND (CAST(id AS VARCHAR(36)) > @indA)
									ORDER BY CAST(id AS VARCHAR(36))
								IF (@indA <> @indB)
								BEGIN
									SET @indA = @indB
									EXEC accounting.p_parsingPattern @condition, @source, @idLine, @result OUT, @message OUT
									IF( (@message = '''') AND (@result = '''') )
									BEGIN	
										SET @no = @no + 1
										EXEC accounting.p_createAccountingEntry 
											@source ,
											@idLine ,
											@id ,
											@no ,
											@debitAccount ,
											@debitAmount ,
											@creditAccount ,
											@creditAmount ,
											@description ,
											@sumAccounting ,
											@message OUT
									END
								END
								ELSE
									SET @indA = ''FINISH''
							END 
						END
					END
					ELSE
					IF (@source = 3)
					BEGIN
						SET @message = ''NIE ZAIMPLEMENTOWANO!''
					END
					ELSE
					IF (@source = 4)	
					BEGIN
						SET @oNDa = 0 
						SET @oNDb = 0
						WHILE (@oNDa >= 0) AND (@message = '''')
						BEGIN
							SELECT Top 1 @idLine = id, @oNDa = v.[order]
							FROM document.CommercialDocumentVatTable v
							WHERE (v.commercialDocumentHeaderId = @id) AND (v.[order] > @oNDb)
							ORDER BY v.[order]

							IF (@oNDa <> @oNDb)
							BEGIN
								SET @oNDb = @oNDa
								SET @no = @no + 1
								EXEC accounting.p_createAccountingEntry 
									@source,
									@idLine,
									@id,
									@no ,
									@debitAccount ,
									@debitAmount ,
									@creditAccount ,
									@creditAmount ,
									@description ,
									@sumAccounting ,
									@message OUT
							END
							ELSE
								SET @oNDa = -1
						END 
					END
					ELSE
						SET @message= ''BŁĄD: '' + @source +'' - nie jest: 1-dokument, 2-pozycje, 3-platnosc, 4-vat!''
				END
				ELSE
					SET @oNa = -1
			END 
			
		END			

		SET @errors = @message

		set @indexOrder = 0
		UPDATE accounting.AccountingEntries
		SET @indexOrder = @indexOrder+1, [order] = @indexOrder
		WHERE documentHeaderId = @id
		
	
		DROP TABLE ##ExchangeTemp
    
    END



/****** Object:  StoredProcedure [accounting].[p_createAccountingEntry]    Script Date: 11/19/2009 11:14:31 ******/
SET ANSI_NULLS ON
' 
END
GO

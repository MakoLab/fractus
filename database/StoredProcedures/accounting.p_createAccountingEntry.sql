/*
name=[accounting].[p_createAccountingEntry]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
1LJ69SqvZcgv5+nYZOOzSA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_createAccountingEntry]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_createAccountingEntry]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_createAccountingEntry]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [accounting].[p_createAccountingEntry]
( 
	@source			int				 ,		
	@id				UNIQUEIDENTIFIER ,		
	@idDocument		UNIQUEIDENTIFIER ,		
	@order			int ,					
	@debitAccount	varchar(100) ,			
	@debitAmount	varchar(100) ,			
	@creditAccount	varchar(100) ,			
	@creditAmount	varchar(100) ,			
	@description	varchar(255) ,			
	@sumAccounting	smallint 	 ,			
	@message		varchar(200) OUT		
)
AS
BEGIN

	DECLARE @resultDebitAccount		varchar(100) 
	DECLARE @resultDebitAmount		varchar(100) 
	DECLARE @resultCreditAccount	varchar(100) 
	DECLARE @resultCreditAmount		varchar(100) 
	DECLARE @resultDescription		varchar(255) 
	DECLARE @resultCondition		varchar(100) 

	DECLARE @valueDebitAmount		numeric(18,2)
	DECLARE @valueCreditAmount		numeric(18,2)

	
	EXEC [accounting].[p_parsingPattern]
			@debitAccount ,
			@source , 
			@id ,
			@resultDebitAccount OUT,
			@message OUT

	IF (@message = '''')
		EXEC [accounting].[p_parsingPattern]
				@debitAmount , 
				@source , 
				@id ,
				@resultDebitAmount OUT,
				@message OUT

	IF (@message = '''')
		EXEC [accounting].[p_parsingPattern]
				@creditAccount , 
				@source , 
				@id ,
				@resultCreditAccount OUT,
				@message OUT

	IF (@message = '''')
		EXEC [accounting].[p_parsingPattern]
				@creditAmount , 
				@source , 
				@id ,
				@resultCreditAmount OUT,
				@message OUT

	IF (@message = '''')
		EXEC [accounting].[p_parsingPattern]
				@description ,
				@source ,  
				@id ,
				@resultDescription OUT,
				@message OUT

	IF (@message = '''')
	BEGIN
		BEGIN TRY
			IF (@resultDebitAmount = '''')
				SET @valueDebitAmount = 0
			ELSE
				SET @valueDebitAmount = CAST( @resultDebitAmount AS numeric(18,2) )
			IF (@resultCreditAmount = '''')
				SET @valueCreditAmount = 0
			ELSE
				SET @valueCreditAmount = CAST( @resultCreditAmount AS numeric(18,2) )
		END TRY
		BEGIN CATCH
			SET @message = ''Błąd kwoty: '' + @resultDebitAmount + '' lub '' + @resultCreditAmount
		END CATCH
	END

	IF (@message = '''')
		IF (@sumAccounting = 1)
			IF(EXISTS(
				SELECT * 
				FROM [accounting].[AccountingEntries] 
				WHERE (documentHeaderId = @idDocument) AND (debitAccount = @resultDebitAccount) AND (creditAccount = @resultCreditAccount)
				)
			)
				UPDATE [accounting].[AccountingEntries]
				SET debitAmount = debitAmount + @valueDebitAmount,
					creditAmount = creditAmount + @valueCreditAmount
				WHERE (documentHeaderId = @idDocument) AND (debitAccount = @resultDebitAccount) AND (creditAccount = @resultCreditAccount)
			ELSE
				INSERT INTO [accounting].[AccountingEntries] 
					(	
						[documentHeaderId],
						[order],
						[debitAccount],
						[debitAmount],
						[creditAccount],
						[creditAmount],
						[description]
					)
				VALUES (
						@idDocument,
						@order,
						@resultDebitAccount,
 						@valueDebitAmount,
						@resultCreditAccount,
						@valueCreditAmount,
						@resultDescription
						)
		ELSE
			INSERT INTO [accounting].[AccountingEntries] 
				(	
					[documentHeaderId],
					[order],
					[debitAccount],
					[debitAmount],
					[creditAccount],
					[creditAmount],
					[description]
				)
			VALUES (
					@idDocument,
					@order,
					@resultDebitAccount,
 					@valueDebitAmount,
					@resultCreditAccount,
					@valueCreditAmount,
					@resultDescription
					)	
END



/****** Object:  StoredProcedure [accounting].[p_getAccountingEntries]    Script Date: 11/19/2009 11:14:58 ******/
SET ANSI_NULLS ON



/****** Object:  StoredProcedure [accounting].[p_getAccountingEntries]    Script Date: 02/25/2010 15:23:49 ******/
SET ANSI_NULLS ON

' 
END
GO

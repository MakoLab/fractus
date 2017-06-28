/*
name=[document].[p_insertFinancialDocumentHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
3ZwcJvPYrFw6Wm4Fuy1aig==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertFinancialDocumentHeader]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertFinancialDocumentHeader]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertFinancialDocumentHeader]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_insertFinancialDocumentHeader]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
		@applicationUserId UNIQUEIDENTIFIER,
		@numberSettingsId UNIQUEIDENTIFIER,
		@seriesId UNIQUEIDENTIFIER,
		@seriesValue VARCHAR(100),
		@number_new VARCHAR(50),
		@number INT,
		@snap XML,
        @localTransactionId UNIQUEIDENTIFIER,
        @deferredTransactionId UNIQUEIDENTIFIER,
		@databaseId UNIQUEIDENTIFIER,
		@format VARCHAR(50),
		@formatedNumber  VARCHAR(50)
		
    
	/* Formatowanie numeru*/
	SELECT @format = textValue FROM configuration.Configuration WHERE [key] like ''document.sequentialNumberLong''



	/*Pobieram dane o operacji z XML*/
    SELECT  @seriesId = NULLIF(con.value(''(seriesId)[1]'', ''char(36)''), ''''),
			@number = NULLIF(con.value(''(number)[1]'', ''int''), ''''),
            @seriesValue = con.value(''(seriesValue)[1]'', ''varchar(100)''),
            @numberSettingsId = NULLIF(con.value(''(numberSettingId)[1]'', ''char(36)''),'''')
    FROM    @xmlVar.nodes(''root/financialDocumentHeader/entry'') AS C ( con ) 
	
	SELECT
			@localTransactionId = NULLIF(x.value(''@localTransactionId'', ''char(36)''), ''''),
			@deferredTransactionId = NULLIF(x.value(''@deferredTransactionId'', ''char(36)''), ''''),
			@databaseId = NULLIF(x.value(''@databaseId'', ''char(36)''), '''')
	FROM @xmlVar.nodes(''root'') AS a ( x )

	/*Jeśli numer i seria są przekazane, następuje aktualizacja lastNumber w tabeli series*/
	IF @number IS NULL AND @seriesId IS NULL
		BEGIN


			/*Aktualizacja numeru serii*/
			UPDATE [document].[Series] WITH(TABLOCK)
			SET lastNumber = lastNumber + 1 
			WHERE Series.numberSettingId = @numberSettingsId
				AND Series.seriesValue = @seriesValue


			/*Wstawienie nowej serii numeracji*/
			IF @@rowcount = 0
				BEGIN

					SELECT  @seriesId = NEWID(),
							@number = 1

					/*Dodanie wpisu o nowej serii numeracji*/
					INSERT  INTO [document].[Series] ([id],[numberSettingId],[seriesValue],[lastNumber]	)
					SELECT  @seriesId, @numberSettingsId, @seriesValue,	@number
				
					/*Tworzenie obrazu series*/
					SELECT @snap = ( SELECT	( SELECT	''insert'' AS ''@action'',
														@seriesId AS id,
														@numberSettingsId AS numberSettingId,
														@seriesValue AS seriesValue,
														@number AS lastNumber
											  FOR XML PATH(''entry''),TYPE
											)
									FOR XML PATH(''series''),	ROOT(''root'')
								)

					/*Wstawienie danych*/
					INSERT  INTO communication.OutgoingXmlQueue ( id,localTransactionId,deferredTransactionId,[type],[xml],creationDate )
					SELECT  NEWID(),@localTransactionId, @deferredTransactionId,''Series'',@snap, GETDATE()
			
			END
		ELSE
			BEGIN

				/*Pobranie numeru serii*/
				SELECT  @seriesId = id , @number = lastNumber
				FROM    [document].Series 
				WHERE   Series.numberSettingId = @numberSettingsId
					AND Series.seriesValue = @seriesValue

			END
		END
	ELSE
		BEGIN
			/*Aktualizacja numeru serii*/
			UPDATE [document].[Series] WITH(ROWLOCK)
			SET lastNumber = @number
			WHERE id = @seriesId
			
		END

	/*Formatowanie numeru*/
	SELECT @formatedNumber = dbo.xp_format(@format, ISNULL(@number,1))

	/*Pobranie użytkownika aplikacji*/
    SELECT  @applicationUserId = a.value(''@applicationUserId'', ''char(36)'')
    FROM    @xmlVar.nodes(''root'') AS x ( a )


	/*Wstawienie danych o nagłówku dokumentu*/
	INSERT INTO [document].[FinancialDocumentHeader] ([id],[status],[branchId],[companyId],[documentTypeId],[contractorId],[contractorAddressId],[number],[fullNumber],[seriesId],[issueDate],[issuingPersonContractorId],[modificationDate],[modificationApplicationUserId],[amount],[version], [xmlConstantData],[financialReportId],[documentCurrencyId],[systemCurrencyId])
    SELECT  con.value(''(id)[1]'', ''char(36)''),
            con.value(''(status)[1]'', ''int''),
            NULLIF(con.value(''(branchId)[1]'', ''char(36)''),''''),
            NULLIF(con.value(''(companyId)[1]'', ''char(36)''),''''),
            con.value(''(documentTypeId)[1]'', ''char(36)''),
            NULLIF(con.value(''(contractorId)[1]'', ''char(36)''),''''),
			NULLIF(con.value(''(contractorAddressId)[1]'', ''char(36)''),''''),
            @number,
			REPLACE(con.value(''(fullNumber)[1]'', ''nvarchar(200)''),''[SequentialNumber]'',@formatedNumber),
            ISNULL(NULLIF(con.value(''(seriesId)[1]'', ''char(36)''),''''),@seriesId),
            con.value(''(issueDate)[1]'', ''datetime''),
            NULLIF(con.value(''(issuingPersonContractorId)[1]'', ''char(36)''),''''),
            NULLIF(con.value(''(modificationDate)[1]'', ''datetime''),''''),
            NULLIF(con.value(''(modificationApplicationUserId)[1]'', ''char(36)''),''''),
            con.value(''(amount)[1]'', ''numeric(18,2)''),
			con.value(''(version)[1]'', ''char(36)''),
            CASE WHEN con.exist(''xmlConstantData'') = 1
                 THEN con.query(''xmlConstantData/*'')
                 ELSE NULL
            END,
            con.value(''(financialReportId)[1]'', ''char(36)''),
            con.value(''(documentCurrencyId)[1]'', ''char(36)''),
            con.value(''(systemCurrencyId)[1]'', ''char(36)'')
    FROM    @xmlVar.nodes(''/root/financialDocumentHeader/entry'') AS C ( con )


	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN

            SET @errorMsg = ''Błąd wstawiania danych table:FinancialDocumentHeader; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            IF @rowcount = 0 
                RAISERROR ( 50011, 16, 1 ) ;
        END
' 
END
GO

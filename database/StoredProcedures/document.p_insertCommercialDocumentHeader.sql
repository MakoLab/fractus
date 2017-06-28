/*
name=[document].[p_insertCommercialDocumentHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dizILVp0BD0i6BzDzCK/YQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertCommercialDocumentHeader]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertCommercialDocumentHeader]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertCommercialDocumentHeader]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [document].[p_insertCommercialDocumentHeader]
@xmlVar XML
AS
  
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
		@applicationUserId UNIQUEIDENTIFIER,
		@numberSettingsId UNIQUEIDENTIFIER,
		@seriesId UNIQUEIDENTIFIER,
		@seriesValue VARCHAR(100),
		@number INT,
		@snap XML,
        @localTransactionId UNIQUEIDENTIFIER,
        @deferredTransactionId UNIQUEIDENTIFIER,
		@databaseId UNIQUEIDENTIFIER,
		@idoc INT,
		@format VARCHAR(50),
		@formatedNumber  VARCHAR(50)

	DECLARE @tmp_CommercialDocumentHeader TABLE (id uniqueidentifier ,  documentTypeId uniqueidentifier ,  contractorId uniqueidentifier ,  companyId uniqueidentifier ,  branchId uniqueidentifier ,  receivingPersonContractorId uniqueidentifier ,  issuingPersonContractorId uniqueidentifier ,  issuerContractorId uniqueidentifier ,  contractorAddressId uniqueidentifier ,  issuerContractorAddressId uniqueidentifier ,  documentCurrencyId uniqueidentifier ,  systemCurrencyId uniqueidentifier ,  exchangeDate datetime ,  exchangeScale numeric(18,0) ,  exchangeRate numeric(18,6) ,  number int ,  fullNumber nvarchar(50) ,  issuePlaceId uniqueidentifier ,  issueDate datetime ,  eventDate datetime ,  netValue numeric(18,2) ,  grossValue numeric(18,2) ,  vatValue numeric(18,2) ,  xmlConstantData xml ,  printDate datetime ,  isExportedForAccounting bit ,  netCalculationType bit ,  vatRatesSummationType bit ,  creationDate datetime ,  modificationDate datetime ,  modificationApplicationUserId uniqueidentifier ,  version uniqueidentifier ,  seriesId uniqueidentifier ,  status int ,  sysNetValue numeric(18,2) ,  sysGrossValue numeric(18,2) ,  sysVatValue numeric(18,2) )

	/* Formatowanie numeru*/
	SELECT @format = textValue FROM configuration.Configuration WHERE [key] like ''document.sequentialNumberLong''


	/*Pobieram dane o operacji z XML*/
    SELECT  @number =  con.value(''(number)[1]'', ''int''),
			@seriesId = NULLIF(con.value(''(seriesId)[1]'', ''char(36)''), ''''),
            @seriesValue = con.value(''(seriesValue)[1]'', ''varchar(100)''),
            @numberSettingsId = NULLIF(con.value(''(numberSettingId)[1]'', ''char(36)''),'''')
    FROM    @xmlVar.nodes(''root/commercialDocumentHeader/entry'') AS C ( con ) 

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
			IF @@rowcount = 0 AND @numberSettingsId IS NOT NULL
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

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

		INSERT INTO @tmp_CommercialDocumentHeader ([id],  [documentTypeId],  [contractorId],  [companyId],  [branchId],  [receivingPersonContractorId],  [issuingPersonContractorId],  [issuerContractorId],  [contractorAddressId],  [issuerContractorAddressId],  [documentCurrencyId],  [systemCurrencyId],  [exchangeDate],  [exchangeScale],  [exchangeRate],  [number],  [fullNumber],  [issuePlaceId],  [issueDate],  [eventDate],  [netValue],  [grossValue],  [vatValue],  [xmlConstantData],  [printDate],  [isExportedForAccounting],  [netCalculationType],  [vatRatesSummationType],  [creationDate],  [modificationDate],  [modificationApplicationUserId],  [version],  [seriesId],  [status],  [sysNetValue],  [sysGrossValue],  [sysVatValue]) 
		SELECT [id],  [documentTypeId],  [contractorId],  [companyId],  [branchId],  [receivingPersonContractorId],  [issuingPersonContractorId],  [issuerContractorId],  [contractorAddressId],  
		[issuerContractorAddressId],  [documentCurrencyId],  [systemCurrencyId],  [exchangeDate],  [exchangeScale],  [exchangeRate],  [number],  [fullNumber],  [issuePlaceId],  [issueDate],  
		[eventDate],  [netValue],  [grossValue],  [vatValue], [xmlConstantData].query(''xmlConstantData/*'') ,  [printDate],  [isExportedForAccounting],  [netCalculationType],  [vatRatesSummationType],  [creationDate],  
		[modificationDate],  [modificationApplicationUserId],  [version],  [seriesId],  [status],  [sysNetValue],  [sysGrossValue],  [sysVatValue]
		FROM OPENXML(@idoc, ''/root/commercialDocumentHeader/entry'')
				WITH(
							id uniqueidentifier ''id'' ,  
							documentTypeId uniqueidentifier ''documentTypeId'' ,  
							contractorId uniqueidentifier ''contractorId'' ,  
							companyId uniqueidentifier ''companyId'' ,  
							branchId uniqueidentifier ''branchId'' ,  
							receivingPersonContractorId uniqueidentifier ''receivingPersonContractorId'' ,  
							issuingPersonContractorId uniqueidentifier ''issuingPersonContractorId'' ,  
							issuerContractorId uniqueidentifier ''issuerContractorId'' ,  
							contractorAddressId uniqueidentifier ''contractorAddressId'' ,  
							issuerContractorAddressId uniqueidentifier ''issuerContractorAddressId'' ,  
							documentCurrencyId uniqueidentifier ''documentCurrencyId'' ,  
							systemCurrencyId uniqueidentifier ''systemCurrencyId'' ,  
							exchangeDate datetime ''exchangeDate'' ,  
							exchangeScale numeric(18,0) ''exchangeScale'' ,  
							exchangeRate numeric(18,6) ''exchangeRate'' ,  
							number int ''number'' ,  
							fullNumber nvarchar(50) ''fullNumber'' ,  
							issuePlaceId uniqueidentifier ''issuePlaceId'' ,  
							issueDate datetime ''issueDate'' ,  
							eventDate datetime ''eventDate'' ,  
							netValue numeric(18,2) ''netValue'' ,  
							grossValue numeric(18,2) ''grossValue'' ,  
							vatValue numeric(18,2) ''vatValue'' ,  
							xmlConstantData xml ''xmlConstantData'' ,  
							printDate datetime ''printDate'' ,  
							isExportedForAccounting bit ''isExportedForAccounting'' ,  
							netCalculationType bit ''netCalculationType'' ,  
							vatRatesSummationType bit ''vatRatesSummationType'' ,  
							creationDate datetime ''creationDate'' ,  
							modificationDate datetime ''modificationDate'' ,  
							modificationApplicationUserId uniqueidentifier ''modificationApplicationUserId'' ,  
							version uniqueidentifier ''version'' ,  
							seriesId uniqueidentifier ''seriesId'' ,  
							status int ''status'' ,  
							sysNetValue numeric(18,2) ''sysNetValue'' ,  
							sysGrossValue numeric(18,2) ''sysGrossValue'' ,  
							sysVatValue numeric(18,2) ''sysVatValue'' 
			)

	/*Wstawienie danych o nagłówku dokumentu*/
	INSERT INTO  [document].[CommercialDocumentHeader] ([id],  [documentTypeId],  [contractorId],  [companyId],  [branchId],  [receivingPersonContractorId],  [issuingPersonContractorId],  [issuerContractorId],  [contractorAddressId],  [issuerContractorAddressId],  [documentCurrencyId],  [systemCurrencyId],  [exchangeDate],  [exchangeScale],  [exchangeRate],  [number],  [fullNumber],  [issuePlaceId],  [issueDate],  [eventDate],  [netValue],  [grossValue],  [vatValue],  [xmlConstantData],  [printDate],  [isExportedForAccounting],  [netCalculationType],  [vatRatesSummationType],  [creationDate],  [modificationDate],  [modificationApplicationUserId],  [version],  [seriesId],  [status],  [sysNetValue],  [sysGrossValue],  [sysVatValue]) 
	SELECT [id],  [documentTypeId],  [contractorId],  [companyId],  [branchId],  [receivingPersonContractorId],  [issuingPersonContractorId],  
			[issuerContractorId],  [contractorAddressId],  [issuerContractorAddressId],  [documentCurrencyId],  [systemCurrencyId],  [exchangeDate],  
			[exchangeScale],  [exchangeRate], @number [number],  
			REPLACE([fullNumber],''[SequentialNumber]'',@formatedNumber) 
			,  [issuePlaceId],  [issueDate],  [eventDate],  [netValue],  
			[grossValue],  [vatValue],  [xmlConstantData],  [printDate],  [isExportedForAccounting],  [netCalculationType],  [vatRatesSummationType],  
			ISNULL([creationDate],GETDATE()),  [modificationDate],  ISNULL([modificationApplicationUserId],@applicationUserId),  [version],  @seriesId [seriesId],  [status],  
			[sysNetValue] =  ISNULL(x.sysNetValue, (x.netValue *  x.exchangeRate)/ x.exchangeScale),
			[sysGrossValue] =  ISNULL(x.sysGrossValue, (x.grossValue * x.exchangeRate)/x.exchangeScale),
			[sysVatValue] =  ISNULL(x.sysVatValue, (x.vatValue * x.exchangeRate) / x.exchangeScale)
    FROM   @tmp_CommercialDocumentHeader x


	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT

	EXEC sp_xml_removedocument @idoc
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:CommercialDocumentHeader; error:''
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

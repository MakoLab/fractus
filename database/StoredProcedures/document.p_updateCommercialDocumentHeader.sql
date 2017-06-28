/*
name=[document].[p_updateCommercialDocumentHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
C5rFFvm2FGjwlST9AVrs6Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateCommercialDocumentHeader]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateCommercialDocumentHeader]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateCommercialDocumentHeader]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_updateCommercialDocumentHeader]
@xmlVar XML
AS
BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT,
            @applicationUserId UNIQUEIDENTIFIER,
			@idoc INT,
			@id UNIQUEIDENTIFIER,
			@newNumber INT,
			@oldNumber INT,
			@newDate DATETIME,
			@oldDate DATETIME,
			@series UNIQUEIDENTIFIER,
			@numberSettingId UNIQUEIDENTIFIER,
			@numberFormat VARCHAR(200),
			@seriesFormat VARCHAR(200),
			@seriesValue VARCHAR(200),
			@dtSymbol VARCHAR(50),
			@bSymbol VARCHAR(50),
			@oldFullNumber VARCHAR(200),
			@maxLastNumber INT
			

		DECLARE @tmp_CommercialDocumentHeader TABLE (id uniqueidentifier ,  documentTypeId uniqueidentifier ,  contractorId uniqueidentifier ,  companyId uniqueidentifier ,  branchId uniqueidentifier ,  receivingPersonContractorId uniqueidentifier ,  issuingPersonContractorId uniqueidentifier ,  issuerContractorId uniqueidentifier ,  contractorAddressId uniqueidentifier ,  issuerContractorAddressId uniqueidentifier ,  documentCurrencyId uniqueidentifier ,  systemCurrencyId uniqueidentifier ,  exchangeDate datetime ,  exchangeScale numeric(18,0) ,  exchangeRate numeric(18,6) ,  number int ,  fullNumber nvarchar(50) ,  issuePlaceId uniqueidentifier ,  issueDate datetime ,  eventDate datetime ,  netValue numeric(18,2) ,  grossValue numeric(18,2) ,  vatValue numeric(18,2) ,  xmlConstantData xml ,  printDate datetime ,  isExportedForAccounting bit ,  netCalculationType bit ,  vatRatesSummationType bit ,  creationDate datetime ,  modificationDate datetime ,  modificationApplicationUserId uniqueidentifier ,  version uniqueidentifier ,  seriesId uniqueidentifier ,  status int ,  sysNetValue numeric(18,2) ,  sysGrossValue numeric(18,2) ,  sysVatValue numeric(18,2) , version_ uniqueidentifier)

		/*Pobranie uzytkownika aplikacji*/
        SELECT  @applicationUserId = a.value(''@applicationUserId'', ''char(36)'')
        FROM    @xmlVar.nodes(''root'') AS x ( a )
		
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

		INSERT INTO @tmp_CommercialDocumentHeader ([id],  [documentTypeId],  [contractorId],  [companyId],  [branchId],  [receivingPersonContractorId],  [issuingPersonContractorId],  [issuerContractorId],  [contractorAddressId],  [issuerContractorAddressId],  [documentCurrencyId],  [systemCurrencyId],  [exchangeDate],  [exchangeScale],  [exchangeRate],  [number],  [fullNumber],  [issuePlaceId],  [issueDate],  [eventDate],  [netValue],  [grossValue],  [vatValue],  [xmlConstantData],  [printDate],  [isExportedForAccounting],  [netCalculationType],  [vatRatesSummationType],  [creationDate],  [modificationDate],  [modificationApplicationUserId],  [version],  [seriesId],  [status],  [sysNetValue],  [sysGrossValue],  [sysVatValue], [version_]) 
		SELECT [id],  [documentTypeId],  [contractorId],  [companyId],  [branchId],  [receivingPersonContractorId],  [issuingPersonContractorId],  [issuerContractorId],  [contractorAddressId],  [issuerContractorAddressId],  [documentCurrencyId],  [systemCurrencyId],  [exchangeDate],  [exchangeScale],  [exchangeRate],  [number],  [fullNumber],  [issuePlaceId],  [issueDate],  [eventDate],  [netValue],  [grossValue],  [vatValue], 
		[xmlConstantData].query(''//constant'') [xmlConstantData],  [printDate],  [isExportedForAccounting],  [netCalculationType],  [vatRatesSummationType],  [creationDate],  [modificationDate],  [modificationApplicationUserId],  [version],  [seriesId],  [status],  [sysNetValue],  [sysGrossValue],  [sysVatValue], [_version]
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
							sysVatValue numeric(18,2) ''sysVatValue'' ,
							_version uniqueidentifier ''_version''
			)

			/*Poprawka na zmianę daty dokumentu, nie ma obsługi w kernelu a należ pobrać wolny numer oraz zaktualizować serię dokumentu*/

			SELECT @id = h.id , @oldNumber = h.number, @newNumber = t.number, @oldDate = h.issueDate , @newDate = t.issueDate ,@series = h.seriesId, @dtSymbol =  dt.symbol,
					@bSymbol = b.symbol, @oldFullNumber = h.fullNumber
			FROM  document.CommercialDocumentHeader h 
				JOIN @tmp_CommercialDocumentHeader t ON h.id = t.id
				JOIN dictionary.DocumentType dt ON h.documentTypeId = dt.id
				JOIN dictionary.Branch b ON h.branchId = b.id
		
			IF @oldDate <> @newDate
				BEGIN
					SELECT @numberSettingId = numberSettingId ,@seriesValue = seriesValue FROM document.Series WHERE id = @series
					SELECT @numberFormat = numberFormat, @seriesFormat = seriesFormat FROM dictionary.NumberSetting WHERE id = @numberSettingId
			
					SELECT 
							@seriesFormat = 
										REPLACE(
											REPLACE(
												REPLACE(
														REPLACE(@seriesFormat,''[StrippedDocumentSymbol]'', @dtSymbol),
														''[DocumentMonth]'',MONTH(@newDate)
														),''[DocumentYear]'', YEAR(@newDate)
													), ''[BranchSymbol]'',@bSymbol
												)
					SELECT @maxLastNumber =  1 + (SELECT MAX(LastNumber) FROM document.Series WHERE numberSettingId = @numberSettingId AND seriesValue = @seriesFormat ) 

					SELECT
							@numberFormat = 
										REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
															REPLACE(@numberFormat,''[StrippedDocumentSymbol]'', @dtSymbol),
															''[DocumentMonth]'',MONTH(@newDate)
															),''[DocumentYear]'', YEAR(@newDate)
														), ''[BranchSymbol]'',@bSymbol
													),''[SequentialNumber]'',@maxLastNumber 
												)
			
					IF @seriesFormat <> @seriesValue
						BEGIN
							UPDATE document.Series
								SET seriesValue = @seriesFormat, lastNumber = @maxLastNumber
							WHERE numberSettingId = @numberSettingId AND seriesValue = @seriesFormat

							UPDATE  @tmp_CommercialDocumentHeader 
								SET number = @maxLastNumber, fullNumber = @numberFormat
						END
					ELSE
						/*Jeśli zmiana data dokumentu nie zmienia przynależności serii dokumentu to numer pozostawiam bez zmian */
						BEGIN
							UPDATE @tmp_CommercialDocumentHeader 
								SET number = @oldNumber, fullNumber = @oldFullNumber
							
						END
				END


			
 --exec [tools].[p_crList]  ''CommercialDocumentHeader'' ,''document'',''UPS''    
        
        /*Aktualizacja danych o nagłówku dokumentu handlowego*/
		 UPDATE  y 
        SET y.[id] =  x.id,  
			y.[documentTypeId] =  x.documentTypeId,  
			y.[contractorId] =  x.contractorId,  
			y.[companyId] =  x.companyId,  
			y.[branchId] =  x.branchId,  
			y.[receivingPersonContractorId] =  x.receivingPersonContractorId,  
			y.[issuingPersonContractorId] =  x.issuingPersonContractorId,  
			y.[issuerContractorId] =  x.issuerContractorId,  
			y.[contractorAddressId] =  x.contractorAddressId,  
			y.[issuerContractorAddressId] =  x.issuerContractorAddressId,  
			y.[documentCurrencyId] =  x.documentCurrencyId,  
			y.[systemCurrencyId] =  x.systemCurrencyId,  
			y.[exchangeDate] =  x.exchangeDate,  
			y.[exchangeScale] =  x.exchangeScale,  
			y.[exchangeRate] =  x.exchangeRate,  
			/*Komentarz w momencie nadawania numeru przez insert header*/
			y.[number] =  ISNULL(x.number,y.[number]),  
			y.[fullNumber] =  ISNULL(x.fullNumber,y.[fullNumber] ),
			y.[issuePlaceId] =  x.issuePlaceId,  
			y.[issueDate] =  x.issueDate,  
			y.[eventDate] =  x.eventDate,  
			y.[netValue] =  x.netValue,  
			y.[grossValue] =  x.grossValue,  
			y.[vatValue] =  x.vatValue,  
			y.[xmlConstantData] =  x.xmlConstantData,  
			y.[printDate] =  x.printDate,  
			y.[isExportedForAccounting] =  x.isExportedForAccounting,  
			y.[netCalculationType] =  x.netCalculationType,  
			y.[vatRatesSummationType] =  x.vatRatesSummationType,  
			y.[creationDate] =  ISNULL(x.creationDate, y.[creationDate] ), 
			y.[modificationDate] =  ISNULL(x.modificationDate,  GETDATE()),
			y.[modificationApplicationUserId] =  ISNULL(x.modificationApplicationUserId,  @applicationUserId),
			/*Niestety Arek to zjebał w kernelu i nie bardzo mam czas to odkręcić, różne typy dokumentów innaczej przekazują nową wersję TADA :) */
			y.[version] = CASE WHEN y.[version] = x.version_ THEN x.version ELSE  x.version_ END,  
			-- Szymon mówi że już takiej opcji nie  ma zmianę, Bug 187 z BugTracker
			y.[seriesId] =  ISNULL(x.seriesId,  y.[seriesId]),
			y.[status] =  x.status,  
			y.[sysNetValue] =  ISNULL(x.sysNetValue, (x.netValue *  x.exchangeRate)/ x.exchangeScale),
			y.[sysGrossValue] =  ISNULL(x.sysGrossValue, (x.grossValue * x.exchangeRate)/x.exchangeScale),
			y.[sysVatValue] =  ISNULL(x.sysVatValue, (x.vatValue * x.exchangeRate) / x.exchangeScale)
		FROM [document].CommercialDocumentHeader y JOIN @tmp_CommercialDocumentHeader x ON y.id = x.id
        

		/*Pobranie liczby pozycji*/
        SET @rowcount = @@ROWCOUNT
        
		EXEC sp_xml_removedocument @idoc

		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:CommercialDocumentHeader; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                
                IF @rowcount = 0 
                    RAISERROR ( 50012, 16, 1 ) ;
            END
    END
' 
END
GO

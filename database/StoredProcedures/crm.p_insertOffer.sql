/*
name=[crm].[p_insertOffer]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
vDrAEWRqFveyUWbPuaiPxQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_insertOffer]') AND type in (N'P', N'PC'))
DROP PROCEDURE [crm].[p_insertOffer]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_insertOffer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'





CREATE PROCEDURE [crm].[p_insertOffer] 
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
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
			@idoc int


	/*Pobieram dane o operacji z XML*/
    SELECT  @number =  con.value(''(number)[1]'', ''int''),
			@seriesId = NULLIF(con.value(''(seriesId)[1]'', ''char(36)''), ''''),
            @seriesValue = con.value(''(seriesValue)[1]'', ''varchar(100)''),
            @numberSettingsId = NULLIF(con.value(''(numberSettingId)[1]'', ''char(36)''),'''')
    FROM    @xmlVar.nodes(''root/offer/entry'') AS C ( con ) 

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
print ''test''
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
			/* Aktualizacja numeru serii */
			UPDATE [document].[Series] WITH(ROWLOCK)
			SET lastNumber = @number
			WHERE id = @seriesId
			
		END

	/* Pobranie użytkownika aplikacji */
    SELECT  @applicationUserId = a.value(''@applicationUserId'', ''char(36)'')
    FROM    @xmlVar.nodes(''root'') AS x ( a )


	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
	
      
	INSERT INTO crm.Offer ([id],  [documentTypeId],  [contractorId],  [number],  [fullNumber],  [seriesId],  [statusId],  [issueDate],  [title],  [creationDate],  [modificationDate],  [modificationApplicationUserId],  [creationApplicationUserId],  [version])   
	SELECT [id],  [documentTypeId],  [contractorId],  ISNULL([number],@number),  [fullNumber],  ISNULL([seriesId],@seriesId),  [statusId],  [issueDate],  [title],  [creationDate],  [modificationDate],  [modificationApplicationUserId],  [creationApplicationUserId],  [version] 
	FROM OPENXML(@idoc, ''/root/offer/entry'')
			WITH(
				[id] char(36) ''id'', 
				[documentTypeId] char(36) ''documentTypeId'', 
				[contractorId] char(36) ''contractorId'', 
				[number] int ''number'', 
				[fullNumber] nvarchar(50) ''fullNumber'', 
				[seriesId] char(36) ''seriesId'', 
				[statusId] char(36) ''statusId'', 
				[issueDate] datetime ''issueDate'', 
				[title] varchar(4000) ''title'', 
				[creationDate] datetime ''creationDate'', 
				[modificationDate] datetime ''modificationDate'', 
				[modificationApplicationUserId] char(36) ''modificationApplicationUserId'', 
				[creationApplicationUserId] char(36) ''creationApplicationUserId'', 
				[version] char(36) ''version''
				
			)
  
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
 	EXEC sp_xml_removedocument @idoc
 	   
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:Offer ; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            IF @rowcount = 0 
                RAISERROR ( 50011, 16, 1 ) ;
        END
END
' 
END
GO

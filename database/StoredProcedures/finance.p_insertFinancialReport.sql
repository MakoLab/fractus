/*
name=[finance].[p_insertFinancialReport]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
tuYSeFidtF+D4n7wrPQJ4g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_insertFinancialReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_insertFinancialReport]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_insertFinancialReport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [finance].[p_insertFinancialReport]
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
        @deferredTransactionId UNIQUEIDENTIFIER


	/*Pobieram dane o operacji z XML*/
    SELECT  @number = NULLIF(con.query(''number'').value(''.'', ''int''), ''''),
			@seriesId = NULLIF(con.query(''seriesId'').value(''.'', ''char(36)''), ''''),
            @seriesValue = con.query(''seriesValue'').value(''.'', ''varchar(100)''),
            @numberSettingsId = NULLIF(con.query(''numberSettingId'').value(''.'', ''char(36)''),'''')
    FROM    @xmlVar.nodes(''root/financialReport/entry'') AS C ( con ) 


	IF @number IS NULL AND @seriesId IS NULL
		BEGIN

			/*Pobranie numeru serii*/
			SELECT  @seriesId = id , @number = ISNULL(lastNumber + 1 ,1)  
			FROM    [document].Series 
			WHERE   Series.numberSettingId = @numberSettingsId
				AND Series.seriesValue = @seriesValue


			/*Wstawienie nowej serii numeracji*/
			IF @seriesId IS NULL
				BEGIN

					SELECT  @seriesId = NEWID(),
							@localTransactionId = NEWID(),
							@deferredTransactionId = NEWID(),
							@number = 1

					/*Dodanie wpisu o nowej serii numeracji*/
					INSERT  INTO [document].[Series]( [id], [numberSettingId], [seriesValue],lastNumber)
					SELECT  @seriesId,@numberSettingsId,@seriesValue,@number
				
					/*Tworzenie obrazu series*/
					SELECT @snap = ( SELECT	( SELECT	''insert'' AS ''@action'',
														@seriesId AS id,
														@numberSettingsId AS numberSettingId,
														@seriesValue AS seriesValue,
														@number AS lastNumber
											  FOR XML PATH(''entry''),TYPE
											)
									FOR XML PATH(''series''), ROOT(''root'')
								)

							/*Wstawienie danych*/
					INSERT  INTO communication.OutgoingXmlQueue	( id, localTransactionId, deferredTransactionId,[type],[xml], creationDate )
					SELECT  NEWID(),@localTransactionId,@deferredTransactionId,''Series'',@snap,GETDATE()
			
				END
		ELSE
			/*Aktualizacja numeru serii*/
			UPDATE [document].[Series] WITH(ROWLOCK)
			SET lastNumber = @number
			WHERE id = @seriesId
		END

	/*Aktualizacja numeru serii*/
	UPDATE [document].[Series]
	SET lastNumber = @number
	WHERE id = @seriesId


	/*Pobranie użytkownika aplikacji*/
    SELECT  @applicationUserId = a.value(''@applicationUserId'', ''char(36)'')
    FROM    @xmlVar.nodes(''root'') AS x ( a )

	/*Wstawienie danych o nagłówku dokumentu*/

    INSERT  INTO [finance].[FinancialReport] ([id],[version],[financialRegisterId],[number],[fullNumber],[seriesId],[creatingApplicationUserId],[creationDate],[closingApplicationUserId],[closureDate],[openingApplicationUserId],[openingDate],[initialBalance],[incomeAmount],[outcomeAmount],[isClosed])
    SELECT  con.query(''id'').value(''.'', ''char(36)''),
            con.query(''version'').value(''.'', ''char(36)''),
            con.query(''financialRegisterId'').value(''.'', ''char(36)''),
            @number,
			REPLACE(con.query(''fullNumber'').value(''.'', ''nvarchar(200)''),''[SequentialNumber]'',@number ),
            @seriesId,
            NULLIF(con.query(''creatingApplicationUserId'').value(''.'', ''char(36)''),''''), 
			NULLIF(con.query(''creationDate'').value(''.'', ''datetime''),''''),
            NULLIF(con.query(''closingApplicationUserId'').value(''.'', ''char(36)''),''''),
            NULLIF(con.query(''closureDate'').value(''.'', ''datetime''),''''),
            NULLIF(con.query(''openingApplicationUserId'').value(''.'', ''char(36)''),''''),
			NULLIF(con.query(''openingDate'').value(''.'', ''datetime''),''''),
            con.query(''initialBalance'').value(''.'', ''numeric(18,2)''),
            NULLIF(con.query(''incomeAmount'').value(''.'', ''varchar(50)''),''''),
			NULLIF(con.query(''outcomeAmount'').value(''.'', ''varchar(50)''),''''),
			con.query(''isClosed'').value(''.'', ''bit'')
    FROM    @xmlVar.nodes(''/root/financialReport/entry'') AS C ( con )



	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:FinancialReport; error:''
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

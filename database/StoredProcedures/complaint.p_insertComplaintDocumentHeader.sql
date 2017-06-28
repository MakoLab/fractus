/*
name=[complaint].[p_insertComplaintDocumentHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
/CyqBsngLVSXsgJpuQgZ0A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_insertComplaintDocumentHeader]') AND type in (N'P', N'PC'))
DROP PROCEDURE [complaint].[p_insertComplaintDocumentHeader]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_insertComplaintDocumentHeader]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [complaint].[p_insertComplaintDocumentHeader] 
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
		@databaseId UNIQUEIDENTIFIER


	/*Pobieram dane o operacji z XML*/
    SELECT  @number = NULLIF(con.query(''number'').value(''.'', ''int''), ''''),
			@seriesId = NULLIF(con.query(''seriesId'').value(''.'', ''char(36)''), ''''),
            @seriesValue = con.query(''seriesValue'').value(''.'', ''varchar(100)''),
            @numberSettingsId = NULLIF(con.query(''numberSettingId'').value(''.'', ''char(36)''),'''')
    FROM    @xmlVar.nodes(''root/complaintDocumentHeader/entry'') AS C ( con ) 

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



	/*Odpalić dla inserta do tabeli*/
	INSERT INTO complaint.ComplaintDocumentHeader ([id],  [seriesId],  [fullNumber],  [number],  [documentTypeId],  [issuerContractorId],  [issuerContractorAddressId],  [contractorId],  [contractorAddressId],  [version],[status])   
	SELECT 
		con.query(''id'').value(''.'',''uniqueidentifier'') ,  
		@seriesId,  
		REPLACE(con.query(''fullNumber'').value(''.'', ''nvarchar(200)''),''[SequentialNumber]'',ISNULL(@number,''1'')), 
		@number ,  
		con.query(''documentTypeId'').value(''.'',''uniqueidentifier'') ,  
		NULLIF(con.query(''issuerContractorId'').value(''.'',''char(36)'') ,''''),  
		NULLIF(con.query(''issuerContractorAddressId'').value(''.'',''char(36)''),'''') ,  
		NULLIF(con.query(''contractorId'').value(''.'',''char(36)'') ,''''),  
		NULLIF(con.query(''contractorAddressId'').value(''.'',''char(36)''),'''') ,  
		con.query(''version'').value(''.'',''uniqueidentifier'') ,
		con.query(''status'').value(''.'',''int'') 
	FROM  @xmlVar.nodes(''/root/complaintDocumentHeader/entry'') AS a(con)

				
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:ComplaintDocumentHeader; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
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

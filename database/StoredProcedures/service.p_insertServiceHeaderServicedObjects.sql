/*
name=[service].[p_insertServiceHeaderServicedObjects]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
GQExWKfpyiEDVRAVxyH+FA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_insertServiceHeaderServicedObjects]') AND type in (N'P', N'PC'))
DROP PROCEDURE [service].[p_insertServiceHeaderServicedObjects]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_insertServiceHeaderServicedObjects]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [service].[p_insertServiceHeaderServicedObjects] 
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@idoc int

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
	
	INSERT INTO service.ServiceHeaderServicedObjects ([id],[serviceHeaderId],  [servicedObjectId],  [incomeDate],  [outcomeDate],  [plannedEndDate],  [description],  [ordinalNumber],  [version]) 
	SELECT [id],[serviceHeaderId],  [servicedObjectId],  [incomeDate],  [outcomeDate],  [plannedEndDate],   [description],  [ordinalNumber],  [version]
	FROM OPENXML(@idoc, ''/root/serviceHeaderServicedObjects/entry'')
				WITH(
					id char(36) ''id'',
					serviceHeaderId char(36) ''serviceHeaderId'',
					servicedObjectId char(36) ''servicedObjectId'',
					incomeDate datetime ''incomeDate'',
					outcomeDate datetime ''outcomeDate'',
					plannedEndDate dateTime ''plannedEndDate'',
					description nvarchar(max) ''description'',
					ordinalNumber int ''ordinalNumber'',
					version char(36) ''version''
					)
	EXEC sp_xml_removedocument @idoc

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:ServiceHeaderServicedObjects; error:''
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

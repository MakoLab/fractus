/*
name=[service].[p_insertServiceHeaderServicePlace]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
FqXm+DU5APqoolIKqNpdDQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_insertServiceHeaderServicePlace]') AND type in (N'P', N'PC'))
DROP PROCEDURE [service].[p_insertServiceHeaderServicePlace]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_insertServiceHeaderServicePlace]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [service].[p_insertServiceHeaderServicePlace] 
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@idoc int

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
	INSERT INTO service.ServiceHeaderServicePlace ([id],[serviceHeaderId],  [servicePlaceId],  [workTime],  [timeFraction],  [plannedStartDate],  [plannedEndDate],  [description],  [ordinalNumber],  [version]) 
	SELECT [id],[serviceHeaderId],  [servicePlaceId],  [workTime],  [timeFraction],  [plannedStartDate],  [plannedEndDate],  [description],  [ordinalNumber],  [version]
	FROM OPENXML(@idoc, ''/root/serviceHeaderServicePlace/entry'')
				WITH(
					id char(36) ''id'',
					serviceHeaderId char(36) ''serviceHeaderId'',
					servicePlaceId char(36) ''servicePlaceId'',
					workTime numeric(18,6) ''workTime'',
					timeFraction numeric(18,6) ''timeFraction'',
					plannedStartDate dateTime ''plannedStartDate'',
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
            SET @errorMsg = ''Błąd wstawiania danych table:ServiceHeaderServicePlace; error:''
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

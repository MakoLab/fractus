/*
name=[service].[p_insertServiceHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
mSYdGJI8wg/0DUSO72UH2g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_insertServiceHeader]') AND type in (N'P', N'PC'))
DROP PROCEDURE [service].[p_insertServiceHeader]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_insertServiceHeader]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [service].[p_insertServiceHeader] 
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@idoc int

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
	
	INSERT INTO service.ServiceHeader ([commercialDocumentHeaderId],  [plannedEndDate], [description],  [version], [closureDate]) 
	SELECT [commercialDocumentHeaderId],  [plannedEndDate],    [description],  [version], [closureDate]
	FROM OPENXML(@idoc, ''/root/serviceHeader/entry'')
				WITH(
					commercialDocumentHeaderId char(36) ''commercialDocumentHeaderId'',
					plannedEndDate datetime ''plannedEndDate'',
					description nvarchar(max) ''description'',
					version char(36) ''version'',
					closureDate datetime ''closureDate''
					)
	
	EXEC sp_xml_removedocument @idoc

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:ServiceHeader; error:''
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

/*
name=[service].[p_insertServicedObject]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
qcpuBaA96w/UIB6owyCGUw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_insertServicedObject]') AND type in (N'P', N'PC'))
DROP PROCEDURE [service].[p_insertServicedObject]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_insertServicedObject]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [service].[p_insertServicedObject] 
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@idoc int

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
	
	INSERT INTO service.ServicedObject ([id],  [identifier],  [servicedObjectTypeId],  [ownerContractorId],    [modificationDate],  [version], [remarks], [description])   
	SELECT [id],  [identifier],  [servicedObjectTypeId],  [ownerContractorId],    [modificationDate],  [version], [remarks], [description]
	FROM OPENXML(@idoc, ''/root/servicedObject/entry'')
				WITH(
						id char(36) ''id'' ,  
						identifier nvarchar(50) ''identifier'' ,  
						servicedObjectTypeId char(36) ''servicedObjectTypeId'' ,  
						ownerContractorId char(36) ''ownerContractorId'' ,  
						modificationDate datetime ''modificationDate'' ,  
						version char(36) ''version'', 
						remarks nvarchar(500) ''remarks'',
						description nvarchar(500) ''description''  
					)
	EXEC sp_xml_removedocument @idoc

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:ServicedObject; error:''
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

/*
name=[document].[p_insertDraft]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fSlJ2ayR1REhn1ofHRINgQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertDraft]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertDraft]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertDraft]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_insertDraft] 
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
			@idoc int,
			@id uniqueidentifier


	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
	
	SELECT @id = newid()
      
	INSERT INTO document.Draft ([id],  [documentTypeId],  [date],  [applicationUserId],  [contractorId],  [dataXml])  
	SELECT @id,  [documentTypeId]  ,getdate(),  [applicationUserId],  [contractorId],  [dataXml] 
	FROM OPENXML(@idoc, ''/root/draft/entry'')
				WITH(
				[documentTypeId] char(36) ''documentTypeId'', 
				[applicationUserId] char(36) ''applicationUserId'', 
				[contractorId] char(36) ''contractorId'', 
				[dataXml] xml ''dataXml/*''
			)
  
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
 	EXEC sp_xml_removedocument @idoc
 	   
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:Draft ; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            --RAISERROR ( @errorMsg, 16, 1 )
            SELECT CAST(''<root>'' + @errorMsg + ''</root>'' as XML) returnXml
        END
    ELSE 
        BEGIN
            IF @rowcount = 0 
                RAISERROR ( 50011, 16, 1 ) ;
        END
   SELECT CAST(''<root><id>'' + CAST(@id AS char(36)) + ''</id></root>'' as XML) returnXml
END        
' 
END
GO

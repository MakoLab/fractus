/*
name=[dictionary].[p_insertServicePlace]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
58CMtLECnUjAdoROnoddMw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertServicePlace]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_insertServicePlace]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertServicePlace]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_insertServicePlace] 
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@idoc int

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
	INSERT INTO dictionary.ServicePlace ([id],  [name],  [version],  [order])  
	SELECT [id],  [name],  [version],  [order] 

	FROM OPENXML(@idoc, ''/root/servicePlace/entry'')
				WITH(
						id uniqueidentifier ''id'' ,  
						name nvarchar(100) ''name'' ,  
						version uniqueidentifier ''version'' ,  
						[order] int ''order'' 
					)
	EXEC sp_xml_removedocument @idoc

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:ServicePlace; error:''
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

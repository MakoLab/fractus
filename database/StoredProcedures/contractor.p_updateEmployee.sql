/*
name=[contractor].[p_updateEmployee]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
/TcjmKw5Jrm01zpfeYYqzg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_updateEmployee]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_updateEmployee]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_updateEmployee]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_updateEmployee]
@xmlVar XML
AS
BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT,
			@error int 
    
	BEGIN TRY

        
        
        /*Aktualizacja danych o pracownikach*/
        UPDATE  contractor.Employee
        SET     jobPositionId = con.value(''(jobPositionId)[1]'', ''char(36)'') ,
                [version] =   ISNULL(con.value(''(_version)[1]'', ''char(36)''),con.value(''(version)[1]'', ''char(36)''))
        FROM    @xmlVar.nodes(''/root/employee/entry'') AS C ( con )
        WHERE   Employee.contractorId = con.value(''(contractorId)[1]'', ''char(36)'') 

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT	
        
      END TRY
	BEGIN CATCH
			SELECT @errorMsg = ''BBd wstawiania danych tabela:Employee; error:''
				+ CAST(@@ERROR AS VARCHAR(50)) + '';Procedura:'' + ERROR_PROCEDURE() + '';Linia:'' + CAST(ERROR_LINE() as varchar(50))+ '';Opis:'' + ERROR_MESSAGE() 
            RAISERROR ( @errorMsg, 16, 1)
    END CATCH        
	IF @rowcount = 0 AND @@NESTLEVEL < 4  
		BEGIN
			EXEC contractor.p_insertEmployee @xmlVar
		END
	ELSE IF @rowcount = 0
			BEGIN
				RAISERROR ( 50011, 16, 1 ) ;
			END
    END
' 
END
GO

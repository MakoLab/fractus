/*
name=[contractor].[p_insertApplicationUser]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
UkAmzOR+WvLiTjYZat7X0w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertApplicationUser]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_insertApplicationUser]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertApplicationUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [contractor].[p_insertApplicationUser] @xmlVar XML
AS 
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
			@error int 
    
	BEGIN TRY

 
    /*Wstawienie danych o użytkownikach*/
    INSERT  INTO contractor.ApplicationUser
            (
              contractorId,
              login,
              password,
				permissionProfile,
              version,
              restrictDatabaseId,
			  isActive
            )
            SELECT  NULLIF(con.value(''(contractorId)[1]'', ''char(36)''),''''),
                    NULLIF(con.value(''(login)[1]'', ''nvarchar(50)''), ''''),
                    NULLIF(con.value(''(password)[1]'', ''nvarchar(64)''), ''''),
					NULLIF(con.value(''(permissionProfile)[1]'', ''varchar(100)''), ''''),
                    ISNULL(con.value(''(_version)[1]'', ''char(36)''),con.value(''(version)[1]'', ''char(36)'')),
                    NULLIF(con.value(''(restrictDatabaseId)[1]'', ''char(36)''), ''''),
					NULLIF(con.value(''(isActive)[1]'', ''bit''), '''')
            FROM    @xmlVar.nodes(''/root/applicationUser/entry'') AS C ( con )
			WHERE NULLIF(con.value(''(contractorId)[1]'', ''char(36)''),'''') NOT IN (SELECT contractorId FROM  contractor.ApplicationUser)
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
        
    END TRY
	BEGIN CATCH
			SELECT @errorMsg = ''BBd wstawiania danych tabela:ApplicationUser; error:''
				+ CAST(@@ERROR AS VARCHAR(50)) + '';Procedura:'' + ERROR_PROCEDURE() + '';Linia:'' + CAST(ERROR_LINE() as varchar(50))+ '';Opis:'' + ERROR_MESSAGE() 
            RAISERROR ( @errorMsg, 16, 1)
    END CATCH        
	IF @rowcount = 0 AND @@NESTLEVEL < 4  
		BEGIN
			EXEC contractor.[p_updateApplicationUser] @xmlVar
		END
	ELSE IF @rowcount = 0
			BEGIN
				RAISERROR ( 50011, 16, 1 ) ;
			END
    END
' 
END
GO

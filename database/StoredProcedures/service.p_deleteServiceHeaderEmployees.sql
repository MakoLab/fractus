/*
name=[service].[p_deleteServiceHeaderEmployees]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
MnmN2GfGeWf1+tRqZNFuAQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_deleteServiceHeaderEmployees]') AND type in (N'P', N'PC'))
DROP PROCEDURE [service].[p_deleteServiceHeaderEmployees]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_deleteServiceHeaderEmployees]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [service].[p_deleteServiceHeaderEmployees] @xmlVar XML
AS 
	
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT


    /*Kasowanie danych o ServiceHeaderEmployees*/
    DELETE FROM service.ServiceHeaderEmployees
    WHERE   id IN (
            SELECT  NULLIF(con.value(''.'', ''char(36)''), '''')
            FROM    @xmlVar.nodes(''/root/*/entry/id'') AS C ( con )
             )

	/*Pobieranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            SET @errorMsg = ''Błąd kasowania danych:ServiceHeaderEmployees; error:'' + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            IF @rowcount = 0 
                RAISERROR ( 50012, 16, 1 ) ;
        END
' 
END
GO

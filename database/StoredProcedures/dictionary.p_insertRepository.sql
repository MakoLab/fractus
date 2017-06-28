/*
name=[dictionary].[p_insertRepository]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
SOXmoYVWPqSjt6aLiycB/g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertRepository]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_insertRepository]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertRepository]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_insertRepository]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    
    /*Wstawienie danych o repozytorium plików*/
    INSERT  INTO [dictionary].[Repository] ( id, url, version )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''url'').value(''.'', ''varchar(300)''), ''''),
                    con.query(''version'').value(''.'', ''char(36)'')
            FROM    @xmlVar.nodes(''/root/repository/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Aktualizacja wersji słowników*/
    EXEC [dictionary].[p_updateVersion] ''Repository''
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:Repository; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            
            IF @rowcount = 0 
                RAISERROR ( 50011, 16, 1 ) ;
        END
' 
END
GO

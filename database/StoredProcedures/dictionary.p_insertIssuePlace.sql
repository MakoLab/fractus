/*
name=[dictionary].[p_insertIssuePlace]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
o5wV7YJtPNevBj/mc+FTDg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertIssuePlace]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_insertIssuePlace]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertIssuePlace]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_insertIssuePlace]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    /*Wstawienie danych o miejscach wystawienia*/
    INSERT  INTO [dictionary].[IssuePlace]
            (
              id,
              name,
              version,
              [order]
            )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
                    con.query(''name'').value(''.'', ''varchar(50)''),
                    con.query(''version'').value(''.'', ''char(36)''),
                    con.query(''order'').value(''.'', ''int'')
            FROM    @xmlVar.nodes(''/root/issuePlace/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Aktualizacja miejsc wystawienia*/
    EXEC [dictionary].[p_updateVersion] ''IssuePlace''
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR	<> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:IssuePlace; error:''
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

/*
name=[dictionary].[p_insertBranch]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
otjsIaUGkfW3xwgefpGuXg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertBranch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_insertBranch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertBranch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_insertBranch]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    /*Wstawienie danych o firmach*/
    INSERT  INTO [dictionary].[Branch]
            (
              id,
			  companyId,
			  databaseId,
              xmlLabels,
              version,
              [order],
              symbol
            )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
					con.query(''companyId'').value(''.'', ''char(36)''),
					con.query(''databaseId'').value(''.'', ''char(36)''),
                    con.query(''xmlLabels/*''),
                    con.query(''version'').value(''.'', ''char(36)''),
                    con.query(''order'').value(''.'', ''int''),
                    con.query(''symbol'').value(''.'', ''nvarchar(50)'')
            FROM    @xmlVar.nodes(''/root/branch/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Aktualizacja wersji słowników*/
    EXEC [dictionary].[p_updateVersion] ''Branch''
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:Branch; error:''
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

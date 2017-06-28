/*
name=[dictionary].[p_insertDocumentField]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
KqyYjTekDzcEU7QZoTbr9Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertDocumentField]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_insertDocumentField]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertDocumentField]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_insertDocumentField]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    /*Wstawienie danych o */
    INSERT  INTO [dictionary].[DocumentField]
            (
              id,
              name,
              xmlLabels,
              xmlMetadata,
              version,
              [order]
            )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
                    con.query(''name'').value(''.'', ''varchar(50)''),
                    con.query(''xmlLabels/*''),
                    con.query(''xmlMetadata/*''),
                    con.query(''version'').value(''.'', ''char(36)''),
                    con.query(''order'').value(''.'', ''int'')
            FROM    @xmlVar.nodes(''/root/documentField/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Aktualizacja wersji słowników*/
    EXEC [dictionary].[p_updateVersion] ''DocumentField''
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:DocumentField; error:''
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

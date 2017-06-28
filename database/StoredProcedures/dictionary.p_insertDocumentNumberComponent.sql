/*
name=[dictionary].[p_insertDocumentNumberComponent]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
TMWiTcCjVzggRUlf2S0PSQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertDocumentNumberComponent]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_insertDocumentNumberComponent]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertDocumentNumberComponent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_insertDocumentNumberComponent]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    
    /*Wstawienei danych o komponentach numeracji dokumentów*/
    INSERT  INTO [dictionary].[DocumentNumberComponent]
            (
              id,
              symbol,
              xmlMetadata,
              xmlLabels,
              version,
              [order]
            )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
                    con.query(''symbol'').value(''.'', ''varchar(50)''),
                    con.query(''xmlMetadata/*''),
                    con.query(''xmlLabels/*''),
                    con.query(''version'').value(''.'', ''char(36)''),
                    con.query(''order'').value(''.'', ''int'')
            FROM    @xmlVar.nodes(''/root/documentNumberComponent/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Aktualizacja wersji słowników*/
    EXEC [dictionary].[p_updateVersion] ''DocumentNumberComponent''
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:DocumentNumberComponent; error:''
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

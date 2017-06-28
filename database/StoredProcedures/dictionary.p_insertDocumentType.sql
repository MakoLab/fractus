/*
name=[dictionary].[p_insertDocumentType]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
11hIJ/kfnUh0IZuCgi7asQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertDocumentType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_insertDocumentType]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertDocumentType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_insertDocumentType]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    
    /*Wstawienie danych o typach dokumentów*/
    INSERT  INTO [dictionary].[DocumentType]
            (
              id,
              symbol,
              xmlLabels,
              version,
              [order],
			  documentCategory,
			  xmlOptions
            )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
                    con.query(''symbol'').value(''.'', ''varchar(20)''),
                    con.query(''xmlLabels/*''),
                    con.query(''version'').value(''.'', ''char(36)''),
                    con.query(''order'').value(''.'', ''int''),
					con.query(''documentCategory'').value(''.'', ''int''),
					con.query(''xmlOptions/*'')
            FROM    @xmlVar.nodes(''/root/documentType/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Aktualizacja wersji słowników*/
    EXEC [dictionary].[p_updateVersion] ''DocumentType''
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:DocumentType; error:''
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

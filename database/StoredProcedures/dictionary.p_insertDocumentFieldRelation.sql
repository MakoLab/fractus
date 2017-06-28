/*
name=[dictionary].[p_insertDocumentFieldRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
jBCq5jjzMMwD1ns1xc6dHQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertDocumentFieldRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_insertDocumentFieldRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertDocumentFieldRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_insertDocumentFieldRelation]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    /*Wstawienie danych o powiązaniach pól dodatkowych dokumentu*/
    INSERT  INTO [dictionary].[DocumentFieldRelation]
            (
              id,
              documentFieldId,
              documentTypeId,
              version
            )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''documentFieldId'').value(''.'', ''char(36)''),''''),
                    NULLIF(con.query(''documentTypeId'').value(''.'', ''char(36)''),''''),
                    con.query(''version'').value(''.'', ''char(36)'')
            FROM    @xmlVar.nodes(''/root/documentFieldRelation/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Aktualizacja wersji słowników*/
    EXEC [dictionary].[p_updateVersion] ''DocumentFieldRelation''
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:DocumentFieldRelation; error:''
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

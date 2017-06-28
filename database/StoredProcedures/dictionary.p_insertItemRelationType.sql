/*
name=[dictionary].[p_insertItemRelationType]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
wOv/YcYS8p6FDzr6JLQn/g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertItemRelationType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_insertItemRelationType]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertItemRelationType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_insertItemRelationType]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    

	/*Wstawienie danych o typach relacji towarów*/
    INSERT  INTO [dictionary].[ItemRelationType]
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
            FROM    @xmlVar.nodes(''/root/itemRelationType/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Aktualizacja wersji słownikow*/
    EXEC [dictionary].[p_updateVersion] ''ItemRelationType''
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:ItemRelationType; error:''
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

/*
name=[dictionary].[p_insertItemType]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
5E1BNMkIhfLzaY5zsjgZ4Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertItemType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_insertItemType]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertItemType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_insertItemType]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    
    /*Wstawienie danych o typach towarów*/
    INSERT  INTO [dictionary].[ItemType]
            (
              id,
              name,
              xmlLabels,
              xmlMetadata,
              version,
              [order],
			  isWarehouseStorable
            )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
                    con.query(''name'').value(''.'', ''varchar(50)''),
                    con.query(''xmlLabels/*''),
                    con.query(''xmlMetadata/*''),
                    con.query(''version'').value(''.'', ''char(36)''),
                    con.query(''order'').value(''.'', ''int''),
                    con.query(''isWarehouseStorable'').value(''.'', ''bit'')
            FROM    @xmlVar.nodes(''/root/itemType/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Aktualizacja wersji słowników*/
    EXEC [dictionary].[p_updateVersion] ''ItemType''
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:ItemType; error:''
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

/*
name=[dictionary].[p_insertUnit]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
0cEZk+QHwTeaLrQdxKp8zQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertUnit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_insertUnit]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertUnit]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_insertUnit]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    
    /*Wstawienie danych o jednostkach miar*/
    INSERT  INTO [dictionary].[Unit]
            (
              id,
              unitTypeId,
              conversionRate,
              xmlLabels,
              version,
              [order]
            )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''unitTypeId'').value(''.'', ''char(36)''), ''''),
                    con.query(''conversionRate'').value(''.'', ''numeric(16,8)''),
                    con.query(''xmlLabels/*''),
                    con.query(''version'').value(''.'', ''char(36)''),
                    con.query(''order'').value(''.'', ''int'')
            FROM    @xmlVar.nodes(''/root/unit/entry'') AS C ( con )


	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Aktualizacja wersji słowników*/
    EXEC [dictionary].[p_updateVersion] ''Unit''
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:Unit; error:''
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

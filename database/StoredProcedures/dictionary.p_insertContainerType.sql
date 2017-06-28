/*
name=[dictionary].[p_insertContainerType]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
bkekjqfLk3dHb8IhoiE1bg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertContainerType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_insertContainerType]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertContainerType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_insertContainerType] @xmlVar XML
AS 
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    /*Wstawienie danych o krajach*/
    INSERT  INTO [dictionary].ContainerType
            (
              id,
			  isSlot,
			  isItemContainer,
              xmlLabels,
			  xmlMetadata,
              version,
              [order],
				availability
            )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
                    con.query(''isSlot'').value(''.'', ''bit''),
                    con.query(''isItemContainer'').value(''.'', ''bit''),
                    con.query(''xmlLabels/*''),
					con.query(''xmlMetadata/*''),
                    con.query(''version'').value(''.'', ''char(36)''),
                    con.query(''order'').value(''.'', ''int''),
					con.query(''availability'').value(''.'', ''int'')
            FROM    @xmlVar.nodes(''/root/containerType/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Aktualizacja wersji słowników*/
    EXEC [dictionary].[p_updateVersion] ''ContainerType''
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:ContainerType; error:''
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

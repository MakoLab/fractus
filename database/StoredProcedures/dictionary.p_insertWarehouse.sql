/*
name=[dictionary].[p_insertWarehouse]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
B+WtLXsKMy0gSe9wBFH/xw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertWarehouse]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_insertWarehouse]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertWarehouse]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_insertWarehouse]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    /*Wstawienie danych o magazynach*/
    --INSERT  INTO [dictionary].[Warehouse]
    --        (
    --          id,
    --          symbol,
			 -- branchId,
			 -- valuationMethod,
			 -- isActive,
    --          xmlLabels,
			 -- xmlMetadata,
    --          version,
    --          [order],
			 -- issuePlaceId
    --        )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
                    con.query(''symbol'').value(''.'', ''varchar(5)''),
					con.query(''branchId'').value(''.'', ''char(36)''),
					con.query(''valuationMethod'').value(''.'', ''int''),
					con.query(''isActive'').value(''.'', ''bit''),
                    con.query(''xmlLabels/*''),
					con.query(''xmlMetadata/*''),
                    con.query(''version'').value(''.'', ''char(36)''),
                    con.query(''order'').value(''.'', ''int''),
					con.query(''issuePlaceId'').value(''.'', ''char(36)'')
            FROM    @xmlVar.nodes(''/root/warehouse/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Aktualizacja wersji słowników*/
    EXEC [dictionary].[p_updateVersion] ''Warehouse''
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:Warehouse; error:''
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

/*
name=[dictionary].[p_updateWarehouse]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
UD11EANIgDp6OvMzWOHUuw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateWarehouse]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_updateWarehouse]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateWarehouse]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_updateWarehouse]
@xmlVar XML
AS
BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
        /*Aktualizacja danych o magazynach*/
        UPDATE  dictionary.Warehouse
        SET     symbol = CASE WHEN con.exist(''symbol'') = 1
                              THEN con.query(''symbol'').value(''.'', ''varchar(5)'')
                              ELSE NULL
                         END,
                branchId = CASE WHEN con.exist(''branchId'') = 1
                               THEN con.query(''branchId'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END,
                valuationMethod = CASE WHEN con.exist(''valuationMethod'') = 1
                               THEN con.query(''valuationMethod'').value(''.'', ''int'')
                               ELSE NULL
                          END,
                isActive = CASE WHEN con.exist(''isActive'') = 1
                               THEN con.query(''isActive'').value(''.'', ''bit'')
                               ELSE NULL
                          END,
                xmlLabels = CASE WHEN con.exist(''xmlLabels'') = 1
                                 THEN con.query(''xmlLabels/*'')
                                 ELSE NULL
                            END,
                xmlMetadata = CASE WHEN con.exist(''xmlMetadata'') = 1
                                 THEN con.query(''xmlMetadata/*'')
                                 ELSE NULL
                            END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END,
                [order] = CASE WHEN con.exist(''order'') = 1
                               THEN con.query(''order'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END,
                issuePlaceId = CASE WHEN con.exist(''issuePlaceId'') = 1
                               THEN con.query(''issuePlaceId'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/warehouse/entry'') AS C ( con )
        WHERE   Warehouse.id = con.query(''id'').value(''.'', ''char(36)'')

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
                    RAISERROR ( 50012, 16, 1 ) ;
            END
    END
' 
END
GO

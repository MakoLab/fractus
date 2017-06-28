/*
name=[document].[p_insertCommercialWarehouseValuation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
KfWi3xKpYdGkOr1Spy1l0A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertCommercialWarehouseValuation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertCommercialWarehouseValuation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertCommercialWarehouseValuation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_insertCommercialWarehouseValuation]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    

	/*Wstawienie danych o powiązaniach wycenowych dokumentów handlowych z magazynowymi*/
    INSERT  INTO [document].[CommercialWarehouseValuation]
            (
              id,
              commercialDocumentLineId,
              warehouseDocumentLineId,
			  quantity,
			  [value],
			  price,
			  version
            )
            SELECT  con.query(''id'').value(''.'', ''char(36)''),
                    NULLIF(con.query(''commercialDocumentLineId'').value(''.'', ''char(36)''),''''),
                    con.query(''warehouseDocumentLineId'').value(''.'', ''char(36)''),
                    con.query(''quantity'').value(''.'', ''numeric(18,6)''),
					con.query(''value'').value(''.'', ''numeric(18,2)''),
                    con.query(''price'').value(''.'', ''numeric(18,6)''),
					con.query(''version'').value(''.'', ''char(36)'')
            FROM    @xmlVar.nodes(''/root/commercialWarehouseValuation/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:CommercialWarehouseValuation; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
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

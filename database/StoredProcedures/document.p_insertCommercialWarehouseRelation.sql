/*
name=[document].[p_insertCommercialWarehouseRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
FZJwfL6H9xbHD0WoerAM9A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertCommercialWarehouseRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertCommercialWarehouseRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertCommercialWarehouseRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_insertCommercialWarehouseRelation]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    

	/*Wstawienie danych o powiązaniach dokumentów handlowych z magazynowymi*/
    INSERT  INTO [document].[CommercialWarehouseRelation]
            (
              id,
              commercialDocumentLineId,
              warehouseDocumentLineId,
			  quantity,
			  [value],
			  isValuated,
			  isOrderRelation,
			  isCommercialRelation,
			  isServiceRelation,
			  version
            )
            SELECT  con.query(''id'').value(''.'', ''char(36)''),
                    con.query(''commercialDocumentLineId'').value(''.'', ''char(36)''),
                    con.query(''warehouseDocumentLineId'').value(''.'', ''char(36)''),
                    con.query(''quantity'').value(''.'', ''numeric(18,6)''),
					con.query(''value'').value(''.'', ''numeric(18,2)''),
					con.query(''isValuated'').value(''.'', ''bit''),
					con.query(''isOrderRelation'').value(''.'', ''bit''),
                    con.query(''isCommercialRelation'').value(''.'', ''bit''),
                    con.query(''isServiceRelation'').value(''.'', ''bit''),
					con.query(''version'').value(''.'', ''char(36)'')
            FROM    @xmlVar.nodes(''/root/commercialWarehouseRelation/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:CommercialWarehouseRelation; error:''
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

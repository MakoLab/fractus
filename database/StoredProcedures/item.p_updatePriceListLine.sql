/*
name=[item].[p_updatePriceListLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
3O2ZwNUpJrKS+XnvDSWGbg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updatePriceListLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_updatePriceListLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updatePriceListLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_updatePriceListLine] 
	@xmlVar XML
AS
BEGIN
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT
        
        UPDATE item.PriceListLine
		SET
		[id] =  CASE WHEN con.exist(''id'') = 1 THEN con.query(''id'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
		[priceListHeaderId] =  CASE WHEN con.exist(''priceListHeaderId'') = 1 THEN con.query(''priceListHeaderId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
		[ordinalNumber] =  CASE WHEN con.exist(''ordinalNumber'') = 1 THEN con.query(''ordinalNumber'').value(''.'',''int'') ELSE NULL END ,  
		[itemId] =  CASE WHEN con.exist(''itemId'') = 1 THEN con.query(''itemId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
		[price] =  CASE WHEN con.exist(''price'') = 1 THEN con.query(''price'').value(''.'',''decimal(18,2)'') ELSE NULL END ,  
		[version] =  CASE WHEN con.exist(''_version'') = 1 THEN con.query(''version'').value(''.'',''uniqueidentifier'') ELSE NULL END  
		FROM    @xmlVar.nodes(''/root/priceListLine /entry'') AS C ( con )
        WHERE   PriceListLine.id = con.query(''id'').value(''.'', ''char(36)'')
                AND PriceListLine.version = con.query(''version'').value(''.'', ''char(36)'')
                
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obs?uga błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:PriceListLine ; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            IF @rowcount = 0 
                RAISERROR ( 50011, 16, 1 ) ;
        END
END
' 
END
GO

/*
name=[item].[p_insertPriceListLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
z6u8dPfAaJGHwA4uQMtJxA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertPriceListLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_insertPriceListLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertPriceListLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_insertPriceListLine] 
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
			@idoc int


	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
	
	
	INSERT INTO item.PriceListLine ([id],  [priceListHeaderId],  [ordinalNumber],  [itemId],  [price],  [version])   
	SELECT [id],  [priceListHeaderId],  [ordinalNumber],  [itemId],  [price],  [version] 
	FROM OPENXML(@idoc, ''/root/priceListLine/entry'')
				WITH(
					[id] char(36) ''id'', 
					[priceListHeaderId] char(36) ''priceListHeaderId'', 
					[ordinalNumber] int ''ordinalNumber'', 
					[itemId] char(36) ''itemId'', 
					[price] decimal(18,2) ''price'', 
					[version] char(36) ''version''  
					 )
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
 	EXEC sp_xml_removedocument @idoc
 	   
    /*Obsługa błędów i wyjątków*/
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

/*
name=[item].[p_updateItemAddress]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
nTyamQV6QPNm6/OaDrkp9Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItemAddress]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_updateItemAddress]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItemAddress]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE item.p_updateItemAddress 
	@xmlVar XML
AS
BEGIN
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT
        
        UPDATE item.ItemAddress
		SET
			[itemId] =  CASE WHEN con.exist(''itemId'') = 1 THEN con.query(''itemId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[countryId] =  CASE WHEN con.exist(''countryId'') = 1 THEN con.query(''countryId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[city] =  CASE WHEN con.exist(''city'') = 1 THEN con.query(''city'').value(''.'',''nvarchar(50)'') ELSE NULL END ,  
			[postCode] =  CASE WHEN con.exist(''postCode'') = 1 THEN con.query(''postCode'').value(''.'',''nvarchar(30)'') ELSE NULL END ,  
			[postOffice] =  CASE WHEN con.exist(''postOffice'') = 1 THEN con.query(''postOffice'').value(''.'',''nvarchar(50)'') ELSE NULL END ,  
			[address] =  CASE WHEN con.exist(''address'') = 1 THEN con.query(''address'').value(''.'',''nvarchar(300)'') ELSE NULL END ,  
			[version] =  CASE WHEN con.exist(''_version'') = 1 THEN con.query(''_version'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[order] =  CASE WHEN con.exist(''order'') = 1 THEN con.query(''order'').value(''.'',''int'') ELSE NULL END ,  
			[addressNumber] =  CASE WHEN con.exist(''addressNumber'') = 1 THEN con.query(''addressNumber'').value(''.'',''nvarchar(10)'') ELSE NULL END ,  
			[flatNumber] =  CASE WHEN con.exist(''flatNumber'') = 1 THEN con.query(''flatNumber'').value(''.'',''nvarchar(10)'') ELSE NULL END 
		FROM    @xmlVar.nodes(''/root/itemAddress/entry'') AS C ( con )
        WHERE   ItemAddress.id = con.query(''id'').value(''.'', ''char(36)'')
                AND ItemAddress.version = con.query(''version'').value(''.'', ''char(36)'')
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obs?uga błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:ItemAddress ; error:''
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

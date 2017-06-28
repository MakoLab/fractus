/*
name=[crm].[p_updateOfferLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
hLUoPklqFZBxcswy147tpg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_updateOfferLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [crm].[p_updateOfferLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_updateOfferLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE crm.p_updateOfferLine 
	@xmlVar XML
AS
BEGIN
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT
        
        UPDATE crm.OfferLine
        SET
			[offerId] =  CASE WHEN con.exist(''offerId'') = 1 THEN con.query(''offerId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[ordinalNumber] =  CASE WHEN con.exist(''ordinalNumber'') = 1 THEN con.query(''ordinalNumber'').value(''.'',''int'') ELSE NULL END ,  
			[itemId] =  CASE WHEN con.exist(''itemId'') = 1 THEN con.query(''itemId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[itemVersion] =  CASE WHEN con.exist(''itemVersion'') = 1 THEN con.query(''itemVersion'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[quantity] =  CASE WHEN con.exist(''quantity'') = 1 THEN con.query(''quantity'').value(''.'',''numeric(18,6)'') ELSE NULL END ,  
			[grossValue] =  CASE WHEN con.exist(''grossValue'') = 1 THEN con.query(''grossValue'').value(''.'',''numeric(18,2)'') ELSE NULL END ,  
			[version] =  CASE WHEN con.exist(''version'') = 1 THEN con.query(''version'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[itemName] =  CASE WHEN con.exist(''itemName'') = 1 THEN con.query(''itemName'').value(''.'',''nvarchar(500)'') ELSE NULL END 
		FROM    @xmlVar.nodes(''/root/offerLine/entry'') AS C ( con )
        WHERE   OfferLine.id = con.query(''id'').value(''.'', ''char(36)'')
        
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obs?uga błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:OfferLine ; error:''
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

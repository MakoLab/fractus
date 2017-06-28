/*
name=[item].[p_updatePriceListHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
RTtypNOHWvycIGxrIsJu7A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updatePriceListHeader]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_updatePriceListHeader]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updatePriceListHeader]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [item].[p_updatePriceListHeader] 
	@xmlVar XML
AS
BEGIN
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT
        
        UPDATE item.PriceListHeader
			SET
			[id] =  CASE WHEN con.exist(''id'') = 1 THEN con.query(''id'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[name] =  CASE WHEN con.exist(''name'') = 1 THEN con.query(''name'').value(''.'',''nvarchar(200)'') ELSE NULL END ,  
			--[label] =  CASE WHEN con.exist(''label'') = 1 THEN con.query(''label'').value(''.'',''nvarchar(500)'') ELSE NULL END ,  
			[description] =  CASE WHEN con.exist(''description'') = 1 THEN con.query(''description'').value(''.'',''nvarchar(500)'') ELSE NULL END ,  
			[creationApplicationUserId] =  CASE WHEN con.exist(''creationApplicationUserId'') = 1 THEN con.query(''creationApplicationUserId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[creationDate] =  CASE WHEN con.exist(''creationDate'') = 1 THEN con.query(''creationDate'').value(''.'',''datetime'') ELSE NULL END ,  
			[modificationDate] =  CASE WHEN con.exist(''modificationDate'') = 1 THEN con.query(''modificationDate'').value(''.'',''datetime'') ELSE NULL END ,  
			[modificationApplicationUserId] =  CASE WHEN con.exist(''modificationApplicationUserId'') = 1 THEN con.query(''modificationApplicationUserId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[priceType] =  CASE WHEN con.exist(''priceType'') = 1 THEN con.query(''priceType'').value(''.'',''int'') ELSE NULL END ,  
			[version] =  CASE WHEN con.exist(''_version'') = 1 THEN con.query(''version'').value(''.'',''uniqueidentifier'') ELSE NULL END 
	    FROM    @xmlVar.nodes(''/root/priceListHeader/entry'') AS C ( con )
        WHERE   PriceListHeader.id = con.query(''id'').value(''.'', ''char(36)'')
                AND PriceListHeader.version = con.query(''version'').value(''.'', ''char(36)'')

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obs?uga błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:PriceListHeader ; error:''
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

/*
name=[item].[p_insertItemAddress]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
8mbkb32WN/jU27Rbpa/zSA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertItemAddress]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_insertItemAddress]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertItemAddress]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE item.p_insertItemAddress 
	@xmlVar XML
AS
BEGIN
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

	INSERT INTO item.ItemAddress ([id],  [itemId],  [countryId],  [city],  [postCode],  [postOffice],  [address],  [version],  [order],  [addressNumber],  [flatNumber])   
	SELECT NULLIF(x.value(''(id)[1]'',''char(36)'') ,''''),  
		NULLIF(x.value(''(itemId)[1]'',''char(36)'') ,''''),  
		NULLIF(x.value(''(countryId)[1]'',''char(36)'') ,''''),  
		NULLIF(x.value(''(city)[1]'',''nvarchar(50)'') ,''''),  
		NULLIF(x.value(''(postCode)[1]'',''nvarchar(30)'') ,''''), 
		NULLIF(x.value(''(postOffice)[1]'',''nvarchar(50)'') ,''''),  
		NULLIF(x.value(''(address)[1]'',''nvarchar(300)'') ,''''),  
		NULLIF(x.value(''(version)[1]'',''char(36)'') ,''''),  
		NULLIF(x.value(''(order)[1]'',''int'') ,''''),  
		NULLIF(x.value(''(addressNumber)[1]'',''nvarchar(10)'') ,''''),  
		NULLIF(x.value(''(flatNumber)[1]'',''nvarchar(10)'') ,'''')  
	FROM @xmlVar.nodes(''root'') as a(x) 
  
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obs?uga b??dów i wyj?tków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''B??d wstawiania danych table:ItemAddress ; error:''
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

/*
name=[item].[p_insertPriceListHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JGp7Xxx+cNQxWBWW+SLDCQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertPriceListHeader]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_insertPriceListHeader]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertPriceListHeader]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_insertPriceListHeader]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT


	/*Wstawienie danych o nagłówku dokumentu*/
	INSERT INTO item.PriceListHeader ([id],  [name],    [description],  [creationApplicationUserId],  [creationDate],  [modificationDate],  [modificationApplicationUserId],  [priceType],  [version], [label])   
	SELECT 
		NULLIF(con.query(''id'').value(''.'',''char(36)''),'''') ,  
		con.query(''name'').value(''.'',''nvarchar(200)'') ,  
		--con.query(''label'').value(''.'',''nvarchar(200)'') ,  
		con.query(''description'').value(''.'',''nvarchar(500)'') ,  
		con.query(''creationApplicationUserId'').value(''.'',''char(36)'') ,  
		ISNULL(NULLIF(con.query(''creationDate'').value(''.'',''datetime'') ,''''),getdate()),  
		con.query(''modificationDate'').value(''.'',''datetime'') , 
		NULLIF(con.query(''modificationApplicationUserId'').value(''.'',''char(36)'') ,''''),  
		con.query(''priceType'').value(''.'',''int'') ,  
		NULLIF(con.query(''version'').value(''.'',''char(36)'') ,''''),
		con.query(''label'').value(''.'',''nvarchar(500)'')  
	FROM @xmlVar.nodes(''root/priceListHeader/entry'') as a(con)
	--WHERE con.query(''name'').value(''.'',''nvarchar(200)'') NOT IN (SELECT [name] FROM item.PriceListHeader)
	
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:PriceListItemHeader; error:''
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

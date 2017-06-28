/*
name=[document].[p_insertInventorySheet]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
GDS+tizFo+sNKNbeiWmgGg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertInventorySheet]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertInventorySheet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertInventorySheet]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_insertInventorySheet] 
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT

	/*Odpalić dla inserta do tabeli*/
	INSERT INTO document.InventorySheet ([id],  [inventoryDocumentHeaderId],  [ordinalNumber],  [status],  [creationApplicationUserId],  [creationDate],  [modificationApplicationUserId],  [modificationDate],  [closureApplicationUserId],  [closureDate],  [version], [warehouseId])  
	SELECT 
		con.query(''id'').value(''.'',''uniqueidentifier'') ,  
		con.query(''inventoryDocumentHeaderId'').value(''.'',''uniqueidentifier'') ,  
		con.query(''ordinalNumber'').value(''.'',''int'') ,  
		con.query(''status'').value(''.'',''int'') ,  
		con.query(''creationApplicationUserId'').value(''.'',''uniqueidentifier'') ,  
		con.query(''creationDate'').value(''.'',''datetime'') ,  
		NULLIF(con.query(''modificationApplicationUserId'').value(''.'',''char(36)'') ,''''),  
		NULLIF(con.query(''modificationDate'').value(''.'',''datetime'') ,''''),  
		NULLIF(con.query(''closureApplicationUserId'').value(''.'',''char(36)''),'''') ,  
		NULLIF(con.query(''closureDate'').value(''.'',''datetime''), '''') ,  
		con.query(''version'').value(''.'',''uniqueidentifier''),
		NULLIF(con.query(''warehouseId'').value(''.'',''char(36)''),'''')
	FROM  @xmlVar.nodes(''/root/inventorySheet/entry'') as a(con)
				

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:InventorySheet; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
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

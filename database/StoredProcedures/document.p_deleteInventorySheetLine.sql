/*
name=[document].[p_deleteInventorySheetLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
OQv4TlzB6Gwut/4hRxbH/Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteInventorySheetLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_deleteInventorySheetLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteInventorySheetLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_deleteInventorySheetLine] 
	@xmlVar XML
AS 
	
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT


    /*Kasowanie danych o powiązaniach pozycji dokumentu magazynowego*/
    DELETE  FROM  document.InventorySheetLine
    WHERE   id IN (
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''),'''')
            FROM    @xmlVar.nodes(''/root/inventorySheetLine/entry'') AS C ( con )
            WHERE   id = NULLIF(con.query(''id'').value(''.'', ''char(36)''),'''') )

	/*Pobieranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            SET @errorMsg = ''Błąd kasowania danych:InventorySheetLine; error:'' + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            IF @rowcount = 0 
                RAISERROR ( 50012, 16, 1 ) ;
        END
' 
END
GO

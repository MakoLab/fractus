/*
name=[document].[p_updateInventorySheet]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ozie3pL9dja3LwwvhirjHA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateInventorySheet]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateInventorySheet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateInventorySheet]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_updateInventorySheet] 
@xmlVar XML
AS 
    BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT,
            @applicationUserId UNIQUEIDENTIFIER

		/*Pobranie uzytkownika aplikacji*/
        SELECT  @applicationUserId = a.value(''@applicationUserId'', ''char(36)'')
        FROM    @xmlVar.nodes(''root'') AS x ( a )

        /*Aktualizacja danych */
        UPDATE  document.InventorySheet
        SET    
		   [inventoryDocumentHeaderId] =  con.value(''(inventoryDocumentHeaderId)[1]'',''uniqueidentifier'') ,  
		   [ordinalNumber] =   con.value(''(ordinalNumber)[1]'' ,''int'')   ,  
		   [status] =  con.value(''(status)[1]'' ,''int'')   ,  
		   [creationApplicationUserId] =   con.value(''(creationApplicationUserId)[1]'' ,''uniqueidentifier'') ,  
		   [creationDate] = con.value(''(creationDate)[1]'' ,''datetime'') ,  
		   [modificationApplicationUserId] =   con.value(''(modificationApplicationUserId)[1]'' ,''uniqueidentifier'')  ,  
		   [modificationDate] = con.value(''(modificationDate)[1]'' ,''datetime'')   ,  
		   [closureApplicationUserId] =  con.value(''(closureApplicationUserId)[1]'' ,''uniqueidentifier'') ,  
		   [closureDate] =   con.value(''(closureDate)[1]'' ,''datetime'') ,  
		   [version] =    con.value(''(_version)[1]'' ,''uniqueidentifier'') ,
		   [warehouseId] =   con.value(''(warehouseId)[1]'' ,''uniqueidentifier'')                        
        FROM    @xmlVar.nodes(''/root/inventorySheet/entry'') AS C ( con )
        WHERE   InventorySheet.id = con.value(''(id)[1]'', ''char(36)'')
                 


		/*Pobranie liczby pozycji*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:InventorySheet; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                IF @rowcount = 0 
                    RAISERROR ( 50012, 16, 1 ) ;
            END
 END
' 
END
GO

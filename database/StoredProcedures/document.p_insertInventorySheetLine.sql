/*
name=[document].[p_insertInventorySheetLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
M+w95+qef59BgQqkUoME1w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertInventorySheetLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertInventorySheetLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertInventorySheetLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_insertInventorySheetLine] 
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@idoc int

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
	
	INSERT INTO document.InventorySheetLine ([id],  [inventorySheetId],  [ordinalNumber],  [itemId],  [systemQuantity],  [systemDate],  [userQuantity],  [userDate],  [description],  [version], [direction], [unitId])   
	SELECT [id],  [inventorySheetId],  [ordinalNumber],  [itemId],  [systemQuantity],  [systemDate],  [userQuantity],  [userDate],  [description],  [version] , [direction], [unitId]
	FROM OPENXML(@idoc, ''/root/inventorySheetLine/entry'')
				WITH(
						id uniqueidentifier ''id'' ,  
						inventorySheetId uniqueidentifier ''inventorySheetId'' ,  
						ordinalNumber int ''ordinalNumber'' ,  
						itemId uniqueidentifier ''itemId'' ,  
						systemQuantity numeric(18,6) ''systemQuantity'' ,  
						systemDate datetime ''systemDate'' ,  
						userQuantity numeric(18,6) ''userQuantity'' ,  
						userDate datetime ''userDate'' ,  
						[description] nvarchar(1000) ''description'' ,  
						[version] uniqueidentifier ''version'',
						[direction] int ''direction'',
						[unitId] uniqueidentifier ''unitId''
					)
	EXEC sp_xml_removedocument @idoc

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:InventorySheetLine; error:''
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

/*
name=[document].[p_checkInventorySheetVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Uvmg+Ml/IEnfYXq/340MiA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkInventorySheetVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_checkInventorySheetVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkInventorySheetVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_checkInventorySheetVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN
		/*Walidacja wersji*/
        IF NOT EXISTS ( SELECT  id
                        FROM    [document].InventorySheet
                        WHERE   InventorySheet.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO

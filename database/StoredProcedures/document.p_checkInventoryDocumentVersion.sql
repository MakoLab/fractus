/*
name=[document].[p_checkInventoryDocumentVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
LQgBc02TDKfM0XjgBBpADA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkInventoryDocumentVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_checkInventoryDocumentVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkInventoryDocumentVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_checkInventoryDocumentVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN
		/*Walidacja wersji*/
        IF NOT EXISTS ( SELECT  id
                        FROM    [document].InventoryDocumentHeader
                        WHERE   InventoryDocumentHeader.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO

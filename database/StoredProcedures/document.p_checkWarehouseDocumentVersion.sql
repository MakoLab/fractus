/*
name=[document].[p_checkWarehouseDocumentVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
amJCfS5iilOUfP8PyrZMMA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkWarehouseDocumentVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_checkWarehouseDocumentVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkWarehouseDocumentVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_checkWarehouseDocumentVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN
		/*Walidacja wersji*/
        IF NOT EXISTS ( SELECT  id
                        FROM    [document].WarehouseDocumentHeader
                        WHERE   WarehouseDocumentHeader.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO

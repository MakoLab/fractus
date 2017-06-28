/*
name=[communication].[p_getInventoryDocumentPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
iR+IqZyQBjxvN+Asp5+iwg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getInventoryDocumentPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getInventoryDocumentPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getInventoryDocumentPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getInventoryDocumentPackage] @id UNIQUEIDENTIFIER
AS
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @result XML,@rowcount int
		/*Budowanie obrazu danych*/
        SELECT  @result = (  SELECT   ( SELECT    ( 
									SELECT    s.*
												FROM      document.InventoryDocumentHeader  s 
												WHERE     s.id = @id
												FOR XML PATH(''entry''), TYPE
											   )
											   FOR XML PATH(''inventoryDocumentHeader''), TYPE
								   ),(SELECT   (
												SELECT    e.*
												FROM      document.InventorySheet e
												WHERE     e.inventoryDocumentHeaderId = @id
												FOR XML PATH(''entry''), TYPE
											   )
											   FOR XML PATH(''inventorySheet''), TYPE
								   ),(SELECT   (
												SELECT    e.*
												FROM      document.DocumentAttrValue e
												WHERE     e.inventoryDocumentHeaderId = @id
												FOR XML PATH(''entry''), TYPE
											   )
											   FOR XML PATH(''documentAttrValue''), TYPE
								   )
						FOR XML PATH(''root''),TYPE 
						)
        SELECT @rowcount = @@rowcount

        /*Zwrócenie wyników*/                  
        SELECT  @result 

        /*Obsługa pustego resulta*/
        IF @rowcount = 0 
            SELECT  ''''
            FOR     XML PATH(''root''), TYPE
    END
' 
END
GO

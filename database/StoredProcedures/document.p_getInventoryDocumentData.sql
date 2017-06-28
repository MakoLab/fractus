/*
name=[document].[p_getInventoryDocumentData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
NKanwkWfCMWi4AzIQ9ZrTw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getInventoryDocumentData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getInventoryDocumentData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getInventoryDocumentData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getInventoryDocumentData] 
@inventoryDocumentHeaderId uniqueidentifier
AS
BEGIN
SELECT (
	SELECT    ( SELECT    ( 
							SELECT    s.*
							FROM      document.InventoryDocumentHeader  s 
							WHERE     s.id = @inventoryDocumentHeaderId
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''inventoryDocumentHeader''), TYPE
			   ),(SELECT   (
							SELECT    e.*
							FROM      document.InventorySheet e
							WHERE     e.inventoryDocumentHeaderId = @inventoryDocumentHeaderId
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''inventorySheet''), TYPE
			   ),(SELECT   (
							SELECT    e.*
							FROM      document.DocumentAttrValue e
							WHERE     e.inventoryDocumentHeaderId = @inventoryDocumentHeaderId
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''documentAttrValue''), TYPE
			   )
	FOR XML PATH(''root''),TYPE 
) AS returnsXML

END
' 
END
GO

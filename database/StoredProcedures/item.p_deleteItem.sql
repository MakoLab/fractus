/*
name=[item].[p_deleteItem]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
n2VcRQ0eiOyoAiA5hGo2FQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_deleteItem]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_deleteItem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_deleteItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [item].[p_deleteItem]
	@itemId uniqueidentifier
AS
BEGIN	

	 IF @itemId IN (SELECT itemId FROM complaint.ComplaintDocumentLine
					 UNION SELECT itemId FROM item.ItemRelation
					 UNION SELECT itemId FROM document.CommercialDocumentLine
					 UNION SELECT itemId FROM document.WarehouseDocumentLine
					 UNION SELECT itemId FROM dictionary.ItemField
					 --UNION SELECT itemId FROM item.ItemUnitRelation
					 UNION SELECT itemId FROM document.InventorySheetLine
					 UNION SELECT itemId FROM document.WarehouseStock WHERE quantity <> 0
					-- UNION SELECT itemId FROM item.PriceListLine
					 )
					-- UNION SELECT itemId FROM item.ItemAttrValue)
		BEGIN
			UPDATE item.Item SET visible = 0 WHERE id = @itemId
			--RAISERROR ( N''Towar użyty'', 16, 1 )
		END
	ELSE
		DELETE FROM item.PriceListLine WHERE itemId = @itemId	
		DELETE FROM item.ItemAttrValue WHERE itemId = @itemId	
		DELETE FROM item.ItemDictionaryRelation WHERE itemId = @itemId	
		DELETE FROM item.ItemRelation where relatedObjectId =@itemId
		DELETE FROM item.ItemDictionary 
        WHERE   id NOT IN (
						SELECT itemDictionaryId 
						FROM item.ItemDictionaryRelation ir 
						)
		DELETE FROM document.WarehouseStock WHERE itemId = @itemId
		DELETE FROM item.ItemUnitRelation WHERE itemId = @itemId
		DELETE FROM item.Item WHERE id = @itemId
			
END
' 
END
GO

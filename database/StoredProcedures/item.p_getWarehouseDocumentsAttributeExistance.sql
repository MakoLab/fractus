/*
name=[item].[p_getWarehouseDocumentsAttributeExistance]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
jqq+dMY0mbYCuXisNcl2Mw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getWarehouseDocumentsAttributeExistance]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getWarehouseDocumentsAttributeExistance]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getWarehouseDocumentsAttributeExistance]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getWarehouseDocumentsAttributeExistance]
@xmlVar XML
as
BEGIN
	DECLARE @id uniqueidentifier, @name nvarchar(50)
	
	SELECT @id = x.value(''(.)[1]'',''char(36)''),
			@name =  x.value(''(@attributeName)[1]'',''char(36)'')
	FROM @xmlVar.nodes(''root'') as a(x)
	
	
SELECT (
		SELECT 
			CASE WHEN (SELECT TOP 1 v.textValue FROM item.ItemAttrValue v JOIN dictionary.ItemField f ON v.itemFieldId = f.id where f.name = @name AND v.itemId = l.itemId) IS NOT NULL THEN 1 ELSE 0 END AS ''@attributeExistance'', 
			l.itemId ''@itemId'', 
			l.id ''@lineId'', 
			l.quantity ''@quantity''
			,(SELECT v.textValue value FROM item.ItemAttrValue v JOIN dictionary.ItemField f ON v.itemFieldId = f.id where f.name = @name AND v.itemId = l.itemId FOR XML PATH(''''),TYPE)
		FROM document.WarehouseDocumentLine l  
		WHERE l.WarehouseDocumentHeaderId = @id
		GROUP BY  l.itemId,l.id ,  l.quantity
		FOR XML PATH(''line''),TYPE
	) FOR XML PATH(''root''),TYPE
	
END
' 
END
GO

/*
name=[reports].[p_getTop10PopularItems]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Aj1/ZXIaWJZPRZ+K4FVwag==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getTop10PopularItems]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getTop10PopularItems]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getTop10PopularItems]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE reports.p_getTop10PopularItems
@xmlVar XML
AS
BEGIN

	DECLARE @date datetime

	SELECT @date = DATEADD(m,-1,getdate())

	SELECT (
		SELECT top 10 i.name ''@itemName'', q ''@monthQuantity''
		FROM item.Item i WITH(NOLOCK)
			JOIN dictionary.ItemType it WITH(NOLOCK) ON i.itemTypeId = it.id
			JOIN (	SELECT SUM(quantity) q , itemId
					FROM document.CommercialDocumentLine l WITH(NOLOCK)
						JOIN document.CommercialDocumentHeader h WITH(NOLOCK) ON l.commercialDocumentHeaderId = h.id
					WHERE (l.commercialDirection * l.quantity) < 0 
						AND h.issueDate >= @date 
					GROUP BY itemId	) s ON s.itemId = i.id
		WHERE it.isWarehouseStorable = 1
		ORDER BY q DESC			
		FOR XML PATH(''line''), TYPE )
	FOR XML PATH(''line''), TYPE		

END
' 
END
GO

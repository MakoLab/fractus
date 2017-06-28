/*
name=[item].[p_getPriceListDataXML]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
LCa0jCPg1yZoYhk8idm1rg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getPriceListDataXML]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getPriceListDataXML]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getPriceListDataXML]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getPriceListDataXML]
    @xmlVar XML
AS 
    BEGIN
        DECLARE @id UNIQUEIDENTIFIER

		SELECT @id = @xmlVar.value(''.'',''char(36)'')

	SELECT  
		(SELECT (
			SELECT (
				SELECT *
				FROM item.PriceListHeader 
				WHERE id = @id
				FOR XML PATH(''entry''), TYPE )
			FOR XML PATH(''priceListHeader''),TYPE)),
		(SELECT (
			SELECT (
				SELECT l.*, i.name itemName
				FROM item.PriceListLine l
					JOIN item.Item i ON l.itemId = i.id
				WHERE priceListHeaderId = @id
				FOR XML PATH(''entry''), TYPE )
			FOR XML PATH(''priceListLine''),TYPE))
		FOR XML PATH(''root''),TYPE
    END
' 
END
GO

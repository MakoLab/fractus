/*
name=[item].[p_deletePriceList]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ZcfF53aVxT8Wn6f/ARlUNg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_deletePriceList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_deletePriceList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_deletePriceList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_deletePriceList]
	@xmlVar XML
AS
BEGIN	
	/*Procedura do kasowania cenników z customProcedure*/

	DECLARE @tmp TABLE (id uniqueidentifier)

	INSERT INTO @tmp 
	SELECT x.value(''(id)[1]'',''uniqueidentifier'')
	FROM @xmlVar.nodes(''root'') AS a(x)

	DELETE FROM item.PriceListLine WHERE priceListHeaderId IN( SELECT id FROM @tmp)
	DELETE FROM item.PriceListHeader WHERE id IN ( SELECT id FROM @tmp)
	
	SELECT CAST(''<root/>'' as xml) xml
END
' 
END
GO

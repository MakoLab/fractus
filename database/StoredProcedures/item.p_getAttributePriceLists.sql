/*
name=[item].[p_getAttributePriceLists]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JmlQ/MJzxu6HrgYdqFsxpQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getAttributePriceLists]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getAttributePriceLists]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getAttributePriceLists]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getAttributePriceLists] @xmlVar XML
AS
BEGIN
SELECT (
	SELECT id as ''@id'', xmlLabels.value(''(labels/label[@lang="pl"])[1]'',''varchar(50)'') as ''@label'', [order] as ''@ordinalNumer''
	FROM dictionary.ItemField WHERE name like ''Price%''
	FOR XML PATH(''priceListHeader''), TYPE)
 FOR XML PATH(''priceLists'')

END
' 
END
GO

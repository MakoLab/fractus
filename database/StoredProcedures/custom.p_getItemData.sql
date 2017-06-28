/*
name=[custom].[p_getItemData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
/xPwcrYHqdZ4UOj+u39c+Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getItemData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_getItemData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getItemData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [custom].[p_getItemData]
@xmlVar xml
AS

	DECLARE @itemId uniqueidentifier

	SELECT @itemId = @xmlVar.value(''(/*/itemId)[1]'', ''uniqueidentifier'')

	DECLARE @arg xml SET @arg = ''<root><item id="'' + CAST(@itemId AS char(36)) + ''"/></root>''

	DECLARE @deliveries table (x xml)
	INSERT INTO @deliveries
	EXEC item.p_getDeliveriesWithNoLock @arg

	SELECT (
		SELECT
			I.code AS ''code'',
			I.[name] AS ''name'',
			U.xmlLabels.value(''(/labels/label[@lang="pl"]/@symbol)[1]'', ''varchar(100)'') AS ''unit'',
			I.defaultPrice AS ''netPrice'',
			ROUND(V.rate * I.defaultPrice, 2) AS ''grossPrice'',
			(SELECT textValue FROM item.ItemAttrValue FN_V JOIN dictionary.ItemField FN_F ON FN_V.itemFieldId = FN_F.id WHERE FN_V.itemId = I.id AND FN_F.[name] = ''Attribute_FiscalName'') as fiscalName,
			(SELECT x.query(''/root/*'') FROM @deliveries) AS ''deliveries''
		FROM
			item.Item I
			JOIN dictionary.Unit U ON U.id = I.unitId
			JOIN dictionary.VatRate V ON V.id = I.vatRateId
		WHERE I.id = @itemId
		FOR XML PATH (''''), TYPE
	) FOR XML PATH (''item'')
' 
END
GO

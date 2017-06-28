/*
name=[item].[p_getItemsByItemCode]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
jGO8Ny6W0a41gIJXnq7D0Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsByItemCode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemsByItemCode]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsByItemCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getItemsByItemCode] 
@xmlVar XML
AS
BEGIN

	DECLARE @tmp TABLE ( code nvarchar(500))
	DECLARE @client_name NVARCHAR(40)
	--DECLARE @xmlVar XML
	--SET @xmlVar = ''<root><item code="ob2010"/><item code="ow2011"/></root>'';
	INSERT INTO @tmp (code)
	SELECT  x.value(''@code'',''nvarchar(500)'')
	FROM @xmlVar.nodes(''root/item'') as a (x)
		
	/*Pobieranie klienta - dla Unigumu wyszukiwanie odbywa się po kodzie producenta, a nie towaru*/
	SELECT @client_name = shortName
	FROM contractor.Contractor
	WHERE isOwnCompany = 1

	
	IF @client_name = ''PPH UNIGUM Wrotek Zbigniew''
		BEGIN
			SELECT ( 
				SELECT defaultPrice as ''@initialNetPrice'', unitId ''@unitId'', vatRateId as ''@vatRateId'', i.version as ''@version'', [name] as ''@name'', i.id as ''@id'', t.code as ''@code''
				FROM item.Item i
					JOIN item.ItemAttrValue ia ON i.id = ia.itemId AND ia.itemFieldId IN (SELECT id FROM dictionary.ItemField WHERE name = ''Attribute_ManufacturerCode'')
					JOIN @tmp t ON ia.textValue = t.code
				FOR XML PATH(''item''), TYPE )
			FOR XML PATH(''root''), TYPE
		END
	ELSE
		BEGIN
			SELECT ( 
				SELECT defaultPrice as ''@initialNetPrice'', unitId ''@unitId'', vatRateId as ''@vatRateId'', version as ''@version'', [name] as ''@name'', id as ''@id'', t.code as ''@code''
				FROM item.Item i
					JOIN @tmp t ON i.code = t.code
				FOR XML PATH(''item''), TYPE )
			FOR XML PATH(''root''), TYPE
		END
END
' 
END
GO

/*
name=[item].[p_getItemsByManufacturerAndCode]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
/b+EcJcwIswIreWr1qfeww==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsByManufacturerAndCode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemsByManufacturerAndCode]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsByManufacturerAndCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getItemsByManufacturerAndCode]
@xmlVar XML 
AS
BEGIN


DECLARE @Attribute_ManufacturerCode uniqueidentifier,
		@Attribute_Manufacturer uniqueidentifier,
		@idoc int


DECLARE @tmp_ TABLE (ManufacturerCode nvarchar(500), Manufacturer nvarchar(500) )

EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

	INSERT INTO @tmp_ (ManufacturerCode, Manufacturer)
	SELECT 
	manufacturerCode,
	manufacturer
	FROM OPENXML(@idoc, ''/root/item'')
				WITH(
						manufacturerCode nvarchar(500) ''@manufacturerCode'',
						manufacturer nvarchar(500) ''@manufacturer''
				)
EXEC sp_xml_removedocument @idoc


SELECT (
	SELECT id as ''@id'', unitId AS ''@unitId'', [name] AS ''@name'', vatRateId as ''@vatRateId'', version ''@version'', xx.manufacturer as ''@manufacturer'' , xx.manufacturerCode as ''@manufacturerCode''
	FROM (
			SELECT i.id as id, i.unitId AS unitId, i.name as [name], i.vatRateId as vatRateId, i.version version,
				( SELECT textValue FROM item.ItemAttrValue  WHERE itemId = i.id AND itemFieldId = (SELECT id FROM  dictionary.ItemField WHERE [name] = ''Attribute_Manufacturer'') AND textValue in (SELECT Manufacturer FROM @tmp_) ) as manufacturer , --AND textValue in (SELECT Manufacturer FROM @tmp_)
				( SELECT textValue FROM item.ItemAttrValue  WHERE itemId = i.id AND itemFieldId = (SELECT id FROM  dictionary.ItemField WHERE [name] = ''Attribute_ManufacturerCode'') AND textValue in (SELECT ManufacturerCode FROM @tmp_) ) as manufacturerCode -- AND textValue in (SELECT ManufacturerCode FROM @tmp_) 
			FROM item.Item  i
		) xx
		JOIN @tmp_ t ON xx.manufacturer = t.Manufacturer AND xx.manufacturerCode = t.ManufacturerCode
	FOR XML PATH(''item''), TYPE
) FOR XML PATH(''root''), TYPE
END
' 
END
GO

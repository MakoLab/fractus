/*
name=[item].[p_getItemsManufacturerAndCode]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
k2sE89x483Xx+DS4RxK3Pw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsManufacturerAndCode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemsManufacturerAndCode]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsManufacturerAndCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getItemsManufacturerAndCode]
@xmlVar XML 
AS
BEGIN
DECLARE @Attribute_ManufacturerCode uniqueidentifier,
		@Attribute_Manufacturer uniqueidentifier,
		@idoc int


SELECT @Attribute_ManufacturerCode = id FROM dictionary.ItemField WHERE [name] = ''Attribute_ManufacturerCode''
SELECT @Attribute_Manufacturer = id FROM dictionary.ItemField WHERE [name] = ''Attribute_Manufacturer''



DECLARE @tmp_ TABLE ( id uniqueidentifier )

/*Przepisuję te wieści do tabel tymczasowych dla wydajności*/
EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
	INSERT INTO @tmp_ (id)
	SELECT 	id
	FROM OPENXML(@idoc, ''/root/item'')
	WITH( id uniqueidentifier ''@id'')
EXEC sp_xml_removedocument @idoc


SELECT (
	SELECT	x.id as ''@id'', 
			(SELECT top 1 textValue FROM item.ItemAttrValue WHERE itemFieldId = @Attribute_Manufacturer AND itemId = x.id ) as ''@manufacturer'',
			(SELECT top 1 textValue FROM item.ItemAttrValue WHERE itemFieldId = @Attribute_ManufacturerCode AND  itemId = x.id ) as ''@manufacturerCode''
	FROM @tmp_ x
	FOR XML PATH(''item''), TYPE )
FOR XML PATH(''root''), TYPE


END
' 
END
GO

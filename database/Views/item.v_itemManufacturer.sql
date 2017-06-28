/*
name=[item].[v_itemManufacturer]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Jom11HbPhSuS5I2cv0kBcA==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[item].[v_itemManufacturer]'))
DROP VIEW [item].[v_itemManufacturer]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[item].[v_itemManufacturer]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [item].[v_itemManufacturer] WITH SCHEMABINDING AS

SELECT i.textValue field, i.itemId
FROM [item].ItemAttrValue i
	JOIN dictionary.ItemField df ON i.itemFieldId = df.id
WHERE df.name = ''Attribute_Manufacturer''
' 
GO

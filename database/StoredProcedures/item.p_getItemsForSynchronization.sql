/*
name=[item].[p_getItemsForSynchronization]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
yICLTwG9dFPdmbNt4lPE9Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsForSynchronization]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemsForSynchronization]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsForSynchronization]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getItemsForSynchronization]
AS

BEGIN

SELECT i.id, 
       a1.textValue Attribute_ManufacturerCode ,
       a2.textValue Attribute_VehicleType ,
       a3.textValue Attribute_Manufacturer ,
       a4.textValue Attribute_Tread ,
       a5.textValue Attribute_TyreWidth ,
       a6.textValue Attribute_Profile ,
       a7.textValue Attribute_Construction ,
       a8.textValue Attribute_LoadIndex ,
       a9.textValue Attribute_SpeedIndex ,
       a10.textValue Attribute_Gain ,
       a11.textValue Attribute_Application ,
       a12.textValue Attribute_Other ,
       a13.decimalValue Attribute_NetPrice ,
       a14.decimalValue Attribute_GrossPrice ,
       a15.decimalValue Attribute_IsAvailable,
       a16.textValue Attribute_Season,
       a17.textValue Attribute_NoiseLevel,
       a18.textValue Attribute_FuelEfficiency,
       a19.textValue Attribute_TireAdherence,
       i.name
FROM item.Item i 
       LEFT JOIN item.ItemAttrValue a1 ON i.id = a1.itemId AND a1.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_ManufacturerCode'' )
       LEFT JOIN item.ItemAttrValue a2 ON i.id = a2.itemId AND a2.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_VehicleType'' )
       LEFT JOIN item.ItemAttrValue a3 ON i.id = a3.itemId AND a3.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_Manufacturer'' )
       LEFT JOIN item.ItemAttrValue a4 ON i.id = a4.itemId AND a4.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_Tread'' )
       LEFT JOIN item.ItemAttrValue a5 ON i.id = a5.itemId AND a5.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_TyreWidth'' )
       LEFT JOIN item.ItemAttrValue a6 ON i.id = a6.itemId AND a6.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_Profile'' )
       LEFT JOIN item.ItemAttrValue a7 ON i.id = a7.itemId AND a7.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_Construction'' )
       LEFT JOIN item.ItemAttrValue a8 ON i.id = a8.itemId AND a8.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_LoadIndex'' )
       LEFT JOIN item.ItemAttrValue a9 ON i.id = a9.itemId AND a9.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_SpeedIndex'' )
       LEFT JOIN item.ItemAttrValue a10 ON i.id = a10.itemId AND a10.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_Gain'' )
       LEFT JOIN item.ItemAttrValue a11 ON i.id = a11.itemId AND a11.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_Application'' )
       LEFT JOIN item.ItemAttrValue a12 ON i.id = a12.itemId AND a12.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_Other'' )
       LEFT JOIN item.ItemAttrValue a13 ON i.id = a13.itemId AND a13.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_NetPrice'' )
       LEFT JOIN item.ItemAttrValue a14 ON i.id = a14.itemId AND a14.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_GrossPrice'' )
       LEFT JOIN item.ItemAttrValue a15 ON i.id = a15.itemId AND a15.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_IsAvailable'' )
       LEFT JOIN item.ItemAttrValue a16 ON i.id = a16.itemId AND a16.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_Season'' )
       LEFT JOIN item.ItemAttrValue a17 ON i.id = a17.itemId AND a17.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_NoiseLevel'' )
       LEFT JOIN item.ItemAttrValue a18 ON i.id = a18.itemId AND a18.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_FuelEfficiency'' )
       LEFT JOIN item.ItemAttrValue a19 ON i.id = a19.itemId AND a19.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_TireAdherence'' )
END
' 
END
GO

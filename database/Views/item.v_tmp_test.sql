/*
name=[item].[v_tmp_test]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
FBKJcR0wmkPFtAkUlLyr/g==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[item].[v_tmp_test]'))
DROP VIEW [item].[v_tmp_test]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[item].[v_tmp_test]'))
EXEC dbo.sp_executesql @statement = N'create view [item].[v_tmp_test]
AS
SELECT i.*, a1.textValue Manufacturer, a2.textValue  Barcode,a3.textValue PKWiU,a4.textValue FiscalName
FROM item.Item i 
	LEFT join item.ItemAttrValue a1 on i.id = a1.itemId and a1.itemFieldId = ''9499C778-8324-49B3-A0AD-0810028283AC''
	LEFT join item.ItemAttrValue a2 on i.id = a2.itemId and a2.itemFieldId = ''E662DBA6-5B46-4EA1-B9BD-D1716FB6226B''
	LEFT join item.ItemAttrValue a3 on i.id = a3.itemId and a3.itemFieldId = ''0A54B156-31C7-4C21-B428-E2615C26A524''
	LEFT join item.ItemAttrValue a4 on i.id = a4.itemId and a4.itemFieldId = ''7D73643C-31C2-4020-AACC-F6A7A10B9137''
' 
GO

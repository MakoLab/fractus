/*
name=[item].[p_getItemsByBarcode]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
G+wuq3YbGCSeAnt+9Jnrrw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsByBarcode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemsByBarcode]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsByBarcode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [item].[p_getItemsByBarcode] @xmlVar xml
AS
BEGIN

		DECLARE @tmp_barcodes TABLE ( barcode varchar(100))

		INSERT INTO @tmp_barcodes
		SELECT x.value(''.'',''varchar(100)'')
		FROM @xmlVar.nodes(''root/barcode'') as a(x)
		
		SELECT v.itemName as ''@name'', v.code AS ''@code'' , v.itemId as ''@id'', ISNULL(v.textValue,s.barcode) AS ''@barcode'', v.unitId AS ''@unitId''
		FROM @tmp_barcodes s
			OUTER APPLY 
				(SELECT TOP 1 _v.code, _v.textValue, _v.itemName, _v.itemId, _v.unitId FROM [item].[v_itemBarcode] _v
				 LEFT JOIN dictionary.ItemField f ON _v.itemFieldId = f.id
				 WHERE (f.name = ''Attribute_Barcode'' OR f.name IS NULL)
					AND s.barcode = _v.textValue) v
		FOR XML PATH(''item''),ROOT(''root'')
		
		
END
' 
END
GO

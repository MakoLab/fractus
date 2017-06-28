/*
name=[dbo].[p_importStanyCSV]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
V3N+9I5jusw+az828SV0zw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[p_importStanyCSV]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[p_importStanyCSV]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[p_importStanyCSV]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[p_importStanyCSV]
AS

BEGIN 

CREATE TABLE #xx ( 
producent nvarchar(1000) COLLATE Polish_CI_AS,  
kod nvarchar(1000) COLLATE Polish_CI_AS,  
[100] nvarchar(1000) COLLATE Polish_CI_AS, 
[102] nvarchar(1000) COLLATE Polish_CI_AS, 
[103] nvarchar(1000) COLLATE Polish_CI_AS, 
[104] nvarchar(1000) COLLATE Polish_CI_AS, 
[106] nvarchar(1000) COLLATE Polish_CI_AS, 
[107] nvarchar(1000) COLLATE Polish_CI_AS, 
[115] nvarchar(1000) COLLATE Polish_CI_AS, 
[120] nvarchar(1000) COLLATE Polish_CI_AS, 
[140] nvarchar(1000) COLLATE Polish_CI_AS, 
[150] nvarchar(1000) COLLATE Polish_CI_AS, 
[160] nvarchar(1000) COLLATE Polish_CI_AS, 
[165] nvarchar(1000) COLLATE Polish_CI_AS, 
[170] nvarchar(1000) COLLATE Polish_CI_AS, 
[200] nvarchar(1000) COLLATE Polish_CI_AS, 
[211] nvarchar(1000) COLLATE Polish_CI_AS, 
[500] nvarchar(1000) COLLATE Polish_CI_AS, 
[512] nvarchar(1000) COLLATE Polish_CI_AS, 
[700] nvarchar(1000) COLLATE Polish_CI_AS
)

BULK INSERT #xx
   FROM  ''D:\Fractus2\Stany\stany.csv''
   WITH 
      (
         FIELDTERMINATOR = '';'',
         ROWTERMINATOR = ''\n''  ,CODEPAGE = ''65001''
      )

SELECT newid() id, warehouse, item, unitId, qty
INTO #stany
FROM  (
	SELECT  w.id warehouse, s.id item , unitId , 
		CASE 
			WHEN w.symbol = N''100'' THEN s.[100] 
			WHEN w.symbol = N''102'' THEN s.[102] 
			WHEN w.symbol = N''103'' THEN s.[103] 
			WHEN w.symbol = N''104'' THEN s.[104] 
			WHEN w.symbol = N''106'' THEN s.[106] 
			WHEN w.symbol = N''107'' THEN s.[107] 
			WHEN w.symbol = N''115'' THEN s.[115] 
			WHEN w.symbol = N''120'' THEN s.[120] 
			WHEN w.symbol = N''140'' THEN s.[140] 
			WHEN w.symbol = N''160'' THEN s.[160] 
			WHEN w.symbol = N''165'' THEN s.[165] 
			WHEN w.symbol = N''170'' THEN s.[170] 
			WHEN w.symbol = N''200'' THEN s.[200]
			WHEN w.symbol = N''211'' THEN s.[211]
			WHEN w.symbol = N''512'' THEN s.[512]
			ELSE 0 END qty , w.symbol
	FROM (	SELECT *
			FROM #xx a 
				JOIN (
					SELECT i.id, i.unitId, 
						( SELECT textValue FROM item.ItemAttrValue  WHERE itemId = i.id AND itemFieldId = (SELECT id FROM  dictionary.ItemField WHERE [name] = ''Attribute_Manufacturer'') ) Manufacturer,
						( SELECT textValue FROM item.ItemAttrValue  WHERE itemId = i.id AND itemFieldId = (SELECT id FROM  dictionary.ItemField WHERE [name] = ''Attribute_ManufacturerCode'') ) Code
					FROM item.Item  i
					) x ON a.producent =  x.Manufacturer AND a.kod = x.Code
		) s 
		JOIN dictionary.Warehouse w ON 1 = 1 AND w.symbol IN (''104'',''170'',''106'',''165'',''140'',''107'',''512'',''103'',''102'',''200'',''211'',''120'',''160'',''700'',''500'', ''115'', ''150'',''100'' )
) xxx 

UPDATE document.WarehouseStock 
SET quantity = qty
FROM document.WarehouseStock w
JOIN #stany s ON w.warehouseId = s.warehouse AND w.itemId = s.item


INSERT INTO document.WarehouseStock
SELECT s.id, warehouse, item, s.unitId, qty, null ,null
FROM #stany s
	LEFT JOIN document.WarehouseStock w ON s.warehouse = w.warehouseId AND s.item  = w.itemId 
WHERE w.id IS NULL  AND s.qty > 0

delete from #xx
delete from #stany

END' 
END
GO

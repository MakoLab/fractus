/*
name=[reports].[p_getWarehouseStockStructure]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
EHKKddxMPjJw1Q8YNydBag==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getWarehouseStockStructure]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getWarehouseStockStructure]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getWarehouseStockStructure]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [reports].[p_getWarehouseStockStructure]
@xmlVar XML
AS


DECLARE
	@includeUnassignedItems bit,
	@itemGroups varchar(8000),
	@containers varchar(8000),
	@item	char(36),
	@itemType varchar(8000),
	@container char(36),
	@period_1_from int,
	@period_1_to int,
	@period_2_from int,
	@period_2_to int,
	@period_3_from int,
	@period_3_to int,
	@today datetime,
	@companyId varchar(8000),
	@branchId varchar(8000),
	@warehouseId varchar(8000),
	@replaceConf_item varchar(8000),
	@query NVARCHAR(max),
	@condition varchar(max),
	@manufacturer varchar(max)	
	
	DECLARE @tmp_line TABLE ( i int identity(1,1), itemId uniqueidentifier, itemName varchar(500), itemCode varchar(500), quantity numeric(18,4), value numeric(18,4) , incomeDate datetime, manufacturer nvarchar(500))
	

		SELECT 
			@itemGroups = x.value(''itemGroups[1]'', ''varchar(8000)''),
			@containers = x.value(''containers[1]'', ''varchar(8000)''),
			@item = x.value(''item[1]'', ''char(8000)''),
			@period_1_from = NULLIF(x.value(''(period1/@from)[1]'', ''int''), '''') ,
			@period_1_to = x.value(''(period1/@to)[1]'', ''int''),
			@period_2_from = x.value(''(period2/@from)[1]'', ''int''),
			@period_2_to = x.value(''(period2/@to)[1]'', ''int''),
			@period_3_from = x.value(''(period3/@from)[1]'', ''int''),
			@period_3_to = x.value(''(period3/@to)[1]'', ''int''),
			@today = CONVERT( char(10), getdate(),120),
			@companyId = x.value(''(//filters/column[@field="companyId"])[1]'', ''varchar(8000)''),
			@branchId = x.value(''(//filters/column[@field="branchId"])[1]'', ''varchar(8000)''),
			@warehouseId = x.value(''(//filters/column[@field="warehouseId"])[1]'', ''varchar(8000)''),
			@itemType = x.value(''(//filters/column[@field="itemType"])[1]'', ''varchar(8000)''),
			@query = ISNULL(REPLACE(REPLACE(RTRIM(NULLIF(@xmlVar.query(''*/query'').value(''.'', ''nvarchar(1000)''),'''')), ''*'', ''%''),'''''''',''''''''''''),'''') 
		FROM @xmlVar.nodes(''/searchParams'') AS a (x)


	    SELECT @condition = (
				SELECT x.value(''(.)[1]'',''varchar(max)'')
				FROM @xmlVar.nodes(''searchParams/sqlConditions/condition'') a(x)
						)
						
		IF @condition IS NOT NULL
		BEGIN
			SELECT @manufacturer = SUBSTRING(@condition, PATINDEX(''%textValue like %'', @condition)+16, (PATINDEX(''%[%]%'', @condition)-PATINDEX(''%textValue like %'', @condition)-15))
		END


		/*Pobranie konfiguracji*/
		SELECT	@replaceConf_item = xmlValue.value(''(root/indexing/object[@name="item"]/replaceConfiguration)[1]'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''
		
	

		SELECT @includeUnassignedItems = x.value(''@includeUnassigned'', ''char(1)'')
		FROM @xmlVar.nodes(''/searchParams/itemGroups'') AS a (x)


		INSERT INTO @tmp_line( itemId ,itemName,itemCode,quantity ,value ,incomeDate, manufacturer)
		SELECT itemId ,[name],[code], SUM(quantity) quantity, SUM(value) value, incomeDate, manufacturer
		FROM (
				SELECT  l.id,i.id itemId,i.name , i.code, 
						ABS(l.quantity) - SUM(ISNULL(rout.quantity,0)) quantity,
						ABS(l.value) - SUM( ISNULL(rout.quantity,0) * ABS(l.value/l.quantity)) value,
						CONVERT(VARCHAR(10),l.incomeDate,121) incomeDate, (SELECT TOP 1 textValue FROM item.ItemAttrValue va WHERE va.itemId = i.id AND va.itemFieldId = (select id from dictionary.ItemField where name like ''Attribute_Manufacturer'')) manufacturer,
						(SELECT TOP 1 textValue FROM item.ItemAttrValue va WHERE va.itemId = i.id AND va.itemFieldId = (select id from dictionary.ItemField where name like ''Attribute_ManufacturerCode'')) manufacturerCode 
				FROM document.WarehouseDocumentHeader h WITH(NOLOCK)
					JOIN document.WarehouseDocumentLine l WITH(NOLOCK) ON h.id = l.warehouseDocumentHeaderId  AND h.status >= 40
					LEFT JOIN document.IncomeOutcomeRelation rout WITH(NOLOCK) ON l.id = rout.incomeWarehouseDocumentLineId 
					JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id --AND documentCategory = 1 
					JOIN item.Item i WITH(NOLOCK) ON l.itemId = i.id 
					LEFT JOIN (
						SELECT DISTINCT ll.itemId
						FROM warehouse.Container c  WITH( NOLOCK ) 
							JOIN warehouse.Shift s WITH( NOLOCK ) ON s.containerId  = c.id
							LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx  WITH( NOLOCK ) GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId 
							LEFT JOIN document.WarehouseDocumentLine ll ON s.incomeWarehouseDocumentLineId = ll.id
						WHERE ISNULL((s.quantity - ISNULL(x.q,0)),0) > 0 AND s.containerId IS NOT NULL
							/*Filtr nazwy kontenera*/
							AND c.name like  REPLACE(RTRIM(@containers),''*'', ''%'')
							) sub ON i.id = sub.itemId
					LEFT JOIN (		SELECT DISTINCT itemId 
									FROM item.v_itemDictionary  d WITH(NOLOCK) 
										JOIN dbo.xp_split(dbo.f_replace2(@query,@replaceConf_item),'' '') x ON  d.field LIKE x.word + ''%''  AND d.field <> ''''  
									WHERE  NULLIF(x.word,'''') IS NOT NULL
								) z1 ON  i.id  = z1.itemId 
			WHERE (l.direction * l.quantity) > 0 
				AND l.outcomeDate IS NULL 
				AND (  i.id IN (
							SELECT itm.id 
							FROM item.item itm WITH( NOLOCK )  
								LEFT JOIN item.ItemGroupMembership igm WITH( NOLOCK ) ON itm.id = igm.itemId 
							WHERE igm.itemId IS NULL AND @includeUnassignedItems = 1
							UNION 
							SELECT itemId 
							FROM item.ItemGroupMembership  WITH( NOLOCK )
							WHERE itemGroupId IN (SELECT CAST(NULLIF(word ,'''') AS char(36)) FROM dbo.xp_split(ISNULL(@itemGroups,''''), '','') )
							)
					 OR (@itemGroups IS NULL	AND @includeUnassignedItems IS NULL)
						)
				AND ( (NULLIF( @containers ,'''') IS NOT NULL AND sub.itemId IS NOT NULL )  OR (NULLIF( @containers ,'''') IS NULL ) )
				AND ( (NULLIF( @item , '''' ) IS NOT NULL AND i.id = @item ) OR (NULLIF( @item , '''' ) IS NULL ) )
				AND ( (NULLIF( @companyId , '''' ) IS NOT NULL AND h.companyId IN (SELECT CAST( NULLIF(word ,'''') AS char(36) ) FROM dbo.xp_split(@companyId, '','') ) ) OR (NULLIF( @companyId , '''' ) IS NULL ) )
				AND ( (NULLIF( @branchId , '''' ) IS NOT NULL AND h.branchId IN (SELECT CAST( NULLIF(word ,'''') AS char(36) ) FROM dbo.xp_split(@branchId, '','') )  ) OR (NULLIF( @branchId , '''' ) IS NULL ) )
				AND ( (NULLIF( @warehouseId , '''' ) IS NOT NULL AND h.warehouseId IN (SELECT CAST( NULLIF(word ,'''') AS char(36) ) FROM dbo.xp_split(@warehouseId, '','') )  ) OR (NULLIF( @warehouseId , '''' ) IS NULL ) )
				AND ( (NULLIF( @itemType , '''' ) IS NOT NULL AND i.itemTypeId IN (SELECT CAST( NULLIF(word ,'''') AS char(36) ) FROM dbo.xp_split(@itemType, '','') )  ) OR (NULLIF( @itemType , '''' ) IS NULL ) )
				AND ( (NULLIF(@query,'''') IS NULL ) OR ( NULLIF(@query,'''') IS NOT NULL AND z1.itemId IS NOT NULL ))
			GROUP BY l.id, i.id,i.name , i.code, CONVERT(VARCHAR(10),l.incomeDate,121) ,l.quantity, l.value
			HAVING ABS(l.quantity) - SUM(ISNULL(rout.quantity,0)) <> 0 OR 	(ABS(l.value) - SUM( ISNULL(rout.quantity,0) * (l.value/l.quantity)  ) ) <> 0
		) x 
		WHERE ISNULL(manufacturer,'''') LIKE ISNULL(@manufacturer,''%'')
		GROUP BY itemId ,[name] ,[code] ,incomeDate,id,manufacturer
	
		SELECT (
		SELECT DISTINCT itemCode as ''@itemCode'', itemName as ''@itemName'', itemId as ''@itemId'', 
			period_1_qty as ''@period_1_qty'', period_1_val as ''@period_1_val'', period_2_qty as ''@period_2_qty'' , period_2_val as ''@period_2_val'', period_3_qty as ''@period_3_qty'', period_3_val as ''@period_3_val'' ,
			totalQuantity as ''@totalQuantity'', totalValue as ''@totalValue'', manufacturer as ''@manufacturer''
			FROM (
					SELECT	
						--symbol as containerSymbol, 
						itemCode as itemCode,
						manufacturer as manufacturer,
						itemName as itemName, 
						itemId as itemId,
						SUM( CASE WHEN incomeDate <= DATEADD(dd,-ISNULL(@period_1_from,0),@today) AND  incomeDate > DATEADD(dd,-@period_1_to,@today) THEN quantity ELSE 0 END ) period_1_qty,
						SUM( CASE WHEN incomeDate <= DATEADD(dd,-ISNULL(@period_1_from,0),@today) AND  incomeDate > DATEADD(dd,-@period_1_to,@today) THEN [value] ELSE 0 END ) period_1_val, 
						SUM( CASE WHEN incomeDate <= DATEADD(dd,-ISNULL(@period_2_from,0),@today) AND  incomeDate > DATEADD(dd,-@period_2_to,@today) THEN quantity ELSE 0 END ) period_2_qty,
						SUM( CASE WHEN incomeDate <= DATEADD(dd,-ISNULL(@period_2_from,0),@today) AND  incomeDate > DATEADD(dd,-@period_2_to,@today) THEN [value] ELSE 0 END ) period_2_val, 
						SUM( CASE WHEN incomeDate <= DATEADD(dd,-ISNULL(@period_3_from,0),@today) THEN quantity ELSE 0 END ) period_3_qty,   
						SUM( CASE WHEN incomeDate <= DATEADD(dd,-ISNULL(@period_3_from,0),@today)  THEN [value] ELSE 0 END ) period_3_val,  
						SUM(quantity) as totalQuantity,
						SUM([value]) as totalValue
					FROM  @tmp_line 
					GROUP BY itemCode, itemName, itemId, manufacturer
				) x
			FOR XML PATH(''line''), TYPE
		) FOR XML PATH(''lines''), TYPE
' 
END
GO

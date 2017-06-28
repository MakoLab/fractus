/*
name=[reports].[p_getWarehouseStockAvailability]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
d6fOghnbQq633IOnwZ9L/w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getWarehouseStockAvailability]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getWarehouseStockAvailability]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getWarehouseStockAvailability]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [reports].[p_getWarehouseStockAvailability]
@xmlVar XML
AS
DECLARE
	@includeUnassignedItems bit,
	@itemGroups varchar(8000),
	@containers varchar(8000),
	@item	char(36),
	@itemType varchar(8000),
	@period_1 int,
	@period_2 int,
	@dateFrom datetime,
	@dateTo datetime,
	@today datetime,
	@companyId varchar(8000),
	@branchId varchar(8000),
	@warehouseId varchar(8000),
	@replaceConf_item varchar(8000),
	@query NVARCHAR(max),
	@condition varchar(max),
	@manufacturer varchar(max)	


		SELECT 
			@itemGroups = x.value(''itemGroups[1]'', ''varchar(8000)''),
			@containers = x.value(''containers[1]'', ''varchar(8000)''),
			@item = x.value(''item[1]'', ''char(8000)''),
			@period_1 = 15,
			@period_2 = 15,
			@today = CONVERT( char(10), getdate(),120),
			@dateFrom =  DATEADD(dd,-90, GETDATE()) ,
			@dateTo  = GETDATE(),	
			@companyId = x.value(''(//filters/column[@field="companyId"])[1]'', ''varchar(8000)''),
			@branchId = x.value(''(//filters/column[@field="branchId"])[1]'', ''varchar(8000)''),
			@warehouseId = x.value(''(//filters/column[@field="warehouseId"])[1]'', ''varchar(8000)''),
			@itemType = x.value(''(//filters/column[@field="itemType"])[1]'', ''varchar(8000)''),
			@query = ISNULL(REPLACE(REPLACE(RTRIM(NULLIF(@xmlVar.query(''*/query'').value(''.'', ''nvarchar(1000)''),'''')), ''*'', ''%''),'''''''',''''''''''''),'''') 
		FROM @xmlVar.nodes(''/searchParams'') AS a (x)


		SELECT @includeUnassignedItems = x.value(''@includeUnassigned'', ''char(1)'')
		FROM @xmlVar.nodes(''/searchParams/itemGroups'') AS a (x)


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


SELECT (
SELECT DISTINCT itemCode as ''@itemCode'', itemName as ''@itemName'', itemId as ''@itemId'', totalOutcome as ''@totalOutcome'',
	period_1_qty as ''@period_1_qty'', period_1_val as ''@period_1_val'', period_2_qty as ''@period_2_qty'' , period_2_val as ''@period_2_val'',
	totalQuantity as ''@totalQuantity'', totalValue as ''@totalValue'', manufacturer as ''@manufacturer''
	FROM (
		SELECT	
		--symbol as containerSymbol, 
		code as itemCode, 
		[name] as itemName, 
		itemId as itemId,
		manufacturer as manufacturer,
		ISNULL(totalOutcome , 0 ) as  totalOutcome, 
		SUM( CASE WHEN availability <= @period_1  THEN qty ELSE 0 END ) period_1_qty,
		SUM( CASE WHEN availability <= @period_1  THEN [val] ELSE 0 END ) period_1_val, 
		SUM( CASE WHEN availability > @period_2   THEN qty ELSE 0 END ) period_2_qty,
		SUM( CASE WHEN availability > @period_2   THEN [val] ELSE 0 END ) period_2_val, 
		(quantity) as totalQuantity,
		([value]) as totalValue
		FROM (  
			SELECT i.id itemId,i.name , i.code ,sub.totalOutcome , dok.quantity , dok.value, subs.qty, subs.availability, subs.val, (SELECT top 1 textValue FROM item.ItemAttrValue va WHERE va.itemId = i.id AND va.itemFieldId = (select id from dictionary.ItemField where name like ''Attribute_Manufacturer'')) manufacturer,
			 (SELECT top 1 textValue FROM item.ItemAttrValue va WHERE va.itemId = i.id AND va.itemFieldId = (select id from dictionary.ItemField where name like ''Attribute_ManufacturerCode'')) manufacturerCode
			FROM (	SELECT  sum(l.quantity * direction) quantity , sum(ISNULL(ABS(l.value) * SIGN(l.quantity * l.direction),0)) value, l.itemId
					FROM document.WarehouseDocumentHeader h WITH(NOLOCK)
						JOIN document.WarehouseDocumentLine l WITH(NOLOCK) ON h.id = l.warehouseDocumentHeaderId  AND h.status >= 40
					WHERE ( (NULLIF( @companyId , '''' ) IS NOT NULL AND h.companyId IN (SELECT CAST( NULLIF(word ,'''') AS char(36) ) FROM dbo.xp_split(@companyId, '','') ) ) OR (NULLIF( @companyId , '''' ) IS NULL ) )
						AND ( (NULLIF( @branchId , '''' ) IS NOT NULL AND h.branchId IN (SELECT CAST( NULLIF(word ,'''') AS char(36) ) FROM dbo.xp_split(@branchId, '','') )  ) OR (NULLIF( @branchId , '''' ) IS NULL ) )
						AND ( (NULLIF( @warehouseId , '''' ) IS NOT NULL AND h.warehouseId IN (SELECT CAST( NULLIF(word ,'''') AS char(36) ) FROM dbo.xp_split(@warehouseId, '','') )  ) OR (NULLIF( @warehouseId , '''' ) IS NULL ) )	
					GROUP BY l.itemId
				) dok 
				JOIN item.Item i WITH(NOLOCK) ON dok.itemId = i.id 
				/*Tu liczenie stanó na kontenerach*/
				LEFT JOIN (
					SELECT	 c.name,ll.itemId, ct.availability, s.warehouseId ,  SUM(ISNULL((s.quantity - ISNULL(x.q,0)),0)) qty, sum(ISNULL( ( (ISNULL((s.quantity - ISNULL(x.q,0)),0)) * ll.price ) * SIGN(ll.quantity * ll.direction),0)) val
					FROM warehouse.Container c  WITH( NOLOCK ) 
						JOIN dictionary.ContainerType ct WITH( NOLOCK )  ON c.containerTypeId = ct.id
						JOIN warehouse.Shift s WITH( NOLOCK ) ON s.containerId  = c.id
						LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx  WITH( NOLOCK ) GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId 
						LEFT JOIN document.WarehouseDocumentLine ll ON s.incomeWarehouseDocumentLineId = ll.id
					WHERE ISNULL((s.quantity - ISNULL(x.q,0)),0) > 0 AND s.containerId IS NOT NULL
					GROUP BY c.name,ll.itemId, ct.availability, s.warehouseId	
						) subs ON i.id = subs.itemId
				/*Tu liczy się kolumna ilość dokumentów w zadanym okresie*/
				LEFT JOIN ( SELECT COUNT(ll.warehouseDocumentHeaderId) totalOutcome, itemId 
							FROM document.WarehouseDocumentLine ll  WITH( NOLOCK ) 
								JOIN document.WarehouseDocumentHeader hh  WITH( NOLOCK ) ON ll.warehouseDocumentHeaderId = hh.id 
							WHERE (@dateFrom is null OR hh.issueDate >= @dateFrom  ) AND (@dateTo is null OR hh.issueDate <= @dateTo ) AND ll.direction = -1
							GROUP BY ll.itemId
							) sub ON i.id = sub.itemId
				LEFT JOIN (		SELECT DISTINCT itemId 
								FROM item.v_itemDictionary  d WITH(NOLOCK) 
									JOIN dbo.xp_split(dbo.f_replace2(@query,@replaceConf_item),'' '') x ON  d.field LIKE x.word + ''%''  AND d.field <> ''''  
								WHERE  NULLIF(x.word,'''') IS NOT NULL
							) z1 ON  i.id  = z1.itemId 
				WHERE (  i.id IN (
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
						AND ( (NULLIF( @containers ,'''') IS NOT NULL AND subs.name like  REPLACE(RTRIM(@containers),''*'', ''%'') )  OR (NULLIF( @containers ,'''') IS NULL ) )
						AND ( (NULLIF( @item , '''' ) IS NOT NULL AND i.id = @item ) OR (NULLIF( @item , '''' ) IS NULL ) )
						AND ( (NULLIF( @itemType , '''' ) IS NOT NULL AND i.itemTypeId IN (SELECT CAST( NULLIF(word ,'''') AS char(36) ) FROM dbo.xp_split(@itemType, '','') )  ) OR (NULLIF( @itemType , '''' ) IS NULL ) )
						AND ( (NULLIF(@query,'''') IS NULL ) OR ( NULLIF(@query,'''') IS NOT NULL AND z1.itemId IS NOT NULL ))
			   -- GROUP BY i.id, i.name , i.code ,sub.totalOutcome, subs.qty, subs.availability			
				) stany 
		WHERE ISNULL(manufacturer,'''') LIKE ISNULL(@manufacturer,''%'')
		GROUP BY code, [name], itemId, manufacturer, totalOutcome, quantity, value

		) x
		ORDER BY totalOutcome DESC
	FOR XML PATH(''line''), TYPE
) FOR XML PATH(''lines''), TYPE
' 
END
GO

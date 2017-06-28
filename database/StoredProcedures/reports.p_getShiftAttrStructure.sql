/*
name=[reports].[p_getShiftAttrStructure]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Uy/WQRkJ/1axSHTRBGHDtA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getShiftAttrStructure]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getShiftAttrStructure]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getShiftAttrStructure]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE PROCEDURE [reports].[p_getShiftAttrStructure]
@xmlVar XML
AS
BEGIN

DECLARE
	@includeUnassignedItems BIT,
	@itemGroups VARCHAR(8000),
	@containers VARCHAR(8000),
	@item	CHAR(36),
	@itemType VARCHAR(8000),
	@container CHAR(36),
	@period_1Voltage NUMERIC(18,6),
	@period_2Voltage NUMERIC(18,6),
	@period_1Current NUMERIC(18,6),
	@period_2Current NUMERIC(18,6),
	@period_1measureTime INT,
	@period_2measureTime INT,
	@isV BIT, /*Flagi do oznaczania czy opcaj podlega wartościowaniu*/
	@isA BIT,
	@isT BIT,
	@today DATETIME,
	@companyId VARCHAR(8000),
	@branchId VARCHAR(8000),
	@warehouseId VARCHAR(8000),
	@replaceConf_item VARCHAR(8000),
	@query NVARCHAR(max),
	@condition VARCHAR(max),
	@manufacturer VARCHAR(max),
	@zeroStock CHAR(1)
	


		SELECT 
			@itemGroups = x.value(''itemGroups[1]'', ''varchar(8000)''),
			@containers = x.value(''containers[1]'', ''varchar(8000)''),
			@item = x.value(''item[1]'', ''char(8000)''),
			@isV = x.exist(''voltage''),
			@period_1Voltage = x.value(''(voltage/@period1)[1]'', ''numeric(18,6)''),
			@period_2Voltage = x.value(''(voltage/@period2)[1]'', ''numeric(18,6)''),
			@isA = x.exist(''current''),
			@period_1Current = x.value(''(current/@period1)[1]'', ''numeric(18,6)''),
			@period_2Current = x.value(''(current/@period2)[1]'', ''numeric(18,6)''),
			@isT = x.exist(''measureTime''),
			@period_1measureTime = x.value(''(measureTime/@period1)[1]'', ''int''),
			@period_2measureTime = x.value(''(measureTime/@period2)[1]'', ''int''),
			@today = CONVERT( char(10), getdate(),120),
			@companyId = x.value(''(//filters/column[@field="companyId"])[1]'', ''varchar(8000)''),
			@branchId = x.value(''(//filters/column[@field="branchId"])[1]'', ''varchar(8000)''),
			@warehouseId = x.value(''(//filters/column[@field="warehouseId"])[1]'', ''varchar(8000)''),
			@itemType = x.value(''(//filters/column[@field="itemType"])[1]'', ''varchar(8000)''),
			@query = ISNULL(REPLACE(REPLACE(RTRIM(NULLIF(@xmlVar.query(''*/query'').value(''.'', ''nvarchar(1000)''),'''')), ''*'', ''%''),'''''''',''''''''''''),''''),
			@zeroStock = x.value(''(//filters/column[@field="zeroStock"])[1]'', ''varchar(8000)'')
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

SELECT (
SELECT DISTINCT itemCode as ''@itemCode'', itemName as ''@itemName'', itemId as ''@itemId'', 
	period_1_qty as ''@period_1_qty'', period_1_val as ''@period_1_val'', period_2_qty as ''@period_2_qty'' , period_2_val as ''@period_2_val'', period_3_qty as ''@period_3_qty'', period_3_val as ''@period_3_val'' , period_4_qty as ''@period_4_qty'', period_4_val as ''@period_4_val'' ,
	totalQuantity as ''@totalQuantity'', totalValue as ''@totalValue'', manufacturer as ''@manufacturer'',manufacturerCode as ''@manufacturerCode''
	FROM (

	SELECT code itemCode,  name itemName, itemId, manufacturer,manufacturerCode,
		   ISNULL(SUM(CASE WHEN xx = 1 THEN  qty ELSE 0 END),0)	period_1_qty,
		   ISNULL(SUM(CASE WHEN xx = 1 THEN  val ELSE 0 END),0)	period_1_val,
		   ISNULL(SUM(CASE WHEN xx = 2 THEN  qty ELSE 0 END),0)	period_2_qty,
		   ISNULL(SUM(CASE WHEN xx = 2 THEN  val ELSE 0 END),0)	period_2_val,
		   ISNULL(SUM(CASE WHEN xx = 3 THEN  qty ELSE 0 END),0)	period_3_qty,
		   ISNULL(SUM(CASE WHEN xx = 3 THEN  val ELSE 0 END),0)	period_3_val,
		   ISNULL(SUM(CASE WHEN xx = -1 THEN  qty ELSE 0 END),0)	period_4_qty,
		   ISNULL(SUM(CASE WHEN xx = -1 THEN  val ELSE 0 END),0)	period_4_val,
		   (quantity) totalQuantity, (value) totalValue
	FROM ( 
			SELECT DISTINCT subquery.code, subquery.name, subquery.itemId, subquery.quantity ,subquery.value, subquery.shiftId,subquery.qty ,subquery.val, subquery.manufacturer,subquery.manufacturerCode,
					[dbo].[f_attrValuate]( Attribute_Voltage,@isV, Attribute_Current,@isA, Attribute_MeasureTime , @isT) xx
			FROM (
				/*Liczenie stanów na shiftach*/
				SELECT i.id itemId,i.name , i.code , dok.quantity , dok.value, subs.qty, subs.val,  subs.shiftId, (SELECT top 1 textValue FROM item.ItemAttrValue va WHERE va.itemId = i.id AND va.itemFieldId = (select id from dictionary.ItemField where name like ''Attribute_Manufacturer'')) manufacturer,
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
					SELECT	 c.name,ll.itemId, s.id shiftId, s.warehouseId ,  
					SUM(ISNULL((s.quantity - ISNULL(x.q,0)),0)) qty, 
					sum(ISNULL( ( (ISNULL((s.quantity - ISNULL(x.q,0)),0)) * ll.price ) * SIGN(ll.quantity * ll.direction),0)) val
					FROM warehouse.Container c  WITH( NOLOCK ) 
						JOIN dictionary.ContainerType ct WITH( NOLOCK )  ON c.containerTypeId = ct.id
						JOIN warehouse.Shift s WITH( NOLOCK ) ON s.containerId  = c.id
						LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx  WITH( NOLOCK ) GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId 
						LEFT JOIN document.WarehouseDocumentLine ll ON s.incomeWarehouseDocumentLineId = ll.id
					WHERE ISNULL((s.quantity - ISNULL(x.q,0)),0) > 0 AND s.containerId IS NOT NULL
					GROUP BY c.name,ll.itemId, ct.availability, s.warehouseId, s.id	
						) subs ON i.id = subs.itemId 
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
						AND ( (NULLIF( @query, '''') IS NOT NULL  AND z1.itemId IS NOT NULL ) OR NULLIF( @query, '''') IS NULL )
						AND ( (NULLIF( @zeroStock,'''') IS NOT NULL AND ( (@zeroStock = 1 AND  dok.quantity = 0 ) OR (@zeroStock = 0 AND  dok.quantity <> 0 ))))
				-- GROUP BY i.code, i.name, i.id ,  subs.shiftId	
				) subquery 
				LEFT JOIN
					/*Wartosci atrybutów */  
				(	
				SELECT shiftId, Attribute_Voltage,Attribute_Current,Attribute_MeasureTime
				FROM (
							SELECT sav.shiftId, 
								SUM(CASE WHEN @isV = 1 THEN CASE WHEN sf.name = ''Attribute_Voltage'' THEN ISNULL(dbo.f_attrValueCheck( ISNULL(sav.textValue ,sav.decimalValue),iav.textValue ,''V'', @period_1Voltage, @period_2Voltage ),-1)  ELSE NULL END ELSE null END) AS Attribute_Voltage,
								SUM(CASE WHEN @isA = 1 THEN CASE WHEN sf.name = ''Attribute_Current'' THEN ISNULL(dbo.f_attrValueCheck( ISNULL(sav.textValue ,sav.decimalValue) ,iav.textValue ,''A'', @period_1Current, @period_2Current ),-1)  ELSE NULL END ELSE null END) AS Attribute_Current,
								SUM(CASE WHEN @isT = 1 THEN CASE WHEN sf.name = ''Attribute_MeasureTime'' THEN ISNULL(dbo.f_attrValueCheck( ISNULL(sav.textValue ,sav.dateValue) ,iav.textValue ,''T'', @period_1measureTime, @period_2measureTime ),-1)  ELSE NULL END ELSE  null END)  AS Attribute_MeasureTime
							FROM warehouse.ShiftAttrValue sav WITH( NOLOCK ) 
								JOIN (SELECT st.id shiftId, itemId FROM document.WarehouseDocumentLine dl JOIN warehouse.Shift st ON dl.id = st.incomeWarehouseDocumentLineId ) sub ON sav.shiftId = sub.shiftId
								LEFT JOIN dictionary.ShiftField sf WITH( NOLOCK )  ON sav.shiftFieldId = sf.id
								LEFT JOIN (			SELECT ISNULL(ia.textValue , ia.decimalValue ) textValue, fi.name , ia.itemId
													FROM item.ItemAttrValue ia WITH( NOLOCK ) 
														JOIN dictionary.ItemField fi ON ia.itemFieldId = fi.id 
													WHERE fi.name = ''Attribute_Current''
											) iav ON sf.name = iav.name  AND sub.itemId = iav.itemId
							WHERE sf.name IN (''Attribute_Voltage'',''Attribute_Current'',''Attribute_MeasureTime'') 
							group by sav.shiftId
							
				) x 
				
				
			) sAttr ON subquery.shiftId = sAttr.shiftId  
			where isnull(manufacturer,'''') like ISNULL(@manufacturer,''%'')
		) stany 
	GROUP BY code, [name], itemId, manufacturer,manufacturerCode, quantity, value

		) x
	FOR XML PATH(''line''), TYPE
) FOR XML PATH(''lines''), TYPE

END
' 
END
GO

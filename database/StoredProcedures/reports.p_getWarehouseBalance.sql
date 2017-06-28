/*
name=[reports].[p_getWarehouseBalance]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
SSk+mSiJ7gr1s8Dws7d/3w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getWarehouseBalance]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getWarehouseBalance]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getWarehouseBalance]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*
[reports].[p_getWarehouseBalance] ''<searchParams type="CommercialDocument">
  <filters>
  </filters>
</searchParams>''
*/

CREATE PROCEDURE [reports].[p_getWarehouseBalance]
@xmlVar XML
AS
BEGIN
        DECLARE 
			@max INT,
            @i INT,
            @column NVARCHAR(255),
            @select NVARCHAR(max),
            @from NVARCHAR(max),
            @where NVARCHAR(max),
            @opakowanie NVARCHAR(max),
            @dataColumn NVARCHAR(255),
            @containers varchar(8000),
            @exec NVARCHAR(max),
            @dateFrom DATETIME,
            @dateTo DATETIME,
            @filtrDat VARCHAR(200),
			@filter XML,
			@field_name NVARCHAR(255),
			@field_value NVARCHAR(MAX),
			@itemGroups XML,
            @includeUnassignedItems CHAR(1),
			@filter_count INT,
			@replaceConf_item VARCHAR(8000),
			@query NVARCHAR(max),
			@condition VARCHAR(max),
			@having NVARCHAR(MAX),
			@dbId CHAR(36)


		SELECT @dbId = textValue FROM configuration.Configuration WHERE [key] like ''communication.DatabaseId''
        SELECT  
                @dateFrom = NULLIF(x.query(''dateFrom'').value(''.'', ''datetime''),''''),
                @dateTo = NULLIF(x.query(''dateTo'').value(''.'', ''datetime''),''''),
				@itemGroups = @xmlVar.query(''*/itemGroups'').value(''.'', ''varchar(max)''),
				@containers =  x.value(''containers[1]'', ''varchar(8000)''),
				@filter = x.query(''filters/*''),
				@query = ISNULL(REPLACE(REPLACE(RTRIM(NULLIF(@xmlVar.query(''*/query'').value(''.'', ''nvarchar(1000)''),'''')), ''*'', ''%''),'''''''',''''''''''''),'''') + ''%'' 
        FROM    @xmlVar.nodes(''/*'') a(x)

		/*Warunek na datę dalszą od dziś*/
		IF DATEDIFF(ss,GETDATE() , @dateTo) > 0 
			SELECT @dateTo = NULL

	    SELECT @condition = (
				SELECT dbo.Concat( '' AND '' + x.value(''(.)[1]'',''varchar(max)'') )
						FROM @xmlVar.nodes(''searchParams/sqlConditions/condition'') a(x)
						)
		SELECT @where = '' 1 = 1 '' + @condition
					
		/*Pobranie konfiguracji*/
		SELECT	@replaceConf_item = xmlValue.value(''(root/indexing/object[@name="item"]/replaceConfiguration)[1]'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''
		

		SELECT @includeUnassignedItems = x.value(''@includeUnassigned'', ''char(1)'')
		FROM @xmlVar.nodes(''/searchParams/itemGroups'') AS a (x)



        SELECT  @opakowanie = ''	DECLARE @return XML '',
                @select = ''SELECT @return = (  
							SELECT * 
							FROM (	
								SELECT  itemName name, itemCode code , symbol mag, CAST(ROUND(ABS(ISNULL(cost,0) - ISNULL(val,0)),4) as numeric(16,4)) roznica  
								FROM (	
									SELECT i.id ,i.name itemName , i.code itemCode, b.symbol,  b.id warehouseId,
										sum(  ISNULL( ABS(l.value) * SIGN(l.quantity * l.direction) ,0)   ) cost '',
			  
			    @from = ''			FROM item.Item i WITH(NOLOCK) 
										LEFT JOIN document.WarehouseDocumentLine l WITH(NOLOCK) ON i.id = l.itemId 
										LEFT JOIN dictionary.Warehouse b WITH(NOLOCK) ON l.warehouseId = b.id
										LEFT JOIN document.WarehouseDocumentHeader h WITH(NOLOCK) ON h.id = l.warehouseDocumentHeaderId  AND h.status >= 40
										LEFT JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id 
										'' 
										--ws.warehouseId in (SELECT id FROM dictionary.Warehouse where branchId in (SELECT id FROM dictionary.Branch WHERE databaseId = @dbId)) 
										

      	/* Filtr daty */
        IF @dateFrom IS NOT NULL OR @dateTo IS NOT NULL 
                SELECT  @filtrDat =  ISNULL('' issueDate <= '''''' + CONVERT(VARCHAR(30), @dateTo, 21) + '''''' '','''')
		

		/*Filtry - filters*/	
		DECLARE @tmp_filters TABLE (id int identity(1,1), field nvarchar(255), [value] nvarchar(max))

		INSERT INTO @tmp_filters (field, [value] )
		SELECT  x.value(''@field'',''nvarchar(50)''),
				x.value(''.'',''nvarchar(max)'')
		FROM @filter.nodes(''column'') AS a(x)

		SELECT @filter_count = @@ROWCOUNT , @i = 1


		WHILE @i <= @filter_count
			BEGIN
				SELECT @field_name = field, @field_value = [value]
				FROM @tmp_filters WHERE id = @i
				
				IF @field_name = ''related''
					SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + '' cwr_c.id '' + CASE @field_value WHEN  1 THEN '' IS NOT NULL '' WHEN 0 THEN '' IS NULL '' END,
							@from = @from + char(10) +'' LEFT JOIN document.CommercialWarehouseRelation cwr_c ON  l.id = cwr_c.warehouseDocumentLineId  AND cwr_c.isCommercialRelation = 1''
				ELSE	
				IF @field_name = ''documentTypeId''
					SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + ''( h.documentTypeId = '''''' + REPLACE(@field_value,'','','''''' OR h.documentTypeId = '''''') + '''''' ) ''
				ELSE	
				IF @field_name = ''companyId''
					SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + ''( h.companyId = '''''' + REPLACE(@field_value,'','','''''' OR h.companyId = '''''') + '''''' ) ''
				ELSE	
				IF @field_name = ''branchId''
					SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + ''( h.branchId = '''''' + REPLACE(@field_value,'','','''''' OR h.branchId = '''''') + '''''' ) ''
				ELSE
				IF @field_name = ''warehouseId''
					SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + ''( l.warehouseId = '''''' + REPLACE(@field_value,'','','''''' OR l.warehouseId = '''''') + '''''' ) ''
				ELSE
				IF @field_name = ''status''
					SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + '' h.status IN ('' + @field_value + '')''
				ELSE
--				IF @field_name = ''paymentMethodId''
--						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''h.id IN ( SELECT DISTINCT pmi.commercialDocumentHeaderId FROM   finance.Payment pmi  WHERE pmi.paymentMethodId = '''''' + REPLACE(@field_value,'','','''''' OR  pmi.paymentMethodId = '''''') + '''''' ) ''
--				ELSE
				IF @field_name = ''itemTypeId''
						SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + ''( i.itemTypeId = '''''' + REPLACE(@field_value,'','','''''' OR i.itemTypeId = '''''') + '''''' ) ''
				ELSE

				IF @field_name = ''numberSettingId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( Series.numberSettingId = '''''' + REPLACE(@field_value,'','','''''' OR Series.numberSettingId = '''''') + '''''' ) '',
								@from = @from + char(10) +'' LEFT JOIN document.Series ON h.seriesId = Series.id ''
				ELSE
				SELECT @where = ISNULL( @where + '' AND '','' '' )  + @field_name + '' = '''''' + @field_value + ''''''''
		
				SELECT @i = @i + 1
			END			

		/*Sklejam zapytanie z filtrem dat*/
		IF @filtrDat <> ''''
			SELECT  @where = ISNULL(@where + char(10) + '' AND ''  + @filtrDat  , @filtrDat )
                              


		/*filtrowanie po query */
		IF @query <> ''%''
			BEGIN
				/*Przeniesione do funkcji, bałagan robił się przy przeszukiwaniu dictionary wielu obiektów jednocześnie*/
				SELECT @from = @from + '' '' + dbo.f_getQueryFilter(@query ,@replaceConf_item , '' l.itemId '', ''itemId '',''item.v_itemDictionary'', null, null, NULL ) 
			END    

DECLARE @itemGoupsList varchar(max)
SELECT @itemGoupsList = NULLIF(REPLACE(ISNULL(@itemGroups.value(''.'',''varchar(8000)''),'''') ,'','','''''',''''''),'''')
		/*Warunki dla grup towarów*/
		IF NULLIF(CAST(@itemGroups AS varchar(max)), '''') IS NOT NULL OR @includeUnassignedItems IS NOT NULL
			BEGIN
				SELECT  @where = ISNULL( @where + char(10) + '' AND '', '' '' ) + ''
						 (  i.id IN (
									SELECT itm.id 
									FROM item.item itm WITH( NOLOCK )  
										LEFT JOIN item.ItemGroupMembership igm WITH( NOLOCK ) ON itm.id = igm.itemId 
									WHERE igm.itemId IS NULL AND 1 = '' + CAST(ISNULL(@includeUnassignedItems,0) AS VARCHAR(10)) + ''
									GROUP BY itm.id '' + 
									ISNULL( ''
									UNION 
									SELECT itemId 
									FROM item.ItemGroupMembership  WITH( NOLOCK )
									WHERE itemGroupId IN ('''''' + @itemGoupsList + '''''') 
									GROUP BY itemId '' , '''' ) + ''
									)
							)''
			END

 
			
 		IF NULLIF(RTRIM(@containers),'''') IS NOT NULL
			BEGIN
				SELECT @where = ISNULL( @where + char(10) + '' AND '', '' '' ) + ''
				( i.id IN ( SELECT hh.itemId
				FROM warehouse.Container c  WITH( NOLOCK ) 
					JOIN warehouse.Shift s WITH( NOLOCK ) ON s.containerId  = c.id
					LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx  WITH( NOLOCK ) GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
					JOIN document.WarehouseDocumentLine hh ON s.incomeWarehouseDocumentLineId = hh.id
				WHERE ISNULL((s.quantity - ISNULL(x.q,0)),0) > 0 AND s.containerId IS NOT NULL AND c.name LIKE  REPLACE(RTRIM('''''' + @containers + ''''''),''''*'''', ''''%'''') )
				)''
			END

/*W poniższym havingu powinno być jeszcze
OR sum(ISNULL(ABS(l.value) * SIGN(l.quantity * l.direction),0)) <> 0 
eby nie pokazywało pozycji o zerowej ilości i niezerowym koszcie, które wynikaja z błnych kosztów na przychodach/rozchodach */ 

		SELECT @exec = @opakowanie + @select + @from + ISNULL( char(10) + '' WHERE '' + @where ,'''') + '' GROUP BY i.id ,i.name ,  i.code ,b.symbol , b.id
		
		) line  
		LEFT JOIN (SELECT sum(price * quantity) val , itemId, warehouseId FROM document.v_getAvailableDeliveries v WITH(NOLOCK) GROUP BY itemId, warehouseId ) vx ON  line.Id = vx.itemId AND line.warehouseId = vx.warehouseId
		WHERE  ISNULL(cost,0) - ISNULL(val,0)   <> 0
		) line
		order by ABS(roznica) DESC
		FOR XML AUTO);
				 SELECT  @return FOR XML PATH(''''root''''),TYPE ''
		PRINT @exec
        EXECUTE ( @exec ) 
    END
' 
END
GO

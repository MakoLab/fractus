/*
name=[item].[p_getItems]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Uc6Hw7ABQjRcrpU0fvcklw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItems]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItems]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItems]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N' 

CREATE PROCEDURE [item].[p_getItems] @xmlVar XML
AS 
    BEGIN
        DECLARE @max INT,
            @i INT,
            @iDoc INT,
            @column VARCHAR(255),
            @from NVARCHAR(max),
			@from_page NVARCHAR(max),
            @where NVARCHAR(max),
            @groups VARCHAR(max),
			@sort NVARCHAR(max),
            @sortOrder NVARCHAR(max),
            @pageOrder NVARCHAR(max),
			@alterQuery NVARCHAR(4000),
            @includeUnassigned CHAR(1),
            @table VARCHAR(255),
            @select NVARCHAR(max),
            @sortType NCHAR(4),
            @addressFlag BIT,
            @query NVARCHAR(max),
            @dataColumn NVARCHAR(255),
            @itemFieldId CHAR(36),
			@itemFieldName NVARCHAR(100),
            @exec NVARCHAR(max),
            @condition VARCHAR(max),
			@select_page VARCHAR(max),
			@page INT,
			@pageSize INT,
			@defWarehouse CHAR(36),
			@stockFlag bit,
			@availSumFlag bit,
			@filter XML,
			@field_name NVARCHAR(255),
			@field_value NVARCHAR(max),
			@filter_count INT,
			@columnName varchar(100),
			@subQuery nvarchar(4000),
			@replaceConf_item varchar(8000),
			@currentItemPriceId char(36),
			@flag_filter VARCHAR(500),
			@tmp_value NVARCHAR(max),
			@userId uniqueidentifier,
			@hideItems varchar(5),
			@callingTarget varchar(50)
			
		DECLARE @tmp TABLE (i int identity(1,1), [column] varchar(255), dataColumn varchar(255), itemFieldId char(36), itemFieldName nvarchar(100), sortType varchar(10),sortOrder int, columnName varchar(500), subQuery nvarchar(max))
		DECLARE @tmp_filters TABLE (id int identity(1,1), field nvarchar(255), [value] nvarchar(500))

		/*Pobranie konfiguracji*/
		SELECT	@replaceConf_item = xmlValue.value(''(root/indexing/object[@name="item"]/replaceConfiguration)[1]'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''

		SELECT @userId = ISNULL(@xmlVar.value(''(*/@applicationUserId)[1]'',''char(36)''), @xmlVar.value(''(*/applicationUserId)[1]'',''char(36)''))
		SELECT @callingTarget = @xmlVar.value(''(*/callingTarget)[1]'',''varchar(50)'')

		/*Pobranie liczby kolumn z kofiguracji*/
		SELECT  
				@query = ISNULL(REPLACE(REPLACE(RTRIM(NULLIF(RTRIM(  x.value(''(query)[1]'',''nvarchar(1000)'')  ),'''')), ''*'', ''%''),'''''''',''''''''''''),'''') + ''%'' ,
				@groups = RTRIM( x.value(''(groups)[1]'',''nvarchar(max)'')),
				@pageSize = ISNULL(x.value(''(pageSize)[1]'',''int''),0),
				@page = ISNULL(x.value(''(page)[1]'',''int''),0),
				@defWarehouse = x.value(''(currentWarehouse)[1]'',''char(36)''),
				@currentItemPriceId = x.value(''(currentItemPriceId)[1]'',''char(36)''),
				@filter = x.query(''filters''),
				@includeUnassigned = x.value(''(groups/@includeUnassigned)[1]'',''char(1)'')
		FROM @xmlVar.nodes(''searchParams'') as a (x)
		
		SELECT @condition = (
		SELECT dbo.Concat( '' AND '' + x.value(''(.)[1]'',''varchar(max)'') )
				FROM @xmlVar.nodes(''searchParams/sqlConditions/condition'') a(x)
				)
		/*Pobranie column Configuration*/

		INSERT INTO @tmp ( [column], dataColumn, itemFieldId, itemFieldName, sortType, sortOrder, columnName, subQuery )
		SELECT RTRIM(x.value(''(@field)[1]'',''char(36)'')), 
				RTRIM(x.value(''(@column)[1]'',''varchar(255)'')), 
				x.value(''(@itemFieldId)[1]'',''char(36)''), 
				x.value(''(@itemFieldName)[1]'',''nvarchar(100)''), 
				x.value(''(@sortType)[1]'',''varchar(36)''), 
				x.value(''(@sortOrder)[1]'',''int''), 
				RTRIM(x.value(''(@columnName)[1]'',''varchar(500)'')), 
				x.value(''(@subQuery)[1]'',''nvarchar(max)'')
		FROM @xmlVar.nodes(''searchParams/columns/column'') as a(x)
		SELECT @max = @@rowcount

		INSERT INTO @tmp_filters (field, [value] )
		SELECT RTRIM(x.value(''(@field)[1]'',''nvarchar(100)'')),x.value(''(.)[1]'',''nvarchar(100)'') [value] 
		FROM @filter.nodes(''filters/column'') as a(x)
		SELECT @filter_count = @@ROWCOUNT
		
		
		/*Ukryte towary*/
		SELECT @hideItems = ISNULL(( SELECT xmlValue.value(''(profile/permissions/permission[@key="catalogue.items.viewHideItems"]/@level)[1]'',''varchar(50)'') 
		FROM configuration.Configuration  (NOLOCK)
		WHERE [key] = (
						SELECT ''permissions.profiles.'' + permissionProfile
						FROM contractor.ApplicationUser WITH(NOLOCK)
						WHERE contractorId = @userId
					)
					),''0'')
 
        SELECT  @select_page = ''DECLARE @count INT, '' + CHAR(10) + 
							   ''	    @return XML,	'' + CHAR(10) + 
							   ''	    @x XML	'' + CHAR(10) + 
							   '' DECLARE @tmp TABLE (id int identity(1,1), item UNIQUEIDENTIFIER);'' + CHAR(10) +
							   '' INSERT INTO  @tmp (item)''  + CHAR(10) + 
							   ''SELECT Item.id '' + CHAR(10) + ''FROM item.Item '', 
				@select = CHAR(10) +  ''SELECT @return = ( SELECT DISTINCT Item.id as ''''@id'''', i.id ''''@ordinalNumber'''' '', 
				@from_page = '''',
                @from = ''	FROM @tmp i '' + CHAR(10) +  ''	JOIN item.Item  item ON i.item = Item.id '',
                @addressFlag = 0,
                @where = CASE 
							WHEN @hideItems = ''2'' THEN ''1 = 1'' 
							WHEN @hideItems = ''0'' THEN '' Item.id NOT IN (
																	SELECT CGM2.itemId 
																	FROM item.ItemGroupMembership CGM2 WITH(NOLOCK)
																		JOIN  item.ItemGroup i WITH(NOLOCK) ON CGM2.itemGroupId = i.id
																		JOIN [item].[ItemGroupAttributes] ia WITH(NOLOCK) ON i.id = ia.itemGroupId  
																	WHERE ia.name = ''''hideItems'''' AND ia.value = ''''1''''
																		) '' END ,
                @i = 1 
		

		/*Pętla po kolumnach z kofiguracji*/
        WHILE @i <= @max 
            BEGIN
            
				/*Dane o kolumni wyświetlanej*/
                SELECT  @column = [column],
                        @dataColumn =  dataColumn,
                        @itemFieldId = itemFieldId,
                        @itemFieldName = itemFieldName,
						@sortType = sortType,
						@sortOrder = sortOrder,
						@columnName  = columnName,
						@subQuery = subQuery
                FROM    @tmp 
                WHERE i = @i
				
				IF (@dataColumn IS NULL) SELECT @dataColumn = @column	-- jako kolumne tabeli przyjmij domyslnie wartosc w @field

				/*Kolumna z tabeli Item*/
                IF @dataColumn IN ( ''id'', ''code'', ''itemTypeId'', ''name'',''defaultPrice'', ''unitId'', ''version'' ) 
                    BEGIN
                        SELECT  @select = @select + '' , Item.'' + @dataColumn + '' AS ''''@'' + @column + ''''''''
						IF @sortOrder = 1 
							SELECT  @pageOrder = ISNULL(@pageOrder +  '' , '' + '' Item.'' + @dataColumn + '' '' , '' Item.'' + @dataColumn + '' '')  + ISNULL(@sortType, '''') 
                    END

				/*Kolumna z sumą stanów magazynowych, */
                IF @column IN ( ''quantitySum'' ) 
                    BEGIN
						SELECT  @select = @select + '' ,  WS_sum.quantitySum AS ''''@quantitySum''''''
						IF @sortOrder = 1 
							SELECT  @pageOrder = ISNULL( @pageOrder + '', WS_sum.quantitySum '' , '' WS_sum.quantitySum '') + ISNULL(@sortType, '''')  
							
						IF ISNULL(@availSumFlag,0) = 0 
							BEGIN	
								SELECT	@from_page =  @from_page + CHAR(10) + ''	LEFT JOIN ( SELECT SUM(quantity) quantitySum, itemId FROM document.WarehouseStock GROUP BY itemId ) WS_sum ON Item.id = WS_sum.itemId ''
								SELECT	@from = @from + CHAR(10) + ''	LEFT JOIN ( SELECT SUM(quantity) quantitySum, itemId FROM document.WarehouseStock GROUP BY itemId ) WS_sum ON Item.id = WS_sum.itemId '', 
										@availSumFlag = 1
							END

					END
				/*Kolumna z ceną brutto*/
                IF @column IN ( ''grossPrice'' ) 
                    BEGIN
						SELECT  @select = @select + '' ,  ROUND(Item.defaultPrice * ((VatRate.rate / 100)+ 1),2) AS ''''@grossPrice''''''
						IF @sortOrder = 1 
							SELECT  @pageOrder = ISNULL( @pageOrder + '', ROUND(Item.defaultPrice * ((VatRate.rate / 100)+ 1),2)  '' , '' ROUND(Item.defaultPrice * ((VatRate.rate / 100)+ 1),2)  '') + ISNULL(@sortType, '''')  
							
						IF @from_page NOT LIKE ''%LEFT JOIN  dictionary.VatRate  ON Item.vatRateId = VatRate.id%''
							BEGIN	
								SELECT	@from_page =  @from_page + CHAR(10) + ''	LEFT JOIN  dictionary.VatRate  ON Item.vatRateId = VatRate.id ''
								SELECT	@from = @from + CHAR(10) + '' LEFT JOIN  dictionary.VatRate  ON Item.vatRateId = VatRate.id ''
							END

					END
									/*Kolumna z ceną brutto*/
                IF @column IN ( ''profit'' ) 
                    BEGIN
						SELECT  @select = @select + '' , 100 * (  Item.defaultPrice -  ISNULL(WarehouseStock.lastPurchaseNetPrice,0) ) / NULLIF(Item.defaultPrice,0) AS ''''@profit''''''
						
						IF @sortOrder = 1 
							BEGIN
								SELECT	@from_page =  @from_page + CHAR(10) + ''LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId = '''''' + @defWarehouse + ''''''''
								SELECT  @pageOrder = ISNULL( @pageOrder + '',  100 * (  Item.defaultPrice -  ISNULL(WarehouseStock.lastPurchaseNetPrice,0) ) / NULLIF(Item.defaultPrice,0)   '' , ''  100 * (  Item.defaultPrice -  ISNULL(WarehouseStock.lastPurchaseNetPrice,0) ) / NULLIF(Item.defaultPrice,0)  '') + ISNULL(@sortType, '''')  
							END
						IF @from_page NOT LIKE ''%LEFT JOIN  dictionary.VatRate  ON Item.vatRateId = VatRate.id%''
							BEGIN	
								SELECT	@from_page =  @from_page + CHAR(10) + ''	LEFT JOIN  dictionary.VatRate  ON Item.vatRateId = VatRate.id ''
								SELECT	@from = @from + CHAR(10) + '' LEFT JOIN  dictionary.VatRate  ON Item.vatRateId = VatRate.id ''
							END
						IF @from_page NOT LIKE ''%LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId =%''
							BEGIN
								
								SELECT	@from = @from + CHAR(10) + ''LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId = '''''' + @defWarehouse + ''''''''
							
							END

					END
				/*Kolumna z sumą stanów magazynów obcych*/
                IF @column IN ( ''aliensStock'' ) 
                    BEGIN
						SELECT  @select = @select + '' ,  alien.q AS ''''@aliensStock''''''
						IF @sortOrder = 1 
							SELECT  @pageOrder = ISNULL( @pageOrder + '', alien.q '' , ''alien.q '') + ISNULL(@sortType, '''')  
							
						SELECT	@from_page =  @from_page + CHAR(10) + '' LEFT JOIN ( SELECT SUM(quantity) q, itemId FROM document.WarehouseStock WHERE warehouseId <> '''''' + @defWarehouse  + '''''' GROUP BY itemId )  alien  ON Item.id = alien.itemId  ''
						SELECT	@from = @from + CHAR(10) + '' LEFT JOIN ( SELECT SUM(quantity) q, itemId FROM document.WarehouseStock WHERE warehouseId <> '''''' + @defWarehouse  + '''''' GROUP BY itemId )  alien  ON Item.id = alien.itemId  ''
							
					END
					
					
				/*Kolumna z ostatnią ceną*/
                IF @column IN ( ''lastPurchasePrice'' ) 
                    BEGIN
						SELECT  @select = @select + '' ,  ( WarehouseStock.lastPurchaseNetPrice ) AS ''''@lastPurchasePrice''''''
						IF @sortOrder = 1 
							BEGIN
								SELECT	@from_page =  @from_page + CHAR(10) + ''LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId = '''''' + @defWarehouse + ''''''''
								SELECT  @pageOrder = ISNULL( @pageOrder + '',  WarehouseStock.lastPurchaseNetPrice  '' , '' WarehouseStock.lastPurchaseNetPrice '') + ISNULL(@sortType, '''')  
							END
																					
						IF @from_page NOT LIKE ''%LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId =%''
							BEGIN
								
								SELECT	@from = @from + CHAR(10) + ''LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId = '''''' + @defWarehouse + ''''''''
							
							END																						

					END
									

				/*Generic column*/
                IF @columnName IS NOT NULL --@column IN ( ''genericColumn'' ) 
                    BEGIN
						SELECT  @select = @select + '' ,  '' +  @columnName + ''.'' + @columnName + '' AS ''''@'' + @column + ''''''''
						IF @sortOrder = 1 
							SELECT  @pageOrder = ISNULL( @pageOrder + '',  '' + @columnName + ''.'' + @columnName , @columnName + ''.'' + @columnName  ) + '' '' +  ISNULL(@sortType, '''')  
							
								SELECT	@from_page = @from_page + '' '' + @subQuery
								SELECT	@from = @from + '' '' + @subQuery
							
					END
				
				/*color*/
                IF @column = ''color''  
                    BEGIN
						SELECT  @select = @select + '' ,  (SELECT top 1 ia.value FROM item.ItemGroup i join [item].[ItemGroupAttributes] ia ON i.id = ia.itemGroupId  AND ia.type = ''''color''''  JOIN item.ItemGroupMembership im ON i.id = im.itemGroupId WHERE ia.value IS NOT NULL AND im.itemId = Item.id ) AS ''''@'' + @column + ''''''''
							
					END	
				
				/*currentItemPriceId*/
                IF @column = ''currentPrice''  
                    BEGIN
						SELECT  @select = @select + '' , ISNULL((SELECT TOP 1 va.decimalValue FROM item.ItemAttrValue va WHERE va.itemId = Item.id AND va.itemFieldId = NULLIF(''''''+@currentItemPriceId+'''''','''''''') ),Item.defaultPrice) AS ''''@'' + @column + ''''''''

					END	

				/*Kolumna z tabeli Item*/
                IF @column IN ( ''quantity'', ''reservedQuantity'', ''orderedQuantity'' ,''lastPurchaseNetPrice'', ''availableQuantity'') 
                    BEGIN
					
						IF @column = ''availableQuantity''
							BEGIN
								SELECT  @select = @select + '' , WarehouseStock.quantity - WarehouseStock.reservedQuantity AS ''''@availableQuantity''''''
							END
						ELSE
							BEGIN
								SELECT  @select = @select + '' , WarehouseStock.'' + @column + '' AS ''''@'' + @column + ''''''''
							END
						IF @sortOrder = 1 
							BEGIN
								IF ISNULL(@from_page,'''') NOT LIKE ''%LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId =%''
									BEGIN
									print ''t2''
										SELECT	@from_page = @from_page +   CHAR(10) + '' LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId = '''''' + @defWarehouse + ''''''''
									END
								IF @column = ''availableQuantity''
									BEGIN
										SELECT  @pageOrder = ISNULL( @pageOrder + '' , WarehouseStock.quantity - WarehouseStock.reservedQuantity '', ''  WarehouseStock.quantity - WarehouseStock.reservedQuantity '') + ISNULL(@sortType, '''') 
									END
								ELSE
									BEGIN
										SELECT  @pageOrder = ISNULL( @pageOrder + '', WarehouseStock.'' + @column + '' '' , '' WarehouseStock.'' + @column + '' '') + ISNULL(@sortType, '''') 
									END
							END

						IF ISNULL(@from,'''') NOT LIKE ''%LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId =%''
							BEGIN	
							print ''t1''
								SELECT	@from = @from +  CHAR(10) + '' LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId = '''''' + @defWarehouse + '''''''', 
										@stockFlag = 1
							END
								
                    END
				IF @column = ''manufacturerCode''
                    BEGIN
						SELECT  @select = @select + '' ,  mv.textValue AS ''''@manufacturerCode'''''',
								@from = @from + '' LEFT JOIN item.ItemAttrValue mv WITH(NOLOCK) ON mv.itemId = Item.id AND mv.itemFieldId = ''''79EC0441-7BBA-4FB9-ADDE-75BBA472B133 '''''', 
                                @from_page = @from_page + '' LEFT JOIN item.ItemAttrValue mv WITH(NOLOCK) ON mv.itemId = Item.id AND mv.itemFieldId = ''''79EC0441-7BBA-4FB9-ADDE-75BBA472B133 ''''''
                                
                        SELECT  @sort = @sort
                                + CASE WHEN @sortOrder <> ''''
                                       THEN NULLIF(@column, '''') + '' '' + ISNULL(@sortType, '''') + '', ''
                                       ELSE ''''
                                  END 
                        IF @sortOrder = 1 
                            SELECT  @pageOrder = ''mv.textValue '' + ISNULL(@sortType, '''') 
							
					END

				IF @column = ''parameters''
                    BEGIN
					SELECT  @select = @select + '' ,  parameters.textValue AS ''''@parameters'''''',
							 @from = @from +  ''LEFT JOIN (
												SELECT dbo.Concatenate(textValue) textValue, itemId
												FROM (
													SELECT textValue , itemId  
													FROM item.ItemAttrValue 
													WHERE itemFieldId = (SELECT top 1 id FROM dictionary.ItemField WHERE name = ''''Attribute_FuelEfficiency'''')
													UNION 
													SELECT textValue , itemId
													FROM item.ItemAttrValue 
													WHERE itemId = l.itemId AND itemFieldId = (SELECT id FROM dictionary.ItemField WHERE name = ''''Attribute_TireAdherence'''')
													UNION
													SELECT textValue , itemId
													FROM item.ItemAttrValue 
													WHERE itemFieldId = (SELECT id FROM dictionary.ItemField WHERE name = ''''Attribute_NoiseLevel'''') 
													) param GROUP BY itemId 
													) parameters ON parameters.itemId Item.id 
													'' ,
							@from_page = @from_page +  ''LEFT JOIN (
												SELECT dbo.Concatenate(textValue) textValue, itemId
												FROM (
													SELECT textValue , itemId  
													FROM item.ItemAttrValue 
													WHERE itemFieldId = (SELECT top 1 id FROM dictionary.ItemField WHERE name = ''''Attribute_FuelEfficiency'''')
													UNION 
													SELECT textValue , itemId
													FROM item.ItemAttrValue 
													WHERE itemId = l.itemId AND itemFieldId = (SELECT id FROM dictionary.ItemField WHERE name = ''''Attribute_TireAdherence'''')
													UNION
													SELECT textValue , itemId
													FROM item.ItemAttrValue 
													WHERE itemFieldId = (SELECT id FROM dictionary.ItemField WHERE name = ''''Attribute_NoiseLevel'''') 
													) param GROUP BY itemId 
													) parameters ON parameters.itemId Item.id ''
						
                        SELECT  @sort = @sort
                                + CASE WHEN @sortOrder <> ''''
                                       THEN NULLIF(@column, '''') + '' '' + ISNULL(@sortType, '''') + '', ''
                                       ELSE ''''
                                  END 
                        IF @sortOrder = 1 
                            SELECT  @pageOrder = ''mv.textValue '' + ISNULL(@sortType, '''') 
							
					END
				
				/*Kolumna z tabeli ItemAttrValue*/
                IF @dataColumn IN ( ''decimalValue'', ''dateValue'', ''textValue'',''xmlValue'' ) AND (@itemFieldId IS NOT NULL OR @itemFieldName IS NOT NULL)
                    BEGIN
                    
                        SELECT  @select = @select + '' , Iav'' + CAST(@i AS VARCHAR(10)) + ''.'' + @dataColumn + '' AS ''''@'' + @column + '''''' '',
                                @from = @from + '' LEFT JOIN item.ItemAttrValue Iav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Iav'' + CAST(@i AS VARCHAR(10)) + ''.itemId = Item.id AND '' + CASE WHEN NULLIF(@itemFieldId,'''') IS NOT NULL THEN '' Iav'' + CAST(@i AS VARCHAR(10)) + ''.itemFieldId = '''''' + CAST(ISNULL(@itemFieldId, '''') AS VARCHAR(36)) + '''''''' ELSE '' Iav'' + CAST(@i AS VARCHAR(10)) + ''.itemFieldId = (SELECT TOP 1 id FROM dictionary.ItemField WHERE name = '''''' + ISNULL(@itemFieldName,'''') + '''''' ) '' END, 
                                @from_page = @from_page + '' LEFT JOIN item.ItemAttrValue Iav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Iav'' + CAST(@i AS VARCHAR(10)) + ''.itemId = Item.id AND '' + CASE WHEN NULLIF(@itemFieldId,'''') IS NOT NULL THEN '' Iav'' + CAST(@i AS VARCHAR(10)) + ''.itemFieldId = '''''' + CAST(ISNULL(@itemFieldId, '''') AS VARCHAR(36)) + '''''''' ELSE '' Iav'' + CAST(@i AS VARCHAR(10)) + ''.itemFieldId = (SELECT TOP 1 id FROM dictionary.ItemField WHERE name = '''''' + ISNULL(@itemFieldName,'''') + '''''' ) '' END 
                                
                        SELECT  @sort = @sort
                                + CASE WHEN @sortOrder <> ''''
                                       THEN NULLIF(@column, '''') + '' '' + ISNULL(@sortType, '''') + '', ''
                                       ELSE ''''
                                  END 
                        IF @sortOrder = 1 
                            SELECT  @pageOrder = ''Iav'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) + '' '' + ISNULL(@sortType, '''') + '', ''  
                    END

                SELECT  @i = @i + 1
            END



		/*filtrowanie po query */
		/* funkcja szukania po kodzie produktu , jeśli przed szukanym tekstem jest małpa*/
		IF SUBSTRING(@query,1,1) = ''@''
			BEGIN 
				SELECT  @from_page = @from_page + '' JOIN (   SELECT id FROM item.Item WITH(NOLOCK) WHERE code like '''''' + SUBSTRING(@query,2,LEN(@query) - 1) +''%''''  ) z1 ON  Item.id  = z1.id  '' 
			END
		ELSE IF (SELECT SUBSTRING(@query,1,1)) <> ''%''
			BEGIN
			/*Wyszukiwanie w dictionary towaru*/
				
				declare @queryCustom nvarchar(500),@paramsCustom nvarchar(100),@resultCustom nvarchar(100),@resultValue varchar(100)	
				
				/* Ten fragment kodu uruchomi sie tylko w przypadku gdy jest tabela custom.TempData i zawiera bierzące dane*/	
				IF EXISTS (SELECT object_id FROM sys.tables WHERE schema_name(schema_id) = ''custom'' AND  name = ''TempData'')
					BEGIN 
						SELECT @paramsCustom = N''@resultValue nvarchar(100) OUTPUT''
						
						/*Odczytanie wartości tabeli która moze nie istnieć*/
						SELECT @queryCustom = ''SELECT @resultValue = value from custom.TempData where applicationUserId = '''''' + CAST(@userId as char(36)) + '''''' AND DATEDIFF(s, addTime, GETDATE()) <= 5  ''
						EXEC sp_executesql @queryCustom,@paramsCustom, @resultValue OUTPUT

						IF (SELECT ISNULL(@resultCustom,'''') ) <> ''''
							BEGIN
							select @query
								SELECT @query = @resultCustom
							END

	
						SELECT @queryCustom = ''DELETE FROM custom.TempData WHERE applicationUserId = '''''' + CAST(@userId as char(36))  + '''''' OR  DATEDIFF(s, addTime, GETDATE()) > 5 ''

						EXEC (@queryCustom)
					END

				SELECT @from_page = @from_page + '' '' + dbo.f_getQueryFilter(@query ,@replaceConf_item , '' Item.id '', ''itemId '',''item.v_itemDictionary'', null, null,null ) 
			END
		/*Filtry - filters*/	
		SELECT @i = 1
		WHILE @i <= @filter_count
			BEGIN
				SELECT @field_name = field, @field_value = [value]
				FROM @tmp_filters WHERE id = @i
				
				IF @field_name = ''id''
					SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' Item.id = '''''' + @field_value + ''%'''' ''
				ELSE
				IF @field_name = ''code''
					SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' Item.code like '''''' + @field_value + ''%'''' ''
				ELSE
				IF @field_name = ''name''
					SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' Item.name like '''''' + @field_value + ''%'''' ''
				ELSE
				IF @field_name = ''quantity'' 
					BEGIN
						SELECT	@where = CASE WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' WarehouseStock.quantity  > 0'' WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' ISNULL(WarehouseStock.quantity,0)  = 0'' END 
						IF ISNULL(@from_page,'''') NOT LIKE ''%LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId =%''
							BEGIN
								SELECT	@from_page = @from_page +   CHAR(10) + '' LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId = '''''' + @defWarehouse + ''''''''
							END
					END
				ELSE
				IF @field_name = ''reservedQuantity''
					BEGIN
						SELECT	@where = CASE WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' WarehouseStock.reservedQuantity  > 0''  WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' ISNULL(WarehouseStock.reservedQuantity,0)  = 0'' END 
						IF ISNULL(@from_page,'''') NOT LIKE ''%LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId =%''
							BEGIN
								SELECT	@from_page = @from_page +   CHAR(10) + '' LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId = '''''' + @defWarehouse + ''''''''
							END
					END
				ELSE
				IF @field_name = ''orderedQuantity''
					BEGIN
						SELECT	@where = CASE WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' WarehouseStock.orderedQuantity  > 0''  WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' ISNULL(WarehouseStock.orderedQuantity,0)  = 0'' END 
						IF ISNULL(@from_page,'''') NOT LIKE ''%LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId =%''
							BEGIN
								SELECT	@from_page = @from_page +   CHAR(10) + '' LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId = '''''' + @defWarehouse + ''''''''
							END
					END
				ELSE
				IF @field_name = ''available''
					BEGIN
						SELECT	@where = CASE WHEN @field_value = 1   THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' ( WarehouseStock.quantity - ISNULL( WarehouseStock.reservedQuantity,0 ))  > 0''  WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' ISNULL(WarehouseStock.orderedQuantity,0)  = 0'' END 
						IF ISNULL(@from_page,'''') NOT LIKE ''%LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId =%''
							BEGIN
								SELECT	@from_page = @from_page +   CHAR(10) + '' LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId = '''''' + @defWarehouse + ''''''''
							END
					END
				ELSE
				IF @field_name = ''quantitySum''
					SELECT	@where = CASE WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' ISNULL( ( SELECT SUM(w_.quantity) FROM document.WarehouseStock w_ WHERE w_.itemId = item.id ) ,0 ) > 0''  WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + ''  ISNULL( ( SELECT SUM(w_.quantity) FROM document.WarehouseStock w_ WHERE w_.itemId = item.id ) ,0 ) > 0'' END 
				ELSE
				IF @field_name = ''inventoryId''
				/*Foltr do inwentaryzacji, używam niestandardowo magazynu domyślnego jako filtr*/
					SELECT	@where =  ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' Item.Id NOT IN (SELECT itemId FROM document.InventorySheet ish WITH(NOLOCK) JOIN document.InventorySheetLine isl  WITH(NOLOCK) ON ish.id = isl.inventorySheetId WHERE ish.status > 0 AND isl.direction > 0 AND ish.inventoryDocumentHeaderId = '''''' + @field_value + '''''' AND ISNULL( CAST( ish.warehouseId as char(36) ) , '''''' + @defWarehouse + '''''') = '''''' + @defWarehouse + '''''' )''
				ELSE
				IF @field_name = ''availableSum'' AND @field_value = 1
					SELECT	@where = ISNULL(NULLIF(@where,'''') + '' AND '','' '' )  + '' ISNULL( ( SELECT SUM(CASE WHEN w_.quantity > ISNULL(w_.reservedQuantity, 0) THEN w_.quantity - ISNULL(w_.reservedQuantity, 0) ELSE 0 END) FROM document.WarehouseStock w_ WHERE w_.itemId = item.id ) ,0 ) > 0''
				ELSE
				IF @field_name = ''barcode''
					SELECT	@from_page	= @from_page + '' JOIN item.ItemAttrValue iav ON iav.itemFieldId = ( SELECT id FROM dictionary.ItemField WHERE [name] = ''''Attribute_Barcode'''' )
																					AND iav.textValue = '''''' + @field_value + '''''' AND Item.id = iav.itemId '' 
				ELSE
				SELECT @where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + @field_name + '' = '''''' + @field_value + ''''''''
		
				SELECT @i = @i + 1
			END		

		IF @callingTarget = ''AdvancedSalesLinesComponent'' 
			BEGIN
			SELECT @pageOrder =  '' ( WarehouseStock.quantity - ISNULL( WarehouseStock.reservedQuantity,0 ))  DESC '' 
			IF ISNULL(@from_page,'''') NOT LIKE ''%LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId =%''
				BEGIN
					SELECT	@from_page = @from_page +   CHAR(10) + '' LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId = '''''' + @defWarehouse + ''''''''
				END
			END

		IF @callingTarget = ''WMSLinesComponent'' 
			BEGIN
			SELECT @pageOrder =  '' ( WarehouseStock.quantity - ISNULL( WarehouseStock.reservedQuantity,0 ))  DESC '' 
			IF ISNULL(@from_page,'''') NOT LIKE ''%LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId =%''
				BEGIN
					SELECT	@from_page = @from_page +   CHAR(10) + '' LEFT JOIN document.WarehouseStock ON Item.id = WarehouseStock.itemId AND WarehouseStock.warehouseId = '''''' + @defWarehouse + ''''''''
				END
			END

		IF @flag_filter IS NOT NULL
			SELECT @where = ISNULL(NULLIF(@where,'''') + '' AND '' ,'' '' ) +  ISNULL( ''( '' + @flag_filter + '' ) '', '' '' ) 




			/*Obsługa condition*/        
	        IF @condition IS NOT NULL
				SELECT @where = ISNULL(NULLIF(@where,'''') + '' '' + @condition,@condition )
			    
  			/*Warunki dla grup towarów*/
			IF NULLIF(@includeUnassigned, '''') IS NOT NULL 
					SELECT  @where = ISNULL( NULLIF(@where,'''') + '' AND ( CGM.id IS NULL '', '' ( CGM.id IS NULL ''),
							@from = @from + '' LEFT JOIN item.ItemGroupMembership CGM on Item.id = CGM.itemId '',
							@select_page = @select_page + '' LEFT JOIN item.ItemGroupMembership CGM on Item.id = CGM.itemId '' 

			/*Obsługa grup*/
			IF NULLIF(@groups, '''') IS NOT NULL 
				BEGIN
					IF NULLIF(@where,'''') IS NOT NULL 
						SELECT  @where = @where
								+ CASE WHEN NULLIF(@includeUnassigned, '''') IS NOT NULL
									   THEN '' OR ''
									   ELSE '' AND ''
								  END + '' Item.id IN (SELECT CGM2.itemId FROM item.ItemGroupMembership CGM2 WHERE CGM2.itemGroupId in ('' + @groups + ''))''
					ELSE 
						SELECT  @where = '' Item.id IN (SELECT CGM2.itemId FROM item.ItemGroupMembership CGM2 WHERE CGM2.itemGroupId in ('' + @groups + ''))''
				END

		/*Uzupełnienie nawiasu po @includeUnassigned*/
		IF NULLIF(@includeUnassigned, '''') IS NOT NULL 
			SELECT  @where = @where + '')''

	     /*Sklejam zapytanie z filtrem stron*/ 
		IF @page <> 0   
			SELECT  @alterQuery =  char(10) +''WHERE i.id > '' + CAST(@pageSize * ( @page - 1 ) AS VARCHAR(50)) + '' AND i.id <= '' + CAST(@pageSize * ( @page ) AS VARCHAR(50)) + ''  ''
			else
			SELECT  @alterQuery = '' ''	
            
		/*Zapytanie do page*/           
		SELECT @select_page = @select_page + '' '' + @from_page + '' '' + ISNULL( ''WHERE '' + NULLIF(@where,''''),'''') +  ISNULL('' ORDER BY '' + @pageOrder, '''') +'' ; '' + char(10) +''SELECT @count = @@ROWCOUNT ''
			
		/*Sklejam zapytanie*/
        SELECT  @exec = @select_page + ''; '' +  @select + @from  + @alterQuery + '' ORDER BY i.id''  + char(10) + '' FOR XML PATH(''''item''''), TYPE)''  + char(10) + ''SELECT '' + CAST(@page AS VARCHAR(50)) + '' ''''@page'''' ,'' + CAST(@pageSize AS VARCHAR(50))
                + '' ''''@pageSize'''',@count ''''@rowCount'''',@return '' + char(10) + ''FOR XML PATH(''''items'''')''
    PRINT @exec
       EXECUTE ( @exec )
       PRINT @exec
       
       

    END
' 
END
GO

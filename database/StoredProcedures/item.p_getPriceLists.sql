/*
name=[item].[p_getPriceLists]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
9MZUBB2qiTTjfLNAa7IN9g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getPriceLists]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getPriceLists]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getPriceLists]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getPriceLists] @xmlVar XML
AS 
    BEGIN
        DECLARE @max INT,
            @i INT,
            @column NVARCHAR(255),
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
            @itemFieldId UNIQUEIDENTIFIER,
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
			@columnName nvarchar(100),
			@subQuery nvarchar(4000),
			@replaceConf_item varchar(8000)


		/*Pobranie konfiguracji*/
		SELECT	@replaceConf_item = xmlValue.query(''root/indexing/object[@name="item"]/replaceConfiguration'').value(''.'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''

		/*Pobranie liczby kolumn z kofiguracji*/
        SELECT  
				@max = @xmlVar.query(''<a>{ count(/*/columns/column)}</a>'').value(''a[1]'', ''int''),
                @groups = @xmlVar.query(''*/groups'').value(''.'', ''varchar(8000)''),
				@pageSize = @xmlVar.query(''*/pageSize'').value(''.'', ''int''),
                @page = @xmlVar.query(''*/page'').value(''.'', ''int''),
				@filter = @xmlVar.query(''*/filters/*'')

		/*Pobranie wartości z atrybutu z root*/
        SELECT  @includeUnassigned = x.value(''@includeUnassigned'', ''char(1)'')
        FROM    @xmlVar.nodes(''*/groups'') AS a (x)

        SELECT  @select_page = ''DECLARE @count INT, '' + CHAR(10) + 
							   ''	    @return XML	'' + CHAR(10) + 
							   ''DECLARE @tmp TABLE (id int identity(1,1), price UNIQUEIDENTIFIER);'' + CHAR(10) + 
							   ''INSERT INTO  @tmp (price)''  + CHAR(10) + 
							   ''SELECT h.id '' + CHAR(10) + ''FROM item.PriceListHeader h'', 
				@select = CHAR(10) +  ''SELECT @return = ( SELECT DISTINCT h.id as ''''@id'''' '', --SET ROWCOUNT '' + CAST( @pageSize * @page as VARCHAR(50)) + ''; 
				@from_page = '''',
                @from = ''	FROM @tmp i '' + CHAR(10) +  ''	JOIN item.PriceListHeader h ON i.price = h.id '',
                @addressFlag = 0,
                @i = 1 
		

		/*Pętla po kolumnach z kofiguracji*/
        WHILE @i <= @max 
            BEGIN
				
				/*Dane o kolumni wyświetlanej*/
                SELECT  @column = x.value(''@field[1]'', ''nvarchar(255)''),
                        @dataColumn = NULLIF(x.value(''@column[1]'', ''nvarchar(255)''), ''''),
                        @itemFieldId = x.value(''@itemFieldId[1]'',''varchar(255)''),
						@sortType = x.value(''@sortType'', ''VARCHAR(50)''),
						@sortOrder = x.value(''@sortOrder'', ''int''),
						@columnName  = NULLIF(x.value(''@columnName'', ''nvarchar(100)''),''''),
						@subQuery = x.value(''@query'', ''nvarchar(4000)'')
                FROM    @xmlVar.nodes(''/*/columns/column[position()=sql:variable("@i")]'') a ( x )
				
				IF (@dataColumn IS NULL) SELECT @dataColumn = @column	-- jako kolumne tabeli przyjmij domyslnie wartosc w @field

				/*Kolumna z tabeli Item*/
                IF @dataColumn IN ( ''id'', ''name'', ''description'', ''creationDate'',''modificationDate'', ''priceType'', ''version'', ''label'' ) 
                    BEGIN
                        SELECT  @select = @select + '' , h.'' + @dataColumn + '' AS ''''@'' + @column + ''''''''
						IF @sortOrder = 1 
							SELECT  @pageOrder = ISNULL(@pageOrder +  '' , '' + '' h.'' + @dataColumn + '' '' , '' h.'' + @dataColumn + '' '')  + ISNULL(@sortType, '''') 
                    END


                SELECT  @i = @i + 1
            END
		--/*filtrowanie po query */
		--IF @query <> ''%''
		--	BEGIN
		--		/*Przeniesione do funkcji, bałagan robił się przy przeszukiwaniu dictionary wielu obiektów jednocześnie*/
		--		SELECT @from_page = @from_page + '' '' + dbo.f_getQueryFilter(@query ,@replaceConf_item , '' Item.id '', ''itemId '',''item.v_itemDictionary'', null, null,null ) 
		--	END    


		--/*Filtry - filters*/	
		--DECLARE @tmp_filters TABLE (id int identity(1,1), field nvarchar(255), [value] nvarchar(500))

		--DECLARE @flag_filter VARCHAR(500)

		--INSERT INTO @tmp_filters (field, [value] )
		--SELECT  x.value(''@field'',''nvarchar(50)''),
		--		x.value(''.'',''nvarchar(50)'')
		--FROM @filter.nodes(''column'') AS a(x)

		--SELECT @filter_count = @@ROWCOUNT , @i = 1

		--WHILE @i <= @filter_count
		--	BEGIN
		--		SELECT @field_name = field, @field_value = [value]
		--		FROM @tmp_filters WHERE id = @i
				
		--		IF @field_name = ''code''
		--			SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' Item.code like '''''' + @field_value + ''%'''' ''
		--		ELSE
		--		IF @field_name = ''name''
		--			SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' Item.name like '''''' + @field_value + ''%'''' ''
		--		ELSE
		--		IF @field_name = ''quantity'' 
		--			SELECT	@where = CASE WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' WarehouseStock.quantity  > 0'' WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' ISNULL(WarehouseStock.quantity,0)  = 0'' END 
		--		ELSE
		--		IF @field_name = ''reservedQuantity''
		--			SELECT	@where = CASE WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' WarehouseStock.reservedQuantity  > 0''  WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' ISNULL(WarehouseStock.reservedQuantity,0)  = 0'' END 
		--		ELSE
		--		IF @field_name = ''orderedQuantity''
		--			SELECT	@where = CASE WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' WarehouseStock.orderedQuantity  > 0''  WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' ISNULL(WarehouseStock.orderedQuantity,0)  = 0'' END 
		--		ELSE
		--		IF @field_name = ''available''
		--			SELECT	@where = CASE WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' ( WarehouseStock.quantity - ISNULL( WarehouseStock.reservedQuantity,0 ))  > 0''  WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' ISNULL(WarehouseStock.orderedQuantity,0)  = 0'' END 
		--		ELSE
		--		IF @field_name = ''quantitySum''
		--			SELECT	@where = CASE WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' ISNULL( ( SELECT SUM(w_.quantity) FROM document.WarehouseStock w_ WHERE w_.itemId = item.id ) ,0 ) > 0''  WHEN @field_value = 1 THEN ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + ''  ISNULL( ( SELECT SUM(w_.quantity) FROM document.WarehouseStock w_ WHERE w_.itemId = item.id ) ,0 ) > 0'' END 
		--		ELSE
		--		IF @field_name = ''inventoryId''
		--		/*Foltr do inwentaryzacji, używam niestandardowo magazynu domyślnego jako filtr*/
		--			SELECT	@where =  ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' Item.Id NOT IN (SELECT itemId FROM document.InventorySheet ish WITH(NOLOCK) JOIN document.InventorySheetLine isl  WITH(NOLOCK) ON ish.id = isl.inventorySheetId WHERE ish.status > 0 AND isl.direction > 0 AND ish.inventoryDocumentHeaderId = '''''' + @field_value + '''''' AND ISNULL( CAST( ish.warehouseId as char(36) ) , '''''' + @defWarehouse + '''''') = '''''' + @defWarehouse + '''''' )''
		--		ELSE
		--		IF @field_name = ''availableSum'' AND @field_value = 1
		--			SELECT	@where = ISNULL(NULLIF(@where,'''') + '' AND '','' '' )  + '' ISNULL( ( SELECT SUM(CASE WHEN w_.quantity > ISNULL(w_.reservedQuantity, 0) THEN w_.quantity - ISNULL(w_.reservedQuantity, 0) ELSE 0 END) FROM document.WarehouseStock w_ WHERE w_.itemId = item.id ) ,0 ) > 0''
		--		ELSE
		--		IF @field_name = ''barcode''
		--			SELECT	@from_page	= @from_page + '' JOIN item.ItemAttrValue iav ON iav.itemFieldId = ( SELECT id FROM dictionary.ItemField WHERE [name] = ''''Attribute_Barcode'''' )
		--																			AND iav.textValue = '''''' + @field_value + '''''' AND Item.id = iav.itemId '' 
		--		ELSE
		--		SELECT @where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + @field_name + '' = '''''' + @field_value + ''''''''
		
		--		SELECT @i = @i + 1
		--	END		

		--IF @flag_filter IS NOT NULL
		--	SELECT @where = ISNULL(NULLIF(@where,'''') + '' AND '' ,'' '' ) +  ISNULL( ''( '' + @flag_filter + '' ) '', '' '' ) 


		--	/*Obsługa condition*/        
	 --       IF @condition IS NOT NULL
		--		SELECT @where = ISNULL(@where + '' AND '' + @condition,@condition )
			    
  --			/*Warunki dla grup towarów*/
		--	IF NULLIF(@includeUnassigned, '''') IS NOT NULL 
		--			SELECT  @where = ISNULL( @where + '' AND ( CGM.id IS NULL '', '' ( CGM.id IS NULL ''),
		--					@from = @from + '' LEFT JOIN item.ItemGroupMembership CGM on Item.id = CGM.itemId '',
		--					@select_page = @select_page + '' LEFT JOIN item.ItemGroupMembership CGM on Item.id = CGM.itemId '' 

		--	/*Obsługa grup*/
		--	IF NULLIF(@groups, '''') IS NOT NULL 
		--		BEGIN
		--			IF @where IS NOT NULL 
		--				SELECT  @where = @where
		--						+ CASE WHEN NULLIF(@includeUnassigned, '''') IS NOT NULL
		--							   THEN '' OR ''
		--							   ELSE '' AND ''
		--						  END + '' Item.id IN (SELECT CGM2.itemId FROM item.ItemGroupMembership CGM2 WHERE CGM2.itemGroupId in ('' + @groups + ''))''
		--			ELSE 
		--				SELECT  @where = '' Item.id IN (SELECT CGM2.itemId FROM item.ItemGroupMembership CGM2 WHERE CGM2.itemGroupId in ('' + @groups + ''))''
		--		END

		--/*Uzupełnienie nawiasu po @includeUnassigned*/
		--IF NULLIF(@includeUnassigned, '''') IS NOT NULL 
		--	SELECT  @where = @where + '')''

	     /*Sklejam zapytanie z filtrem stron*/ 
		IF @page <> 0   
			SELECT  @alterQuery =  char(10) +''WHERE i.id >= '' + CAST(@pageSize * ( @page - 1 ) AS VARCHAR(50)) + '' AND i.id <= '' + CAST(@pageSize * ( @page ) AS VARCHAR(50)) + ''  ''
			else
			SELECT  @alterQuery = '' ''	
            
		/*Zapytanie do page*/           
		SELECT @select_page = @select_page + '' '' + @from_page + '' '' + ISNULL( ''WHERE '' + NULLIF(@where,''''),'''') +  ISNULL('' ORDER BY '' + @pageOrder, '''') +'' ; '' + char(10) +''SELECT @count = @@ROWCOUNT ''
	--print @alterQuery

		/*Sklejam zapytanie*/
        SELECT  @exec = @select_page + ''; '' +  @select + '', i.id ''''@ordinalNumber'''' '' + @from  + @alterQuery + ISNULL('' ORDER BY '' + @pageOrder, '''') + char(10) + '' FOR XML PATH(''''priceListHeader''''), TYPE)''  + char(10) + ''SELECT '' + CAST(@page AS VARCHAR(50)) + '' ''''@page'''' ,'' + CAST(@pageSize AS VARCHAR(50))
                + '' ''''@pageSize'''',@count ''''@rowCount'''',@return '' + char(10) + ''FOR XML PATH(''''priceLists'''')''
       print @exec
       EXECUTE ( @exec )
      -- PRINT @exec
    END
' 
END
GO

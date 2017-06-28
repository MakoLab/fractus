/*
name=[warehouse].[p_getShiftTransactions]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
yw+W3VOvXGpHazThd4ET5Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getShiftTransactions]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_getShiftTransactions]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getShiftTransactions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_getShiftTransactions]
@xmlVar XML
AS
BEGIN
        DECLARE @max INT,
            @i INT,
            @column NVARCHAR(255),
            @select NVARCHAR(max),
			@select_page NVARCHAR(MAX),
            @from NVARCHAR(max),
			@from_group NVARCHAR(MAX),
            @from_count NVARCHAR(max),
			@group NVARCHAR(max),
            @where NVARCHAR(max),
            @opakowanie NVARCHAR(max),
            @sortType NCHAR(4),
            @query NVARCHAR(max),
            @relatedObject NVARCHAR(255),
            @dataColumn NVARCHAR(255),
            @documentFieldId UNIQUEIDENTIFIER,
            @exec NVARCHAR(max),
            @condition VARCHAR(500),
            @dateFrom DATETIME,
            @dateTo DATETIME,
            @filtrDat VARCHAR(500),
            @page INT,
            @pageSize INT,
            @alterQuery NVARCHAR(max),
            @sort NVARCHAR(max),
            @sortOrder NVARCHAR(max),
            @pageOrder NVARCHAR(max),
			@filter XML,
			@field_name NVARCHAR(255),
			@field_value NVARCHAR(max),
			@filter_count INT,
			@external_flag INT

		/*Dzielenie wyrażenia query na słowa*/
        DECLARE @tmp_word TABLE
            (
              id INT IDENTITY(1, 1),
              word NVARCHAR(100)
            )

		/*Pobranie liczby kolumn z kofiguracji*/
        SELECT  @max = @xmlVar.query(''<a>{ count(/*/columns/column)}</a>'').value(''a[1]'', ''int''),
                @query = REPLACE(REPLACE(NULLIF(x.query(''query'').value(''.'', ''nvarchar(1000)''),''''), ''*'', ''%''),'''''''','''''''''''') + ''%'',
                @condition = NULLIF(REPLACE(REPLACE(REPLACE(CAST(x.query(''sqlConditions/condition'') AS VARCHAR(MAX)),''</condition><condition>'','') AND (''),''<condition>'', ''( ''),''</condition>'', '') ''), ''''),
                @dateFrom = NULLIF(x.query(''dateFrom'').value(''.'', ''datetime''),''''),
                @dateTo = NULLIF(x.query(''dateTo'').value(''.'', ''datetime''),''''),
                @pageSize = x.query(''pageSize'').value(''.'', ''int''),
                @page = x.query(''page'').value(''.'', ''int''),
				@filter = x.query(''filters/*'')
        FROM    @xmlVar.nodes(''/*'') a(x)
					

        SELECT  @opakowanie = ''	DECLARE @return XML, @from INT, @to INT, @count int;  
								DECLARE @tmp TABLE (id int identity(1,1), shiftId UNIQUEIDENTIFIER); 
 
								'',
				@select_page = ''INSERT INTO  @tmp (shiftId)
								SELECT s.id
								'',
                @select =''		SELECT @return = (  
											SELECT * FROM (
													SELECT tmp.id lp_id, s.id '',
                @from_group = '' FROM warehouse.Shift s WITH(NOLOCK) 
									JOIN warehouse.ShiftTransaction  st WITH(NOLOCK) ON st.id = s.shiftTransactionId 
									JOIN document.WarehouseDocumentLine l WITH(NOLOCK) ON s.incomeWarehouseDocumentLineId = l.id 
									LEFT JOIN warehouse.Container sourceContainer ON sourceContainer.id = [warehouse].[p_getShiftContainer](s.sourceShiftId)
									LEFT JOIN warehouse.Container targetContainer ON targetContainer.id = s.containerId
									 '',
							
				@from = ''		FROM @tmp tmp 
									JOIN warehouse.Shift s WITH(NOLOCK) ON tmp.shiftId = s.id 
									JOIN warehouse.ShiftTransaction  st WITH(NOLOCK) ON st.id = s.shiftTransactionId 
									LEFT JOIN warehouse.Container sourceContainer ON sourceContainer.id = [warehouse].[p_getShiftContainer](s.sourceShiftId)
									LEFT JOIN warehouse.Container targetContainer ON targetContainer.id = s.containerId '',
                @i = 1,
				@sort = ''''


/*-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------Kolumny z konfiguracji----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------*/

		/* Pętla po kolumnach z kofiguracji */
        WHILE @i <= @max 
            BEGIN
            
				/*Dane o kolumni wyświetlanej*/
                SELECT  @column = field,
                        @dataColumn = dataColumn,
                        @documentFieldId = documentFieldId,
                        @sortType = sortType,
                        @relatedObject = relatedObject,
                        @sortOrder = sortOrder
                FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY x.value(''@sortOrder'', ''int'') ) row,
                                    x.value(''@field[1]'', ''nvarchar(255)'') field,
                                    x.value(''@column[1]'', ''nvarchar(255)'') dataColumn,
                                    ISNULL(x.value(''@documentFieldId[1]'',''varchar(36)''), NULL) documentFieldId,
                                    NULLIF(RTRIM(x.value(''@relatedObject[1]'',''nvarchar(255)'')), '''') relatedObject,
                                    x.value(''@sortOrder'', ''int'') sortOrder,
                                    x.value(''@sortType'', ''VARCHAR(50)'') sortType
                          FROM      @xmlVar.nodes(''/*/columns/column'') a ( x )
                        ) sub
                WHERE   row = @i

					/*Dane podstawowe jak: issueDate, number*/				
					IF @dataColumn IN ( SELECT name FROM syscolumns WHERE id = OBJECT_ID( ''warehouse.ShiftTransaction'' )  )  AND @relatedObject IS NULL 
						BEGIN
							SELECT  @select = @select + '' , st.'' + @dataColumn  + '' '' + ISNULL(@column,'''')
	                        
							IF @sortOrder = 1 
									SELECT  
											@pageOrder = ''st.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) + '' '' + ISNULL(@sortType, '''') + '', '',
											@group = @group + ISNULL('', '' + ''st.'' + ISNULL(NULLIF(@dataColumn, ''''),@column) ,'''')
						END
					/*Dane  */				
					IF @dataColumn IN ( SELECT name FROM syscolumns WHERE id = OBJECT_ID( ''warehouse.Shift'' )  )  AND @relatedObject IS NULL 
						BEGIN
							SELECT  @select = @select + '' , s.'' + @dataColumn + '' '' +  ISNULL(@column,'''')
	                        
							IF @sortOrder = 1 
									SELECT  
											@pageOrder = ''s.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) + '' '' + ISNULL(@sortType, '''') + '', '',
											@group = @group + ISNULL('', '' + ''s.'' + ISNULL(NULLIF(@dataColumn, ''''),@column) ,'''')
						END

					IF @dataColumn = ''sourceContainer''
						BEGIN
							SELECT  @select = @select + '' , sourceContainer.symbol '' + @column
	                        
							IF @sortOrder = 1 
									SELECT  
											@pageOrder = '' sourceContainer.symbol '' + ISNULL(@sortType, '''') + '', '',
											@group = @group + '' sourceContainer.symbol '' 
						END
						
					IF @dataColumn = ''targetContainer''
						BEGIN
							SELECT  @select = @select + '' , targetContainer.symbol '' + @column
	                        
							IF @sortOrder = 1 
									SELECT  
											@pageOrder = '' targetContainer.symbol '' + ISNULL(@sortType, '''') + '', '',
											@group = @group + '' targetContainer.symbol '' 
						END
						
				SELECT  @i = @i + 1

            END
		/*KONIEC pętli po kolumnach*/
		

		/*Podział query na słowa kluczowe*/
        IF NULLIF(RTRIM(@query), '''') IS NOT NULL 
            BEGIN
                SET @i = 0
                INSERT  INTO @tmp_word ( word )
                        SELECT  word
                        FROM    xp_split(@query, '' '')

				/*Pętla po splitowanyvh słowach*/
                 WHILE @@rowcount > 0
					BEGIN
						SET @i = @i + 1
						SELECT  @where = ISNULL(@where + '' AND '' ,'''') 
								+ ''   l.id IN ( 
 												 SELECT DISTINCT dr.itemId 
													FROM item.ItemDictionaryRelation dr
													JOIN item.ItemDictionary d on d.id = dr.itemDictionaryId WHERE d.field like ''''''
													+ word + ''%'''' )''
						FROM    @tmp_word
						WHERE   id = @i

					END
            END
            
		/*Warunki SQL */
        IF @condition IS NOT NULL 
            BEGIN
                SELECT  @where = ISNULL( @where + '' '' + '' AND '','''') + @condition 	
            END

		/* Filtr daty */
        IF @dateFrom IS NOT NULL OR @dateTo IS NOT NULL 
                SELECT  @filtrDat =  ISNULL('' st.issueDate >= '''''' + CAST(@dateFrom AS VARCHAR(20)) + '''''' '', '''') + ISNULL('' AND st.issueDate <= '''''' + CAST(@dateTo AS VARCHAR(20)) + '''''' '','''')
	


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
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' cwr_c.id '' + CASE @field_value WHEN  1 THEN '' IS NOT NULL '' WHEN 0 THEN '' IS NULL '' END,
							@from_group = @from_group + '' LEFT JOIN document.CommercialWarehouseRelation cwr_c ON  WarehouseDocumentLine.id = cwr_c.warehouseDocumentLineId  AND cwr_c.isCommercialRelation = 1''
				ELSE
				IF @field_name = ''numberSettingId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' Series.numberSettingId = '''''' + @field_value + '''''''',
								@from_group = @from_group + '' LEFT JOIN document.Series ON WarehouseDocumentHeader.seriesId = Series.id ''
				ELSE
				IF @field_name = ''documentTypeId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' WarehouseDocumentHeader.documentTypeId IN ('' + @field_value + '')''
				ELSE
				IF @field_name = ''documentCategory''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' WarehouseDocumentHeader.documentTypeId IN ( SELECT id FROM dictionary.DocumentType WHERE documentCategory IN ('' + @field_value + ''))''
				ELSE
				IF @field_name = ''status''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' WarehouseDocumentHeader.status IN ('' + @field_value + '')''
				ELSE
				IF @field_name = ''objectExported''
					SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' ( ( em.id IS NOT NULL AND  CAST('' + @field_value + '' AS INT) = 1 ) OR ( em.id IS NULL AND  CAST('' + @field_value + '' AS INT) = 0 ) ) '',
							@from_group	= @from_group + CASE WHEN @external_flag = 0 THEN '' LEFT JOIN accounting.ExternalMapping em WITH(NOLOCK) ON em.id =  WarehouseDocumentHeader.id ''	 ELSE '''' END
				ELSE
				IF @field_name = ''warehouseId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' WarehouseDocumentLine.warehouseId = '''''' + @field_value + '''''''' 
				ELSE
				IF @field_name = ''fullNumber''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' WarehouseDocumentHeader.fullNumber LIKE '''''' + REPLACE(REPLACE(@field_value,''*'',''%'') + ''%'''''' ,''%%'',''%'')
				ELSE
					SELECT @where = ISNULL( @where + '' AND '','' '' )  + @field_name + '' = '''''' + @field_value + ''''''''
		
				SELECT @i = @i + 1
			END		

		/*Sklejam zapytanie z filtrem dat*/
		IF @filtrDat <> ''''
			SELECT  @where = ISNULL(@where + '' AND ''  + @filtrDat  ,@filtrDat )
                              

        
    	/*Sklejam zapytanie z filtrem stron*/    
        SELECT  @alterQuery = '' WHERE tmp.id >= '' + CAST(@pageSize * ( @page - 1 ) AS VARCHAR(50)) + '' AND tmp.id < '' + CAST(@pageSize * ( @page ) AS VARCHAR(50)) + ''  ''
			
 
        /*Do sortowania*/
        IF RTRIM(@pageOrder) <> '''' 
                SELECT  @pageOrder = LEFT(@pageOrder, LEN(@pageOrder) - 1)
	

--select @select, @select_page, @from_group, @group, @where, @pageOrder


		SELECT @select_page	= 
						@select_page + 
						@from_group + ISNULL( '' WHERE '' + @where ,'''') + '' '' + 
						ISNULL(@group,'''') + 
						ISNULL('' ORDER BY '' + NULLIF(@pageOrder ,''''),'''') +
						'' ; SELECT @count = @@rowcount; ''
		
        SELECT  @exec = @opakowanie + @select_page + ISNULL(@exec,'''') + '' '' + @select + '' '' + @from + 
						@alterQuery +  '' ) shifts  
						ORDER BY  shifts.lp_id FOR XML AUTO);
						SELECT '' + CAST(@page AS VARCHAR(50)) + '' ''''@page'''' ,'' + CAST(@pageSize AS VARCHAR(50)) + '' ''''@pageSize'''',@count ''''@rowCount'''', @return 
						FOR XML PATH(''''shifts''''),TYPE ''
SELECT @exec

       EXECUTE ( @exec ) 
    END
' 
END
GO

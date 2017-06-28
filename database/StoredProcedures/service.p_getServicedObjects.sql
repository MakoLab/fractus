/*
name=[service].[p_getServicedObjects]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
aZJUl9uujfWZNfBZYFd7iQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_getServicedObjects]') AND type in (N'P', N'PC'))
DROP PROCEDURE [service].[p_getServicedObjects]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_getServicedObjects]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [service].[p_getServicedObjects] @xmlVar XML
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
            @table VARCHAR(255),
            @select NVARCHAR(max),
            @sortType NCHAR(4),
            @query NVARCHAR(max),
            @dataColumn NVARCHAR(255),
            @exec NVARCHAR(max),
            @condition VARCHAR(max),
			@select_page VARCHAR(max),
			@page INT,
			@pageSize INT,
			@filter XML,
			@field_name NVARCHAR(255),
			@field_value NVARCHAR(max),
			@filter_count INT,
			@columnName nvarchar(100),
			@subQuery nvarchar(4000),
			@replaceConf varchar(8000)


		/*Pobranie liczby kolumn z kofiguracji*/
        SELECT  
				@max = @xmlVar.query(''<a>{ count(/*/columns/column)}</a>'').value(''a[1]'', ''int''),
                @query = ISNULL(REPLACE(REPLACE(RTRIM(NULLIF(@xmlVar.query(''*/query'').value(''.'', ''nvarchar(1000)''),'''')), ''*'', ''%''),'''''''',''''''''''''),'''') + ''%'' ,
                @condition = NULLIF(REPLACE(REPLACE(REPLACE(CAST(@xmlVar.query(''*/sqlConditions/condition'') AS VARCHAR(MAX)),''</condition><condition>'','') AND (''),''<condition>'', ''( ''),''</condition>'', '') ''), ''''),
                @groups = @xmlVar.query(''*/groups'').value(''.'', ''varchar(8000)''),
				@pageSize = @xmlVar.query(''*/pageSize'').value(''.'', ''int''),
                @page = @xmlVar.query(''*/page'').value(''.'', ''int''),
				@filter = @xmlVar.query(''*/filters/*'')



		/*Pobranie konfiguracji*/
		SELECT @replaceConf = xmlValue.value(''(root/indexing/object[@name="item"]/replaceConfiguration)[1]'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''
		
		
        SELECT  @select_page = ''DECLARE @count INT, '' + CHAR(10) + 
							   ''	    @return XML	'' + CHAR(10) + 
							   ''DECLARE @tmp TABLE (id int identity(1,1), servicedObject UNIQUEIDENTIFIER);'' + CHAR(10) + 
							   ''INSERT INTO  @tmp (servicedObject)''  + CHAR(10) + 
							   ''SELECT servicedObject.id '' + CHAR(10) + ''FROM service.ServicedObject WITH(NOLOCK)''  + CHAR(10) , 
				@select = CHAR(10) + CHAR(9) +  ''SELECT @return = ( SELECT DISTINCT servicedObject.id as ''''@id'''' '',
				@from_page = '''',
                @from = CHAR(9) + ''	FROM @tmp i '' + CHAR(10) +  ''	JOIN service.ServicedObject servicedObject WITH(NOLOCK) ON i.servicedObject = servicedObject.id '',
                @i = 1 
		

		/*Pętla po kolumnach z kofiguracji*/
        WHILE @i <= @max 
            BEGIN
				
				/*Dane o kolumni wyświetlanej*/
                SELECT  @column = x.value(''@field[1]'', ''nvarchar(255)''),
                        @dataColumn = x.value(''@column[1]'', ''nvarchar(255)''),
						@sortType = x.value(''@sortType'', ''VARCHAR(50)''),
						@sortOrder = x.value(''@sortOrder'', ''int''),
						@columnName  = NULLIF(x.value(''@columnName'', ''nvarchar(100)''),''''),
						@subQuery = x.value(''@query'', ''nvarchar(4000)'')
                FROM    @xmlVar.nodes(''/*/columns/column[position()=sql:variable("@i")]'') a ( x )
				
				

				/*Kolumna z tabeli ServicedObject*/
                IF @column IN ( ''id'', ''identifier'', ''description'', ''remarks'', ''servicedObjectTypeId'', ''ownerContractorId'',''creationDate'', ''modificationDate'', ''version'' ) 
                    BEGIN 
						IF @sortOrder = 1 
							SELECT  @pageOrder = ISNULL(@pageOrder +  '' , '' + '' servicedObject.'' + @column + '' '' , '' servicedObject.'' + @column + '' '')  + ISNULL(@sortType, '''') 
							
						SELECT  @select = @select + '' , servicedObject.'' + @column + '' AS ''''@'' + @column + ''''''''	
                    END

				/*Generic column*/
                IF @columnName IS NOT NULL 
                    BEGIN
						
						IF @sortOrder = 1 
							SELECT  @pageOrder = ISNULL( @pageOrder + '',  '' + @columnName + ''.'' + @columnName , @columnName + ''.'' + @columnName  ) + '' '' +  ISNULL(@sortType, '''')  

						SELECT  @select = @select + '' ,  '' +  @columnName + ''.'' + @columnName + '' AS ''''@'' + @column + '''''''' ,
								@from_page = @from_page + '' '' + @subQuery ,
								@from = @from + @from_page
							
					END

				/*Kolumna z tabeli Contractor*/
                IF @column IN ( ''fullName'', ''shortName'', ''code'' ) 
                    BEGIN
                        
						IF @sortOrder = 1 
							SELECT  @pageOrder = ISNULL( @pageOrder + '', Contractor.'' + @column + '' '' , '' Contractor.'' + @column + '' '') + ISNULL(@sortType, '''') 
							
						SELECT  @select = @select + '' , Contractor.'' + @column + '' AS ''''@'' + @column + ''''''''	,
								@from_page = @from_page +   CHAR(9) + ''	LEFT JOIN contractor.Contractor ON servicedObject.ownerContractorId = Contractor.id '' + char(10) ,
								@from = @from +  CHAR(9) + ''	LEFT JOIN contractor.Contractor ON servicedObject.ownerContractorId = Contractor.id '' + char(10)
                    END

                SELECT  @i = @i + 1
            END

		/*filtrowanie po query */
		IF @query <> ''%''
			BEGIN
				/*Przeniesione do funkcji, bałagan robił się przy przeszukiwaniu dictionary wielu obiektów jednocześnie*/
				SELECT @from_page = @from_page + '' '' + dbo.f_getQueryFilter(@query ,@replaceConf , '' servicedObject.id  '', ''servicedObjectId '',''[contractor].[v_contractorDictionaryServicedObject]'',''[service].[v_servicedObjects]'', null ,null ) 
				SELECT @from_page = REPLACE(@from_page, ''WITH(NOLOCK) WHERE field like '''''', ''WITH(NOLOCK) WHERE field like ''''%'')
			END    

		/*Obsługa condition*/        
        IF @condition IS NOT NULL
			SELECT @where = ISNULL(@where + '' AND '' + @condition,@condition )



		/*Filtry - filters*/	
		DECLARE @tmp_filters TABLE (id int identity(1,1), field nvarchar(255), [value] nvarchar(max))

		INSERT INTO @tmp_filters (field, [value] )
		SELECT  x.value(''@field'',''nvarchar(50)''),
				x.value(''.'',''nvarchar(max)'')
		FROM @filter.nodes(''column'') AS a(x)

		SELECT @filter_count = @@ROWCOUNT , @i = 1

		/*Pętla po kolumnach filtrowanych*/
		WHILE @i <= @filter_count
			BEGIN
				SELECT @field_name = field, @field_value = [value]
				FROM @tmp_filters WHERE id = @i
				
				IF @field_name = ''contractorId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + CASE WHEN NULLIF( @field_value,'''') IS NULL THEN ''servicedObject.ownerContractorId IS NULL'' ELSE '' (  servicedObject.ownerContractorId = '''''' + @field_value +'''''' ) '' END
				IF @field_name = ''id'' 
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' servicedObject.''+ @field_name + '' ='''''' + @field_value +''''''''
				SELECT @i = @i + 1
			END		




	     /*Sklejam zapytanie z filtrem stron*/ 
		IF @page <> 0   
			SELECT  @alterQuery =  char(10) +'' WHERE i.id > '' + CAST(@pageSize * ( @page - 1 ) AS VARCHAR(50)) + '' AND i.id <= '' + CAST(@pageSize * ( @page ) AS VARCHAR(50)) + ''  ''
		ELSE
			SELECT  @alterQuery = '' ''	
            
		/*Zapytanie do page*/           
		SELECT @select_page = @select_page + '' '' + @from_page + '' '' + ISNULL( ''WHERE '' + NULLIF(@where,''''),'''') +  ISNULL('' ORDER BY '' + @pageOrder, '''') +'' ; '' + char(10) +''SELECT @count = @@ROWCOUNT ''
	

		/*Sklejam zapytanie*/
        SELECT  @exec = @select_page + ''; '' +  @select + '', i.id ''''@ordinalNumber'''' '' + @from  + @alterQuery + ISNULL('' ORDER BY '' + @pageOrder, '''') + char(10) + '' FOR XML PATH(''''servicedObject''''), TYPE)''  + char(10) + ''SELECT '' + CAST(@page AS VARCHAR(50)) + '' ''''@page'''' ,'' + CAST(@pageSize AS VARCHAR(50))
                + '' ''''@pageSize'''',@count ''''@rowCount'''',@return '' + char(10) + ''FOR XML PATH(''''servicedObjects'''')''
PRINT @exec
       EXECUTE ( @exec )
    END
' 
END
GO

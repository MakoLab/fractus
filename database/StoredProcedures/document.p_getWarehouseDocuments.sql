/*
name=[document].[p_getWarehouseDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
KhM7yeW/GeZoyfvFSTsXFA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getWarehouseDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getWarehouseDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getWarehouseDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getWarehouseDocuments] 
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
            @documentFieldId char(36),
			@documentFieldName nvarchar(100),
            @exec NVARCHAR(max),
            @condition VARCHAR(500),
            @dateFrom VARCHAR(50),
            @dateTo VARCHAR(50),
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
			@external_flag INT,
			@replaceConf_item varchar(8000),
			@replaceConf_contractor varchar(8000)
			
		/*Dzielenie wyrażenia query na słowa*/
        DECLARE @tmp_word TABLE
            (
              id INT IDENTITY(1, 1),
              word NVARCHAR(100)
            )


		/*Pobranie konfiguracji*/
		SELECT	@replaceConf_item = xmlValue.query(''root/indexing/object[@name="item"]/replaceConfiguration'').value(''.'', ''varchar(8000)''),
				@replaceConf_contractor = xmlValue.query(''root/indexing/object[@name="contractor"]/replaceConfiguration'').value(''.'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''



		/*Pobranie liczby kolumn z kofiguracji*/
        SELECT  @max = @xmlVar.query(''<a>{ count(/*/columns/column)}</a>'').value(''a[1]'', ''int''),
                @query = REPLACE(REPLACE(NULLIF(x.query(''query'').value(''.'', ''nvarchar(1000)''),''''), ''*'', ''%''),'''''''','''''''''''') + ''%'',
                --@condition = NULLIF(REPLACE(REPLACE(REPLACE(CAST(x.query(''sqlConditions/condition'') AS VARCHAR(MAX)),''</condition><condition>'','') AND (''),''<condition>'', ''( ''),''</condition>'', '') ''), ''''),
                @dateFrom = NULLIF(x.query(''dateFrom'').value(''.'', ''VARCHAR(50)''),''''),
                @dateTo = NULLIF(x.query(''dateTo'').value(''.'', ''VARCHAR(50)''),''''),
                @pageSize = x.query(''pageSize'').value(''.'', ''int''),
                @page = x.query(''page'').value(''.'', ''int''),
				@filter = x.query(''filters/*'')
        FROM    @xmlVar.nodes(''/*'') a(x)
					
		SELECT @condition = (
				SELECT dbo.Concat( '' AND '' + x.value(''(.)[1]'',''varchar(max)'') )
						FROM @xmlVar.nodes(''searchParams/sqlConditions/condition'') a(x)
						)			

        SELECT  @opakowanie = ''	DECLARE @return XML, @from INT, @to INT, @count int;  
								DECLARE @tmp TABLE (id int identity(1,1), warehouseDocument UNIQUEIDENTIFIER); 
 
								'',
				@select_page = ''INSERT INTO  @tmp (warehouseDocument)
								SELECT WarehouseDocumentHeader.id
								'',
                @select = ''SELECT @return = (  SELECT * FROM (SELECT DISTINCT tmp.id ordinalNumber, WarehouseDocumentHeader.id '',
                @from_group = '' FROM document.WarehouseDocumentHeader WITH(NOLOCK) JOIN document.WarehouseDocumentLine WITH(NOLOCK) ON WarehouseDocumentHeader.id = WarehouseDocumentLine.warehouseDocumentHeaderId '',
				@from = '' FROM @tmp tmp JOIN document.WarehouseDocumentHeader WITH(NOLOCK)  ON tmp.warehouseDocument = WarehouseDocumentHeader.id '',
                @i = 1,
				@sort = '''',
				@external_flag = 0,
				@group = '' GROUP BY WarehouseDocumentHeader.id ''

/*-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------Kolumny z konfiguracji----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------*/

		/*Pętla po kolumnach z kofiguracji*/
        WHILE @i <= @max 
            BEGIN
            
				/*Dane o kolumni wyświetlanej*/
                SELECT  @column = field,
                        @dataColumn = dataColumn,
                        @documentFieldId = documentFieldId,
                        @documentFieldName = documentFieldName,
                        @sortType = sortType,
                        @relatedObject = relatedObject,
                        @sortOrder = sortOrder
                FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY x.value(''@sortOrder'', ''int'') ) row,
                                    x.value(''@field[1]'', ''nvarchar(255)'') field,
                                    x.value(''@column[1]'', ''nvarchar(255)'') dataColumn,
                                    NULLIF(ISNULL(x.value(''@documentFieldId[1]'',''varchar(36)''), NULL) ,'''') documentFieldId,
                                    ISNULL(x.value(''@documentFieldName[1]'',''nvarchar(200)''), NULL) documentFieldName,
                                    NULLIF(RTRIM(x.value(''@relatedObject[1]'',''nvarchar(255)'')), '''') relatedObject,
                                    x.value(''@sortOrder'', ''int'') sortOrder,
                                    x.value(''@sortType'', ''VARCHAR(50)'') sortType
                          FROM      @xmlVar.nodes(''/*/columns/column'') a ( x )
                        ) sub
                WHERE   row = @i

				
				/*Kolumna z tabeli CommercialDocumentHeader*/
                IF @column IN ( SELECT name FROM syscolumns WHERE id = OBJECT_ID( ''document.WarehouseDocumentHeader'' )  ) 
                    BEGIN
                        SELECT  @select = @select + '' , WarehouseDocumentHeader.'' + @column
                        
                        IF @sortOrder = 1 
								SELECT  
										@pageOrder = ''WarehouseDocumentHeader.'' + REPLACE(ISNULL(NULLIF(@dataColumn, ''''), @column), ''fullNumber'', ''number'') + '' '' + ISNULL(@sortType, '''') + '', '',
										@group = @group + REPLACE(ISNULL('', '' + ''WarehouseDocumentHeader.'' + ISNULL(NULLIF(@dataColumn, ''''),@column) ,''''), ''fullNumber'', ''number'')
                    END

				/*Kolumna z tabeli ExternalMapping*/
                IF @column IN ( ''objectExported'' ) 
                    BEGIN
						
						SELECT  @from = @from + '' LEFT JOIN accounting.ExternalMapping em WITH(NOLOCK) ON em.id = WarehouseDocumentHeader.id 
													          LEFT JOIN document.ExportStatus es WITH(NOLOCK) ON es.documentId = WarehouseDocumentHeader.id '',
								@from_group = @from_group + '' LEFT JOIN accounting.ExternalMapping em WITH(NOLOCK) ON em.id = WarehouseDocumentHeader.id 
													          LEFT JOIN document.ExportStatus es WITH(NOLOCK) ON es.documentId = WarehouseDocumentHeader.id '',
								@external_flag = 1,
								@select = @select + '' , CASE 
															WHEN es.documentId IS NOT NULL THEN ''''exportedWithErrors''''
															WHEN em.id IS NOT NULL AND em.objectVersion = WarehouseDocumentHeader.version  THEN ''''exportedAndUnchanged'''' 
															WHEN em.id IS NOT NULL AND em.objectVersion <> WarehouseDocumentHeader.version  THEN ''''exportedAndChanged'''' 
															ELSE ''''unexported'''' END  AS objectExported ''

                    END

				/*Kolumna z tabeli DocumentAttrValue*/
                IF @dataColumn IN ( ''decimalValue'', ''dateValue'', ''textValue'',''xmlValue'' ) AND @relatedObject IS NULL 
                    BEGIN
                    
                        SELECT  @select = @select + '' , Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + @dataColumn + '' '' + @column + '' '' ,
								@from_group = @from_group + '' LEFT JOIN document.DocumentAttrValue Dav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Dav'' + CAST(@i AS VARCHAR(10)) + ''.warehouseDocumentHeaderId = WarehouseDocumentHeader.id AND '' + CASE WHEN NULLIF(@documentFieldId,'''') IS NOT NULL THEN '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = '''''' + CAST(ISNULL(@documentFieldId, '''') AS VARCHAR(36)) + '''''''' ELSE '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = (SELECT TOP 1 id FROM dictionary.DocumentField WHERE name = '''''' + ISNULL(@documentFieldName,'''') + '''''' ) '' END ,
                                @from = @from + '' LEFT JOIN document.DocumentAttrValue Dav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Dav'' + CAST(@i AS VARCHAR(10)) + ''.warehouseDocumentHeaderId = WarehouseDocumentHeader.id AND '' + CASE WHEN NULLIF(@documentFieldId,'''') IS NOT NULL THEN '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = '''''' + CAST(ISNULL(@documentFieldId, '''') AS VARCHAR(36)) + '''''''' ELSE '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = (SELECT TOP 1 id FROM dictionary.DocumentField WHERE name = '''''' + ISNULL(@documentFieldName,'''') + '''''' ) '' END 
                                
                        SELECT  @sort = @sort
                                + CASE WHEN @sortOrder <> ''''
                                       THEN NULLIF(@column, '''') + '' '' + ISNULL(@sortType, '''') + '', ''
                                       ELSE ''''
                                  END 
                        IF @sortOrder = 1 
                            SELECT  @pageOrder = ''Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) + '' '' + ISNULL(@sortType, '''') + '', ''
									, @group = ISNULL( @group + '', '','''') +  ''Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column)  
                    END


				IF @dataColumn = ''related''
					BEGIN
					SELECT	@select = @select +  '', CASE WHEN ISNULL(cwr_c.isR,0) < cwr_c.lCount THEN 0 ELSE 1 END related '',
							--@from_group = @from_group + '' LEFT JOIN document.CommercialWarehouseRelation cwr_c ON  WarehouseDocumentLine.id = cwr_c.warehouseDocumentLineId  AND cwr_c.isCommercialRelation = 1 '',
							@from = @from + '' LEFT JOIN (SELECT wl.warehouseDocumentHeaderId ,  SUM(CAST(isCommercialRelation AS int)) isR, count(wl.id) lCount
														FROM document.WarehouseDocumentLine wl WITH(NOLOCK) 
															LEFT JOIN document.CommercialWarehouseRelation r ON  wl.id = r.warehouseDocumentLineId  AND r.isCommercialRelation = 1 
														GROUP BY  wl.warehouseDocumentHeaderId ) cwr_c ON  cwr_c.warehouseDocumentHeaderId = WarehouseDocumentHeader.id ''
					END 
					
				/*Dane kontrahenta*/
                IF @dataColumn IN ( ''fullName'', ''shortName'', ''nip'', ''code'' ) AND @relatedObject IS NOT NULL 
                    BEGIN
                        SELECT  @select = @select + '' , Con''
                                + CAST(@i AS VARCHAR(10)) + ''.'' + @dataColumn
                                + '' '' + @column + '' '' 

                        SELECT  @from = @from + '' LEFT JOIN contractor.Contractor Con'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Con'' + CAST(@i AS VARCHAR(10)) + ''.id = WarehouseDocumentHeader.''
									+ CASE WHEN @relatedObject = ''contractor''
										   THEN ''contractorId ''
										   WHEN @relatedObject = ''receivingPersonContractor''
										   THEN ''receivingPersonContractorId ''
									  END,
								@from_group = @from_group + '' LEFT JOIN contractor.Contractor Con'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Con'' + CAST(@i AS VARCHAR(10)) + ''.id = WarehouseDocumentHeader.''
									+ CASE WHEN @relatedObject = ''contractor''
										   THEN ''contractorId ''
										   WHEN @relatedObject = ''receivingPersonContractor''
										   THEN ''receivingPersonContractorId ''
									  END

                        IF @sortOrder = 1 
                            SELECT  @pageOrder = ''Con'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) + '' '' + ISNULL(@sortType, '''') + '', '',
									@group = @group +	'', Con'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column)
                    END

                SELECT  @i = @i + 1

            END
		/*KONIEC pętli po kolumnach*/
		


		/*Podział query na słowa kluczowe*/
        IF NULLIF(RTRIM(@query), '''') IS NOT NULL 
			SELECT @from_group = @from_group + dbo.f_getQueryFilter(@query ,@replaceConf_item , '' WarehouseDocumentHeader.id'', ''warehouseDocumentHeaderId'',''item.[v_itemDictionaryWarehouseDocument] '' ,''contractor.v_contractorDictionaryWarehouseDocument '', null, NULL )  


        IF @condition IS NOT NULL 
            BEGIN
                SELECT  @where = ''1 = 1'' + @condition 	
            END

		/* Filtr daty */
        IF @dateFrom IS NOT NULL OR @dateTo IS NOT NULL 
                SELECT  @filtrDat =  ISNULL('' issueDate >= '''''' + CAST(@dateFrom AS VARCHAR(50)) + '''''' '', '''') + ISNULL('' AND issueDate <= '''''' + CAST(@dateTo AS VARCHAR(50)) + '''''' '','''')
	
		/*Filtry - filters*/	
		DECLARE @tmp_filters TABLE (id int identity(1,1), field nvarchar(255), [value] nvarchar(max), documentFieldId varchar(36), documentFieldName nvarchar(200))

		INSERT INTO @tmp_filters (field, [value], documentFieldId, documentFieldName )
		SELECT  x.value(''@field'',''nvarchar(50)''),
				x.value(''.'',''nvarchar(max)''),
				ISNULL(x.value(''@documentFieldId[1]'',''varchar(36)''), NULL) ,
                ISNULL(x.value(''@documentFieldName[1]'',''nvarchar(200)''), NULL) 
		FROM @filter.nodes(''column'') AS a(x)

		SELECT @filter_count = @@ROWCOUNT , @i = 1

		WHILE @i <= @filter_count
			BEGIN
				SELECT @field_name = field, @field_value = [value], @documentFieldId = documentFieldId, @documentFieldName = documentFieldName
				FROM @tmp_filters WHERE id = @i

				IF @field_name = ''related''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' cwr_c.id '' + CASE @field_value WHEN  1 THEN '' IS NOT NULL '' WHEN 0 THEN '' IS NULL '' END,
							@from_group = @from_group + '' LEFT JOIN document.CommercialWarehouseRelation cwr_c ON  WarehouseDocumentLine.id = cwr_c.warehouseDocumentLineId  AND cwr_c.isCommercialRelation = 1 ''
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
					SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' (
																CASE 
																WHEN es.documentId IS NOT NULL THEN ''''exportedWithErrors''''
																WHEN em.id IS NOT NULL AND em.objectVersion = WarehouseDocumentHeader.version  THEN ''''exportedAndUnchanged'''' 
																WHEN em.id IS NOT NULL AND em.objectVersion <> WarehouseDocumentHeader.version  THEN ''''exportedAndChanged'''' 
																ELSE ''''unexported'''' END   = '''''' + @field_value  + '''''' ) '',
				
							@from_group	= @from_group + CASE WHEN @external_flag = 0 THEN '' LEFT JOIN accounting.ExternalMapping em WITH(NOLOCK) ON em.id =  WarehouseDocumentHeader.id ''	 ELSE '''' END
				ELSE
				/*Dane z tabeli accounting.DocumentData */
                IF @field_name =  ''hasDecree'' 
					SELECT  @from_group = @from_group + '' LEFT JOIN accounting.DocumentData dd WITH(NOLOCK) ON dd.WarehouseDocumentId = WarehouseDocumentHeader.id '',
							@where = ISNULL(@where + '' AND '' , '' '' ) + '' dd.id IS ''	+ CASE WHEN @field_value = 1 THEN '' NOT NULL '' ELSE '' NULL '' END	
				ELSE
				IF @field_name = ''warehouseId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' WarehouseDocumentLine.warehouseId = '''''' + @field_value + '''''''' 
				ELSE
				IF @field_name = ''fullNumber''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' WarehouseDocumentHeader.fullNumber LIKE '''''' + REPLACE(REPLACE(@field_value,''*'',''%'') + ''%'''''' ,''%%'',''%'')
				ELSE
				IF @field_name = ''number''
					BEGIN
						IF (CHARINDEX(''\'',@field_value ) > 0)  OR CHARINDEX(''/'',@field_value ) > 0
							BEGIN
								SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' WarehouseDocumentHeader.fullNumber LIKE '''''' + REPLACE(REPLACE(@field_value,''*'',''%'') + ''%'''''' ,''%%'',''%'')
							END
						ELSE
							BEGIN	
								SELECT @field_value = REPLACE(REPLACE( @field_value, substring( @field_value,PATINDEX(''%[^ 0-9]%'',@field_value),1),'',''),'' '','''')
								SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CAST(WarehouseDocumentHeader.number AS varchar(500)) in ( '' + @field_value + '')''
							END
					END
					--BEGIN
					--	SELECT @field_value = REPLACE(REPLACE( @field_value, substring( @field_value,PATINDEX(''%[^ 0-9]%'',@field_value),1),'',''),'' '','''')
					--	SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' WarehouseDocumentHeader.number in ( '' + @field_value + '')''
					--END	
				ELSE	
				IF @field_name IN( ''decimalValue'', ''dateValue'', ''textValue'' )
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' WarehouseDocumentHeader.id IN   ( SELECT warehouseDocumentHeaderId FROM document.DocumentAttrValue Dav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) WHERE  '' + CASE WHEN NULLIF(@documentFieldId,'''') IS NOT NULL THEN '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = '''''' + CAST(ISNULL(@documentFieldId, '''') AS VARCHAR(36)) + '''''''' ELSE '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = (SELECT TOP 1 id FROM dictionary.DocumentField WHERE name = '''''' + ISNULL(@documentFieldName,'''') + '''''' ) '' END  + '' AND  Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + @field_name + '' = '''''' + @field_value + '''''') ''
				ELSE
					SELECT @where = ISNULL( @where + '' AND '','' '' )  + @field_name + '' = '''''' + @field_value + ''''''''
		
				SELECT @i = @i + 1
			END		

		/*Sklejam zapytanie z filtrem dat*/
		IF @filtrDat <> ''''
			SELECT  @where = ISNULL(@where + '' AND ''  + @filtrDat  ,@filtrDat )
                              

        
    	/*Sklejam zapytanie z filtrem stron*/    
        SELECT  @alterQuery = '' WHERE tmp.id > '' + CAST(@pageSize * ( @page - 1 ) AS VARCHAR(50)) + '' AND tmp.id <= '' + CAST(@pageSize * ( @page ) AS VARCHAR(50)) + ''  ''
			
 
        /*Do sortowania*/
        IF RTRIM(@pageOrder) <> '''' 
            BEGIN
                SELECT  
                        @pageOrder = LEFT(@pageOrder, LEN(@pageOrder) - 1)
                SELECT  @select = REPLACE(@select,''ORDER BY WarehouseDocumentHeader.id'',''ORDER BY '' + ISNULL(@pageOrder, ''''))
            END 
		/*Fragment podsumowań*/
		DECLARE @SUMATION nvarchar(4000)
		SELECT @SUMATION = '' DECLARE @netValue decimal(18,2);
							 SELECT @netValue = SUM(value) FROM @tmp t JOIN document.WarehouseDocumentHeader h ON t.warehouseDocument = h.id; ''
							 
		SELECT @select_page	= @select_page	+ @from_group + ISNULL( '' WHERE '' + @where ,'''') + '' ''  + @group  + ISNULL('' ORDER BY '' + NULLIF(@pageOrder ,''''),'''') + '' ; SELECT @count = @@rowcount; '' + @SUMATION
		
        SELECT  @exec = @opakowanie + @select_page + ISNULL(@exec,'''') + '' '' + @select + '' '' + @from
                + @alterQuery +  '' ) warehouseDocumentHeader  ORDER BY  warehouseDocumentHeader.ordinalNumber FOR XML AUTO);
				 SELECT '' + CAST(@page AS VARCHAR(50)) + '' ''''@page'''' ,'' + CAST(@pageSize AS VARCHAR(50)) + '' ''''@pageSize'''',@count ''''@rowCount'''',  @netValue ''''@netValue'''' , @return FOR XML PATH(''''warehouseDocuments''''),TYPE ''
	   print @exec
       EXECUTE ( @exec ) 
    END
' 
END
GO

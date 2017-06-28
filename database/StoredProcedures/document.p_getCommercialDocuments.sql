/*
name=[document].[p_getCommercialDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ejb9W93vfqWTAOCSR774rQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCommercialDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getCommercialDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCommercialDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getCommercialDocuments] @xmlVar XML
AS
BEGIN
        DECLARE 
			@max INT,
            @i INT,
            @column NVARCHAR(255),
            @select NVARCHAR(max),
			@select_page NVARCHAR(MAX),
            @from NVARCHAR(max),
			@from_group NVARCHAR(MAX),
            @from_count NVARCHAR(max),
			@group_by NVARCHAR(max),
            @where NVARCHAR(max),
            @opakowanie NVARCHAR(max),
            @sortType NCHAR(4),
            @query NVARCHAR(max),
            @relatedObject NVARCHAR(255),
            @dataColumn NVARCHAR(255),
            @documentFieldId CHAR(36),
            @exec NVARCHAR(max),
            @condition VARCHAR(max),
            @dateFrom varchar(50),
            @dateTo varchar(50),
            @filtrDat VARCHAR(200),
            @page INT,
            @pageSize INT,
            @alterQuery NVARCHAR(4000),
            @sort NVARCHAR(1000),
            @sortOrder NVARCHAR(max),
            @pageOrder NVARCHAR(max),
			@filter XML,
			@field_name NVARCHAR(255),
			@field_value NVARCHAR(MAX),
			@filter_count INT,
			@external_flag INT,
			@servicedObject_flag INT,
			@replaceConf_item VARCHAR(8000),
			@replaceConf_contractor VARCHAR(8000),
			@replaceConf_commercialDoc VARCHAR(8000),
			@subQuery nvarchar(4000),
			@columnName nvarchar(100),
			@reportType nvarchar(100),
			@documentFieldName nvarchar(100),
			@sqlFilter xml

		/*Dzielenie wyrażenia query na słowa*/
        DECLARE @tmp_word TABLE
            (
              id INT IDENTITY(1, 1),
              word NVARCHAR(100)
            )

		/*Pobranie konfiguracji*/
		SELECT	@replaceConf_item = xmlValue.query(''root/indexing/object[@name="item"]/replaceConfiguration'').value(''.'', ''varchar(8000)''),
				@replaceConf_contractor = xmlValue.query(''root/indexing/object[@name="contractor"]/replaceConfiguration'').value(''.'', ''varchar(8000)''),
				@replaceConf_commercialDoc = xmlValue.query(''root/indexing/object[@name="commercialDocument"]/replaceConfiguration'').value(''.'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''
		

		/*Pobranie liczby kolumn z kofiguracji*/
        SELECT  @max = @xmlVar.query(''<a>{ count(/*/columns/column)}</a>'').value(''a[1]'', ''int''),
                @query = REPLACE(REPLACE(NULLIF(x.query(''query'').value(''.'', ''nvarchar(1000)''),''''), ''*'', ''%''),'''''''','''''''''''') + ''%'',
                --@condition = NULLIF(REPLACE(REPLACE(REPLACE(CAST(x.query(''sqlConditions/condition/text()'') AS VARCHAR(MAX)),''</condition><condition>'','') AND (''),''<condition>'', ''( ''),''</condition>'', '') ''), ''''),
                @dateFrom = NULLIF(x.query(''dateFrom'').value(''.'', ''varchar(50)''),''''),
                @dateTo = NULLIF(x.query(''dateTo'').value(''.'', ''varchar(50)''),''''),
                @pageSize = x.query(''pageSize'').value(''.'', ''int''),
                @page = x.query(''page'').value(''.'', ''int''),
				@filter = x.query(''filters/*''),
				@reportType = x.value(''(@type)[1]'',''nvarchar(100)'')
        FROM    @xmlVar.nodes(''/*'') a(x)
			
		SELECT @condition = (
				SELECT dbo.Concat( '' AND '' + x.value(''(.)[1]'',''varchar(max)'') )
						FROM @xmlVar.nodes(''searchParams/sqlConditions/condition[string-length(@filterId) = 0]'') a(x)
						)
		SELECT @sqlFilter = x.query(''../../sqlConditions'') FROM @xmlVar.nodes(''searchParams/sqlConditions/condition[string-length(@filterId) > 0]'') a(x)

        SELECT  @opakowanie = ''	DECLARE @return XML, @from INT, @to INT, @count int;  
								DECLARE @tmp TABLE (id int identity(1,1), commercialDocument UNIQUEIDENTIFIER); 
 
								'',
				@select_page = ''INSERT INTO  @tmp (commercialDocument)
								SELECT CommercialDocumentHeader.id
								'',
                @select = ''SELECT @return = (  SELECT * FROM (SELECT DISTINCT tmp.id id_lp, CommercialDocumentHeader.id '',
                @from_group = '' FROM document.CommercialDocumentHeader WITH(NOLOCK) 
									LEFT JOIN document.CommercialDocumentLine WITH(NOLOCK) ON CommercialDocumentHeader.id = CommercialDocumentLine.commercialDocumentHeaderId 
									LEFT JOIN dictionary.DocumentType dt WITH(nolock) ON CommercialDocumentHeader.documentTypeId = dt.id
									'',
				@from = '' FROM @tmp tmp 
							JOIN document.CommercialDocumentHeader WITH(NOLOCK)  ON tmp.commercialDocument = CommercialDocumentHeader.id 
							LEFT JOIN document.CommercialDocumentLine WITH(NOLOCK) ON CommercialDocumentHeader.id = CommercialDocumentLine.commercialDocumentHeaderId  
							 '',
                @i = 1,
				@external_flag = 0,
				@servicedObject_flag = 0,
                @sort = '''' 


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
                        @sortOrder = sortOrder,
						@columnName  = columnName,
						@subQuery = subQuery
                FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY x.value(''@sortOrder'', ''int'') ) row,
                                    x.value(''@field[1]'', ''nvarchar(255)'') field,
                                    x.value(''@column[1]'', ''nvarchar(255)'') dataColumn,
                                    ISNULL(x.value(''@documentFieldId[1]'',''varchar(36)''), NULL) documentFieldId,
                                    ISNULL(x.value(''@documentFieldName[1]'',''nvarchar(200)''), NULL) documentFieldName,
                                    NULLIF(RTRIM(x.value(''@relatedObject[1]'',''nvarchar(255)'')), '''') relatedObject,
                                    x.value(''@sortOrder'', ''int'') sortOrder,
                                    x.value(''@sortType'', ''VARCHAR(50)'') sortType,
									NULLIF(x.value(''@columnName'', ''nvarchar(100)''),'''') columnName,
									x.value(''@query'', ''nvarchar(4000)'') subQuery
                          FROM      @xmlVar.nodes(''/*/columns/column'') a ( x )
                        ) sub
                WHERE   row = @i

				
				/*Kolumna z tabeli CommercialDocumentHeader*/
                IF @column IN ( SELECT name FROM syscolumns WHERE id = OBJECT_ID( ''document.CommercialDocumentHeader'' )  ) 
                    BEGIN/*FIXME*/
                        SELECT  @select = @select + '' , CommercialDocumentHeader.'' + ISNULL(@column,'''') + '' '' + ISNULL(@dataColumn,'''')
                        
                        SELECT  @sort = @sort
                                + CASE WHEN @sortOrder <> ''''
                                       THEN ''CommercialDocumentHeader.'' + ISNULL(NULLIF(@dataColumn, ''''),@column) + '' '' + ISNULL(@sortType, '''') + '', ''
                                       ELSE ''''
                                  END
						
                        IF @sortOrder = 1 
                            SELECT  @pageOrder = ''CommercialDocumentHeader.''+REPLACE(ISNULL(NULLIF(@dataColumn, ''''), @column), ''fullNumber'', ''number'') + '' '' + ISNULL(@sortType, '''') + '', '',
									@group_by = '',  CommercialDocumentHeader.'' + REPLACE( ISNULL(NULLIF(@dataColumn, ''''), @column), ''fullNumber'', ''number'')
                    END
                    
				/*Kolumna z tabeli servicedObject*/
                IF @column IN ( ''servicedObjectDescription'', ''servicedObjectIdentifier'' ) 
                    BEGIN/*FIXME*/
                        SELECT  @select = @select + '' , xx.'' + @dataColumn 
						IF @servicedObject_flag = 0
							BEGIN
								SELECT  @from = @from + '' LEFT JOIN (	SELECT so.description , so.identifier , sso.serviceHeaderId
																		FROM service.ServiceHeaderServicedObjects sso WITH(NOLOCK) 
																			LEFT JOIN service.ServicedObject so WITH(NOLOCK) ON sso.servicedObjectId = so.id 
																	) xx ON xx.serviceHeaderId = tmp.commercialDocument	'',
										@from_group = @from_group + ''   LEFT JOIN (		SELECT so.description, so.identifier , sso.serviceHeaderId
																						FROM service.ServiceHeaderServicedObjects sso WITH(NOLOCK)  
																							LEFT JOIN service.ServicedObject so WITH(NOLOCK) ON sso.servicedObjectId = so.id 
																				) xx ON  xx.serviceHeaderId = CommercialDocumentHeader.id  ''

								SELECT  @sort = @sort
										+ CASE WHEN @sortOrder <> ''''
											   THEN ISNULL('' xx.'' + NULLIF(@dataColumn, ''''),'''') + '' '' + ISNULL(@sortType, '''') + '', ''
											   ELSE ''''
										  END,
									    @servicedObject_flag = 1
							END
                        IF @sortOrder = 1 
                            SELECT  @pageOrder = REPLACE(ISNULL(NULLIF(@dataColumn, ''''), @column), ''fullNumber'', ''number'') + '' '' + ISNULL(@sortType, '''') + '', '',
									@group_by = '', '' + REPLACE( ISNULL(NULLIF(@dataColumn, ''''), @column), ''fullNumber'', ''number'')
                    END
                    
                    
				/*Kolumna z tabeli ExternalMapping*/
               
                    IF @column IN ( ''objectExported'' ) 
                        BEGIN
							
							SELECT  @from = @from + '' LEFT JOIN accounting.ExternalMapping em WITH(NOLOCK) ON em.id = CommercialDocumentHeader.id 
													  LEFT JOIN document.ExportStatus es WITH(NOLOCK) ON es.documentId = CommercialDocumentHeader.id '',
									@from_group = @from_group + '' LEFT JOIN accounting.ExternalMapping em WITH(NOLOCK) ON em.id = CommercialDocumentHeader.id 
													  LEFT JOIN document.ExportStatus es WITH(NOLOCK) ON es.documentId = CommercialDocumentHeader.id '',
									@external_flag = 1,
									@select = @select + '' , CASE 
																WHEN es.documentId IS NOT NULL THEN ''''exportedWithErrors''''
																WHEN em.id IS NOT NULL AND em.objectVersion = CommercialDocumentHeader.version  THEN ''''exportedAndUnchanged'''' 
																WHEN em.id IS NOT NULL AND em.objectVersion <> CommercialDocumentHeader.version  THEN ''''exportedAndChanged'''' 
																ELSE ''''unexported'''' END  AS objectExported ''

                        END


				/*Kolumna marża*/
               
                    IF @column IN ( ''profit'' ) 
                        BEGIN
							
							SELECT  @from = @from + ''LEFT JOIN (		SELECT  SUM(ISNULL(ll.value,0)) value ,  l.commercialDocumentHeaderId
																FROM document.CommercialWarehouseRelation v WITH(NOLOCK) 
																JOIN document.WarehouseDocumentLine ll WITH(NOLOCK) ON v.warehouseDocumentLineId = ll.id 
																JOIN document.CommercialDocumentLine l on v.commercialDocumentLineId = l.id
																Group by  l.commercialDocumentHeaderId 
																                      /*SELECT SUM(ISNULL(value,0)) value , commercialDocumentHeaderId
																		FROM document.CommercialWarehouseValuation cwv WITH(NOLOCK) 
																			JOIN document.CommercialDocumentLine l ON cwv.commercialDocumentLineId = l.id
																		GROUP BY commercialDocumentHeaderId*/
																) cost ON CommercialDocumentHeader.id = cost.commercialDocumentHeaderId
													 '',
									@from_group = @from_group +''LEFT JOIN (		SELECT  SUM(ISNULL(ll.value,0)) value ,  l.commercialDocumentHeaderId
																FROM document.CommercialWarehouseRelation v WITH(NOLOCK) 
																JOIN document.WarehouseDocumentLine ll WITH(NOLOCK) ON v.warehouseDocumentLineId = ll.id 
																JOIN document.CommercialDocumentLine l on v.commercialDocumentLineId = l.id
																Group by  l.commercialDocumentHeaderId 
																                      /*SELECT SUM(ISNULL(value,0)) value , commercialDocumentHeaderId
																		FROM document.CommercialWarehouseValuation cwv WITH(NOLOCK) 
																			JOIN document.CommercialDocumentLine l ON cwv.commercialDocumentLineId = l.id
																		GROUP BY commercialDocumentHeaderId*/
																) cost ON CommercialDocumentHeader.id = cost.commercialDocumentHeaderId
													'',
									@external_flag = 1,
									@select = @select + '' , ROUND(( (CommercialDocumentHeader.sysNetValue - NULLIF(cost.value,0)) /NULLIF(CommercialDocumentHeader.sysNetValue,0))  * 100,  2)  AS profit ''

                        END
                        
                    IF @column IN ( ''profitValue'' ) 
                        BEGIN
							
							SELECT  @from = @from + '' LEFT JOIN (		SELECT  SUM(ISNULL(ll.value,0)) value ,  l.commercialDocumentHeaderId
																FROM document.CommercialWarehouseRelation v WITH(NOLOCK) 
																JOIN document.WarehouseDocumentLine ll WITH(NOLOCK) ON v.warehouseDocumentLineId = ll.id 
																JOIN document.CommercialDocumentLine l on v.commercialDocumentLineId = l.id
																Group by  l.commercialDocumentHeaderId 
																                      /*SELECT SUM(ISNULL(value,0)) value , commercialDocumentHeaderId
																		FROM document.CommercialWarehouseValuation cwv WITH(NOLOCK) 
																			JOIN document.CommercialDocumentLine l ON cwv.commercialDocumentLineId = l.id
																		GROUP BY commercialDocumentHeaderId*/
																) cost2 ON CommercialDocumentHeader.id = cost2.commercialDocumentHeaderId
													 '',
									@from_group = @from_group +'' LEFT JOIN (		SELECT  SUM(ISNULL(ll.value,0)) value ,  l.commercialDocumentHeaderId
																FROM document.CommercialWarehouseRelation v WITH(NOLOCK) 
																JOIN document.WarehouseDocumentLine ll WITH(NOLOCK) ON v.warehouseDocumentLineId = ll.id 
																JOIN document.CommercialDocumentLine l on v.commercialDocumentLineId = l.id
																Group by  l.commercialDocumentHeaderId 
																                      /*SELECT SUM(ISNULL(value,0)) value , commercialDocumentHeaderId
																		FROM document.CommercialWarehouseValuation cwv WITH(NOLOCK) 
																			JOIN document.CommercialDocumentLine l ON cwv.commercialDocumentLineId = l.id
																		GROUP BY commercialDocumentHeaderId*/
																) cost2 ON CommercialDocumentHeader.id = cost2.commercialDocumentHeaderId
													'',
									@external_flag = 1,
									@select = @select + '' , ROUND(( CommercialDocumentHeader.sysNetValue - NULLIF(cost.value,0))  ,  2)  AS profitValue ''

                        END

                    IF @column IN ( ''hasNegativeProfit'' ) 
                        BEGIN
							SELECT  @from = @from + '' LEFT JOIN (	SELECT SUM(value) value,	commercialDocumentHeaderId 
																	FROM	(
																		SELECT CASE WHEN ABS(l.sysNetValue) -  ABS(sum(ISNULL(ll.value,0))) < 0 THEN 1 ELSE 0 END  value , commercialDocumentHeaderId
																FROM document.CommercialWarehouseRelation v WITH(NOLOCK) 
																JOIN document.WarehouseDocumentLine ll WITH(NOLOCK) ON v.warehouseDocumentLineId = ll.id 
																JOIN document.CommercialDocumentLine l on v.commercialDocumentLineId = l.id
																Group by  l.commercialDocumentHeaderId , l.sysNetValue, l.id
																                      /*SELECT CASE WHEN ABS(l.sysNetValue) -  ABS(sum(ISNULL(value,0))) < 0 THEN 1 ELSE 0 END  value , commercialDocumentHeaderId
																		FROM document.CommercialDocumentLine l WITH(NOLOCK) 
																			JOIN document.CommercialWarehouseValuation cwv ON cwv.commercialDocumentLineId = l.id
																		GROUP BY commercialDocumentHeaderId, l.sysNetValue,l.id*/
																		) x
																		GROUP BY x.commercialDocumentHeaderId
																) NegativeProfit ON CommercialDocumentHeader.id = NegativeProfit.commercialDocumentHeaderId
													 '',
									@from_group = @from_group +'' LEFT JOIN (		SELECT SUM(value) value,	commercialDocumentHeaderId 
																					FROM	(
																						SELECT CASE WHEN ABS(l.sysNetValue) -  ABS(sum(ISNULL(ll.value,0))) < 0 THEN 1 ELSE 0 END  value , commercialDocumentHeaderId
																FROM document.CommercialWarehouseRelation v WITH(NOLOCK) 
																JOIN document.WarehouseDocumentLine ll WITH(NOLOCK) ON v.warehouseDocumentLineId = ll.id 
																JOIN document.CommercialDocumentLine l on v.commercialDocumentLineId = l.id
																Group by  l.commercialDocumentHeaderId , l.sysNetValue, l.id
																                      /*SELECT CASE WHEN ABS(l.sysNetValue) -  ABS(sum(ISNULL(value,0))) < 0 THEN 1 ELSE 0 END  value , commercialDocumentHeaderId
																						FROM document.CommercialDocumentLine l WITH(NOLOCK) 
																			JOIN document.CommercialWarehouseValuation cwv ON cwv.commercialDocumentLineId = l.id
																						GROUP BY commercialDocumentHeaderId, l.sysNetValue, l.id*/
																						) x
																					GROUP BY x.commercialDocumentHeaderId
																) NegativeProfit ON CommercialDocumentHeader.id = NegativeProfit.commercialDocumentHeaderId
													'',
									@external_flag = 1,
									@select = @select + '' , CASE WHEN NegativeProfit.value >= 1 THEN 1 ELSE 0 END  AS hasNegativeProfit ''

                        END
                     
				/*Kolumna z tabeli DocumentAttrValue*/
                IF @dataColumn IN ( ''decimalValue'', ''dateValue'', ''textValue'',''xmlValue'' ) AND @relatedObject IS NULL 
                    BEGIN
                   
                        SELECT  @select = @select + '' , Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + @dataColumn + '' '' + @column + '' '',
								@from_group = @from_group + '' LEFT JOIN document.DocumentAttrValue Dav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Dav'' + CAST(@i AS VARCHAR(10)) + ''.commercialDocumentHeaderId = CommercialDocumentHeader.id AND '' + CASE WHEN NULLIF(@documentFieldId,'''') IS NOT NULL THEN '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = '''''' + CAST(ISNULL(@documentFieldId, '''') AS VARCHAR(36)) + '''''''' ELSE '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = (SELECT TOP 1 id FROM dictionary.DocumentField WHERE name = '''''' + ISNULL(@documentFieldName,'''') + '''''' ) '' END ,
                                @from = @from + '' LEFT JOIN document.DocumentAttrValue Dav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Dav'' + CAST(@i AS VARCHAR(10)) + ''.commercialDocumentHeaderId = CommercialDocumentHeader.id AND '' + CASE WHEN NULLIF(@documentFieldId,'''') IS NOT NULL THEN '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = '''''' + CAST(ISNULL(@documentFieldId, '''') AS VARCHAR(36)) + '''''''' ELSE '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = (SELECT TOP 1 id FROM dictionary.DocumentField WHERE name = '''''' + ISNULL(@documentFieldName,'''') + '''''' ) '' END 
                                
                        SELECT  @sort = @sort
                                + CASE WHEN @sortOrder <> ''''
                                       THEN NULLIF(@column, '''') + '' '' + ISNULL(@sortType, '''') + '', ''
                                       ELSE ''''
                                  END 
                        IF @sortOrder = 1 
                            SELECT  @pageOrder = ''Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) + '' '' + ISNULL(@sortType, '''') + '', '',
									@group_by = '', '' +  ''Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column)  
                    END

				/*Kolumna z tabeli DocumentAttrValue*/
                IF @dataColumn IN ( ''orderStatus'' ) 
                    BEGIN
                        SELECT  @select = @select + '' , CASE WHEN ISNULL(xx.quantity ,0) = 0 THEN 1 ELSE 0 END  orderStatus'',
                                @from = @from + '' LEFT JOIN (SELECT  SUM(ABS(cl.quantity)) - SUM(ISNULL(r_c.quantity,0)) quantity , cl.CommercialDocumentHeaderId FROM document.CommercialDocumentLine cl WITH(NOLOCK) LEFT JOIN document.CommercialWarehouseRelation r_c WITH(NOLOCK) ON  cl.id = r_c.commercialDocumentLineId GROUP BY cl.CommercialDocumentHeaderId ) xx ON CommercialDocumentLine.CommercialDocumentHeaderId = xx.CommercialDocumentHeaderId ''
                    END

				/*Dane kontrahenta*/
                IF @dataColumn IN ( ''fullName'', ''shortName'', ''nip'', ''code'' )
                    AND @relatedObject IS NOT NULL 
                    BEGIN
                        SELECT  @select = @select + '' , Con''
                                + CAST(@i AS VARCHAR(10)) + ''.'' + @dataColumn
                                + '' '' + @column + '' '' 

                        SELECT  @from = @from + '' LEFT JOIN contractor.Contractor Con'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Con'' + CAST(@i AS VARCHAR(10)) + ''.id = CommercialDocumentHeader.''
									+ CASE WHEN @relatedObject = ''contractor''
										   THEN ''contractorId ''
										   WHEN @relatedObject = ''receivingPersonContractor''
										   THEN ''receivingPersonContractorId ''
									  END,
								@from_group = @from_group + '' LEFT JOIN contractor.Contractor Con'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Con'' + CAST(@i AS VARCHAR(10)) + ''.id = CommercialDocumentHeader.''
									+ CASE WHEN @relatedObject = ''contractor''
										   THEN ''contractorId ''
										   WHEN @relatedObject = ''receivingPersonContractor''
										   THEN ''receivingPersonContractorId ''
									  END

                        SELECT  @sort = @sort
                                + CASE WHEN @sortOrder <> ''''
                                       THEN ISNULL(@column, '''') + '' '' + ISNULL(@sortType, '''') + '', ''
                                       ELSE ''''
                                  END 
						
                        IF @sortOrder = 1 
                            SELECT  @pageOrder = ''Con'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) + '' '' + ISNULL(@sortType, '''') + '', '',
									@group_by = '', '' + ''Con'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) 
                    END

				/*Generic column*/
				IF @columnName IS NOT NULL --@column IN ( ''genericColumn'' ) 
					BEGIN
						SELECT  @select = @select + '' ,  '' +  @columnName + ''.'' + @columnName --+ '' AS ''''@'' + @column + ''''''''
						IF @sortOrder = 1 
							SELECT  @pageOrder = ISNULL( @pageOrder + '',  '' + @columnName + ''.'' + @columnName , @columnName + ''.'' + @columnName  ) + '' '' +  ISNULL(@sortType, '''')  
							
								SELECT	@from_group = @from_group + '' '' + @subQuery
								SELECT	@from = @from + @subQuery
							
					END

                SELECT  @i = @i + 1

            END
		/*KONIEC pętli po kolumnach*/
		

		/*Przeszukiwanie listy barcode w tabelach custom.ItemCode*/
		IF LEN(@query) = 19 AND (SELECT textValue FROM configuration.Configuration WHERE [key] =  ''item.searchEngine.specialBarCodeSearch'') = ''true''
			BEGIN
				SELECT @filter_count = 0, @where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' CommercialDocumentLine.itemid = '''''' + CAST(itemId  as CHAR(36))  + '''''' ''
				FROM custom.ItemCode 
				WHERE ean = LEFT(@query, 13) 
					AND itemNumber = CAST(RIGHT(REPLACE(@query,''%'',''''),5) as INT)
			END
		ELSE 
		/*Podział query na słowa kluczowe*/
        IF NULLIF(RTRIM(@query), '''') IS NOT NULL 
			BEGIN
				IF SUBSTRING(@query,1,1) = ''@''
					SELECT  @from_group = @from_group + '' JOIN (  SELECT lx.commercialDocumentHeaderId id FROM item.Item WITH(NOLOCK) JOIN document.CommercialDocumentLine lx WITH(NOLOCK)  ON  item.id = lx.itemId WHERE code like '''''' + SUBSTRING(@query,2,LEN(@query) - 1) +''%''''  ) s1 ON  CommercialDocumentHeader.id  = s1.id  '' 
				ELSE
					BEGIN
						IF @reportType = ''ServiceDocument''
							SELECT @from_group = @from_group + dbo.f_getQueryFilter(@query ,@replaceConf_item , '' CommercialDocumentHeader.id'', ''commercialDocumentHeaderId'',''document.v_commercialDocumentDictionary '' ,''[item].[v_itemDictionaryCommercialDocument]'',''[contractor].[v_contractorDictionaryCommercialDocument]'' ,''[service].[v_serviceHeaderServicedObjectsIdentifier]'')  				 
						IF @reportType = ''CommercialDocument''	
							SELECT @from_group = @from_group + dbo.f_getQueryFilter(@query ,@replaceConf_item , '' CommercialDocumentHeader.id'', ''commercialDocumentHeaderId'',''document.v_commercialDocumentDictionary '' ,''[item].[v_itemDictionaryCommercialDocument]'',''[contractor].[v_contractorDictionaryCommercialDocument]'' ,NULL)  
					END
            END
             
         
        IF @condition IS NOT NULL 
            BEGIN
                SELECT  @where = ''1 = 1 '' + @condition 	
            END
		 
		IF @sqlFilter IS NOT NULL
			BEGIN
				SELECT @where = ISNULL(@where,'' 1 = 1 '') +
					CASE x.value(''(@name)[1]'',''varchar(50)'') 
					WHEN ''user'' THEN '' AND modificationApplicationUserId = '' + x.value(''(.)[1]'',''varchar(50)'') 
					ELSE '''' END
				FROM @sqlFilter.nodes(''sqlConditions/condition'') a(x)
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

		/*Pętla po kolumnach filtrowanych*/
		WHILE @i <= @filter_count
			BEGIN
				SELECT @field_name = field, @field_value = [value], @documentFieldId = documentFieldId, @documentFieldName = documentFieldName
				FROM @tmp_filters WHERE id = @i
				
				IF @field_name = ''related''
					begin
					-- sprawdzamy powiazania ale tylko pozycji ktore moga byc powiazane tzn. towary (nie uslugi) o ilosci innej niz 0 (by nie uwzgledniac korekt wartosciowych)
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CommercialDocumentLine.quantity <> 0 
																	
																	AND cwr_c.id IS NOT NULL  '' ,
							@from_group = @from_group + ''
								LEFT JOIN(
									SELECT cwl.commercialDocumentHeaderId id
									FROM  document.CommercialDocumentLine cwl 
										JOIN item.Item cwr_item ON cwr_item.id = cwl.itemId
										JOIN dictionary.ItemType cwr_type ON cwr_type.id = cwr_item.itemTypeId
										LEFT JOIN (
											select ABS(sum(isnull(quantity,0))) quantity, commercialDocumentLineId 
											from document.CommercialWarehouseRelation WITH(NOLOCK) 
											'' +
											CASE (SELECT [value] FROM @tmp_filters WHERE field = ''documentCategory'')
											WHEN ''3,4'' THEN '' WHERE isOrderRelation = 1 ''
											WHEN ''0,5,6'' THEN '' WHERE isCommercialRelation = 1 '' 
											ELSE '' '' END 
											+	''  
											group by commercialDocumentLineId
										) cwr_sub ON cwl.id = cwr_sub.commercialDocumentLineId 
									WHERE cwr_type.isWarehouseStorable = 1 
									GROUP BY cwl.commercialDocumentHeaderId 
									HAVING SUM(ISNULL(cwr_sub.quantity,0)) '' + CASE @field_value WHEN  1 THEN '' = '' WHEN 0 THEN '' <> '' END + '' SUM(ABS(ISNULL(cwl.quantity,0)))
						) cwr_c ON  CommercialDocumentHeader.id = cwr_c.id ''
					END							
				ELSE	
				IF @field_name = ''documentCategory''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CommercialDocumentHeader.documentTypeId IN ( SELECT id FROM dictionary.DocumentType WHERE documentCategory IN ('' + @field_value + ''))''
				ELSE
				IF @field_name = ''documentTypeId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CommercialDocumentHeader.documentTypeId IN ('' + @field_value + '')''
				ELSE	
				IF @field_name = ''status''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CommercialDocumentHeader.status IN ('' + @field_value + '')''
				ELSE
				/*Dane z tabeli accounting.DocumentData */
                IF @field_name =  ''hasDecree'' 
					SELECT  @from_group = @from_group + '' LEFT JOIN accounting.DocumentData dd WITH(NOLOCK) ON dd.CommercialDocumentid = CommercialDocumentHeader.id '',
							@where = ISNULL(@where + '' AND '' , '' '' ) + '' dd.id IS ''	+ CASE WHEN @field_value = 1 THEN '' NOT NULL '' ELSE '' NULL '' END	
				ELSE			
				IF @field_name = ''objectExported''
					SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' (
																CASE 
																WHEN es.documentId IS NOT NULL THEN ''''exportedWithErrors''''
																WHEN em.id IS NOT NULL AND em.objectVersion = CommercialDocumentHeader.version  THEN ''''exportedAndUnchanged'''' 
																WHEN em.id IS NOT NULL AND em.objectVersion <> CommercialDocumentHeader.version  THEN ''''exportedAndChanged'''' 
																ELSE ''''unexported'''' END   = '''''' + @field_value  + '''''' ) '',
							@from_group	= @from_group + CASE WHEN @external_flag = 0 THEN '' LEFT JOIN accounting.ExternalMapping em WITH(NOLOCK) ON em.id =  CommercialDocumentHeader.id ''	 ELSE '''' END
				ELSE
				/*Mogło by działać prosto ale kolega szymon prawidłowo uzasadnił dlaczego nie chce mu się tego implementować co przekonało kolegę kuba by stwierdzić że edycja płatności to szatański pomysł...*/
				--IF @field_name = ''unsettled''
				--		SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' ISNULL(p_.isSettled,0) <> 1 '',
				--				@from_group = @from_group + '' LEFT JOIN  finance.Payment p_ ON CommercialDocumentHeader.id = p_.commercialDocumentHeaderId ''
				--ELSE
				IF @field_name = ''unsettled''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' ABS(ps.psAmount) <> ABS(CommercialDocumentHeader.grossValue) AND ps.amount <> 0 '',
								@from_group = @from_group + '' LEFT JOIN (	SELECT SUM( ISNULL(ps_.amount,0)) psAmount, sum(p_.direction * p_.amount) amount, p_.commercialDocumentHeaderId  
																			FROM finance.Payment p_ 
																				LEFT JOIN  finance.PaymentSettlement ps_ ON p_.id = ps_.incomePaymentId OR p_.id = ps_.outcomePaymentId
																			GROUP BY p_.commercialDocumentHeaderId --, p_.direction , p_.amount 
																		) ps ON CommercialDocumentHeader.id = ps.commercialDocumentHeaderId ''
				ELSE
				IF @field_name = ''warehouseId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CommercialDocumentLine.warehouseId = '''''' + @field_value + '''''''' 
				ELSE
				IF @field_name = ''fullNumber''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CommercialDocumentHeader.fullNumber LIKE ''''%'' + REPLACE(REPLACE(@field_value,''*'',''%'') + ''%'''''' ,''%%'',''%'')
				ELSE
				IF @field_name = ''isFiscal'' AND @field_value = ''1''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' (  dt.xmlOptions.value(''''(/root/commercialDocument/@defaultFiscalPrintProfile)[1]'''', ''''varchar(50)'''') IS NOT NULL AND  netCalculationType = 0 )''
				ELSE
				IF @field_name = ''number''
					BEGIN
						IF (CHARINDEX(''\'',@field_value ) > 0)  OR CHARINDEX(''/'',@field_value ) > 0
							BEGIN
								SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CommercialDocumentHeader.fullNumber LIKE '''''' + REPLACE(REPLACE(@field_value,''*'',''%'') + ''%'''''' ,''%%'',''%'')
							END
						ELSE
							BEGIN	
								SELECT @field_value = REPLACE(REPLACE( @field_value, substring( @field_value,PATINDEX(''%[^ 0-9]%'',@field_value),1),'',''),'' '','''')
								SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CAST(CommercialDocumentHeader.number AS varchar(500)) in ( '' + @field_value + '')''
							END
					END
				--IF @field_name = ''number''
				--	BEGIN
				--		SELECT @field_value = REPLACE(REPLACE( @field_value, substring( @field_value,PATINDEX(''%[^ 0-9]%'',@field_value),1),'',''),'' '','''')
				--		SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CAST(CommercialDocumentHeader.number AS varchar(500)) in ( '' + @field_value + '')''
				--	END
					--SELECT @from_group = @from_group + [dbo].[xp_replace] (@field_value,@replaceConf_item) 
				ELSE
				IF @field_name = ''numberSettingId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' Series.numberSettingId = '''''' + @field_value + '''''''',
								@from_group = @from_group + '' LEFT JOIN document.Series ON CommercialDocumentHeader.seriesId = Series.id ''
				ELSE
				IF @field_name = ''paymentMethodId''
					BEGIN
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CommercialDocumentHeader.id in ( SELECT commercialDocumentHeaderId FROM finance.Payment WHERE paymentMethodId IN ('' + REPLACE(@field_value,'','','','') + '') )''
						--print @where
					END	
				ELSE
				IF @field_name IN( ''decimalValue'', ''dateValue'', ''textValue'' )
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CommercialDocumentHeader.id IN   ( SELECT commercialDocumentHeaderId FROM document.DocumentAttrValue Dav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) WHERE  '' + CASE WHEN NULLIF(@documentFieldId,'''') IS NOT NULL THEN '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = '''''' + CAST(ISNULL(@documentFieldId, '''') AS VARCHAR(36)) + '''''''' ELSE '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = (SELECT TOP 1 id FROM dictionary.DocumentField WHERE name = '''''' + ISNULL(@documentFieldName,'''') + '''''' ) '' END  + '' AND  Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + @field_name + '' = '''''' + @field_value + '''''') ''
				ELSE
				SELECT @where = ISNULL( @where + '' AND '','' '' )  + @field_name + '' = '''''' + @field_value + ''''''''
		
				SELECT @i = @i + 1
			END		

		/*Sklejam zapytanie z filtrem dat*/
		IF @filtrDat <> ''''
			SELECT  @where = ISNULL(@where + '' AND ''  + @filtrDat  ,@filtrDat )
                              

        
        
    	/*Sklejam zapytanie z filtrem stron*/    
        SELECT  @alterQuery = '' WHERE tmp.id > ''
                + CAST( @pageSize * ( @page - 1 ) AS VARCHAR(50))
                + '' AND tmp.id <= ''
                + CAST(@pageSize * ( @page ) AS VARCHAR(50)) + ''  ''
			
                  
        /*Do sortowania*/
        IF RTRIM(@sort) <> '''' 
            BEGIN
                SELECT  @sort = LEFT(@sort, LEN(@sort) - 1),
                        @pageOrder = LEFT(@pageOrder, LEN(@pageOrder) - 1)
                SELECT  @select = REPLACE(@select,''ORDER BY CommercialDocumentHeader.id'',''ORDER BY '' + ISNULL(@pageOrder, ''''))
            END 

		/*Fragment podsumowań*/
		DECLARE @SUMATION nvarchar(4000)
		SELECT @SUMATION = '' DECLARE @netValue decimal(18,2), @grossValue decimal(18,2), @vatValue decimal(18,2);
							 SELECT @netValue = SUM(sysNetValue), @grossValue = SUM(sysGrossValue),  @vatValue = SUM(sysVatValue) FROM @tmp t JOIN document.CommercialDocumentHeader h ON t.commercialDocument = h.id; ''
	
		SELECT @select_page	= @select_page	+ @from_group + ISNULL( '' WHERE '' + @where ,'''') + '' GROUP BY CommercialDocumentHeader.id '' + @group_by + ISNULL('' ORDER BY '' + @pageOrder, '''') + ''; SELECT @count = @@ROWCOUNT; '' + @SUMATION
		
        SELECT  @exec = @opakowanie + @select_page + ISNULL(@exec,'''') + '' '' + @select + '' '' + @from
                + @alterQuery + '' ) commercialDocumentHeader  ORDER BY id_lp FOR XML AUTO);
				 SELECT '' + CAST(@page AS VARCHAR(50)) + '' ''''@page'''' ,'' + CAST(@pageSize AS VARCHAR(50)) + '' ''''@pageSize'''',@count ''''@rowCount'''', @netValue ''''@netValue'''', @grossValue ''''@grossValue'''', @vatValue ''''@vatValue'''',  @return FOR XML PATH(''''commercialDocuments''''),TYPE ''
--select @exec
   print @exec
       EXECUTE ( @exec ) 
       print @exec
    END
' 
END
GO

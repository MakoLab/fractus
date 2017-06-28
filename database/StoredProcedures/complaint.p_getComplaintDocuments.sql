/*
name=[complaint].[p_getComplaintDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
61J2+0tkJdCNJK5cfbcCvw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_getComplaintDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [complaint].[p_getComplaintDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_getComplaintDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [complaint].[p_getComplaintDocuments] @xmlVar XML
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
            @documentFieldId UNIQUEIDENTIFIER,
            @exec NVARCHAR(max),
            @condition VARCHAR(max),
            @dateFrom DATETIME,
            @dateTo DATETIME,
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
			@replaceConf_item VARCHAR(8000),
			@replaceConf_contractor VARCHAR(8000),
			@replaceConf_commercialDoc VARCHAR(8000)

		/*Dzielenie wyrażenia query na słowa*/
        DECLARE @tmp_word TABLE
            (
              id INT IDENTITY(1, 1),
              word NVARCHAR(100)
            )

		/*Pobranie konfiguracji*/
		SELECT	@replaceConf_item = xmlValue.value(''(root/indexing/object[@name="item"]/replaceConfiguration)[1]'', ''varchar(8000)''),
				@replaceConf_contractor = xmlValue.value(''(root/indexing/object[@name="contractor"]/replaceConfiguration)[1]'', ''varchar(8000)''),
				@replaceConf_commercialDoc = xmlValue.value(''(root/indexing/object[@name="commercialDocument"]/replaceConfiguration)[1]'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''
		
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
								DECLARE @tmp TABLE (id int identity(1,1), complaintDocument UNIQUEIDENTIFIER); 
 
								'',
				@select_page = ''INSERT INTO  @tmp (complaintDocument)
								SELECT ComplaintDocumentHeader.id
								'',
                @select = ''SELECT @return = (  SELECT * FROM (SELECT DISTINCT tmp.id id_lp, ComplaintDocumentHeader.id '',
                @from_group = '' FROM complaint.ComplaintDocumentHeader WITH(NOLOCK) JOIN complaint.ComplaintDocumentLine WITH(NOLOCK) ON ComplaintDocumentHeader.id = ComplaintDocumentLine.complaintDocumentHeaderId '',
				@from = '' FROM @tmp tmp JOIN complaint.ComplaintDocumentHeader WITH(NOLOCK)  ON tmp.complaintDocument = ComplaintDocumentHeader.id JOIN complaint.ComplaintDocumentLine WITH(NOLOCK) ON ComplaintDocumentHeader.id = ComplaintDocumentLine.complaintDocumentHeaderId  '',
                @i = 1,
				@external_flag = 0,
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

				
				/*Kolumna z tabeli CommercialDocumentHeader*/
                IF @column IN ( SELECT name FROM syscolumns WHERE id = OBJECT_ID( ''complaint.ComplaintDocumentHeader'' )  ) 
                    BEGIN/*FIXME*/
                        SELECT  @select = @select + '' , ComplaintDocumentHeader.'' + @column 
                        
                        SELECT  @sort = @sort
                                + CASE WHEN @sortOrder <> ''''
                                       THEN ''ComplaintDocumentHeader.'' + ISNULL(NULLIF(@dataColumn, ''''),@column) + '' '' + ISNULL(@sortType, '''') + '', ''
                                       ELSE ''''
                                  END
						
                        IF @sortOrder = 1 
                            SELECT  @pageOrder = REPLACE(ISNULL(NULLIF(@dataColumn, ''''), @column), ''fullNumber'', ''number'') + '' '' + ISNULL(@sortType, '''') + '', ''
									
						SELECT @group_by = '', '' + REPLACE( ISNULL(NULLIF(@dataColumn, ''''), @column), ''fullNumber'', ''number'')
							
                    END
                /*Prowizorka na maksa*/    
				IF @column IN (''issueDate'')
					BEGIN
						SELECT  @select = @select + '' ,(SELECT top 1 issueDate FROM complaint.ComplaintDocumentLine WITH(NOLOCK) WHERE  ComplaintDocumentHeader.id = ComplaintDocumentLine.complaintDocumentHeaderId  ORDER BY issueDate) issueDate '' 
					END
				/*Kolumna z tabeli DocumentAttrValue*/
                IF @dataColumn IN ( ''decimalValue'', ''dateValue'', ''textValue'',''xmlValue'' ) AND @relatedObject IS NULL 
                    BEGIN
                        SELECT  @select = @select + '' , Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + @dataColumn + '' '' + @column + '' '',
								@from_group = @from_group + '' LEFT JOIN document.DocumentAttrValue Dav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Dav'' + CAST(@i AS VARCHAR(10)) + ''.complaintDocumentHeaderId = ComplaintDocumentHeader.id AND Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = '''''' + CAST(ISNULL(@documentFieldId, '''') AS VARCHAR(36)) + '''''''' ,
                                @from = @from + '' LEFT JOIN document.DocumentAttrValue Dav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Dav'' + CAST(@i AS VARCHAR(10)) + ''.complaintDocumentHeaderId = ComplaintDocumentHeader.id AND Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = '''''' + CAST(ISNULL(@documentFieldId, '''') AS VARCHAR(36)) + ''''''''
                                
                        SELECT  @sort = @sort
                                + CASE WHEN @sortOrder <> ''''
                                       THEN NULLIF(@column, '''') + '' '' + ISNULL(@sortType, '''') + '', ''
                                       ELSE ''''
                                  END 
                        IF @sortOrder = 1 
                            SELECT  @pageOrder = ''Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) + '' '' + ISNULL(@sortType, '''') + '', ''
									
						SELECT @group_by = '', '' +  ''Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column)  
                    END

				/*Dane kontrahenta*/
                IF @dataColumn IN ( ''fullName'', ''shortName'', ''nip'', ''code'' )
                    AND @relatedObject IS NOT NULL 
                    BEGIN
                        SELECT  @select = @select + '' , Con''
                                + CAST(@i AS VARCHAR(10)) + ''.'' + @dataColumn
                                + '' '' + @column + '' '' 

                        SELECT  @from = @from + '' LEFT JOIN contractor.Contractor Con'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Con'' + CAST(@i AS VARCHAR(10)) + ''.id = ComplaintDocumentHeader.''
									+ CASE WHEN @relatedObject = ''contractor''
										   THEN ''contractorId ''
										   WHEN @relatedObject = ''receivingPersonContractor''
										   THEN ''receivingPersonContractorId ''
									  END,
								@from_group = @from_group + '' LEFT JOIN contractor.Contractor Con'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Con'' + CAST(@i AS VARCHAR(10)) + ''.id = ComplaintDocumentHeader.''
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
                            SELECT  @pageOrder = ''Con'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) + '' '' + ISNULL(@sortType, '''') + '', ''

						SELECT @group_by = '', '' + ''Con'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) 
                    END

                SELECT  @i = @i + 1

            END
		/*KONIEC pętli po kolumnach*/
		


		
		/*Podział query na słowa kluczowe*/
        IF NULLIF(RTRIM(@query), '''') IS NOT NULL 
			SELECT @from_group = @from_group + dbo.f_getQueryFilter(@query ,@replaceConf_item , '' ComplaintDocumentHeader.id'', ''complaintDocumentHeaderId'',''contractor.v_contractorDictionaryComplaintDocument '' ,''[item].[v_itemDictionaryComplaintDocument]'',NULL, NULL )  
            
            
        IF @condition IS NOT NULL 
            BEGIN
                SELECT  @where = ISNULL( @where + '' '' + '' AND '','''') + @condition 	
            END
		 
      	/* Filtr daty */
        IF @dateFrom IS NOT NULL OR @dateTo IS NOT NULL 
                SELECT  @filtrDat =  ISNULL('' issueDate >= '''''' + CAST(@dateFrom AS VARCHAR(20)) + '''''' '', '''') + ISNULL('' AND issueDate <= '''''' + CAST(@dateTo AS VARCHAR(20)) + '''''' '','''')
		

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
				
				IF @field_name = ''related''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' cwr_c.id '' + CASE @field_value WHEN  1 THEN '' IS NOT NULL '' WHEN 0 THEN '' IS NULL '' END,
							@from_group = @from_group + '' LEFT JOIN document.CommercialWarehouseRelation cwr_c ON  CommercialDocumentLine.id = cwr_c.commercialDocumentLineId ''
				ELSE	
				IF @field_name = ''documentCategory''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' ComplaintDocumentHeader.documentTypeId IN ( SELECT id FROM dictionary.DocumentType WHERE documentCategory IN ('' + @field_value + ''))''
				ELSE
				IF @field_name = ''documentTypeId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' ComplaintDocumentHeader.documentTypeId IN ('' + @field_value + '')''
				ELSE	
				IF @field_name = ''status''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' ComplaintDocumentHeader.status IN ('' + @field_value + '')''
				ELSE

				IF @field_name = ''fullNumber''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' ComplaintDocumentHeader.fullNumber LIKE ''''%'' + REPLACE(REPLACE(@field_value,''*'',''%'') + ''%'''''' ,''%%'',''%'')
				ELSE
				IF @field_name = ''number''
					--SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CAST(ComplaintDocumentHeader.number AS varchar(500)) LIKE ''''%'' + REPLACE(REPLACE(@field_value,''*'',''%'') + ''%'''''' ,''%%'',''%'')
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CAST(ComplaintDocumentHeader.number AS varchar(500)) in ( '' + REPLACE(REPLACE(@field_value,'' '','',''),'';'','','') + '')''
				ELSE
				IF @field_name = ''numberSettingId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' Series.numberSettingId = '''''' + @field_value + '''''''',
								@from_group = @from_group + '' LEFT JOIN document.Series ON ComplaintDocumentHeader.seriesId = Series.id ''
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
                SELECT  @select = REPLACE(@select,''ORDER BY ComplaintDocumentHeader.id'',''ORDER BY '' + ISNULL(@pageOrder, ''''))
            END 
	
		SELECT @select_page	= @select_page	+ @from_group + ISNULL( '' WHERE '' + @where ,'''') + '' GROUP BY ComplaintDocumentHeader.id '' + @group_by + ISNULL('' ORDER BY '' + @pageOrder, '''') + ''; SELECT @count = @@ROWCOUNT; ''
		
        SELECT  @exec = @opakowanie + @select_page + ISNULL(@exec,'''') + '' '' + @select + '' '' + @from
                + @alterQuery + '' ) complaintDocumentHeader  ORDER BY id_lp FOR XML AUTO);
				 SELECT '' + CAST(@page AS VARCHAR(50)) + '' ''''@page'''' ,'' + CAST(@pageSize AS VARCHAR(50)) + '' ''''@pageSize'''',@count ''''@rowCount'''', @return FOR XML PATH(''''complaintDocuments''''),TYPE ''

       EXECUTE ( @exec ) 
       PRINT @exec 
    END
' 
END
GO

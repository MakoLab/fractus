/*
name=[crm].[p_getOfferDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
USJ8+nUsvMwP+/hCcnOYeQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_getOfferDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [crm].[p_getOfferDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_getOfferDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*

exec  [crm].[p_getOfferDocuments]
''<searchParams type="OfferDocument">
  <pageSize>200</pageSize>
  <page>1</page>
  <columns>
    <column field="documentTypeId" column="documentTypeId"/>
    <column field="fullNumber"/>
    <column field="issueDate" sortOrder="1" sortType="DESC"/>
    <column field="contractor" column="fullName" relatedObject="contractor"/>
  </columns>
  <query/>
  <dateTo>2012-05-25T23:59:59.997</dateTo>
  <dateFrom>2011-05-25</dateFrom>
  <filters>
  </filters>
  <groups/>
</searchParams>''
--select * from crm.Offer
*/

CREATE PROCEDURE [crm].[p_getOfferDocuments] @xmlVar XML
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
			@documentFieldName nvarchar(100)

		/*Dzielenie wyrażenia query na słowa*/
        DECLARE @tmp_word TABLE
            (
              id INT IDENTITY(1, 1),
              word NVARCHAR(100)
            )

		--/*Pobranie konfiguracji*/
		--SELECT	@replaceConf_item = xmlValue.query(''root/indexing/item/replaceConfiguration'').value(''.'', ''varchar(8000)''),
		--		@replaceConf_contractor = xmlValue.query(''root/indexing/contractor/replaceConfiguration'').value(''.'', ''varchar(8000)''),
		--		@replaceConf_commercialDoc = xmlValue.query(''root/indexing/commercialDocument/replaceConfiguration'').value(''.'', ''varchar(8000)'')
		--FROM    configuration.Configuration c
		--WHERE   c.[key] = ''Dictionary''
		
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
						FROM @xmlVar.nodes(''searchParams/sqlConditions/condition'') a(x)
						)

        SELECT  @opakowanie = ''	DECLARE @return XML, @from INT, @to INT, @count int;  
								DECLARE @tmp TABLE (id int identity(1,1), offerId UNIQUEIDENTIFIER); 
 
								'',
				@select_page = ''INSERT INTO  @tmp (offerId)
								SELECT Offer.id
								'',
                @select = ''SELECT @return = (  SELECT * FROM (SELECT DISTINCT tmp.id id_lp, Offer.id '',
                @from_group = '' FROM crm.Offer WITH(NOLOCK) 
									LEFT JOIN crm.OfferLine WITH(NOLOCK) ON Offer.id = OfferLine.offerId 
									LEFT JOIN dictionary.DocumentType dt WITH(NOLOCK) ON Offer.documentTypeId = dt.id
									'',
				@from = '' FROM @tmp tmp 
							JOIN crm.Offer WITH(NOLOCK) ON tmp.offerId = Offer.id
							LEFT JOIN crm.OfferLine WITH(NOLOCK) ON Offer.id = OfferLine.offerId 
							LEFT JOIN dictionary.DocumentType dt WITH(NOLOCK) ON Offer.documentTypeId = dt.id '',
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

				
				/*Kolumna z tabeli Offer*/
                IF @column IN ( SELECT name FROM syscolumns WHERE id = OBJECT_ID( ''crm.Offer'' )  ) 
                    BEGIN/*FIXME*/
                        SELECT  @select = @select + '' , Offer.'' + ISNULL(@column,'''') + '' '' + ISNULL(@dataColumn,'''')
                        
                        SELECT  @sort = @sort
                                + CASE WHEN @sortOrder <> ''''
                                       THEN ''Offer.'' + ISNULL(NULLIF(@dataColumn, ''''),@column) + '' '' + ISNULL(@sortType, '''') + '', ''
                                       ELSE ''''
                                  END
						
                        IF @sortOrder = 1 
                            SELECT  @pageOrder = ''Offer.''+REPLACE(ISNULL(NULLIF(@dataColumn, ''''), @column), ''fullNumber'', ''number'') + '' '' + ISNULL(@sortType, '''') + '', '',
									@group_by = '',  Offer.'' + REPLACE( ISNULL(NULLIF(@dataColumn, ''''), @column), ''fullNumber'', ''number'')
                    END
  
  				/*Kolumna z tabeli DocumentAttrValue*/
                IF @dataColumn IN ( ''decimalValue'', ''dateValue'', ''textValue'',''xmlValue'' ) AND @relatedObject IS NULL 
                    BEGIN
                   
                        SELECT  @select = @select + '' , Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + @dataColumn + '' '' + @column + '' '',
								@from_group = @from_group + '' LEFT JOIN document.DocumentAttrValue Dav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Dav'' + CAST(@i AS VARCHAR(10)) + ''.commercialDocumentHeaderId = Offer.id AND '' + CASE WHEN NULLIF(@documentFieldId,'''') IS NOT NULL THEN '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = '''''' + CAST(ISNULL(@documentFieldId, '''') AS VARCHAR(36)) + '''''''' ELSE '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = (SELECT TOP 1 id FROM dictionary.DocumentField WHERE name = '''''' + ISNULL(@documentFieldName,'''') + '''''' ) '' END ,
                                @from = @from + '' LEFT JOIN document.DocumentAttrValue Dav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Dav'' + CAST(@i AS VARCHAR(10)) + ''.commercialDocumentHeaderId = Offer.id AND '' + CASE WHEN NULLIF(@documentFieldId,'''') IS NOT NULL THEN '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = '''''' + CAST(ISNULL(@documentFieldId, '''') AS VARCHAR(36)) + '''''''' ELSE '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = (SELECT TOP 1 id FROM dictionary.DocumentField WHERE name = '''''' + ISNULL(@documentFieldName,'''') + '''''' ) '' END 
                                
                        SELECT  @sort = @sort
                                + CASE WHEN @sortOrder <> ''''
                                       THEN NULLIF(@column, '''') + '' '' + ISNULL(@sortType, '''') + '', ''
                                       ELSE ''''
                                  END 
                        IF @sortOrder = 1 
                            SELECT  @pageOrder = ''Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) + '' '' + ISNULL(@sortType, '''') + '', '',
									@group_by = '', '' +  ''Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column)  
                    END

				/*Dane kontrahenta*/
                IF @dataColumn IN ( ''fullName'', ''shortName'', ''nip'', ''code'' )
                    AND @relatedObject IS NOT NULL 
                    BEGIN
                        SELECT  @select = @select + '' , Con''
                                + CAST(@i AS VARCHAR(10)) + ''.'' + @dataColumn
                                + '' '' + @column + '' '' 

                        SELECT  @from = @from + '' LEFT JOIN contractor.Contractor Con'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Con'' + CAST(@i AS VARCHAR(10)) + ''.id = Offer.contractorId ''
										,
								@from_group = @from_group + '' LEFT JOIN contractor.Contractor Con'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Con'' + CAST(@i AS VARCHAR(10)) + ''.id = Offer.contractorId''


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
		

           
        IF @condition IS NOT NULL 
            BEGIN
                SELECT  @where = ''1 = 1 '' + @condition 	
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
				
				IF @field_name = ''documentCategory''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' Offer.documentTypeId IN ( SELECT id FROM dictionary.DocumentType WHERE documentCategory IN ('' + @field_value + ''))''
				ELSE
				IF @field_name = ''documentTypeId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' Offer.documentTypeId IN ('' + @field_value + '')''
				ELSE	
				IF @field_name = ''statusId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' Offer.statusId IN ('''''' + REPLACE(@field_value,'','','''''','''''') + '''''')''
				ELSE
				IF @field_name = ''fullNumber''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' Offer.fullNumber LIKE ''''%'' + REPLACE(REPLACE(@field_value,''*'',''%'') + ''%'''''' ,''%%'',''%'')
				ELSE
				IF @field_name = ''number''
					BEGIN
						SELECT @field_value = REPLACE(REPLACE( @field_value, substring( @field_value,PATINDEX(''%[^ 0-9]%'',@field_value),1),'',''),'' '','''')
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CAST(Offer.number AS varchar(500)) in ( '' + @field_value + '')''
					END
					--SELECT @from_group = @from_group + [dbo].[xp_replace] (@field_value,@replaceConf_item) 
				ELSE
				IF @field_name = ''numberSettingId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' Series.numberSettingId = '''''' + @field_value + '''''''',
								@from_group = @from_group + '' LEFT JOIN document.Series ON Offer.seriesId = Series.id ''
				ELSE
				IF @field_name = ''paymentMethodId''
					BEGIN
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' Offer.id in ( SELECT commercialDocumentHeaderId FROM finance.Payment WHERE paymentMethodId IN ('' + REPLACE(@field_value,'','','','') + '') )''
						--print @where
					END	
				ELSE
				IF @field_name IN( ''decimalValue'', ''dateValue'', ''textValue'' )
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' Offer.id IN   ( SELECT commercialDocumentHeaderId FROM document.DocumentAttrValue Dav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) WHERE  '' + CASE WHEN NULLIF(@documentFieldId,'''') IS NOT NULL THEN '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = '''''' + CAST(ISNULL(@documentFieldId, '''') AS VARCHAR(36)) + '''''''' ELSE '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = (SELECT TOP 1 id FROM dictionary.DocumentField WHERE name = '''''' + ISNULL(@documentFieldName,'''') + '''''' ) '' END  + '' AND  Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + @field_name + '' = '''''' + @field_value + '''''') ''
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
                SELECT  @select = REPLACE(@select,''ORDER BY Offer.id'',''ORDER BY '' + ISNULL(@pageOrder, ''''))
            END 

		SELECT @select_page	= @select_page	+ @from_group + ISNULL( '' WHERE '' + @where ,'''') + '' GROUP BY Offer.id '' + @group_by + ISNULL('' ORDER BY '' + @pageOrder, '''') + ''; SELECT @count = @@ROWCOUNT; '' 
		
        SELECT  @exec = @opakowanie + @select_page + ISNULL(@exec,'''') + '' '' + @select + '' '' + @from
                + @alterQuery + '' ) offer  ORDER BY id_lp FOR XML AUTO);
				 SELECT '' + CAST(@page AS VARCHAR(50)) + '' ''''@page'''' ,'' + CAST(@pageSize AS VARCHAR(50)) + '' ''''@pageSize'''',@count ''''@rowCount'''',   @return FOR XML PATH(''''offer''''),TYPE ''
--select @exec
   print @exec
       EXECUTE ( @exec ) 
       print @exec
    END
' 
END
GO

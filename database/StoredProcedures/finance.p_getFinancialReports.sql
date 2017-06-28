/*
name=[finance].[p_getFinancialReports]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
S1rEgaBnKUW4VRMM3Pr/Rg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getFinancialReports]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_getFinancialReports]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getFinancialReports]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [finance].[p_getFinancialReports] 
--declare 
@xmlVar XML
AS
--select @xmlVar = ''<searchParams type="FinancialReport" applicationUserId="AEB5C0EF-1560-4F9D-8B5B-F8049C27C3E3">
--  <pageSize>100000000</pageSize>
--  <page>1</page>
--  <columns>
--    <column field="fullNumber" />
--    <column field="closureDate" column="closureDate" sortOrder="1" sortType="ASC" />
--    <column field="objectExported" />
--  </columns>
--  <query />
--  <groups />
--  <sqlConditions>
--    <condition>closureDate IS NOT NULL</condition>
--  </sqlConditions>
--  <dateTo>2010-08-31T23:59:59.997</dateTo>
--  <dateFrom>2010-08-01</dateFrom>
--  <filters>
--    <column field="objectExported">unexported</column>
--    <column field="financialRegisterId">1AC98FB7-EA86-4826-A2C7-ED2E53CD418E</column>
--    <column field="status">40,20</column>
--  </filters>
--</searchParams>''
BEGIN
--select * from xx
--create table xx(x xml)
--insert into xx(x) select @xmlVar
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
            @dateFrom VARCHAR(50),
            @dateTo VARCHAR(50),
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
			@export_flag INT

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
                @dateFrom = NULLIF(x.query(''dateFrom'').value(''.'', ''VARCHAR(50)''),''''),
                @dateTo = NULLIF(x.query(''dateTo'').value(''.'', ''VARCHAR(50)''),''''),
                @pageSize = x.query(''pageSize'').value(''.'', ''int''),
                @page = x.query(''page'').value(''.'', ''int''),
				@filter = x.query(''filters/*'')
        FROM    @xmlVar.nodes(''/*'') a(x)
					

        SELECT  @opakowanie = ''	DECLARE @return XML, @from INT, @to INT, @count int;  
								DECLARE @tmp TABLE (id int identity(1,1), financialReport UNIQUEIDENTIFIER); 
 
								'',
				@select_page = ''INSERT INTO  @tmp (financialReport)
								SELECT FinancialReport.id
								'',
                @select = ''SELECT @return = (  SELECT * FROM (SELECT distinct FinancialReport.id , tmp.id lp_ ,fr.currencyId  documentCurrencyId'',
                @from_group = '' FROM finance.FinancialReport WITH(NOLOCK) 
									JOIN dictionary.FinancialRegister fr ON FinancialReport.financialRegisterId = fr.id 
									LEFT JOIN document.FinancialDocumentHeader WITH(NOLOCK) ON FinancialDocumentHeader.financialReportId = FinancialReport.id '',
				@from = '' FROM @tmp tmp 
							JOIN finance.FinancialReport WITH(NOLOCK) ON tmp.financialReport = FinancialReport.id 
							JOIN dictionary.FinancialRegister fr ON FinancialReport.financialRegisterId = fr.id '', -- JOIN document.FinancialDocumentHeader WITH(NOLOCK) ON FinancialDocumentHeader.financialReportId = FinancialReport.id '',
                @i = 1,
                @sort = '''' ,
                @export_flag = 0

	

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

				
				/*Kolumna z tabeli FinancialReport*/
                IF @column IN ( SELECT name FROM syscolumns WHERE id = OBJECT_ID( ''finance.FinancialReport'' )  ) 
                    BEGIN
                        SELECT  @select = @select + '' , FinancialReport.'' + @column
                        
                        SELECT  @sort = @sort
                                + CASE WHEN @sortOrder <> ''''
                                       THEN ''FinancialReport.'' + ISNULL(NULLIF(@dataColumn, ''''),@column) + '' '' + ISNULL(@sortType, '''') + '', ''
                                       ELSE ''''
                                  END
						
                        IF @sortOrder = 1 
                            SELECT  @pageOrder =  ''FinancialReport.'' + REPLACE(ISNULL(NULLIF(@dataColumn, ''''), @column),''fullNumber'',''number'') + '' '' + ISNULL(@sortType, '''') + '', '',
									@group_by = '', '' + ''FinancialReport.'' + REPLACE(ISNULL(NULLIF(@dataColumn, ''''), @column),''fullNumber'',''number'')
                    END

				/*Kolumna z tabeli ExternalMapping*/
                    IF @column IN ( ''objectExported'' ) 
                        BEGIN
							SELECT  @from = @from + ''
													LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
																	FROM accounting.ExternalMapping  ex WITH(NOLOCK) 
																		join document.FinancialDocumentHeader fh on fh.id = ex.id AND fh.version = ISNULL(ex.objectVersion ,newid())
																		join @tmp tmp ON tmp.financialReport = fh.financialReportId 
																	WHERE fh.status >= 40
																	GROUP BY fh.financialReportId 
																) eau ON eau.financialReportId = FinancialReport.id
													LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
																	FROM accounting.ExternalMapping   ex WITH(NOLOCK)
																		join document.FinancialDocumentHeader fh on fh.id = ex.id AND fh.version <> ISNULL(ex.objectVersion ,newid()) 
																		join @tmp tmp ON tmp.financialReport = fh.financialReportId 
																	WHERE fh.status >= 40
																	GROUP BY fh.financialReportId 
																) eac ON eac.financialReportId = FinancialReport.id 
													LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
																FROM @tmp tm
																	LEFT join document.FinancialDocumentHeader fh on tm.financialReport = fh.FinancialReportId
																WHERE fh.status >= 40
																GROUP BY fh.financialReportId 
																) u ON u.financialReportId = FinancialReport.id 
													LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
																FROM document.FinancialDocumentHeader fh 
																JOIN document.ExportStatus es ON fh.id = es.documentId
																WHERE es.documentId is NOT NULL
																GROUP BY fh.financialReportId 
																) esd ON esd.financialReportId = FinancialReport.id 
													LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
																FROM document.FinancialDocumentHeader fh 
																WHERE fh.status <= 40
																GROUP BY fh.financialReportId 
																) r ON u.financialReportId = FinancialReport.id 
													LEFT JOIN document.ExportStatus es WITH(NOLOCK) ON FinancialReport.id = es.documentId
													LEFT JOIN accounting.ExternalMapping  ex WITH(NOLOCK) ON FinancialReport.id = ex.id	AND FinancialReport.version = ex.objectVersion																
																'',

									@from_group = @from_group + ''
													LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
																	FROM accounting.ExternalMapping  ex  WITH(NOLOCK)
																		join document.FinancialDocumentHeader fh on fh.id = ex.id AND fh.version = ISNULL(ex.objectVersion ,newid())
																	WHERE fh.status >= 40
																	GROUP BY fh.financialReportId 
																) eau ON eau.financialReportId = FinancialReport.id
													LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
																	FROM accounting.ExternalMapping  ex WITH(NOLOCK)
																		join document.FinancialDocumentHeader fh on fh.id = ex.id AND fh.version <> ISNULL(ex.objectVersion ,newid())
																	WHERE fh.status >= 40
																	GROUP BY fh.financialReportId 
																) eac ON eac.financialReportId = FinancialReport.id 
													LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
																FROM document.FinancialDocumentHeader fh 
																WHERE fh.status >= 40
																GROUP BY fh.financialReportId 
																) u ON u.financialReportId = FinancialReport.id 
													LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
																FROM document.FinancialDocumentHeader fh 
																WHERE fh.status <= 40
																GROUP BY fh.financialReportId 
																) r ON u.financialReportId = FinancialReport.id 																
													LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
																FROM document.FinancialDocumentHeader fh 
																JOIN document.ExportStatus es ON fh.id = es.documentId
																WHERE es.documentId is NOT NULL
																GROUP BY fh.financialReportId 
																) esd ON esd.financialReportId = FinancialReport.id 
													LEFT JOIN document.ExportStatus es WITH(NOLOCK) ON FinancialReport.id = es.documentId
													LEFT JOIN accounting.ExternalMapping  ex WITH(NOLOCK) ON FinancialReport.id = ex.id	AND FinancialReport.version = ex.objectVersion
																
																'',
													
									@external_flag = 1,
									@select = @select + '' , CASE 
																WHEN es.documentId IS NOT NULL OR ISNULL(esd.c,0) <> 0 THEN ''''exportedWithErrors''''
																WHEN ISNULL( eau.c ,0) = ISNULL(u.c,0) AND ISNULL(u.c,0) <> 0 THEN ''''exportedAndUnchanged'''' 
																WHEN  ISNULL( eac.c ,0) = ISNULL(u.c,0)  AND ISNULL(u.c,0) <> 0 THEN ''''exportedAndChanged''''
																WHEN ISNULL(u.c,0) = 0 AND ex.id IS NOT NULL THEN ''''exportedAndUnchanged''''
																ELSE ''''unexported'''' END  AS objectExported ,
															CASE 
																WHEN ISNULL(r.c,0) = 0 THEN 60
																ELSE 40 END  AS status ''

                        END                        
 
				/*Kolumna z tabeli FinancialDocumentHeader*/
                IF @column IN ( SELECT name FROM syscolumns WHERE id = OBJECT_ID( ''document.FinancialDocumentHeader'' )  ) AND @relatedObject = ''FinancialDocumentHeader''
                    BEGIN
                        SELECT  @select = @select + '' , FinancialDocumentHeader.'' + @dataColumn + '' '' + @column + '' ''
                        
                        SELECT  @sort = @sort
                                + CASE WHEN @sortOrder <> ''''
                                       THEN ''FinancialDocumentHeader.'' + ISNULL(NULLIF(@dataColumn, ''''),@column) + '' '' + ISNULL(@sortType, '''') + '', ''
                                       ELSE ''''
                                  END
						
                        IF @sortOrder = 1 
                            SELECT  @pageOrder = ''FinancialDocumentHeader.'' + REPLACE(ISNULL(NULLIF(@dataColumn, ''''), @column),''fullNumber'',''number'') + '' '' + ISNULL(@sortType, '''') + '', '',
									@group_by = '', FinancialDocumentHeader.''  + REPLACE(ISNULL(NULLIF(@dataColumn, ''''), @column),''fullNumber'',''number'')
                    END



                SELECT  @i = @i + 1
            END
		/*KONIEC pętli po kolumnach*/
		
	

        IF @condition IS NOT NULL 
            BEGIN
                SELECT  @where = ISNULL( @where + '' '' + '' AND '','''') + @condition 	
            END

      	/* Filtr daty */
        IF @dateFrom IS NOT NULL OR @dateTo IS NOT NULL 
                SELECT  @filtrDat =  ISNULL('' creationDate <= '''''' + CAST(@dateTo AS VARCHAR(50)) + '''''' '', '''') + ISNULL('' AND ((closureDate >= '''''' + CAST(@dateFrom AS VARCHAR(50)) + '''''' AND closureDate <= '''''' + CAST(@dateTo AS VARCHAR(50)) + '''''') OR closureDate IS NULL ) '','''')
	
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

				IF @field_name = ''fullNumber''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' FinancialReport.fullNumber LIKE '''''' + REPLACE(REPLACE(@field_value,''*'',''%'') + ''%'''''' ,''%%'',''%'')
				ELSE
				IF @field_name = ''number''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CAST( FinancialReport.number AS varchar(500)) in ( '' + REPLACE(REPLACE(@field_value,'' '','',''),'';'','','') + '')''
					--SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CAST( FinancialReport.number as varchar(500) ) LIKE '''''' + REPLACE(REPLACE(@field_value,''*'',''%'') + ''%'''''' ,''%%'',''%'')
				ELSE
				IF @field_name = ''reportId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' FinancialReport.id = '''''' + @field_value + ''''''''
				ELSE
				IF @field_name = ''NumberSettingId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' FinancialReport.seriesId IN (SELECT id FROM document.Series WHERE numberSettingId = '''''' + @field_value + '''''')''
				ELSE
				IF @field_name = ''branchId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' fr.branchId = '''''' + @field_value + ''''''''
				ELSE
				IF @field_name = ''companyId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' fr.branchId IN (SELECT id FROM dictionary.Branch WHERE companyId = '''''' + @field_value + '''''')''
				ELSE
				IF @field_name = ''objectExported''
					BEGIN 
						IF @external_flag = 0
						
							SELECT @from_group = @from_group + '' LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
																	FROM accounting.ExternalMapping  ex  WITH(NOLOCK)
																		join document.FinancialDocumentHeader fh on fh.id = ex.id AND fh.version = ISNULL(ex.objectVersion ,newid())
																	WHERE fh.status >= 40
																	GROUP BY fh.financialReportId 
																) eau ON eau.financialReportId = FinancialReport.id
													LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
																	FROM accounting.ExternalMapping  ex WITH(NOLOCK)
																		join document.FinancialDocumentHeader fh on fh.id = ex.id AND fh.version <> ISNULL(ex.objectVersion ,newid())
																	WHERE fh.status >= 40
																	GROUP BY fh.financialReportId 
																) eac ON eac.financialReportId = FinancialReport.id 
													LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
																FROM document.FinancialDocumentHeader fh 
																WHERE fh.status >= 40
																GROUP BY fh.financialReportId 
																) u ON u.financialReportId = FinancialReport.id 
													LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
																FROM document.FinancialDocumentHeader fh 
																JOIN document.ExportStatus es ON fh.id = es.documentId
																WHERE es.documentId is NOT NULL
																GROUP BY fh.financialReportId 
																) esd ON esd.financialReportId = FinancialReport.id 
													LEFT JOIN document.ExportStatus es WITH(NOLOCK) ON FinancialReport.id = es.documentId
													LEFT JOIN accounting.ExternalMapping  ex WITH(NOLOCK) ON FinancialReport.id = ex.id	AND FinancialReport.version = ex.objectVersion
													''
						
						SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + ''
																CASE 
																	WHEN es.documentId IS NOT NULL OR ISNULL(esd.c,0) <> 0 THEN ''''exportedWithErrors''''
																	WHEN ISNULL( eau.c ,0) = ISNULL(u.c,0) AND ISNULL(u.c,0) <> 0 THEN ''''exportedAndUnchanged'''' 
																	WHEN  ISNULL( eac.c ,0) = ISNULL(u.c,0) AND ISNULL(u.c,0) <> 0 THEN ''''exportedAndChanged''''
																	WHEN ISNULL(u.c,0) = 0 AND ex.id IS NOT NULL THEN ''''exportedAndUnchanged'''' 
																ELSE ''''unexported'''' END = '''''' + @field_value  + ''''''''
																
																
					END
					
				ELSE
				/*Dane z tabeli accounting.DocumentData */
                IF @field_name =  ''hasDecree'' 
					SELECT  --@from_group = @from_group + '' LEFT JOIN accounting.DocumentData dd WITH(NOLOCK) ON dd.FinancialReport = CommercialDocumentHeader.id '',
							@where = ISNULL(@where + '' AND '' , '' '' ) + ''
													CASE WHEN NOT EXISTS (  SELECT fdh.* 
																			FROM  document.FinancialDocumentHeader fdh  WITH(NOLOCK)
																				LEFT JOIN accounting.DocumentData  dd ON fdh.id = dd.financialDocumentId
																			WHERE dd.id IS NULL ) THEN 1
														ELSE 0 END = '' + @field_value 						
							
				ELSE								
				IF @field_name = ''financialRegisterId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' FinancialReport.financialRegisterId IN ('''''' + REPLACE(@field_value,'','','''''','''''') + '''''')''
				--ELSE
				--SELECT @where = ISNULL( @where + '' AND '','' '' )  + @field_name + '' = '''''' + @field_value + ''''''''
		
				SELECT @i = @i + 1
			END		

		/*Sklejam zapytanie z filtrem dat*/
		IF @filtrDat <> ''''
			SELECT  @where = ISNULL(@where + '' AND ''  + @filtrDat  ,@filtrDat )
                              

    	
        
    	/*Sklejam zapytanie z filtrem stron*/    
		IF ISNULL(@pageSize,0) > 0
        SELECT  @alterQuery = '' WHERE tmp.id > ''
                + CAST(@pageSize * ( @page - 1 ) AS VARCHAR(50))
                + '' AND tmp.id <= ''
                + CAST(@pageSize * ( @page ) AS VARCHAR(50)) + ''  ''
			
                  
        /*Do sortowania*/
        IF RTRIM(@sort) <> '''' 
            BEGIN
                SELECT  @sort = LEFT(@sort, LEN(@sort) - 1),
                        @pageOrder = LEFT(@pageOrder, LEN(@pageOrder) - 1)
                SELECT  @select = REPLACE(@select,''ORDER BY FinancialReport.id'',''ORDER BY '' + ISNULL(@pageOrder, ''''))
            END 
	
		SELECT @select_page	= @select_page	+ @from_group + ISNULL( '' WHERE '' + @where ,'''') + '' GROUP BY FinancialReport.id '' + ISNULL(@group_by,'''') + ISNULL('' ORDER BY '' + @pageOrder, '''') + ''; SELECT @count = @@ROWCOUNT; ''
	

		     	
        SELECT  @exec = @opakowanie + @select_page + ISNULL(@exec,'''') + '' '' + @select + '' '' + @from
                + ISNULL(@alterQuery,'''') + '' ) financialReport ORDER BY lp_ FOR XML AUTO);
				 SELECT '' + CAST(ISNULL(@page,0) AS VARCHAR(50)) + '' ''''@page'''' ,'' + CAST(ISNULL(@pageSize,0) AS VARCHAR(50)) + '' ''''@pageSize'''',@count ''''@rowCount'''', @return FOR XML PATH(''''financialReports''''),TYPE ''
print @opakowanie 
print @select_page 
print @select 
print @from
PRINT @alterQuery
PRINT '' ) financialReport ORDER BY lp_ FOR XML AUTO);''
       EXECUTE ( @exec ) 

  --   select @exec
    END
' 
END
GO

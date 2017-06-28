/*
name=[document].[p_getFinancialDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
QeteuR5V5ZTbpogMeC2jxw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getFinancialDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getFinancialDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getFinancialDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [document].[p_getFinancialDocuments] @xmlVar XML
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
            @documentFieldName nvarchar(100),
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
			@external_flag INT,
			@filter_count INT

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
					
			
		SELECT @condition = (
				SELECT dbo.Concat( '' AND '' + x.value(''(.)[1]'',''varchar(max)'') )
						FROM @xmlVar.nodes(''searchParams/sqlConditions/condition'') a(x)
						)
				
        SELECT  @opakowanie = ''	DECLARE @return XML, @from INT, @to INT, @count int;  
								DECLARE @tmp TABLE (id int identity(1,1), financialDocument UNIQUEIDENTIFIER); 
 
								'',
				@select_page = ''INSERT INTO  @tmp (financialDocument)
								SELECT FinancialDocumentHeader.id
								'',
                @select = ''SELECT @return = (  SELECT * FROM (SELECT tmp.id lp1, FinancialDocumentHeader.id '',
                @from_group = '' FROM document.FinancialDocumentHeader WITH(NOLOCK) 
									JOIN finance.FinancialReport WITH(NOLOCK) ON FinancialDocumentHeader.financialReportId = FinancialReport.id '',
				@from = '' FROM @tmp tmp JOIN document.FinancialDocumentHeader WITH(NOLOCK) ON tmp.financialDocument = FinancialDocumentHeader.id 
							JOIN finance.FinancialReport WITH(NOLOCK) ON FinancialDocumentHeader.financialReportId = FinancialReport.id '',
                @i = 1,
                @external_flag = 0,
                @sort = '''' 

	

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
                                    ISNULL(x.value(''@documentFieldId[1]'',''varchar(36)''), NULL) documentFieldId,
                                    ISNULL(x.value(''@documentFieldName[1]'',''nvarchar(200)''), NULL) documentFieldName,
                                    NULLIF(RTRIM(x.value(''@relatedObject[1]'',''nvarchar(255)'')), '''') relatedObject,
                                    x.value(''@sortOrder'', ''int'') sortOrder,
                                    x.value(''@sortType'', ''VARCHAR(50)'') sortType
                          FROM      @xmlVar.nodes(''/*/columns/column'') a ( x )
                        ) sub
                WHERE   row = @i

				
				/*Kolumna z tabeli FinancialDocumentHeader*/
                IF @column IN ( SELECT name FROM syscolumns WHERE id = OBJECT_ID( ''document.FinancialDocumentHeader'' )  )  AND @relatedObject IS NULL
                    BEGIN
                        SELECT  @select = @select + '' , FinancialDocumentHeader.'' + @column
                        /*Replace na sortowaniu zmienia kolumnę sortowaną z fullNumber na number*/
						
                        IF @sortOrder = 1 
                            SELECT  @pageOrder = ISNULL(@pageOrder + '' , '','' '') + ''FinancialDocumentHeader.'' + REPLACE( ISNULL(NULLIF(@dataColumn, ''''), @column), ''fullNumber'',''number'') + '' '' + ISNULL(@sortType, '''') ,
									@group_by = '', FinancialDocumentHeader.'' + REPLACE( ISNULL(NULLIF(@dataColumn, ''''), @column), ''fullNumber'',''number'') 
                    END

				/*Kolumna z tabeli FinancialDocumentHeader*/
                IF @dataColumn IN ( SELECT name FROM syscolumns WHERE id = OBJECT_ID( ''finance.FinancialReport'' )  ) AND @relatedObject = ''FinancialReport''
                    BEGIN
                        SELECT  @select = @select + '' , FinancialReport.'' + @dataColumn + '' '' + @column + '' ''
						
                        IF @sortOrder = 1 
                            SELECT  @pageOrder =  ISNULL(@pageOrder + '' , '','' '') + ''FinancialReport.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) + '' '' + ISNULL(@sortType, '''') ,
									@group_by = '', FinancialReport.'' +  ISNULL(NULLIF(@dataColumn, ''''), @column)
                    END



				/*Kolumna z tabeli DocumentAttrValue*/
                IF @dataColumn IN ( ''decimalValue'', ''dateValue'', ''textValue'',''xmlValue'' ) AND @relatedObject IS NULL 
                    BEGIN
                        SELECT  @select = @select + '' , Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + @dataColumn + '' '' + @column + '' '',
								@from_group = @from_group + '' LEFT JOIN document.DocumentAttrValue Dav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Dav'' + CAST(@i AS VARCHAR(10)) + ''.financialDocumentHeaderId = FinancialDocumentHeader.id AND '' + CASE WHEN NULLIF(@documentFieldId,'''') IS NOT NULL THEN '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = '''''' + CAST(ISNULL(@documentFieldId, '''') AS VARCHAR(36)) + '''''''' ELSE '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = (SELECT TOP 1 id FROM dictionary.DocumentField WHERE name = '''''' + ISNULL(@documentFieldName,'''') + '''''' ) '' END ,
                                @from = @from + '' LEFT JOIN document.DocumentAttrValue Dav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Dav'' + CAST(@i AS VARCHAR(10)) + ''.financialDocumentHeaderId = FinancialDocumentHeader.id AND '' + CASE WHEN NULLIF(@documentFieldId,'''') IS NOT NULL THEN '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = '''''' + CAST(ISNULL(@documentFieldId, '''') AS VARCHAR(36)) + '''''''' ELSE '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = (SELECT TOP 1 id FROM dictionary.DocumentField WHERE name = '''''' + ISNULL(@documentFieldName,'''') + '''''' ) '' END 
                                

                        IF @sortOrder = 1 
                            SELECT  @pageOrder =  ISNULL(@pageOrder + '' , '','' '') + ''Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) + '' '' + ISNULL(@sortType, '''') ,
									@group_by = '', '' +  ''Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column)  
                    END
                    
				/*Kolumna z tabeli ExternalMapping*/ 
                IF @column IN ( ''objectExported'' ) 
                    BEGIN
						
						SELECT  @from = @from + '' LEFT JOIN accounting.ExternalMapping em WITH(NOLOCK) ON em.id = FinancialDocumentHeader.id 
												  LEFT JOIN document.ExportStatus es WITH(NOLOCK) ON es.documentId = CommercialDocumentHeader.id '',
								@from_group = @from_group + '' LEFT JOIN accounting.ExternalMapping em WITH(NOLOCK) ON em.id = FinancialDocumentHeader.id 
													          LEFT JOIN document.ExportStatus es WITH(NOLOCK) ON es.documentId = CommercialDocumentHeader.id '',
								@external_flag = 1,
								@select = @select + '' , CASE 
															WHEN es.documentId IS NOT NULL THEN ''''exportedWithErrors''''
															WHEN em.id IS NOT NULL AND em.objectVersion = FinancialDocumentHeader.version  THEN ''''exportedAndUnchanged'''' 
															WHEN em.id IS NOT NULL AND em.objectVersion <> FinancialDocumentHeader.version  THEN ''''exportedAndChanged'''' 
															ELSE ''''unexported'''' END  AS objectExported ''
                    END

				/*Dane kontrahenta*/
                IF @dataColumn IN ( ''fullName'', ''shortName'', ''nip'', ''code'' )
                    AND @relatedObject IS NOT NULL 
                    BEGIN
	
                        SELECT  @select = @select + '' , Con''
                                + CAST(@i AS VARCHAR(10)) + ''.'' + @dataColumn
                                + '' '' + @column + '' '' 

                        SELECT  @from = @from + '' LEFT JOIN contractor.Contractor Con'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Con'' + CAST(@i AS VARCHAR(10)) + ''.id = FinancialDocumentHeader.''
									+ CASE WHEN @relatedObject = ''contractor''
										   THEN ''contractorId ''
										   WHEN @relatedObject = ''issuingPersonContractorId''
										   THEN ''issuingPersonContractorId ''
									  END,
								@from_group = @from_group + '' LEFT JOIN contractor.Contractor Con'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Con'' + CAST(@i AS VARCHAR(10)) + ''.id = FinancialDocumentHeader.''
									+ CASE WHEN @relatedObject = ''contractor''
										   THEN ''contractorId ''
										   WHEN @relatedObject = ''issuingPersonContractorId''
										   THEN ''issuingPersonContractorId ''
									  END
						
                        IF @sortOrder = 1 
                            SELECT  @pageOrder =  ISNULL(@pageOrder + '' , '','' '') + ''Con'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) + '' '' + ISNULL(@sortType, '''') ,
									@group_by = '', '' + ''Con'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) 
                    END

                SELECT  @i = @i + 1
            END
		/*KONIEC pętli po kolumnach*/
		

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
				SELECT @field_name = field, @field_value = [value]
				FROM @tmp_filters WHERE id = @i

				IF @field_name = ''documentTypeId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' FinancialDocumentHeader.documentTypeId IN ('' + @field_value + '')''
				ELSE	
				IF @field_name = ''status''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' FinancialDocumentHeader.status IN ('' + @field_value + '')''
				ELSE

				IF @field_name = ''fullNumber''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' FinancialDocumentHeader.fullNumber LIKE '''''' + REPLACE(REPLACE(@field_value,''*'',''%'') + ''%'''''' ,''%%'',''%'')
				ELSE
				IF @field_name = ''number''
					BEGIN
						IF (CHARINDEX(''\'',@field_value ) > 0)  OR CHARINDEX(''/'',@field_value ) > 0
							BEGIN
								SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' FinancialDocumentHeader.fullNumber LIKE '''''' + REPLACE(REPLACE(@field_value,''*'',''%'') + ''%'''''' ,''%%'',''%'')
							END
						ELSE
							BEGIN	
								SELECT @field_value = REPLACE(REPLACE( @field_value, substring( @field_value,PATINDEX(''%[^ 0-9]%'',@field_value),1),'',''),'' '','''')
								SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CAST(FinancialDocumentHeader.number AS varchar(500)) in ( '' + @field_value + '')''
							END
					END
					--BEGIN
					--	SELECT @field_value = REPLACE(REPLACE( @field_value, substring( @field_value,PATINDEX(''%[^ 0-9]%'',@field_value),1),'',''),'' '','''')
					--	SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' FinancialDocumentHeader.number in ( '' + @field_value + '')''
					--END
				ELSE
				IF @field_name = ''numberSettingId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' Series.numberSettingId = '''''' + @field_value + '''''''',
								@from_group = @from_group + '' LEFT JOIN document.Series ON FinancialDocumentHeader.seriesId = Series.id ''
				ELSE
				/*Mogło by działać prosto ale kolega szymon prawidłowo uzasadnił dlaczego nie chce mu się tego implementować co przekonało kolegę kuba by stwierdzić że edycja płatności to szatański pomysł...*/
				--IF @field_name = ''unsettled''
				--		SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' ISNULL(p_.isSettled,0) <> 1 '',
				--				@from_group = @from_group + '' LEFT JOIN  finance.Payment p_ ON FinancialDocumentHeader.id = p_.financialDocumentHeaderId ''
				--ELSE
				IF @field_name = ''unsettled''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' ISNULL(ps.psAmount,0) <> FinancialDocumentHeader.amount AND ISNULL(ps.amount,0) <> 0 '',
								@from_group = @from_group + '' LEFT JOIN (	SELECT SUM( ISNULL(ps_.amount,0)) psAmount, sum(p_.direction * p_.amount ) amount , p_.financialDocumentHeaderId  
																			FROM finance.Payment p_ 
																				LEFT JOIN finance.PaymentSettlement ps_ ON p_.id = ps_.incomePaymentId OR p_.id = ps_.outcomePaymentId
																			GROUP BY p_.financialDocumentHeaderId --,p_.direction , p_.amount
																		) ps ON FinancialDocumentHeader.id = ps.financialDocumentHeaderId ''
				ELSE
				/*Dane z tabeli accounting.DocumentData */
                IF @field_name =  ''hasDecree'' 
					SELECT  @from_group = @from_group + '' LEFT JOIN accounting.DocumentData dd WITH(NOLOCK) ON dd.FinancialDocumentId = FinancialDocumentHeader.id '',
							@where = ISNULL(@where + '' AND '' , '' '' ) + '' dd.id IS ''	+ CASE WHEN @field_value = 1 THEN '' NOT NULL '' ELSE '' NULL '' END	
				ELSE			
				IF @field_name = ''objectExported''
					SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' (
																CASE 
																WHEN es.documentId IS NOT NULL THEN ''''exportedWithErrors''''
																WHEN em.id IS NOT NULL AND em.objectVersion = FinancialDocumentHeader.version  THEN ''''exportedAndUnchanged'''' 
																WHEN em.id IS NOT NULL AND em.objectVersion <> FinancialDocumentHeader.version  THEN ''''exportedAndChanged'''' 
																ELSE ''''unexported'''' END   = '''''' + @field_value  + '''''' ) '',
							@from_group	= @from_group + CASE WHEN @external_flag = 0 THEN '' LEFT JOIN accounting.ExternalMapping em WITH(NOLOCK) ON em.id =  FinancialDocumentHeader.id ''	 ELSE '''' END
				ELSE
				IF @field_name = ''financialRegisterId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' FinancialReport.financialRegisterId = '''''' + @field_value + ''''''''
				ELSE
				IF @field_name IN( ''decimalValue'', ''dateValue'', ''textValue'' )
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' FinancialDocumentHeader.id IN   ( SELECT financialDocumentHeaderId FROM document.DocumentAttrValue Dav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) WHERE  '' + CASE WHEN NULLIF(@documentFieldId,'''') IS NOT NULL THEN '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = '''''' + CAST(ISNULL(@documentFieldId, '''') AS VARCHAR(36)) + '''''''' ELSE '' Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = (SELECT TOP 1 id FROM dictionary.DocumentField WHERE name = '''''' + ISNULL(@documentFieldName,'''') + '''''' ) '' END  + '' AND  Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + @field_name + '' = '''''' + @field_value + '''''') ''
				ELSE				
				IF @field_name = ''reportId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' FinancialReport.id = '''''' + @field_value + ''''''''
				ELSE
				SELECT @where = ISNULL( @where + '' AND '','' '' )  + @field_name + '' = '''''' + @field_value + ''''''''
		
				SELECT @i = @i + 1
			END		

		/*Sklejam zapytanie z filtrem dat*/
		IF @filtrDat <> ''''
			SELECT  @where = ISNULL(@where + '' AND ''  + @filtrDat  ,@filtrDat )
                              
 
    		
		/*Podział query na słowa kluczowe*/
        IF NULLIF(RTRIM(@query), '''') IS NOT NULL 
            BEGIN
                SELECT  @where = ISNULL(@where + '' AND '' ,'''') + '' FinancialDocumentHeader.id IN ( ''
                SET @i = 0
                INSERT  INTO @tmp_word ( word )
                        SELECT  word
                        FROM    xp_split(@query, '' '')
				/*Pętla po splitowanyvh słowach*/
                WHILE @@rowcount > 0
                    BEGIN
                        SET @i = @i + 1
                        SELECT  @where = @where
                                + CASE WHEN @i > 1 THEN '' AND ''
                                       ELSE '' ''
                                  END + ''''
                                + CASE WHEN @i > 1
                                       THEN ''  FinancialDocumentHeader.id IN ( ''
                                       ELSE ''''
                                  END
                                + '' SELECT DISTINCT id
									FROM document.FinancialDocumentHeader WITH(NOLOCK)
									WHERE fullnumber like '''''' + word + ''%''''
									UNION
									SELECT DISTINCT financialDocumentHeaderId
									FROM [contractor].[v_contractorDictionaryFinancialDocument] WITH(NOLOCK)
									WHERE field like '''''' + word + ''%'''' ) ''
                        FROM    @tmp_word
                        WHERE   id = @i
                    END
            END
            
        
    	/*Sklejam zapytanie z filtrem stron*/    
		IF ISNULL(@pageSize, 0 ) > 0
        SELECT  @alterQuery = '' WHERE tmp.id > ''
                + CAST(@pageSize * ( @page - 1 ) AS VARCHAR(50))
                + '' AND tmp.id <= ''
                + CAST(@pageSize * ( @page ) AS VARCHAR(50)) + ''  ''
			
                  
        /*Do sortowania*/
        IF RTRIM(@sort) <> '''' 
            BEGIN
                SELECT  @sort = LEFT(@sort, LEN(@sort) - 1),
                        @pageOrder = LEFT(@pageOrder, LEN(@pageOrder) - 1)
                SELECT  @select = REPLACE(@select,''ORDER BY FinancialDocumentHeader.id'',''ORDER BY '' + ISNULL(@pageOrder, ''''))
            END 
	
		/*Fragment podsumowań*/
		DECLARE @SUMATION nvarchar(4000)
		SELECT @SUMATION = '' DECLARE @incomeAmount decimal(18,2),  @outcomeAmount decimal(18,2), @amount decimal(18,2);
							 SELECT @amount = SUM( h.amount)
							 FROM @tmp t JOIN document.FinancialDocumentHeader h ON t.financialDocument = h.id; ''
	
		SELECT @select_page	= @select_page	+ @from_group + ISNULL( '' WHERE '' + @where ,'''') + '' GROUP BY FinancialDocumentHeader.id '' + ISNULL(@group_by,'''') + ISNULL('' ORDER BY '' + @pageOrder, '''') + ''; SELECT @count = @@ROWCOUNT; '' + @SUMATION
	
		     	
        SELECT  @exec = @opakowanie + @select_page + ISNULL(@exec,'''') + '' '' + @select + '' '' + @from
                + ISNULL(@alterQuery,'''') + '' ) financialDocumentHeader ORDER BY financialDocumentHeader.lp1 FOR XML AUTO);
				 SELECT '' + CAST(@page AS VARCHAR(50)) + '' ''''@page'''' ,'' + CAST(@pageSize AS VARCHAR(50)) + '' ''''@pageSize'''' ,@count ''''@rowCount'''', @amount ''''@amount'''', @outcomeAmount ''''@outcomeAmount'''',@incomeAmount ''''@incomeAmount'''' , @return FOR XML PATH(''''financialDocuments''''),TYPE ''
PRINT @exec
       EXECUTE ( @exec ) 

    END
' 
END
GO

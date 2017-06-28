/*
name=[document].[p_getInventoryDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ErNKFXgT0+flz3cMpDctYA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getInventoryDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getInventoryDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getInventoryDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getInventoryDocuments] @xmlVar XML
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
					

        SELECT  @opakowanie = ''	DECLARE @return XML, @from INT, @to INT, @count int;  
								DECLARE @tmp TABLE (id int identity(1,1), InventoryDocument UNIQUEIDENTIFIER); 
 
								'',
				@select_page = ''INSERT INTO  @tmp (InventoryDocument)
								SELECT InventoryDocumentHeader.id
								'',
                @select = ''SELECT @return = (  '' + char(10) + 
                ''	SELECT * FROM (SELECT tmp.id lp1, InventoryDocumentHeader.id '' ,
                @from_group = '' FROM document.InventoryDocumentHeader WITH(NOLOCK) '' + char(10) --+ 
							  --''	LEFT JOIN document.InventorySheet iss WITH(NOLOCK) ON InventoryDocumentHeader.id = iss.inventoryDocumentHeaderId'' + char(10) +
							  --'' LEFT JOIN document.InventorySheetLine il WITH(NOLOCK) ON iss.id = il.inventorySheetId '' 
							  ,
				@from = '' FROM @tmp tmp  '' + char(10) +
						'' JOIN document.InventoryDocumentHeader WITH(NOLOCK) ON tmp.InventoryDocument = InventoryDocumentHeader.id '' +char(10) -- +	
						--'' LEFT JOIN document.InventorySheet iss WITH(NOLOCK) ON InventoryDocumentHeader.id = iss.inventoryDocumentHeaderId'' + char(10) +
					    --'' LEFT JOIN document.InventorySheetLine il WITH(NOLOCK) ON iss.id = il.inventorySheetId ''
					    ,
                @i = 1,
                @sort = '''' 

	

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

				
				/*Kolumna z tabeli FinancialDocumentHeader*/
                IF @column IN ( SELECT name FROM syscolumns WHERE id = OBJECT_ID( ''document.InventoryDocumentHeader'' )  )  AND @relatedObject IS NULL
                    BEGIN
                        SELECT  @select = @select + '' , InventoryDocumentHeader.'' + @column
                        /*Replace na sortowaniu zmienia kolumnę sortowaną z fullNumber na number*/
						
                        IF @sortOrder = 1 
                            SELECT  @pageOrder = ISNULL(@pageOrder + '' , '','' '') + ''InventoryDocumentHeader.'' + REPLACE( ISNULL(NULLIF(@dataColumn, ''''), @column), ''fullNumber'',''number'') + '' '' + ISNULL(@sortType, '''') ,
									@group_by = '', InventoryDocumentHeader.'' + REPLACE( ISNULL(NULLIF(@dataColumn, ''''), @column), ''fullNumber'',''number'') 
                    END

				--/*Kolumna z tabeli InventorySheet*/
    --            IF @dataColumn IN ( SELECT name FROM syscolumns WHERE id = OBJECT_ID( ''document.InventorySheet'' )  ) AND @relatedObject = ''InventorySheet''
    --                BEGIN
    --                    SELECT  @select = @select + '' , InventorySheet.'' + @dataColumn + '' '' + @column + '' ''
						
    --                    IF @sortOrder = 1 
    --                        SELECT  @pageOrder =  ISNULL(@pageOrder + '' , '','' '') + ''InventorySheet.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) + '' '' + ISNULL(@sortType, '''') ,
				--					@group_by = '', InventorySheet.'' +  ISNULL(NULLIF(@dataColumn, ''''), @column)
    --                END



				--/*Kolumna z tabeli DocumentAttrValue*/
    --            IF @dataColumn IN ( ''decimalValue'', ''dateValue'', ''textValue'',''xmlValue'' ) AND @relatedObject IS NULL 
    --                BEGIN
    --                    SELECT  @select = @select + '' , Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + @dataColumn + '' '' + @column + '' '',
				--				@from_group = @from_group + '' LEFT JOIN document.DocumentAttrValue Dav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Dav'' + CAST(@i AS VARCHAR(10)) + ''.commercialDocumentHeaderId = CommercialDocumentHeader.id AND Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = '''''' + CAST(ISNULL(@documentFieldId, '''') AS VARCHAR(36)) + '''''''' ,
    --                            @from = @from + '' LEFT JOIN document.DocumentAttrValue Dav'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Dav'' + CAST(@i AS VARCHAR(10)) + ''.financialDocumentHeaderId = FinancialDocumentHeader.id AND Dav'' + CAST(@i AS VARCHAR(10)) + ''.documentFieldId = '''''' + CAST(ISNULL(@documentFieldId, '''') AS VARCHAR(36)) + ''''''''
                                

    --                    IF @sortOrder = 1 
    --                        SELECT  @pageOrder =  ISNULL(@pageOrder + '' , '','' '') + ''Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) + '' '' + ISNULL(@sortType, '''') ,
				--					@group_by = '', '' +  ''Dav'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column)  
    --                END


				--/*Dane kontrahenta*/
    --            IF @dataColumn IN ( ''fullName'', ''shortName'', ''nip'', ''code'' )
    --                AND @relatedObject IS NOT NULL 
    --                BEGIN
	
    --                    SELECT  @select = @select + '' , Con''
    --                            + CAST(@i AS VARCHAR(10)) + ''.'' + @dataColumn
    --                            + '' '' + @column + '' '' 

    --                    SELECT  @from = @from + '' LEFT JOIN contractor.Contractor Con'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Con'' + CAST(@i AS VARCHAR(10)) + ''.id = FinancialDocumentHeader.''
				--					+ CASE WHEN @relatedObject = ''contractor''
				--						   THEN ''contractorId ''
				--						   WHEN @relatedObject = ''issuingPersonContractorId''
				--						   THEN ''issuingPersonContractorId ''
				--					  END,
				--				@from_group = @from_group + '' LEFT JOIN contractor.Contractor Con'' + CAST(@i AS VARCHAR(10)) + '' WITH(NOLOCK) ON Con'' + CAST(@i AS VARCHAR(10)) + ''.id = FinancialDocumentHeader.''
				--					+ CASE WHEN @relatedObject = ''contractor''
				--						   THEN ''contractorId ''
				--						   WHEN @relatedObject = ''issuingPersonContractorId''
				--						   THEN ''issuingPersonContractorId ''
				--					  END
						
    --                    IF @sortOrder = 1 
    --                        SELECT  @pageOrder =  ISNULL(@pageOrder + '' , '','' '') + ''Con'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) + '' '' + ISNULL(@sortType, '''') ,
				--					@group_by = '', '' + ''Con'' + CAST(@i AS VARCHAR(10)) + ''.'' + ISNULL(NULLIF(@dataColumn, ''''), @column) 
    --                END

                SELECT  @i = @i + 1
            END
		/*KONIEC pętli po kolumnach*/
		

        IF @condition IS NOT NULL 
            BEGIN
                SELECT  @where = ISNULL( @where + '' '' + '' AND '','''') + @condition 	
            END

      	/* Filtr daty */
        IF @dateFrom IS NOT NULL OR @dateTo IS NOT NULL 
                SELECT  @filtrDat =  ISNULL('' creationDate >= '''''' + CAST(@dateFrom AS VARCHAR(50)) + '''''' '', '''') + ISNULL('' AND creationDate <= '''''' + CAST(@dateTo AS VARCHAR(50)) + '''''' '','''')
	
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

				IF @field_name = ''type''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' InventoryDocumentHeader.type IN ('' + @field_value + '')''
				ELSE	
				IF @field_name = ''status''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' InventoryDocumentHeader.status IN ('' + @field_value + '')''
				ELSE

				IF @field_name = ''fullNumber''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' InventoryDocumentHeader.fullNumber LIKE '''''' + REPLACE(REPLACE(@field_value,''*'',''%'') + ''%'''''' ,''%%'',''%'')
				ELSE
				IF @field_name = ''number''
					BEGIN
						SELECT @field_value = REPLACE(REPLACE( @field_value, substring( @field_value,PATINDEX(''%[^ 0-9]%'',@field_value),1),'',''),'' '','''')
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' InventoryDocumentHeader.number  IN ( '' + @field_value + '') ''
					END
				ELSE
				IF @field_name = ''numberSettingId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' Series.numberSettingId = '''''' + @field_value + '''''''',
								@from_group = @from_group + '' LEFT JOIN document.Series ON InventoryDocumentHeader.seriesId = Series.id ''
				ELSE
				/*Mogło by działać prosto ale kolega szymon prawidłowo uzasadnił dlaczego nie chce mu się tego implementować co przekonało kolegę kuba by stwierdzić że edycja płatności to szatański pomysł...*/
				--IF @field_name = ''unsettled''
				--		SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' ISNULL(p_.isSettled,0) <> 1 '',
				--				@from_group = @from_group + '' LEFT JOIN  finance.Payment p_ ON FinancialDocumentHeader.id = p_.financialDocumentHeaderId ''
				--ELSE
				--IF @field_name = ''unsettled''
				--		SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' ISNULL(ps.psAmount,0) <> FinancialDocumentHeader.amount AND ISNULL(ps.amount,0) <> 0 '',
				--				@from_group = @from_group + '' LEFT JOIN (	SELECT SUM( ISNULL(ps_.amount,0)) psAmount, sum(p_.direction * p_.amount ) amount , p_.financialDocumentHeaderId  
				--															FROM finance.Payment p_ 
				--																LEFT JOIN finance.PaymentSettlement ps_ ON p_.id = ps_.incomePaymentId OR p_.id = ps_.outcomePaymentId
				--															GROUP BY p_.financialDocumentHeaderId --,p_.direction , p_.amount
				--														) ps ON FinancialDocumentHeader.id = ps.financialDocumentHeaderId ''
				--ELSE
				--IF @field_name = ''financialRegisterId''
				--		SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' FinancialReport.financialRegisterId = '''''' + @field_value + ''''''''
				--ELSE
				IF @field_name = ''warehouseId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' InventoryDocumentHeader.warehouseId IN ( '''''' + @field_value + '''''')''
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
                SELECT  @where = ISNULL(@where + '' AND '' ,'''') + '' InventoryDocumentHeader.id IN ( ''
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
                                       THEN ''  InventoryDocumentHeader.id IN ( ''
                                       ELSE ''''
                                  END
                                + '' SELECT DISTINCT id
									FROM document.InventoryDocumentHeader WITH(NOLOCK)
									WHERE fullnumber like '''''' + word + ''%''''
									) ''
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
                SELECT  @select = REPLACE(@select,''ORDER BY InventoryDocumentHeader.id'',''ORDER BY '' + ISNULL(@pageOrder, ''''))
            END 
	
		SELECT @select_page	= @select_page	+ @from_group + ISNULL( '' WHERE '' + @where ,'''') + '' GROUP BY InventoryDocumentHeader.id '' + ISNULL(@group_by,'''') + ISNULL('' ORDER BY '' + @pageOrder, '''') + ''; SELECT @count = @@ROWCOUNT; ''
	

		     	
        SELECT  @exec = @opakowanie + @select_page + ISNULL(@exec,'''') + '' '' + @select + '' '' + @from
                + ISNULL(@alterQuery,'''') + '' ) InventoryDocumentHeader ORDER BY InventoryDocumentHeader.lp1 FOR XML AUTO);
				 SELECT '' + CAST(@page AS VARCHAR(50)) + '' ''''@page'''' ,'' + CAST(@pageSize AS VARCHAR(50)) + '' ''''@pageSize'''',@count ''''@rowCount'''', @return FOR XML PATH(''''InventorylDocuments''''),TYPE ''
PRINT @exec
       EXECUTE ( @exec ) 

    END
' 
END
GO

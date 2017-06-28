/*
name=[document].[p_getDrafts]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
koiPnBouS5s3rYYZifkCCQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDrafts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getDrafts]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDrafts]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [document].[p_getDrafts] @xmlVar XML
AS
BEGIN

DECLARE @query nvarchar(500),
		@dateFrom varchar(50),
		@dateTo varchar(50),
		@contractorId char(36),
		@documentTypeId varchar(max),
		@documentCategory varchar(max),
		@max INT,
        @i INT,
        @column NVARCHAR(255),
        @columnName nvarchar(100),
		@dataColumn NVARCHAR(255),
		@relatedObject NVARCHAR(255),
		@sortType NCHAR(4),
        @documentFieldId CHAR(36),
        @documentFieldName nvarchar(100),
        @select NVARCHAR(max),
        @select_page NVARCHAR(MAX),
        @from NVARCHAR(max),
		@from_group NVARCHAR(MAX),
        @from_count NVARCHAR(max),
		@group_by NVARCHAR(max),
        @where NVARCHAR(max),
        @opakowanie NVARCHAR(max),
        @sortOrder NVARCHAR(max),
        @pageOrder NVARCHAR(max),
        @sort NVARCHAR(1000),
        @replaceConf_item VARCHAR(8000)
		
		
		/*Pobranie liczby kolumn z kofiguracji*/
        SELECT  
				@max = @xmlVar.query(''<a>{ count(/*/columns/column)}</a>'').value(''a[1]'', ''int''),
				@i = 1,
                @query = REPLACE(REPLACE(NULLIF(x.value(''(query)[1]'', ''nvarchar(1000)''),''''), ''*'', ''%''),'''''''','''''''''''') + ''%'',
                @dateFrom = NULLIF(x.value(''(dateFrom)[1]'', ''varchar(50)''),''''),
                @dateTo = NULLIF(x.value(''(dateTo)[1]'', ''varchar(50)''),''''),
                @documentTypeId =  NULLIF(x.value(''(filters/column[@field="documentTypeId"])[1]'',''varchar(500)''),''''), -- NULLIF(x.value(''(documentTypeId)[1]'',''varchar(max)''),''''),
                @documentCategory = NULLIF(x.value(''(filters/column[@field="documentCategory"])[1]'',''varchar(500)''),''''),
				@contractorId = NULLIF(x.value(''(contractorId)[1]'',''char(36)''),'''')
        FROM    @xmlVar.nodes(''/*'') a(x)
        

		SELECT	@replaceConf_item = xmlValue.query(''root/indexing/object[@name="item"]/replaceConfiguration'').value(''.'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''
		/*Kwerenda*/
		SELECT 	@select = ''	        
							 SELECT (   
									SELECT draft.id ''''@id'''''',
				@from = ''				
							FROM document.Draft draft WITH(nolock)
								LEFT JOIN contractor.Contractor c WITH(nolock) ON draft.contractorId = c.id 
								JOIN dictionary.DocumentType dt ON draft.documentTypeId = dt.id ''
		/*Wareunki*/						
		SELECT @where = CASE WHEN  NULLIF(@dateFrom,'''') IS NOT NULL THEN '' draft.[date] >= '''''' + @dateFrom + '''''''' ELSE NULL END	
		SELECT @where =  CASE WHEN  NULLIF(@dateTo,'''') IS NOT NULL THEN ISNULL( @where + '' AND '' ,'''') + '' draft.[date] <= '''''' + @dateTo + '''''''' ELSE @where END
		SELECT @where =  CASE WHEN  NULLIF(@contractorId,'''') IS NOT NULL THEN ISNULL( @where + '' AND ''  ,'''') + '' c.contractorId = '''''' + @contractorId + '''''''' ELSE @where END
		SELECT @where =  CASE WHEN  NULLIF(@documentTypeId,'''') IS NOT NULL THEN ISNULL(  @where + '' AND '' ,'''') + '' dt.id IN( '' + REPLACE(@documentTypeId ,''"'','''''''') + '' )'' ELSE @where END
		SELECT @where =  CASE WHEN  NULLIF(@documentCategory,'''') IS NOT NULL THEN ISNULL(  @where + '' AND '' ,'''') + '' dt.documentCategory IN ('' + @documentCategory + '' )'' ELSE @where END
		

		
		/*Podział query na słowa kluczowe*/
        IF NULLIF(RTRIM(@query), '''') IS NOT NULL 
			BEGIN
				SELECT @from = @from + dbo.f_getQueryFilter(@query ,@replaceConf_item , '' draft.id'', ''draftId'',''document.v_draft '' ,null,null ,null)  				 
            END
            
           

		/*Pętla po kolumnach z kofiguracji*/
        WHILE @i <= @max 
            BEGIN
            
				/*Dane o kolumni wyświetlanej*/
                SELECT  @column = field,
                        @dataColumn = [column],
                        @documentFieldId = documentFieldId,
                        @documentFieldName = documentFieldName,
                        @sortType = sortType,
                        @relatedObject = relatedObject,
                        @sortOrder = sortOrder,
						@columnName  = columnName
						
                FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY x.value(''@sortOrder'', ''int'') ) row,
                                    x.value(''@field[1]'', ''nvarchar(255)'') field,
                                    x.value(''@column[1]'', ''nvarchar(255)'') [column],
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
                IF @column IN ( SELECT name FROM syscolumns WHERE id = OBJECT_ID( ''document.Draft'' )  ) 
                    BEGIN/*FIXME*/
                        SELECT  @select = @select + '' , draft.'' + @column  + '' ''''@''+@column+ ''''''''
                        
                        IF @sortOrder = 1
                        SELECT  @sort = ISNULL(@sort,'''')
                                + CASE WHEN @sortOrder <> ''''
                                       THEN ''draft.'' + ISNULL(NULLIF(@dataColumn, ''''),@column) + '' '' + ISNULL(@sortType, '''') 
                                       ELSE ''''
                                  END
						
                    END
     

				/*Generic column*/
				IF @relatedObject = (''contractor'')
					BEGIN
						SELECT  @select = @select + '' ,  c.'' +  @dataColumn + '' ''''@'' + @column  + ''''''''
						SELECT  @sort = @sort
                                + CASE WHEN @sortOrder <> ''''
                                       THEN  ISNULL(NULLIF(@dataColumn, ''''),@column) + '' '' + ISNULL(@sortType, '''') + '', ''
                                       ELSE ''''
                                  END
                                  
					END

                SELECT  @i = @i + 1

            END
		/*KONIEC pętli po kolumnach*/
		
        SELECT @select = @select + '' '' + @from + '' '' + ISNULL( '' WHERE '' + @where,'''')  + ISNULL('' ORDER BY  '' + @sort,'''') + ''
				FOR XML PATH(''''draft''''), TYPE )
		  FOR XML PATH(''''root''''), TYPE ''
		  PRINT @select
		 -- select @select s for xml path(''root'') ,type
		  EXEC ( @select) 

        
END
' 
END
GO

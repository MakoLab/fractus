/*
name=[reports].[p_getSalesByBranch]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
xNPel4tOMCPj1v94F+fIQA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getSalesByBranch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getSalesByBranch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getSalesByBranch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [reports].[p_getSalesByBranch]
@xmlVar XML
AS
BEGIN
/*
reports.p_getSalesByBranch
''<searchParams type="CommercialDocument">
  <filters>
    <column field="itemTypeId">DD659840-E90E-4C28-8774-4D07B307909A,1E12846A-C0BF-4ADA-B571-2E6140507A02,1FF5B3D4-F8BC-4B66-8D85-FE10DF7EAFE7,EA3AA3F3-61AA-4625-9D46-AC5ACDE68EC5,A3099B55-FB2C-4303-A3B8-637AF3362B84</column>
    <column field="hideSalesOrder">1</column>
  </filters>
  <sqlConditions>
	<condition id="dsds" >CommercialDocumentHeader.fullNumber like ''''%01%''''</condition>
	<condition id="dsds" >YEAR(CommercialDocumentHeader.issueDate) = 2010</condition>
  </sqlConditions>
</searchParams>''
*/

        DECLARE 
			@max INT,
            @i INT,
            @column NVARCHAR(255),
            @select NVARCHAR(max),
            @from NVARCHAR(max),
            @where NVARCHAR(max),
            @opakowanie NVARCHAR(max),
            @dataColumn NVARCHAR(255),
            @exec NVARCHAR(max),
            @dateFrom DATETIME,
            @dateTo DATETIME,
            @filtrDat VARCHAR(400),
			@filter XML,
			@field_name NVARCHAR(255),
			@field_value NVARCHAR(MAX),
			@contractorGroups XML,
            @includeUnassignedContractors CHAR(1),
			@itemGroups XML,
            @includeUnassignedItems CHAR(1),
			@filter_count INT,
			@flag_filter NVARCHAR(max),
			@replaceConf_item varchar(8000),
			@query NVARCHAR(max),
			@tx varchar(4000),
			@condition varchar(max)


        SELECT  
                @dateFrom = NULLIF(x.query(''dateFrom'').value(''.'', ''datetime''),''''),
                @dateTo = NULLIF(x.query(''dateTo'').value(''.'', ''datetime''),''''),
				@contractorGroups = @xmlVar.query(''*/contractorGroups'').value(''.'', ''varchar(max)''),
				@itemGroups = @xmlVar.query(''*/itemGroups'').value(''.'', ''varchar(max)''),
				@filter = x.query(''filters/*''),
				@query = ISNULL(REPLACE(REPLACE(RTRIM(NULLIF(@xmlVar.query(''*/query'').value(''.'', ''nvarchar(1000)''),'''')), ''*'', ''%''),'''''''',''''''''''''),'''') + ''%'' ,
				@where = '' 1 = 1 ''
        FROM    @xmlVar.nodes(''/*'') a(x)
        
	   SELECT @condition = (
				SELECT dbo.Concat( '' AND '' + x.value(''(.)[1]'',''varchar(max)'') )
						FROM @xmlVar.nodes(''searchParams/sqlConditions/condition'') a(x)
						)
				
		/*Pobranie konfiguracji*/
		SELECT	@replaceConf_item = xmlValue.value(''(root/indexing/object[@name="item"]/replaceConfiguration)[1]'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''						

		SELECT @includeUnassignedContractors = x.value(''@includeUnassigned'', ''char(1)'')
		FROM @xmlVar.nodes(''/searchParams/contractorGroups'') AS a (x)

		SELECT @includeUnassignedItems = x.value(''@includeUnassigned'', ''char(1)'')
		FROM @xmlVar.nodes(''/searchParams/itemGroups'') AS a (x)


        SELECT  @opakowanie = ''	DECLARE @return XML 
								DECLARE @tmp_branch TABLE (id uniqueidentifier, symbol nvarchar(500))
								INSERT INTO @tmp_branch
								SELECT id ,xmlLabels.value(''''(labels/label[@lang="pl"]/text())[1]'''',''''nvarchar(500)'''')
								FROM dictionary.Branch ;
								'',
                @select = ''SELECT @return = (  
							SELECT * FROM (
									SELECT  b.symbol branch , 
											-(sum(l.quantity * l.commercialDirection)) quantity , 
									sum(ABS(ISNULL(cv.value,0)) * SIGN(l.quantity )) cost ,
									sum((l.netValue * CommercialDocumentHeader.exchangeRate)/CommercialDocumentHeader.exchangeScale) netValue , 
									sum( (l.grossValue * CommercialDocumentHeader.exchangeRate)/CommercialDocumentHeader.exchangeScale) grossValue ,  
									sum( (l.netValue * CommercialDocumentHeader.exchangeRate)/CommercialDocumentHeader.exchangeScale) - SUM( ABS(ISNULL(cv.value,0)) * SIGN(l.quantity) ) profit ,
									(ABS(sum( (l.netValue * CommercialDocumentHeader.exchangeRate)/CommercialDocumentHeader.exchangeScale)) - ABS(SUM( ABS(ISNULL(cv.value,0)) * SIGN(l.quantity) )))  
									/ NULLIF(sum( (l.netValue * CommercialDocumentHeader.exchangeRate)/CommercialDocumentHeader.exchangeScale ),0) profitMargin
									
									
'',
                @from = ''
                	FROM  @tmp_branch b
								JOIN document.CommercialDocumentHeader  WITH(NOLOCK) ON CommercialDocumentHeader.branchId = b.id
								JOIN dictionary.DocumentType dt WITH(NOLOCK) ON CommercialDocumentHeader.documentTypeId = dt.id AND documentCategory IN (0,5) AND CommercialDocumentHeader.status >= 40
								JOIN document.CommercialDocumentLine l WITH(NOLOCK) ON CommercialDocumentHeader.id = l.commercialDocumentHeaderId AND l.commercialDirection <> 0
								LEFT JOIN ( 
											SELECT  SUM(ISNULL(v.value,0)) value , v.commercialDocumentLineId 
											FROM document.CommercialWarehouseValuation v WITH(NOLOCK)  
											Group by  v.commercialDocumentLineId ) cv ON l.id = cv.commercialDocumentLineId		
								LEFT JOIN contractor.Contractor c ON  CommercialDocumentHeader.contractorId = c.id ''


      	/* Filtr daty */
        IF @dateFrom IS NOT NULL OR @dateTo IS NOT NULL 
                SELECT  @filtrDat =  ISNULL('' [dbo].[f_reportsSalesDateSelector](issueDate,eventDate,dt.documentCategory,dt.symbol)  >= '''''' + CAST(@dateFrom AS VARCHAR(50)) + '''''' '', '''') + ISNULL('' AND [dbo].[f_reportsSalesDateSelector](issueDate,eventDate,dt.documentCategory,dt.symbol)  < '''''' + CONVERT(varchar(10),DATEADD(dd,1,@dateTo),21) + '''''' '','''')
		

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
							@from = @from + '' LEFT JOIN document.CommercialWarehouseRelation cwr_c ON  l.id = cwr_c.commercialDocumentLineId  AND cwr_c.isCommercialRelation = 1 ''
				ELSE	
				IF @field_name = ''documentTypeId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.documentTypeId = '''''' + REPLACE(@field_value,'','','''''' OR CommercialDocumentHeader.documentTypeId = '''''') + '''''' ) ''
				ELSE	
				IF @field_name = ''companyId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.companyId = '''''' + REPLACE(@field_value,'','','''''' OR CommercialDocumentHeader.companyId = '''''') + '''''' ) ''
				ELSE	
				IF @field_name = ''branchId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.branchId = '''''' + REPLACE(@field_value,'','','''''' OR CommercialDocumentHeader.branchId = '''''') + '''''' ) ''
				ELSE
				IF @field_name = ''warehouseId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( l.warehouseId = '''''' + REPLACE(@field_value,'','','''''' OR l.warehouseId = '''''') + '''''' ) ''
				ELSE
				IF @field_name = ''status''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CommercialDocumentHeader.status IN ('' + @field_value + '')''
				ELSE
				IF @field_name IN (''isSupplier'',''isReceiver'',''isBusinessEntity'',''isBank'',''isEmployee'', ''isOwnCompany'')
					SELECT  @flag_filter = ISNULL(@flag_filter + '' OR '' , '' '') + @field_name + '' = '' +  @field_value							
				ELSE
				IF @field_name = ''paymentMethodId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''CommercialDocumentHeader.id IN ( SELECT DISTINCT pmi.commercialDocumentHeaderId FROM   finance.Payment pmi  WHERE pmi.paymentMethodId = '''''' + REPLACE(@field_value,'','','''''' OR  pmi.paymentMethodId = '''''') + '''''' ) ''
				ELSE
				IF @field_name = ''itemTypeId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( item.itemTypeId = '''''' + REPLACE(@field_value,'','','''''' OR item.itemTypeId = '''''') + '''''' ) '',
								@from = @from + '' LEFT JOIN item.Item ON l.itemId = item.id ''
				ELSE
				IF @field_name = ''hideSalesOrder''
					BEGIN
					print ''ff''
						SELECT @field_value =  REPLACE(REPLACE(NULLIF(@field_value ,''''),''0'',''false''),''1'',''true'')
						IF @field_value = ''true''
							BEGIN
								SELECT @tx  = CAST( (	SELECT STUFF( '','' + CAST(id AS varchar(max)),1,0,'''') 
														FROM dictionary.DocumentType 
														WHERE xmlOptions.value(''(/root/commercialDocument/@isPrepaymentInvoice)[1]'',''char(6)'') = ''true''
															FOR XML PATH('''')
													)  AS varchar(4000))
									
								SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( dt.documentCategory <> 13 AND dt.id NOT IN ( '''''' + REPLACE( RIGHT(@tx,(LEN(@tx) - 1)),'','','''''','''''') + '''''') ) ''
							END	
					END
				ELSE  

				IF @field_name = ''numberSettingId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( Series.numberSettingId = '''''' + REPLACE(@field_value,'','','''''' OR Series.numberSettingId = '''''') + '''''' ) '',
								@from = @from + '' LEFT JOIN document.Series ON CommercialDocumentHeader.seriesId = Series.id ''
				ELSE
				IF @field_name = ''contractorId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.contractorId = '''''' + REPLACE(@field_value,'','','''''' OR CommercialDocumentHeader.contractorId = '''''') + '''''' ) ''
				ELSE
				SELECT @where = ISNULL( @where + '' AND '','' '' )  + @field_name + '' = '''''' + @field_value + ''''''''
		
				SELECT @i = @i + 1
			END			

		/*Sklejam zapytanie z filtrem dat*/
		IF @filtrDat <> ''''
			SELECT  @where = ISNULL(@where + '' AND ''  + @filtrDat  , @filtrDat )
                              
		/*Warunki dla grup kontrahentów*/
        IF NULLIF(@includeUnassignedContractors, '''') IS NOT NULL 
				IF @includeUnassignedContractors = 1
					SELECT @where = ISNULL( @where + '' AND '','' '') + '' ( CommercialDocumentHeader.contractorId IS NULL OR  CommercialDocumentHeader.contractorId NOT IN ( SELECT contractorId FROM contractor.ContractorGroupMembership CGM WITH(NOLOCK) ) ''
				ELSE
					SELECT @where = ISNULL( @where + '' AND '','' '') + '' (CommercialDocumentHeader.contractorId IN ( SELECT contractorId FROM contractor.ContractorGroupMembership CGM WITH(NOLOCK) ) ''


        IF NULLIF((SELECT @contractorGroups.value(''.'',''varchar(8000)'') ),'''') IS NOT NULL
                    SELECT  @where = ISNULL( @where + CASE WHEN NULLIF(@includeUnassignedContractors, '''') IS NOT NULL THEN '' OR '' ELSE '' AND '' END, '''') +
                             '' CommercialDocumentHeader.contractorId IN (SELECT CGM2.contractorId FROM contractor.ContractorGroupMembership CGM2 WITH(NOLOCK) WHERE CGM2.contractorGroupId in ('''''' + REPLACE(@contractorGroups.value(''.'',''varchar(8000)'') ,'','','''''','''''') + '''''') ) '' 

		/*Uzupełnienie nawiasu po @includeUnassignedContractor*/
        IF NULLIF(@includeUnassignedContractors, '''') IS NOT NULL 
            SELECT  @where = @where + '')''

		/*filtrowanie po query */
		IF @query <> ''%''
			BEGIN
				/*Przeniesione do funkcji, bałagan robił się przy przeszukiwaniu dictionary wielu obiektów jednocześnie*/
				SELECT @from = @from + '' '' + dbo.f_getQueryFilter(@query ,@replaceConf_item , '' l.itemId '', ''itemId '',''item.v_itemDictionary'', null, null, NULL ) 
			END 

		/*Filtr dla kontrahenta*/
		IF @flag_filter IS NOT NULL
			SELECT @where = ISNULL(NULLIF(@where,'''') + '' AND '' ,'' '' ) +  ISNULL( ''( '' + @flag_filter + '' ) '', '' '' ) 


		/*Warunki dla grup towarów*/
		IF NULLIF(@includeUnassignedItems, '''') IS NOT NULL 
			IF @includeUnassignedItems = 1
				SELECT  @where = ISNULL( @where + '' AND (l.itemId NOT IN ( SELECT itemId FROM item.ItemGroupMembership WITH(NOLOCK) ) '', '' ( l.itemId NOT IN ( SELECT itemId FROM item.ItemGroupMembership WITH(NOLOCK) )'') 
			ELSE
				SELECT  @where = ISNULL( @where + '' AND (l.itemId IN ( SELECT itemId FROM item.ItemGroupMembership WITH(NOLOCK) ) '', '' ( l.itemId IN ( SELECT itemId FROM item.ItemGroupMembership WITH(NOLOCK) )'') 


		/*Obsługa grup*/
		IF NULLIF((SELECT @itemGroups.value(''.'',''varchar(8000)'') ) ,'''') IS NOT NULL
				SELECT  @where = ISNULL( @where + CASE WHEN NULLIF(@includeUnassignedItems, '''') IS NOT NULL THEN '' OR '' ELSE '' AND '' END, '''') + 
						'' l.itemId IN (SELECT CGM2.itemId FROM item.ItemGroupMembership CGM2 WHERE CGM2.itemGroupId in  ('''''' + REPLACE(CAST(@itemGroups.query(''.'')as varchar(max)) ,'','','''''','''''') + '''''') ) '' 

		/*Uzupełnienie nawiasu po @includeUnassigned*/
		IF NULLIF(@includeUnassignedItems, '''') IS NOT NULL 
			SELECT  @where = @where + '')''
    

		SELECT @exec	= @opakowanie + @select + @from + ISNULL( '' WHERE '' + @where ,'''') + ISNULL(@condition ,'''') + '' GROUP BY  b.symbol  ) line ORDER BY branch FOR XML AUTO);
				 SELECT  @return FOR XML PATH(''''root''''),TYPE ''
print @exec
        EXECUTE ( @exec ) 
    END
' 
END
GO

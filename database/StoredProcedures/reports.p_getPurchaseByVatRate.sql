/*
name=[reports].[p_getPurchaseByVatRate]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
5iEaIKv/Dr+9kvqSZdO7zw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getPurchaseByVatRate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getPurchaseByVatRate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getPurchaseByVatRate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE PROCEDURE [reports].[p_getPurchaseByVatRate]
@xmlVar XML
AS
BEGIN
        DECLARE 
			@max INT,
            @i INT,
            @column NVARCHAR(255),
            @select NVARCHAR(max),
            @select2 NVARCHAR(max),
            @from NVARCHAR(max),
            @where NVARCHAR(max),
            @dataColumn NVARCHAR(255),
            @exec NVARCHAR(max),
            @dateFrom DATETIME,
            @dateTo DATETIME,
            @filtrDat VARCHAR(200),
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
			@condition varchar(max)

				
		
		declare  @vatAttributeSelect varchar(8000), @vatAttribute varchar(8000), @id char(36), @symbol varchar(50)
		DECLARE @tmpColumn TABLE (i int identity(1,1), symbol varchar(50), id char(36))

		INSERT INTO @tmpColumn (symbol,id)
		SELECT  x.value(''(@symbol)[1]'',''varchar(50)'') ,
				x.value(''.'',''char(36)'') 
		FROM @xmlVar.nodes(''searchParams/vatRate'') AS a(x)


		SELECT @filter_count = @@ROWCOUNT , @i = 1

		WHILE @i <= @filter_count
			BEGIN
				SELECT @id = id, @symbol = RTRIM(symbol)
				FROM @tmpColumn 
				WHERE i = @i
			
					SELECT @vatAttributeSelect =  ISNULL( @vatAttributeSelect + '' ,'' , '' '') + '' value_''+@symbol + '' ''''@value_''+ @symbol + '''''' , netValue_''+@symbol + '' ''''@netValue_''+ @symbol + '''''' '' ,
						   @vatAttribute = ISNULL( @vatAttribute + '' ,'' , '''') + '' SUM(CASE WHEN vr.symbol = '''''' + symbol + '''''' THEN (cdv.vatValue * exchangeRate)/exchangeScale ELSE 0 END ) value_''+@symbol + '', SUM(CASE WHEN vr.symbol = ''''''+symbol+'''''' THEN ( cdv.netValue * exchangeRate)/exchangeScale ELSE 0 END ) netValue_''+@symbol + '' ''

					FROM dictionary.VatRate
					WHERE id = @id
						
					
				SELECT @i = @i +1
			END

        SELECT  
                @dateFrom = NULLIF(x.value(''(dateFrom)[1]'', ''datetime''),''''),
                @dateTo = NULLIF(x.value(''(dateTo)[1]'', ''datetime''),''''),
				@contractorGroups = @xmlVar.value(''(*/contractorGroups)[1]'', ''varchar(max)''),
				@itemGroups = @xmlVar.value(''(*/itemGroups)[1]'', ''varchar(max)'') 
        FROM    @xmlVar.nodes(''/*'') a(x)

		SELECT @filter = @xmlVar.query(''filters/*'')

		SELECT @query = ISNULL(REPLACE(REPLACE(RTRIM(NULLIF(@xmlVar.value(''(*/query)[1]'', ''nvarchar(1000)''),'''')), ''*'', ''%''),'''''''',''''''''''''),'''') + ''%'' 

	    SELECT @condition = (
				SELECT dbo.Concat( '' AND '' + x.value(''(.)[1]'',''varchar(max)'') )
						FROM @xmlVar.nodes(''searchParams/sqlConditions/condition'') a(x)
						)
		SELECT @where = '' 1 = 1 '' + @condition
						
					
		/*Pobranie konfiguracji*/
		SELECT	@replaceConf_item = xmlValue.value(''(root/indexing/object[@name="item"]/replaceConfiguration)[1]'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''	
		
		SELECT @includeUnassignedContractors = x.value(''@includeUnassigned'', ''char(1)'')
		FROM @xmlVar.nodes(''/searchParams/contractorGroups'') AS a (x)

		SELECT @includeUnassignedItems = x.value(''@includeUnassigned'', ''char(1)'')
		FROM @xmlVar.nodes(''/searchParams/itemGroups'') AS a (x)


      	/* Filtr daty */
        IF @dateFrom IS NOT NULL OR @dateTo IS NOT NULL 
                SELECT  @filtrDat =  ISNULL('' [dbo].[f_reportsDateSelector](issueDate,eventDate,dt.documentCategory) >= '''''' + CAST(@dateFrom AS VARCHAR(50)) + '''''' '', '''') + ISNULL('' AND [dbo].[f_reportsDateSelector](issueDate,eventDate,dt.documentCategory) < '''''' + CONVERT(varchar(10),DATEADD(dd,1,@dateTo),21) + '''''' '','''')
		

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
				--IF @field_name = ''warehouseId''
				--	SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( l.warehouseId = '''''' + REPLACE(@field_value,'','','''''' OR l.warehouseId = '''''') + '''''' ) ''
				--ELSE
				IF @field_name = ''status''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CommercialDocumentHeader.status IN ('' + @field_value + '')''
				ELSE
				IF @field_name = ''paymentMethodId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''CommercialDocumentHeader.id IN ( SELECT DISTINCT pmi.commercialDocumentHeaderId FROM   finance.Payment pmi  WHERE pmi.paymentMethodId = '''''' + REPLACE(@field_value,'','','''''' OR  pmi.paymentMethodId = '''''') + '''''' ) ''
				ELSE
				IF @field_name = ''itemTypeId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.id IN (SELECT l.commercialDocumentHeaderId FROM document.CommercialDocumentLine l JOIN item.Item ON l.itemId = item.id WHERE item.itemTypeId = '''''' + REPLACE(@field_value,'','','''''' OR item.itemTypeId = '''''') + '''''' )) ''
				ELSE
				IF @field_name IN (''isSupplier'',''isReceiver'',''isBusinessEntity'',''isBank'',''isEmployee'', ''isOwnCompany'')
					SELECT  @flag_filter = ISNULL(@flag_filter + '' OR '' , '' '') + @field_name + '' = '' +  @field_value
							
				ELSE
				IF @field_name = ''numberSettingId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( Series.numberSettingId = '''''' + REPLACE(@field_value,'','','''''' OR Series.numberSettingId = '''''') + '''''' ) '',
								@from = @from + '' LEFT JOIN document.Series ON CommercialDocumentHeader.seriesId = Series.id ''
				ELSE
				IF @field_name = ''contractorId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.contractorId = '''''' + REPLACE(@field_value,'','','''''' OR CommercialDocumentHeader.contractorId = '''''') + '''''' ) ''
				--ELSE
				--SELECT @where = ISNULL( @where + '' AND '','' '' )  + @field_name + '' = '''''' + @field_value + ''''''''
		
				SELECT @i = @i + 1
			END			

		/*Sklejam zapytanie z filtrem dat*/
		IF @filtrDat <> ''''
			SELECT  @where = ISNULL(@where + '' AND ''  + @filtrDat  , @filtrDat )
                              
		/*Filtr dla kontrahenta*/
		IF @flag_filter IS NOT NULL
			SELECT @where = ISNULL(NULLIF(@where,'''') + '' AND '' ,'' '' ) +  ISNULL( ''( '' + @flag_filter + '' ) '', '' '' ) 

		/*Warunki dla grup kontrahentów*/
        IF NULLIF(@includeUnassignedContractors, '''') IS NOT NULL 
				IF @includeUnassignedContractors = 1
					SELECT @where = ISNULL( @where + '' AND '','' '') + '' ( CommercialDocumentHeader.contractorId IS NULL OR CommercialDocumentHeader.contractorId NOT IN ( SELECT contractorId FROM contractor.ContractorGroupMembership CGM WITH(NOLOCK) ) ''
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
				SELECT @from = @from + '' '' + dbo.f_getQueryFilter(@query ,@replaceConf_item , '' l.itemId '', ''itemId '',''item.v_itemDictionary'', null, null, null ) 
			END    


		/*Warunki dla grup towarów*/
		IF NULLIF(@includeUnassignedItems, '''') IS NOT NULL 
			IF @includeUnassignedItems = 1
				SELECT  @where = ISNULL( @where + '' AND (CommercialDocumentHeader.id IN (SELECT l.commercialDocumentHeaderId FROM document.CommercialDocumentLine l WHERE l.itemId NOT IN ( SELECT itemId FROM item.ItemGroupMembership WITH(NOLOCK) )) '', '' ( CommercialDocumentHeader.id IN (SELECT l.commercialDocumentHeaderId FROM document.CommercialDocumentHeader WHERE  l.itemId NOT IN ( SELECT itemId FROM item.ItemGroupMembership WITH(NOLOCK) ) )'') 
			ELSE
				SELECT  @where = ISNULL( @where + '' AND (CommercialDocumentHeader.id IN (SELECT l.commercialDocumentHeaderId FROM document.CommercialDocumentLine l WHERE l.itemId IN ( SELECT itemId FROM item.ItemGroupMembership WITH(NOLOCK) )) '', '' ( CommercialDocumentHeader.id IN (SELECT l.commercialDocumentHeaderId FROM document.CommercialDocumentHeader WHERE  l.itemId IN ( SELECT itemId FROM item.ItemGroupMembership WITH(NOLOCK) ) )'') 


		/*Obsługa grup*/
		IF NULLIF((SELECT @itemGroups.value(''.'',''varchar(8000)'') ) ,'''') IS NOT NULL
				SELECT  @where = ISNULL( @where + CASE WHEN NULLIF(@includeUnassignedItems, '''') IS NOT NULL THEN '' OR '' ELSE '' AND '' END, '''') + 
						'' CommercialDocumentHeader.id IN (SELECT l.commercialDocumentHeaderId FROM document.CommercialDocumentLine l WHERE  l.itemId IN (SELECT CGM2.itemId FROM item.ItemGroupMembership CGM2 WHERE CGM2.itemGroupId in ('''''' + REPLACE(CAST(@itemGroups.query(''.'')as varchar(max)) ,'','','''''','''''') + '''''') ) ) '' 

		/*Uzupełnienie nawiasu po @includeUnassigned*/
		IF NULLIF(@includeUnassignedItems, '''') IS NOT NULL 
			SELECT  @where = @where + '')''
    

    
    
        SELECT   @select = ''
				DECLARE @return XML 
				DECLARE @tmp TABLE (id uniqueidentifier)

				INSERT INTO @tmp
				SELECT CommercialDocumentHeader.id
				FROM  document.CommercialDocumentHeader  WITH(NOLOCK)
					JOIN dictionary.DocumentType dt WITH(NOLOCK) ON CommercialDocumentHeader.documentTypeId = dt.id AND documentCategory IN (2,6)  AND CommercialDocumentHeader.status >= 40 
				''
				 + ISNULL('' WHERE '' + @where ,'''') + ''


				SELECT @return = (  
							SELECT (
								SELECT DISTINCT CommercialDocumentHeader.id ''''@id'''', CommercialDocumentHeader.fullNumber AS ''''@fullNumber'''',  av.textValue AS ''''@fullNumberD'''',
										CONVERT(CHAR(10),CommercialDocumentHeader.issueDate,120) as ''''@issueDate'''',     
										CONVERT(CHAR(10),CommercialDocumentHeader.eventDate,120) AS ''''@eventDate'''', nip AS ''''@nip'''',  
										ISNULL(NULLIF(CommercialDocumentHeader.xmlConstantData.value(''''(constant/contractor/fullName)[1]'''',''''nvarchar(500)'''') , ''''''''), c.fullName) ''''@contractor_name'''' ,
											(CommercialDocumentHeader.netValue * CommercialDocumentHeader.exchangeRate)/CommercialDocumentHeader.exchangeScale ''''@netValue'''',  
											(CommercialDocumentHeader.vatValue  * CommercialDocumentHeader.exchangeRate)/CommercialDocumentHeader.exchangeScale ''''@vatValue'''',   
											(CommercialDocumentHeader.grossValue * CommercialDocumentHeader.exchangeRate)/CommercialDocumentHeader.exchangeScale ''''@grossValue'''' '' + ISNULL('',''+ @vatAttributeSelect,'' '') 
									,@select2 ='' 
			   						FROM  document.CommercialDocumentHeader  WITH(NOLOCK)
									LEFT JOIN ( 
											SELECT 
												commercialDocumentHeaderId '' + ISNULL('', ''+ @vatAttribute,'''') + ''			
											FROM document.CommercialDocumentVatTable cdv WITH(NOLOCK)
												JOIN @tmp hh ON cdv.commercialDocumentHeaderId = hh.id
												JOIN document.CommercialDocumentHeader tes WITH(NOLOCK) ON hh.id = tes.id
												JOIN dictionary.VatRate vr WITH(NOLOCK) ON cdv.vatRateId = vr.id 
											GROUP BY commercialDocumentHeaderId
											) cdv ON cdv.commercialDocumentHeaderId = CommercialDocumentHeader.id
									JOIN document.Series WITH(NOLOCK) ON CommercialDocumentHeader.seriesId = Series.id		
									JOIN dictionary.DocumentType dt WITH(NOLOCK) ON CommercialDocumentHeader.documentTypeId = dt.id AND documentCategory IN (2,6)  AND CommercialDocumentHeader.status >= 40
									JOIN document.CommercialDocumentLine l WITH(NOLOCK) ON CommercialDocumentHeader.id = l.commercialDocumentHeaderId AND l.commercialDirection <> 0
									LEFT JOIN document.DocumentAttrValue av WITH(NOLOCK)  ON CommercialDocumentHeader.id = av.commercialDocumentHeaderId AND av.documentFieldId = (SELECT id FROM dictionary.DocumentField WHERE name = ''''Attribute_SupplierDocumentNumber'''')
									LEFT JOIN contractor.Contractor c WITH(NOLOCK) ON CommercialDocumentHeader.contractorId = c.id '' + ISNULL(@from,'''') + ISNULL('' WHERE '' + @where ,'''') + ''
								ORDER BY 3
								FOR XML PATH(''''line''''), TYPE )
							FOR XML PATH(''''root''''), TYPE ) 

							SELECT @return ''

PRINT (@select)
PRINT (@select2)
		SELECT @select = @select + @select2
 
        EXECUTE ( @select ) 
    END
	' 
END
GO

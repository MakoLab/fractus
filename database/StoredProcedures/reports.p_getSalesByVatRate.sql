/*
name=[reports].[p_getSalesByVatRate]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JZ+3LnzZu7Kdeutg8jSFIw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getSalesByVatRate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getSalesByVatRate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getSalesByVatRate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [reports].[p_getSalesByVatRate]
@xmlVar XML
AS
BEGIN
--insert into xc(a)
--select @xmlVar

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
				@query = ISNULL(REPLACE(REPLACE(RTRIM(NULLIF(@xmlVar.query(''*/query'').value(''.'', ''nvarchar(1000)''),'''')), ''*'', ''%''),'''''''',''''''''''''),'''') + ''%'',
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

/*--------------------------------------------------------------------------------
kolumny
----------------------------------------------------------------------------------*/

				
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

/*--------------------------------------------------------------------------------
filtry 
----------------------------------------------------------------------------------*/

      	/* Filtr daty */
        IF @dateFrom IS NOT NULL OR @dateTo IS NOT NULL 
                SELECT  @filtrDat =  ISNULL('' [dbo].[f_reportsSalesDateSelector](issueDate,eventDate,dt.documentCategory,dt.symbol) >= '''''' + CAST(@dateFrom AS VARCHAR(50)) + '''''' '', '''') + ISNULL('' AND [dbo].[f_reportsSalesDateSelector](issueDate,eventDate,dt.documentCategory,dt.symbol) < '''''' + CONVERT(varchar(10),DATEADD(dd,1,@dateTo),21) + '''''' '','''')
		

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
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.documentTypeId IN ( '''''' + REPLACE(@field_value,'','','''''' , '''''') + '''''') ) ''
				ELSE	
				IF @field_name = ''companyId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.companyId = '''''' + REPLACE(@field_value,'','','''''' OR CommercialDocumentHeader.companyId = '''''') + '''''' ) ''
				ELSE	
				IF @field_name = ''branchId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.branchId IN ( '''''' + REPLACE(@field_value,'','','''''', '''''') + '''''' )) ''
				ELSE
				--IF @field_name = ''warehouseId''
				--	SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( l.warehouseId = '''''' + REPLACE(@field_value,'','','''''' OR l.warehouseId = '''''') + '''''' ) ''
				--ELSE
				IF @field_name = ''status''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CommercialDocumentHeader.status IN ('' + @field_value + '')''
				ELSE
				IF @field_name = ''paymentMethodId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''CommercialDocumentHeader.id IN ( SELECT DISTINCT pmi.commercialDocumentHeaderId FROM   finance.Payment pmi  WHERE pmi.paymentMethodId IN ( '''''' + REPLACE(@field_value,'','','''''' , '''''') + '''''') ) ''
				ELSE
				IF @field_name = ''itemTypeId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.id IN (SELECT l.commercialDocumentHeaderId FROM document.CommercialDocumentLine l JOIN item.Item ON l.itemId = item.id WHERE item.itemTypeId IN ( '''''' + REPLACE(@field_value,'','','''''' ,'''''') + '''''') )) ''
				ELSE
				IF @field_name IN (''isSupplier'',''isReceiver'',''isBusinessEntity'',''isBank'',''isEmployee'', ''isOwnCompany'')
					SELECT  @flag_filter = ISNULL(@flag_filter + '' OR '' , '' '') + @field_name + '' = '' +  @field_value
							
				ELSE
				IF @field_name = ''hideSalesOrder''
					BEGIN
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
				IF @field_name = ''numberSettingId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( Series.numberSettingId IN ( '''''' + REPLACE(@field_value,'','','''''','''''') + '''''') ) ''
				ELSE
				IF @field_name = ''contractorId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.contractorId IN ('''''' + REPLACE(@field_value,'','','''''','''''') + '''''') ) ''
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
						'' CommercialDocumentHeader.id IN (SELECT l.commercialDocumentHeaderId FROM document.CommercialDocumentLine l WHERE  l.itemId IN (SELECT CGM2.itemId FROM item.ItemGroupMembership CGM2 WHERE CGM2.itemGroupId in ('''''' + REPLACE(CAST(@itemGroups.query(''.'')as varchar(max)),'','','''''','''''') + '''''') ) ) '' 

		/*Uzupełnienie nawiasu po @includeUnassigned*/
		IF NULLIF(@includeUnassignedItems, '''') IS NOT NULL 
			SELECT  @where = @where + '')''
    
    
    
    --select @vatAttributeSelect = ''value_22 ''''@value_22'''', netValue_22 ''''@netValue_22'''', value_7 ''''@value_7'''', netValue_7 ''''@netValue_7'''', value_0 ''''@value_0'''', netValue_0 ''''@netValue_0'''',   value_zw ''''@value_zw'''', netValue_zw ''''@netValue_zw'''',  value_np ''''@value_np'''', netValue_np ''''@netValue_np'''' ''
    
    
        SELECT   @select = ''
				DECLARE @return XML 
				SELECT @return = (  
							SELECT (
								SELECT CommercialDocumentHeader.id AS ''''@id'''',  RTRIM( dt.symbol ) + '''' '''' + CommercialDocumentHeader.fullNumber AS ''''@fullNumber'''',  
								CONVERT(CHAR(10),CommercialDocumentHeader.issueDate,120) as ''''@issueDate'''',     
								CONVERT(CHAR(10),CommercialDocumentHeader.eventDate,120) AS ''''@eventDate'''', nip AS ''''@nip'''',  
								ISNULL(NULLIF(CommercialDocumentHeader.xmlConstantData.value(''''(constant/contractor/fullName)[1]'''',''''nvarchar(500)'''') , ''''''''), c.fullName) ''''@contractor_name'''' ,
								(CommercialDocumentHeader.netValue  * CommercialDocumentHeader.exchangeRate)/CommercialDocumentHeader.exchangeScale ''''@netValue'''',  
								(CommercialDocumentHeader.vatValue * CommercialDocumentHeader.exchangeRate)/CommercialDocumentHeader.exchangeScale ''''@vatValue'''',   
								(CommercialDocumentHeader.grossValue * CommercialDocumentHeader.exchangeRate)/CommercialDocumentHeader.exchangeScale ''''@grossValue'''' '' + ISNULL('',''+ @vatAttributeSelect,'' '')  
				,@select2 =	''
			   					FROM  document.CommercialDocumentHeader 
									LEFT JOIN ( 
											SELECT 
												commercialDocumentHeaderId '' + ISNULL('', ''+ @vatAttribute,'''') + ''				
											FROM document.CommercialDocumentVatTable cdv
												JOIN document.CommercialDocumentHeader hh ON cdv.commercialDocumentHeaderId = hh.id
												JOIN dictionary.VatRate vr ON cdv.vatRateId = vr.id
											GROUP BY commercialDocumentHeaderId
											) cdv ON cdv.commercialDocumentHeaderId = CommercialDocumentHeader.id
									JOIN document.Series ON CommercialDocumentHeader.seriesId = Series.id		
									JOIN dictionary.DocumentType dt ON CommercialDocumentHeader.documentTypeId = dt.id AND documentCategory IN (0,5)  AND CommercialDocumentHeader.status >= 40
									LEFT JOIN contractor.Contractor c ON CommercialDocumentHeader.contractorId = c.id 
									
									'' + ISNULL(@from,'''') + ''
									WHERE  CommercialDocumentHeader.id in (SELECT commercialDocumentHeaderId FROM document.CommercialDocumentLine  WITH(NOLOCK) WHERE commercialDirection <> 0) '' +  ISNULL( '' AND '' + @where ,'''') + ISNULL(@condition ,'''') + ''
								
								ORDER BY CommercialDocumentHeader.issueDate
								FOR XML PATH(''''line''''), TYPE )
							FOR XML PATH(''''root''''), TYPE ) 

							SELECT @return ''


    

		--SELECT @exec	= @opakowanie + @select + @from + ISNULL( '' WHERE '' + @where ,'''') + ''   ) line  FOR XML AUTO);
			--	 SELECT  @return FOR XML PATH(''''root''''),TYPE ''
		print @select
		print @select2
		select @select = @select + @select2
		
        EXECUTE ( @select ) 
        
         --SELECT  @select FOR XML PATH(''root''),TYPE 
    END
' 
END
GO

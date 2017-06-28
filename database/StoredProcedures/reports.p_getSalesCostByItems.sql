/*
name=[reports].[p_getSalesCostByItems]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
vS0/EDvnO37mJ4xrg+91kg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getSalesCostByItems]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getSalesCostByItems]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getSalesCostByItems]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [reports].[p_getSalesCostByItems]
@xmlVar XML
AS
BEGIN

/*
reports.p_getSalesCostByItems
''<searchParams userId="3DD11C20-D737-4A8F-ABD0-E0B9EABB82BD" type="CommercialDocument">
  <filters>
    <column field="itemTypeId">DD659840-E90E-4C28-8774-4D07B307909A,B16B87BE-C199-44EA-916F-6AA713BE16B0,993E1201-76B4-496F-B5FC-A3F9E18F7488,52BF797A-7E5E-4BA5-ACDC-53489779BD51,1E12846A-C0BF-4ADA-B571-2E6140507A02,04D8F782-8143-4B7B-B43F-42A42703C127,DF2FAA94-1E72-4172-A218-297E545DDB2D,D1345414-9822-4E09-B935-0AE7812BC0C4,7C236929-D10E-4B44-94D6-E313B6C292EA,D219451F-4C14-4AF9-8591-8BBE6B12A19E,8BDB2A75-FFB4-4FE4-B850-E0FB3CD2E0FD,CEA8BD92-7418-4387-BF48-81AA0EDE337B</column>
    <column field="hideSalesOrder">1</column>
    <column field="documentTypeId">E40A8132-C8FE-4798-A902-9D7BF61E0FE5</column>
  </filters>
  <dateFrom>2014-01-01</dateFrom>
  <dateTo>2014-10-03T23:59:59.997</dateTo>
</searchParams>''
*/

        DECLARE 
			@max INT,
            @i INT,
            @column NVARCHAR(255),
            @select NVARCHAR(max),
            @from NVARCHAR(max),
            @where NVARCHAR(max),
			@whereW NVARCHAR(max),
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



      	/* Filtr daty */
        IF @dateFrom IS NOT NULL OR @dateTo IS NOT NULL 
		   SELECT  @filtrDat =  ISNULL('' AND h.issueDate  >= '''''' + CAST(@dateFrom AS VARCHAR(50)) + '''''' '', '''') + 
				ISNULL('' AND h.issueDate < '''''' + CONVERT(varchar(10),DATEADD(dd,1,@dateTo),21) + '''''' '','''')
		
    --            SELECT  @filtrDat =  ISNULL('' AND [dbo].[f_reportsSalesDateSelector](issueDate,eventDate,dt.documentCategory,dt.symbol)  >= '''''' + CAST(@dateFrom AS VARCHAR(50)) + '''''' '', '''') + 
				--ISNULL('' AND [dbo].[f_reportsSalesDateSelector](issueDate,eventDate,dt.documentCategory,dt.symbol)  < '''''' + CONVERT(varchar(10),DATEADD(dd,1,@dateTo),21) + '''''' '','''')
		

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
					SELECT	@where = ISNULL( @where ,'' '' )  + '' AND  cwr_c.id '' + CASE @field_value WHEN  1 THEN '' IS NOT NULL '' WHEN 0 THEN '' IS NULL '' END,
							@from = @from + '' LEFT JOIN document.CommercialWarehouseRelation cwr_c ON  l.id = cwr_c.commercialDocumentLineId  AND cwr_c.isCommercialRelation = 1 ''
				ELSE	
				IF @field_name = ''documentTypeId''
					SELECT	@where = ISNULL( @where ,'' '' )  + '' AND( h.documentTypeId = '''''' + REPLACE(@field_value,'','','''''' OR CommercialDocumentHeader.documentTypeId = '''''') + '''''' ) ''
				ELSE	
				IF @field_name = ''companyId''
					SELECT	@where = ISNULL( @where ,'' '' )  + '' AND ( h.companyId = '''''' + REPLACE(@field_value,'','','''''' OR CommercialDocumentHeader.companyId = '''''') + '''''' ) '',
							@whereW = ISNULL( @whereW ,'' '' )  + '' AND ( wh.companyId = '''''' + REPLACE(@field_value,'','','''''' OR wh.companyId = '''''') + '''''' ) ''
				ELSE	
				IF @field_name = ''branchId''
					SELECT	@where = ISNULL( @where   ,'' '' )  + '' AND  ( h.branchId = '''''' + REPLACE(@field_value,'','','''''' OR CommercialDocumentHeader.branchId = '''''') + '''''' ) '',
							@whereW = ISNULL( @whereW ,'' '' )  + '' AND ( wh.branchId = '''''' + REPLACE(@field_value,'','','''''' OR wh.branchId = '''''') + '''''' ) ''
				ELSE
				IF @field_name = ''warehouseId''
					SELECT	@where = ISNULL( @where ,'' '' )  + '' AND ( l.warehouseId = '''''' + REPLACE(@field_value,'','','''''' OR l.warehouseId = '''''') + '''''' ) '',
							@whereW = ISNULL( @whereW ,'' '' )  + '' AND ( wh.warehouseId = '''''' + REPLACE(@field_value,'','','''''' OR wh.warehouseId = '''''') + '''''' ) ''
				ELSE
				IF @field_name IN (''isSupplier'',''isReceiver'',''isBusinessEntity'',''isBank'',''isEmployee'', ''isOwnCompany'')
					SELECT  @flag_filter = ISNULL(@flag_filter + '' OR '' , '' '') + @field_name + '' = '' +  @field_value
				ELSE
				IF @field_name = ''status''
					SELECT	@where = ISNULL( @where ,'' '' )  + '' AND  h.status IN ('' + @field_value + '')''
				ELSE
				IF @field_name = ''paymentMethodId''
						SELECT	@where = ISNULL( @where ,'' '' )  + '' AND h.id IN ( SELECT DISTINCT pmi.commercialDocumentHeaderId FROM   finance.Payment pmi  WHERE pmi.paymentMethodId = '''''' + REPLACE(@field_value,'','','''''' OR  pmi.paymentMethodId = '''''') + '''''' ) ''
				ELSE
				IF @field_name = ''itemTypeId''
						SELECT	@where = ISNULL( @where ,'' '' )  + '' AND ( i.itemTypeId = '''''' + REPLACE(@field_value,'','','''''' OR i.itemTypeId = '''''') + '''''' ) ''
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
									
								SELECT	@where = ISNULL( @where ,'' '' )  + '' AND ( dt.documentCategory <> 13 AND dt.id NOT IN ( '''''' + REPLACE( RIGHT(@tx,(LEN(@tx) - 1)),'','','''''','''''') + '''''') ) ''
							END	
					END
				ELSE	
				IF @field_name = ''numberSettingId''
						SELECT	@where = ISNULL( @where ,'' '' )  + '' AND ( Series.numberSettingId = '''''' + REPLACE(@field_value,'','','''''' OR Series.numberSettingId = '''''') + '''''' ) '',
								@from = @from + '' LEFT JOIN document.Series ON CommercialDocumentHeader.seriesId = Series.id ''
				ELSE
				IF @field_name = ''contractorId''
						SELECT	@where = ISNULL( @where ,'' '' )  + '' AND ( CommercialDocumentHeader.contractorId = '''''' + REPLACE(@field_value,'','','''''' OR CommercialDocumentHeader.contractorId = '''''') + '''''' ) ''
				ELSE
				SELECT @where = ISNULL( @where ,'' '' )  +'' AND ''+ @field_name + '' = '''''' + @field_value + ''''''''
		
				SELECT @i = @i + 1
			END			

		/*Sklejam zapytanie z filtrem dat*/
		IF @filtrDat <> ''''
			SELECT  @where = ISNULL(@where  + @filtrDat  , @filtrDat )
 
 		/*Filtr dla kontrahenta*/
		IF @flag_filter IS NOT NULL
			SELECT @where = ISNULL(NULLIF(@where,'''') + '' AND '' ,'' '' ) +  ISNULL( ''( '' + @flag_filter + '' ) '', '' '' ) 

		/*Warunki dla grup kontrahentów*/
        IF NULLIF(@includeUnassignedContractors, '''') IS NOT NULL 
				IF @includeUnassignedContractors = 1
					SELECT @where = ISNULL( @where + '' AND '','' '') + '' ( h.contractorId IS NULL OR h.contractorId NOT IN ( SELECT contractorId FROM contractor.ContractorGroupMembership CGM WITH(NOLOCK) ) ''
				ELSE
					SELECT @where = ISNULL( @where + '' AND '','' '') + '' (h.contractorId IN ( SELECT contractorId FROM contractor.ContractorGroupMembership CGM WITH(NOLOCK) ) ''
		

        IF NULLIF((SELECT @contractorGroups.value(''.'',''varchar(8000)'') ),'''') IS NOT NULL
                    SELECT  @where = ISNULL( @where + CASE WHEN NULLIF(@includeUnassignedContractors, '''') IS NOT NULL THEN '' OR '' ELSE '' AND '' END, '''') +
                             '' h.contractorId IN (SELECT CGM2.contractorId FROM contractor.ContractorGroupMembership CGM2 WITH(NOLOCK) WHERE CGM2.contractorGroupId in ('''''' + REPLACE(@contractorGroups.value(''.'',''varchar(8000)'') ,'','','''''','''''') + '''''') ) '' 

		/*Uzupełnienie nawiasu po @includeUnassignedContractor*/
        IF NULLIF(@includeUnassignedContractors, '''') IS NOT NULL 
            SELECT  @where = @where + '')''
   
		/*Kwerenda*/
        SELECT  @opakowanie = ''	DECLARE @return XML '',
                @select = ''SELECT @return = (  SELECT * FROM (
								SELECT i.id ,i.name itemName , i.code itemCode,
									ABS(SUM(cost)) cost ,
									SUM( WZk) WZk, 
									SUM(netValue) netValue , 
									SUM(grossValue) grossValue,  
									SUM(netValue) + SUM(cost) + SUM( WZk) profit   '',

                @from = ''	FROM item.Item i WITH(NOLOCK)
								LEFT JOIN (
										SELECT sum((l.netValue * h.exchangeRate)/h.exchangeScale) netValue,
												sum( (l.grossValue * h.exchangeRate)/h.exchangeScale) grossValue,
												l.itemId itemId
										FROM document.CommercialDocumentLine l WITH(NOLOCK) 
											LEFT JOIN document.CommercialDocumentHeader h WITH(NOLOCK) ON h.id = l.commercialDocumentHeaderId
											JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id
										WHERE h.status >= 40 and l.commercialDirection <> 0 AND dt.documentCategory IN (0,5) '' +
										ISNULL(@where,'''') + ''
										GROUP BY l.itemId
									) ll ON  ll.itemId = i.id 
								LEFT JOIN ( 
										SELECT  wl.itemId , 
												SUM( CASE WHEN dtw.symbol =''''WZk'''' THEN ISNULL(wl.value * wl.direction,0) ELSE 0 END) WZk,
												SUM( CASE WHEN dtw.symbol =''''WZ'''' THEN ISNULL(wl.value * wl.direction,0) ELSE 0 END) cost
										FROM document.WarehouseDocumentHeader wh WITH(NOLOCK)  
											JOIN document.WarehouseDocumentLine wl WITH(NOLOCK) ON wh.id = wl.warehouseDocumentHeaderId
											JOIN dictionary.DocumentType dtw WITH(NOLOCK) ON wh.documentTypeId = dtw.id
										WHERE wh.status >= 40 
											and wl.direction <> 0 '' + CHAR(10)+
										ISNULL('' AND wh.issueDate >= '''''' +  CAST(@dateFrom as varchar(50))+ '''''''','''') + CHAR(10)+
										ISNULL('' AND wh.issueDate <= '''''' +  CAST(@dateTo  as varchar(50)) + '''''''','''') + CHAR(10)+ 
										ISNULL(@whereW,'''')


		SELECT	@from = @from + CHAR(10)+ ''		GROUP BY   wl.itemId  ) cv ON i.id = cv.itemId ''+ CHAR(10) ,
				@where = ''WHERE (NULLIF(ll.netValue,0) IS NOT NULL OR  NULLIF(ISNULL(cv.cost,cv.WZk),0) IS NOT NULL ) ''			

		/*filtrowanie po query */
		IF @query <> ''%''
			BEGIN
				/*Przeniesione do funkcji, bałagan robił się przy przeszukiwaniu dictionary wielu obiektów jednocześnie*/
				SELECT @from = @from + '' '' + dbo.f_getQueryFilter(@query ,@replaceConf_item , '' i.id '', ''itemId '',''item.v_itemDictionary'', null, null ,null) 
			END   


		/*Warunki dla grup towarów*/
		IF NULLIF(@includeUnassignedItems, '''') IS NOT NULL 
			IF @includeUnassignedItems = 1
				SELECT  @where = ISNULL( @where + '' AND (i.id NOT IN ( SELECT itemId FROM item.ItemGroupMembership WITH(NOLOCK) ) '', '' ( l.itemId NOT IN ( SELECT itemId FROM item.ItemGroupMembership WITH(NOLOCK) )'') 
			ELSE
				SELECT  @where = ISNULL( @where + '' AND (i.id IN ( SELECT itemId FROM item.ItemGroupMembership WITH(NOLOCK) ) '', '' ( l.itemId IN ( SELECT itemId FROM item.ItemGroupMembership WITH(NOLOCK) )'') 

		/*Obsługa grup*/
		IF NULLIF((SELECT @itemGroups.value(''.'',''varchar(8000)'') ) ,'''') IS NOT NULL
				SELECT  @where = ISNULL( @where + CASE WHEN NULLIF(@includeUnassignedItems, '''') IS NOT NULL THEN '' OR '' ELSE '' AND '' END, '''') + 
						'' i.itemId IN (SELECT CGM2.itemId FROM item.ItemGroupMembership CGM2 WHERE CGM2.itemGroupId in  ('''''' + REPLACE(CAST(@itemGroups.query(''.'')as varchar(max)) ,'','','''''','''''') + '''''') ) '' 

		/*Uzupełnienie nawiasu po @includeUnassigned*/
		IF NULLIF(@includeUnassignedItems, '''') IS NOT NULL 
			SELECT  @where = @where + '')''
    


	

    

		SELECT @exec	= @opakowanie + @select + @from + ISNULL( NULLIF(@where,'''') ,'''')  + ISNULL(@condition ,'''') +  '' GROUP BY  i.id ,i.name  , i.code   ) line ORDER BY itemName FOR XML AUTO);
				 SELECT  @return FOR XML PATH(''''root''''),TYPE ''
--
PRINT @exec
        EXECUTE ( @exec ) 

    END

' 
END
GO

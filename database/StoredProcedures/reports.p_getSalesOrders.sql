/*
name=[reports].[p_getSalesOrders]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
GUyn6l+rILSnwA9Wsg9xWQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getSalesOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getSalesOrders]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getSalesOrders]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [reports].[p_getSalesOrders]
	@xmlVar XML
AS
--drop table xmlVar (x xml)
--insert into xmlVar(x)
--select @xmlVar
/*
EXEC [reports].[p_getSalesOrders]
''<searchParams type="CommercialDocument" applicationUserId="08E5B4A8-C430-47CB-BEEA-76AD1DD443F7">
  <filters>
    <column field="unsettled">2010-11-22T23:59:59.997</column>
  </filters>
</searchParams>''
*/

/*
EXEC [reports].[p_getSalesOrders] 
''<searchParams type="CommercialDocument" timeout="360">
  <filters/>
    <sqlConditions>
	<condition id="dsds" >CommercialDocumentHeader.fullNumber like ''''%01%''''</condition>
	<condition id="dsds" >YEAR(CommercialDocumentHeader.issueDate) = 2010</condition>
  </sqlConditions>
</searchParams>''

[reports].[p_getSalesOrders]
''
<searchParams type="CommercialDocument"> 
  <filters> 
    <column field="relatedOutcome"/> 
    <column field="relatedOutcomeDateFrom">2010-08-01</column> 
    <column field="relatedOutcomeDateTo">2010-08-31T23:59:59.997</column> 
    <column field="salesmanId">53A8F6B0-0131-44E0-829A-128C350A65E9</column> 
    <column field="documentNumber">203/O1/2010</column> 
    <column field="contractorId">7E71489B-5CEF-4B90-9607-A8B69C52D523</column> 
    <column field="cancelled"/> 
    <column field="cancelledFrom">2010-07-01</column> 
    <column field="cancelledTo">2010-08-11T23:59:59.997</column> 
    <column field="prepaid"/> 
    <column field="prepaymentDateFrom">2010-08-02</column> 
    <column field="prepaymentDateTo">2010-08-26T23:59:59.997</column> 
    <column field="settled"/> 
    <column field="settlementDateFrom">2010-07-05</column> 
    <column field="settlementDateTo">2010-08-21T23:59:59.997</column> 
    <column field="unsettled">2010-08-12T23:59:59.997</column> 
    <column field="salesType">item</column> 
  </filters> 
  <dateFrom>2010-08-12</dateFrom> 
  <dateTo>2010-08-12T23:59:59.997</dateTo> 
  <contractorGroups includeUnassigned="1">FAEB8251-3C36-409E-9567-D4F618CB8F8E</contractorGroups> 
  <status value="open,settle,unsettle,advance"/> 
</searchParams> 
''
*/
BEGIN
       DECLARE 
			@max INT,
            @i INT,
            @column NVARCHAR(255),
            @select NVARCHAR(max),
            @select2 NVARCHAR(max),
            @select3 NVARCHAR(max),
            @from NVARCHAR(max),
            @where NVARCHAR(max),
            @status_selector varchar(max),
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
			@status varchar(500),
			@tx varchar(4000),
			@paymentFromFilter varchar(4000),
			@paymentToFilter varchar(4000),
			@financialFromFilter varchar(4000),
			@financialToFilter varchar(4000),
			@prepaid varchar(max),
			@unsettledSubFilter varchar(max),
			@condition varchar(max)


        SELECT  
                @dateFrom = NULLIF(x.value(''(dateFrom)[1]'', ''datetime''),''''),
                @dateTo = NULLIF(x.value(''(dateTo)[1]'', ''datetime''),''''),
				@contractorGroups = x.value(''(contractorGroups)[1]'', ''varchar(max)''),
				@itemGroups = x.value(''(searchParams/itemGroups)[1]'', ''varchar(max)''),
				@filter = x.query(''filters/*''),
				@query = ISNULL(REPLACE(REPLACE(RTRIM(NULLIF(@xmlVar.value(''(*/query)[1]'', ''nvarchar(1000)''),'''')), ''*'', ''%''),'''''''',''''''''''''),'''') + ''%'' ,
				@status = x.value(''(status/@value)[1]'',''varchar(500)'')
        FROM    @xmlVar.nodes(''/searchParams'') a(x)


	    SELECT @condition = (
				SELECT dbo.Concat( '' AND '' + x.value(''(.)[1]'',''varchar(max)'') )
						FROM @xmlVar.nodes(''searchParams/sqlConditions/condition'') a(x)
						)
		SELECT @where = '' 1 = 1 '' + @condition
		
PRINT ''where: '' + ISNULL(@where, '''')
		
		/*Pobranie konfiguracji*/
		SELECT	@replaceConf_item = xmlValue.query(''root/indexing/object[@name="item"]/replaceConfiguration'').value(''.'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''
		
		SELECT @includeUnassignedContractors = x.value(''@includeUnassigned'', ''char(1)'')
		FROM @xmlVar.nodes(''/searchParams/contractorGroups'') AS a (x)

		SELECT @includeUnassignedItems = x.value(''@includeUnassigned'', ''char(1)'')
		FROM @xmlVar.nodes(''/searchParams/itemGroups'') AS a (x)

		DECLARE @specialStatus nvarchar(500)
		
		SELECT @status_selector = ''  '',
				@prepaid = ''( CommercialDocumentHeader.id IN (				SELECT drz.firstCommercialDocumentHeaderId
																									FROM document.DocumentRelation drz WITH(NOLOCK)
																										JOIN document.CommercialDocumentHeader hz  WITH(NOLOCK) ON drz.secondCommercialDocumentHeaderId = hz.id
																										JOIN dictionary.DocumentType dt WITH(NOLOCK) ON dt.id = hz.documentTypeId
																									WHERE documentCategory in( 0,5) AND xmlOptions.exist(''''(root/commercialDocument/@isPrepaymentInvoice)'''') = 1 
																									@@prow_1 @@prow_2))''
		
		
		IF EXISTS (SELECT * FROM xp_split(ISNULL(@status,''''),'','') WHERE word = ''advance'')
			SELECT @status = REPLACE(REPLACE(@status,'',advance'',''''),''advance'',''''), @specialStatus =	'' EXISTS (SELECT id FROM document.DocumentRelation WHERE firstCommercialDocumentHeaderId = CommercialDocumentHeader.id AND relationType = 9) ''
	
		IF NULLIF(RTRIM(@status) ,'''')IS NOT NULL --
			SELECT  @where =	ISNULL( @where + '' AND '','' '' )  + '' ( CommercialDocumentHeader.status IN ('' + ISNULL(REPLACE(REPLACE(REPLACE(REPLACE(@status,''open'',''20,40,60''),''unsettle'',''40''),''settle'',''40,60''),''cancel'',''-20''),'''') + '' )'' +ISNULL( '' OR '' +@specialStatus ,'''') + '')''
		ELSE IF @specialStatus IS NOT NULL
			SELECT  @where = ISNULL( @where + '' AND '','' '' )  + '' ( ''+ @specialStatus + '' ) ''
	
		--select * from @stat
      	/* Filtr daty */
        IF @dateFrom IS NOT NULL OR @dateTo IS NOT NULL 
                SELECT  @filtrDat =  ISNULL('' [dbo].[f_reportsDateSelector](CommercialDocumentHeader.issueDate,CommercialDocumentHeader.eventDate,dt.documentCategory) >= '''''' + CAST(@dateFrom AS VARCHAR(50)) + '''''' '', '''') + ISNULL('' AND [dbo].[f_reportsDateSelector](CommercialDocumentHeader.issueDate,CommercialDocumentHeader.eventDate,dt.documentCategory) < '''''' + CONVERT(varchar(10),DATEADD(dd,1,@dateTo),21) + '''''' '','''')
	
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
			
				IF @field_name = ''relatedOutcome''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.id IN (SELECT drw.firstCommercialDocumentHeaderId FROM document.DocumentRelation drw WITH(NOLOCK) JOIN document.FinancialDocumentHeader hw  WITH(NOLOCK) ON drw.secondFinancialDocumentHeaderId = hw.id ) )'' + CHAR(10)
				ELSE
				IF @field_name = ''relatedOutcomeDateFrom''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.id IN (
									SELECT drw.firstCommercialDocumentHeaderId 
									FROM document.DocumentRelation drw WITH(NOLOCK) 
										JOIN document.FinancialDocumentHeader hw  WITH(NOLOCK) ON drw.secondFinancialDocumentHeaderId = hw.id 
									WHERE hw.issueDate >= '''''' + @field_value+ '''''' ) )'' + CHAR(10),
								@financialFromFilter = '' AND fh.issueDate >= '''''' + @field_value+ '''''' ''	
						
				ELSE
				IF @field_name = ''relatedOutcomeDateTo''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.id IN (
									SELECT drw.firstCommercialDocumentHeaderId 
									FROM document.DocumentRelation drw WITH(NOLOCK) 
										JOIN document.FinancialDocumentHeader hw  WITH(NOLOCK) ON drw.secondFinancialDocumentHeaderId = hw.id 
									WHERE hw.issueDate <= '''''' + @field_value+ '''''') )'' + CHAR(10),
								@financialToFilter = '' AND fh.issueDate <= '''''' + @field_value+ '''''' ''
									
				ELSE
				IF @field_name = ''salesmanId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.id IN (SELECT commercialDocumentHeaderId FROM document.DocumentAttrValue WHERE documentFieldId = (select id from dictionary.DocumentField where name like ''''Attribute_SalesmanId'''') AND textValue ='''''' + @field_value+ '''''') )'' + CHAR(10)
				ELSE
				IF @field_name = ''cancelled''
					SELECT	@status_selector = '' AND CommercialDocumentHeader.status = -20 ''
				ELSE
				IF @field_name = ''cancelledFrom''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CommercialDocumentHeader.modificationDate >= '''''' + @field_value + '''''' ''
				ELSE
				IF @field_name = ''cancelledTo''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CommercialDocumentHeader.modificationDate <= '''''' + @field_value + '''''' ''
				ELSE
				IF @field_name = ''prepaid''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + @prepaid + CHAR(10)
				ELSE
				IF @field_name = ''prepaymentDateFrom''
					BEGIN 
						SELECT	@where = REPLACE(@where ,''@@prow_1'', ''AND hz.issueDate >= '''''' + @field_value+ '''''' '' ),
							    @paymentFromFilter = '' AND hz.issueDate >= '''''' + @field_value+ ''''''''
					END																										
				ELSE
				IF @field_name = ''prepaymentDateTo''
					BEGIN
						SELECT	@where = REPLACE(@where ,''@@prow_2'', ''AND hz.issueDate <= '''''' + @field_value+ '''''' '' ),
								@paymentToFilter = '' AND hz.issueDate <= '''''' + @field_value+ ''''''''		
					END
				ELSE
				--SELECT id FROM dictionary.DocumentType WHERE documentCategory = 0 AND xmlOptions.exist(''(root/commercialDocument/@isPrepaymentInvoice)'') = 1
				IF @field_name = ''salesType''
					IF @field_value = ''itemSales''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.id NOT IN ( SELECT hz.id
																						FROM document.CommercialDocumentHeader hz  WITH(NOLOCK)
																							LEFT JOIN document.CommercialDocumentLine cl  WITH(NOLOCK) ON hz.id = cl.commercialDocumentHeaderId
																							JOIN document.DocumentLineAttrValue a WITH(NOLOCK)  ON cl.id = a.commercialDocumentLineId
																							LEFT JOIN item.Item ci  WITH(NOLOCK) ON cl.itemId = ci.id
																							LEFT JOIN dictionary.ItemType ric  WITH(NOLOCK) ON ci.itemTypeId = ric.id
																						WHERE ric.isWarehouseStorable = 0  
																							AND a.documentFieldId =( select id from dictionary.DocumentField where name like ''''LineAttribute_SalesOrderGenerateDocumentOption'''') 
																							AND a.textValue IN (''''1'''',''''3'''')
																							AND ci.code NOT IN (''''UC22'''',''''UC7'''')
																						 ))'' + CHAR(10)
					IF @field_value = ''serviceSales''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.id IN ( SELECT hz.id
																						FROM document.CommercialDocumentHeader hz  WITH(NOLOCK)
																							LEFT JOIN document.CommercialDocumentLine cl  WITH(NOLOCK) ON hz.id = cl.commercialDocumentHeaderId
																							JOIN document.DocumentLineAttrValue a WITH(NOLOCK)  ON cl.id = a.commercialDocumentLineId
																							LEFT JOIN item.Item ci  WITH(NOLOCK) ON cl.itemId = ci.id
																							LEFT JOIN dictionary.ItemType ric  WITH(NOLOCK) ON ci.itemTypeId = ric.id
																						WHERE ric.isWarehouseStorable = 0  
																							AND a.documentFieldId =( select id from dictionary.DocumentField where name like ''''LineAttribute_SalesOrderGenerateDocumentOption'''') 
																							AND a.textValue IN (''''1'''',''''3'''')
																							AND ci.code NOT IN (''''UC22'''',''''UC7'''')
																						 ))'' + CHAR(10)
																												
				ELSE
				IF @field_name = ''settled''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.status >= 40 )'' + CHAR(10)
				ELSE
				IF @field_name = ''settlementDateFrom''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.status >= 40 AND v.dateValue >= '''''' + @field_value+ ''''''  )'' + CHAR(10)
				ELSE
				IF @field_name = ''settlementDateTo''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.status >= 40 AND v.dateValue <= '''''' + @field_value+ ''''''  )'' + CHAR(10)
																									
																									
				ELSE
				IF @field_name = ''unsettled''
							-- gdereck - poprawilem warunek na anulowane - ma nie wyswietlac anulowanych przed danym dniem
							-- czyli ma wyswietlac takie ktore nie sa anulowane albo sa anulowane ale po danym dniu (data modyfikacji pozniejsza)
							SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CommercialDocumentHeader.issueDate <= '''''' + ISNULL(@field_value ,getdate())+'''''' 
																AND ((v.dateValue > '''''' + ISNULL(@field_value,getdate()) + '''''' OR  CommercialDocumentHeader.status < 40 )
																AND (CommercialDocumentHeader.status > -20 OR CommercialDocumentHeader.modificationDate  > '''''' + ISNULL(@field_value ,getdate())+'''''')) '' + CHAR(10),
									@unsettledSubFilter = ISNULL( '' AND issueDate <= '''''' + ISNULL(@field_value,getdate()) + '''''' '', '''')
				ELSE
				IF @field_name = ''documentNumber''
					BEGIN
						/*To jest prowizorka która zakłada ze dostępne ustawienia numeracji dla dokumentów używają  / jako separatora składników numerów*/
						IF  substring( @field_value,PATINDEX(''%[^ 0-9A-Z]%'',@field_value),1) = ''/''
							BEGIN
								SELECT @field_value = REPLACE(REPLACE( @field_value, substring( @field_value,PATINDEX(''%[^/ 0-9A-Z]%'',@field_value),1),'''''',''''''),'' '','''')
								SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.fullNumber in(''''''+ @field_value +'''''') )'' + CHAR(10)
							END
						ELSE 
							BEGIN
								SELECT @field_value = REPLACE(REPLACE( @field_value, substring( @field_value,PATINDEX(''%[^ 0-9]%'',@field_value),1),'',''),'' '','''')
								SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.number in (''+ @field_value +'') )'' + CHAR(10)
							END		
					END	
				ELSE
				
				
				IF @field_name = ''related''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' cwr_c.id '' + CASE @field_value WHEN  1 THEN '' IS NOT NULL '' WHEN 0 THEN '' IS NULL '' END,
							@from = @from + '' LEFT JOIN document.CommercialWarehouseRelation cwr_c ON  l.id = cwr_c.commercialDocumentLineId  AND cwr_c.isCommercialRelation = 1 '' + CHAR(10)
				ELSE		
				IF @field_name = ''companyId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.companyId = '''''' + REPLACE(@field_value,'','','''''' OR CommercialDocumentHeader.companyId = '''''') + '''''' ) '' + CHAR(10)
				ELSE	
				IF @field_name = ''branchId''
					SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.branchId = '''''' + REPLACE(@field_value,'','','''''' OR CommercialDocumentHeader.branchId = '''''') + '''''' ) '' + CHAR(10)
				ELSE
				--IF @field_name = ''status''
				--	SELECT	@where = ISNULL( @where + '' AND '','' '' )  + '' CommercialDocumentHeader.status IN ('' + @field_value + '')''
				--ELSE
--TO DO albo TO THINK ...				
				--IF @field_name = ''paymentMethodId''
				--		SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''CommercialDocumentHeader.id IN ( SELECT DISTINCT pmi.commercialDocumentHeaderId FROM   finance.Payment pmi  WHERE pmi.paymentMethodId = '''''' + REPLACE(@field_value,'','','''''' OR  pmi.paymentMethodId = '''''') + '''''' ) ''
				--ELSE
				IF @field_name = ''itemTypeId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.id IN (SELECT l.commercialDocumentHeaderId FROM document.CommercialDocumentLine l JOIN item.Item ON l.itemId = item.id WHERE item.itemTypeId = '''''' + REPLACE(@field_value,'','','''''' OR item.itemTypeId = '''''') + '''''' )) ''  + CHAR(10)
				ELSE
				IF @field_name IN (''isSupplier'',''isReceiver'',''isBusinessEntity'',''isBank'',''isEmployee'', ''isOwnCompany'')
					SELECT  @flag_filter = ISNULL(@flag_filter + '' OR '' , '' '') + @field_name + '' = '' +  @field_value
							
				ELSE
				IF @field_name = ''contractorId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( CommercialDocumentHeader.contractorId = '''''' + REPLACE(@field_value,'','','''''' OR CommercialDocumentHeader.contractorId = '''''') + '''''' ) '' + CHAR(10)
				--ELSE
				--SELECT @where = ISNULL( @where + '' AND '','' '' )  + @field_name + '' = '''''' + @field_value + ''''''''
		
				SELECT @i = @i + 1
			END			

		/*Usuwam @@prow_1 @@prow_2*/
		SELECT @where = REPLACE(REPLACE(@where,''@@prow_1'',''''),''@@prow_2'','''')
		/*Sklejam zapytanie z filtrem dat*/
		IF @filtrDat <> ''''
			SELECT  @where = ISNULL(@where + '' AND ''  + @filtrDat  , @filtrDat )
                              
		/*Filtr dla kontrahenta*/
		IF @flag_filter IS NOT NULL
			SELECT @where = ISNULL(NULLIF(@where,'''') + '' AND '' ,'' '' ) +  ISNULL( ''( '' + @flag_filter + '' ) '', '' '' ) 

		/*Warunki dla grup kontrahentów*/
        IF NULLIF(@includeUnassignedContractors, '''') IS NOT NULL 
				IF @includeUnassignedContractors = 1
					SELECT @where = ISNULL( @where + '' AND '','' '') + '' ( CommercialDocumentHeader.contractorId IS NULL OR CommercialDocumentHeader.contractorId NOT IN ( SELECT contractorId FROM contractor.ContractorGroupMembership CGM WITH(NOLOCK) ) '' + CHAR(10)
				ELSE
					SELECT @where = ISNULL( @where + '' AND '','' '') + '' (CommercialDocumentHeader.contractorId IN ( SELECT contractorId FROM contractor.ContractorGroupMembership CGM WITH(NOLOCK) ) '' + CHAR(10)
 
        IF NULLIF((SELECT @contractorGroups.value(''.'',''varchar(8000)'') ),'''') IS NOT NULL
			BEGIN 
                    SELECT  @where = ISNULL( @where + CASE WHEN NULLIF(@includeUnassignedContractors, '''') IS NOT NULL THEN '' OR '' ELSE '' AND '' END, '''') +
                             '' CommercialDocumentHeader.contractorId IN (SELECT CGM2.contractorId FROM contractor.ContractorGroupMembership CGM2 WITH(NOLOCK) WHERE CGM2.contractorGroupId in ('''''' + REPLACE(@contractorGroups.value(''.'',''varchar(8000)'') ,'','','''''','''''') + '''''') ) ''  + CHAR(10)


			END
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
						'' CommercialDocumentHeader.id IN (SELECT l.commercialDocumentHeaderId FROM document.CommercialDocumentLine l WHERE  l.itemId IN (SELECT CGM2.itemId FROM item.ItemGroupMembership CGM2 WHERE CGM2.itemGroupId in ('''''' + REPLACE(@itemGroups.value(''.'',''varchar(8000)'') ,'','','''''','''''') + '''''') ) ) '' 

		/*Uzupełnienie nawiasu po @includeUnassigned*/
		IF NULLIF(@includeUnassignedItems, '''') IS NOT NULL 
			SELECT  @where = @where + '')''
   	

    	
SELECT @select = ''
		DECLARE @tmp TABLE (firstCommercialDocumentHeaderId uniqueidentifier, id uniqueidentifier, documentTypeId uniqueidentifier,category varchar(50) ,fullNumber varchar(100),  issueDate varchar(50), documentCategory int, warehouseValue numeric(18,2),netValue numeric(18,2), grossValue numeric(18,2), z_netValue numeric(18,2), z_grossValue numeric(18,2) , r_netValue numeric(18,2),r_grossValue numeric(18,2), m_grossValue numeric(18,2) )
		DECLARE @tmp_filtered_documents TABLE ( id uniqueidentifier)
		
		INSERT INTO @tmp_filtered_documents (id)
		SELECT CommercialDocumentHeader.id
		FROM document.CommercialDocumentHeader WITH(NOLOCK)
			JOIN dictionary.DocumentType dt WITH(NOLOCK) ON CommercialDocumentHeader.documentTypeId = dt.id
			LEFT JOIN document.Series WITH(NOLOCK) ON CommercialDocumentHeader.seriesId = Series.id
			LEFT JOIN document.DocumentAttrValue v  WITH(NOLOCK) ON v.CommercialDocumentHeaderId = CommercialDocumentHeader.id  AND  v.documentFieldId = (SELECT id FROM dictionary.DocumentField WHERE name = ''''Attribute_ProcessStateChangeDate'''')
    	WHERE dt.documentCategory = 13 '' + @status_selector + ISNULL('' AND ''+ @where ,'''') + 			
''	    INSERT INTO @tmp (firstCommercialDocumentHeaderId,   id,documentTypeId,  category,   fullNumber,						  issueDate,     documentCategory,warehouseValue,netValue,grossValue, z_netValue, z_grossValue,r_netValue, r_grossValue, m_grossValue )
		SELECT CommercialDocumentHeader.id,   x.id, x.documentTypeId,  x.category,  x.fullNumber,						  x.issueDate,     x.documentCategory,x.warehouseValue,x.netValue,x.grossValue, x.z_netValue, x.z_grossValue,x.r_netValue, x.r_grossValue, x.m_grossValue 
		FROM document.CommercialDocumentHeader WITH(NOLOCK)
			JOIN @tmp_filtered_documents dtl ON dtl.id = CommercialDocumentHeader.id
		LEFT JOIN (
			SELECT drz.firstCommercialDocumentHeaderId,hz.id,		dtz.id documentTypeId, ''''Zaliczka'''' category, hz.fullNumber,CONVERT(char(10),hz.issueDate,121) issueDate,dtz.documentCategory , null warehouseValue, hz.netValue netValue,hz.grossValue grossValue ,hz.netValue z_netValue, hz.grossValue z_grossValue,null r_netValue, NULL r_grossValue, null m_grossValue
			FROM document.DocumentRelation drz WITH(NOLOCK)
				JOIN @tmp_filtered_documents dtl ON dtl.id = drz.firstCommercialDocumentHeaderId
				JOIN document.CommercialDocumentHeader hz  WITH(NOLOCK) ON drz.secondCommercialDocumentHeaderId = hz.id
				JOIN dictionary.DocumentType dtz  WITH(NOLOCK) ON hz.documentTypeId = dtz.id
				LEFT JOIN document.CommercialDocumentLine cl  WITH(NOLOCK) ON hz.id = cl.commercialDocumentHeaderId
				LEFT JOIN item.Item ci  WITH(NOLOCK) ON cl.itemId = ci.id
				LEFT JOIN dictionary.ItemType ric  WITH(NOLOCK) ON ci.itemTypeId = ric.id
			WHERE ric.[name] = ''''Prepaid''''  '' + ISNULL(@paymentFromFilter,'''') + '' '' + ISNULL(@paymentToFilter,'''') + ''	'' + ISNULL( @unsettledSubFilter,'''') + ''
			UNION
			SELECT  drr.firstCommercialDocumentHeaderId,	hr.id  , dtr.id documentTypeId , ''''Rozliczenie'''' category,  hr.fullNumber , CONVERT(char(10),hr.issueDate,121) issueDate ,dtr.documentCategory ,      null warehouseValue, null netValue,null grossValue,null z_netValue, null z_grossValue , hr.netValue r_netValue ,hr.grossValue r_grossValue       ,null m_grossValue 
			FROM document.DocumentRelation drr WITH(NOLOCK)
				JOIN @tmp_filtered_documents dtl ON dtl.id = drr.firstCommercialDocumentHeaderId
				JOIN document.CommercialDocumentHeader hr  WITH(NOLOCK) ON drr.secondCommercialDocumentHeaderId = hr.id
				JOIN dictionary.DocumentType dtr  WITH(NOLOCK) ON hr.documentTypeId = dtr.id
				LEFT JOIN document.CommercialDocumentLine cl  WITH(NOLOCK) ON hr.id = cl.commercialDocumentHeaderId
				LEFT JOIN item.Item ci  WITH(NOLOCK) ON cl.itemId = ci.id
				LEFT JOIN dictionary.ItemType ric  WITH(NOLOCK) ON ci.itemTypeId = ric.id
			WHERE ISNULL(ric.[name],'''''''') <> ''''Prepaid''''
			UNION
			SELECT l.CommercialDocumentHeaderId firstCommercialDocumentHeaderId,	hw.id  , dtw.id documentTypeId , ''''Wydanie'''' category,  hw.fullNumber , CONVERT(char(10),hw.issueDate,121) issueDate ,dtw.documentCategory ,  SUM( cwr.quantity * wl.price) warehouseValue, null netValue,null grossValue,null z_netValue, null z_grossValue ,null r_netValue ,null r_grossValue      ,null  m_grossValue
			FROM document.CommercialDocumentLine l WITH(NOLOCK)
				JOIN @tmp_filtered_documents dtl ON dtl.id = l.CommercialDocumentHeaderId
				JOIN document.CommercialWarehouseRelation cwr WITH(NOLOCK) ON l.id = cwr.commercialDocumentLineId
				JOIN document.WarehouseDocumentLine wl WITH(NOLOCK) ON wl.id = cwr.warehouseDocumentLineId
				JOIN document.WarehouseDocumentHeader hw  WITH(NOLOCK) ON wl.WarehouseDocumentHeaderId = hw.id
				JOIN dictionary.DocumentType dtw  WITH(NOLOCK) ON hw.documentTypeId = dtw.id
			GROUP BY l.CommercialDocumentHeaderId,	hw.id  , dtw.id,  hw.fullNumber , CONVERT(char(10),hw.issueDate,121)  ,dtw.documentCategory
		''
		SELECT @select2 = ''				
			UNION
			SELECT l.CommercialDocumentHeaderId firstCommercialDocumentHeaderId,	hw.id  , dtw.id documentTypeId , ''''Wydanie'''' category,  hw.fullNumber , CONVERT(char(10),hw.issueDate,121) issueDate ,dtw.documentCategory ,  SUM( wl.value) warehouseValue, null netValue,null grossValue,null z_netValue, null z_grossValue ,null r_netValue ,null r_grossValue      ,null  m_grossValue
			FROM document.CommercialDocumentLine l WITH(NOLOCK)
				JOIN @tmp_filtered_documents dtl ON dtl.id = l.CommercialDocumentHeaderId
				JOIN document.CommercialWarehouseRelation cwr WITH(NOLOCK) ON l.id = cwr.commercialDocumentLineId
				JOIN document.WarehouseDocumentLine wll WITH(NOLOCK) ON wll.id = cwr.warehouseDocumentLineId
				JOIN document.WarehouseDocumentLine wl WITH(NOLOCK) ON wll.id = wl.correctedWarehouseDocumentLineId
				JOIN document.WarehouseDocumentHeader hw  WITH(NOLOCK) ON wl.WarehouseDocumentHeaderId = hw.id
				JOIN dictionary.DocumentType dtw  WITH(NOLOCK) ON hw.documentTypeId = dtw.id
			GROUP BY l.CommercialDocumentHeaderId,	hw.id  , dtw.id,  hw.fullNumber , CONVERT(char(10),hw.issueDate,121)  ,dtw.documentCategory
			UNION
			SELECT  cdl.CommercialDocumentHeaderId firstCommercialDocumentHeaderId,	ch.id  , dtw.id documentTypeId , ''''Rozliczenie'''' category,  ch.fullNumber , CONVERT(char(10),ch.issueDate,121) issueDate ,dtw.documentCategory ,      null warehouseValue, null netValue,null grossValue,null z_netValue, null z_grossValue , SUM(chl.netValue) r_netValue ,SUM(chl.grossValue) r_grossValue       ,null m_grossValue 
			FROM document.CommercialDocumentLine cdl WITH(NOLOCK)
				JOIN @tmp_filtered_documents dtl ON dtl.id = cdl.CommercialDocumentHeaderId
				JOIN document.DocumentLineAttrValue dlav WITH(NOLOCK) ON cdl.id =  dlav.guidValue 
				JOIN dictionary.DocumentField df WITH(NOLOCK) ON dlav.documentFieldId = df.id
				JOIN document.CommercialDocumentLine chl  WITH(NOLOCK) ON chl.id = dlav.commercialDocumentLineId 
				JOIN document.CommercialDocumentHeader ch  WITH(NOLOCK) ON ch.id = chl.commercialDocumentHeaderId 
				JOIN dictionary.DocumentType dtw  WITH(NOLOCK) ON ch.documentTypeId = dtw.id	
			WHERE  documentCategory <>  13 AND df.name = ''''LineAttribute_RealizedSalesOrderLineId''''
			GROUP BY  cdl.CommercialDocumentHeaderId,	ch.id  , dtw.id  , ch.fullNumber , CONVERT(char(10),ch.issueDate,121)  ,dtw.documentCategory 
			UNION
			SELECT  cdl.CommercialDocumentHeaderId firstCommercialDocumentHeaderId,	ch.id  , dtw.id documentTypeId , ''''Rozliczenie'''' category,  ch.fullNumber , CONVERT(char(10),ch.issueDate,121) issueDate ,dtw.documentCategory ,      null warehouseValue, null netValue,null grossValue,null z_netValue, null z_grossValue , SUM(chl.netValue) r_netValue ,SUM(chl.grossValue) r_grossValue       ,null m_grossValue 
			FROM document.CommercialDocumentLine cdl WITH(NOLOCK)
				JOIN @tmp_filtered_documents dtl ON dtl.id = cdl.CommercialDocumentHeaderId
				JOIN document.DocumentLineAttrValue dlav WITH(NOLOCK) ON cdl.id =  dlav.guidValue 
				JOIN dictionary.DocumentField df WITH(NOLOCK) ON dlav.documentFieldId = df.id
				JOIN document.CommercialDocumentLine chll  WITH(NOLOCK) ON chll.id = dlav.commercialDocumentLineId 
				JOIN document.CommercialDocumentLine chl  WITH(NOLOCK) ON chll.id = chl.correctedCommercialDocumentLineId
				JOIN document.CommercialDocumentHeader ch  WITH(NOLOCK) ON ch.id = chl.commercialDocumentHeaderId 
				JOIN dictionary.DocumentType dtw  WITH(NOLOCK) ON ch.documentTypeId = dtw.id	
			WHERE  documentCategory <>  13 AND df.name = ''''LineAttribute_RealizedSalesOrderLineId''''
			GROUP BY  cdl.CommercialDocumentHeaderId,	ch.id  , dtw.id  , ch.fullNumber , CONVERT(char(10),ch.issueDate,121)  ,dtw.documentCategory 
		    UNION
			SELECT  dr.firstCommercialDocumentHeaderId ,  fh.id , dtw.id documentTypeId, ''''Wypłata'''' category ,fh.fullNumber , CONVERT(char(10),fh.issueDate,121) issueDate, dtw.documentCategory  ,  NULL warehouseValue ,null netValue, null grossValue,null z_netValue, null z_grossValue , null r_netValue, null r_grossValue, SUM(ISNULL(dr.decimalValue,fh.amount))/1.23 m_grossValue
			FROM document.DocumentRelation dr WITH(NOLOCK)
				JOIN @tmp_filtered_documents dtl ON dtl.id = dr.firstCommercialDocumentHeaderId
				JOIN document.FinancialDocumentHeader fh  WITH(NOLOCK) ON dr.secondFinancialDocumentHeaderId = fh.id 
				JOIN dictionary.DocumentType dtw  WITH(NOLOCK) ON fh.documentTypeId = dtw.id
			WHERE 1 = 1 '' + ISNULL(@financialFromFilter,'''') + '' '' + ISNULL(@financialToFilter,'''') + '' 
			GROUP BY dr.firstCommercialDocumentHeaderId ,  fh.id , dtw.id , fh.fullNumber , CONVERT(char(10),fh.issueDate,121) , dtw.documentCategory  
			) x  ON CommercialDocumentHeader.id = x.firstCommercialDocumentHeaderId ''
				
	
	SELECT @select3 = ''
		-- dirty hack by gdereck - zerowanie wartości proform i faktur detalicznych na podstawie id typu dokumentu
		UPDATE @tmp
		SET z_netValue = NULL, z_grossValue = NULL, r_netValue = NULL, r_grossValue = NULL, netValue = NULL, grossValue = NULL
		WHERE documentTypeId IN (''''A8731752-4216-4D23-9086-2F0692852AE3'''', ''''04875D95-2669-4090-9FE5-49299433990F'''')
		
		SELECT (
					SELECT CommercialDocumentHeader.id ''''@id'''', CommercialDocumentHeader.documentTypeId ''''@documentTypeId'''', nr.textValue ''''@privNumber'''', c.shortName ''''@contractorName'''',  CommercialDocumentHeader.fullNumber ''''@fullNumber'''', CommercialDocumentHeader.number ''''@number'''', CONVERT(char(10),CommercialDocumentHeader.issueDate,121) ''''@issueDate'''', 
							CommercialDocumentHeader.netValue ''''@netValue'''', CommercialDocumentHeader.grossValue ''''@grossValue'''',SUM(r_netValue) ''''@r_netValue'''', SUM(r_grossValue) ''''@r_grossValue'''', SUM(z_netValue) ''''@z_netValue'''', SUM(z_grossValue) ''''@z_grossValue'''', 
							SUM(warehouseValue) ''''@warehouseValue'''' ,SUM(m_grossValue) ''''@m_netValue'''',SUM(m_grossValue) ''''@m_grossValue'''' ,
							CASE WHEN  CommercialDocumentHeader.status >= 40 THEN (1 * ( ( SUM(ISNULL( z_netValue ,0) + ISNULL(r_netValue,0) ) - (SUM(ISNULL(m_grossValue,0)))) - SUM(ISNULL(warehouseValue,0)))) / NULLIF((( SUM(ISNULL(z_netValue,0) + ISNULL(r_netValue,0)) - SUM(ISNULL(m_grossValue,0)))),0) ELSE NULL END ''''@profitMargin'''' , 
							CASE WHEN  CommercialDocumentHeader.status >= 40 THEN DATEDIFF(dd,CommercialDocumentHeader.creationDate,ISNULL(CommercialDocumentHeader.modificationDate,getDate())) ELSE NULL END ''''@realizationTime'''', 
							CASE WHEN CommercialDocumentHeader.status >= 40 THEN DATEDIFF(dd,(SELECT MIN(tt.issueDate) FROM @tmp tt WHERE tt.category = ''''Wydanie'''' AND tt.firstCommercialDocumentHeaderId = CommercialDocumentHeader.id),ISNULL(CommercialDocumentHeader.modificationDate,getdate())) ELSE NULL END ''''@serviceRealizationTime'''',
						(	SELECT  id ''''@id'''',documentTypeId ''''@documentTypeId'''',  category ''''@category'''',   fullNumber ''''@fullNumber'''',issueDate ''''@issueDate'''',documentCategory ''''@documentCategory'''',warehouseValue ''''@warehouseValue'''',netValue ''''@netValue'''',grossValue ''''@grossValue'''', z_netValue ''''@z_netValue'''', z_grossValue ''''@z_grossValue'''' ,r_netValue ''''@r_netValue'''', r_grossValue ''''@r_grossValue'''', m_grossValue  ''''@m_grossValue''''
							FROM @tmp t 
							WHERE t.firstCommercialDocumentHeaderId = CommercialDocumentHeader.id
							'' + ISNULL( @unsettledSubFilter,'''') + ''
							FOR XML PATH(''''relatedDocument''''), TYPE  ) 
					FROM @tmp tm
						JOIN document.CommercialDocumentHeader WITH(NOLOCK) ON CommercialDocumentHeader.id = tm.firstCommercialDocumentHeaderId
						LEFT JOIN contractor.Contractor c  WITH(NOLOCK) ON CommercialDocumentHeader.contractorId = c.id
						LEFT JOIN document.DocumentAttrValue nr  WITH(NOLOCK) ON nr.commercialDocumentHeaderId = CommercialDocumentHeader.id AND nr.documentFieldId = (SELECT id FROM dictionary.DocumentField  WITH(NOLOCK) WHERE [name] = ''''Attribute_OrderNumber'''')
						LEFT JOIN document.DocumentAttrValue status  WITH(NOLOCK) ON status.commercialDocumentHeaderId = CommercialDocumentHeader.id AND status.documentFieldId = (SELECT id FROM dictionary.DocumentField  WITH(NOLOCK) WHERE [name] = ''''Attribute_ProcessState'''')
					GROUP BY tm.firstCommercialDocumentHeaderId, CommercialDocumentHeader.id, CommercialDocumentHeader.status ,CommercialDocumentHeader.modificationDate, CommercialDocumentHeader.creationDate, CommercialDocumentHeader.documentTypeId , nr.textValue , c.shortName ,  CommercialDocumentHeader.fullNumber ,CommercialDocumentHeader.number, CONVERT(char(10),CommercialDocumentHeader.issueDate,121) , CommercialDocumentHeader.netValue , CommercialDocumentHeader.grossValue
					ORDER BY CommercialDocumentHeader.number
					FOR XML PATH(''''salesOrderDocument''''), TYPE)
			FOR XML PATH(''''root''''), TYPE		 
			''
			
		SELECT @select = @select + @select2 + @select3
		
		PRINT @select
		PRINT @select2
		PRINT @select3
						
        EXEC ( @select ) 
        
      --select @select for xml path(''root'')
END
' 
END
GO

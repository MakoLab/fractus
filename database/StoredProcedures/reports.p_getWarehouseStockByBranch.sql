/*
name=[reports].[p_getWarehouseStockByBranch]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ZayuBeS9XJwFTK9yUtiuJQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getWarehouseStockByBranch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getWarehouseStockByBranch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getWarehouseStockByBranch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [reports].[p_getWarehouseStockByBranch]
@xmlVar XML
AS
BEGIN
        DECLARE 
			@max INT,
            @i INT,
            @column NVARCHAR(255),
            @select NVARCHAR(max),
            @from NVARCHAR(max),
            @where NVARCHAR(max),
            @opakowanie NVARCHAR(max),
            @dataColumn NVARCHAR(255),
            @containers varchar(8000),
            @exec NVARCHAR(max),
            @dateFrom DATETIME,
            @dateTo DATETIME,
            @filtrDat VARCHAR(200),
			@filter XML,
			@field_name NVARCHAR(255),
			@field_value NVARCHAR(MAX),
			@itemGroups XML,
            @includeUnassignedItems CHAR(1),
			@filter_count INT,
			@replaceConf_item varchar(8000),
			@query NVARCHAR(max),	
			@end NVARCHAR(max),	
			@end_where NVARCHAR(max),
			@client_name NVARCHAR(40),
			@condition varchar(max)	

        SELECT  
                @dateFrom = NULLIF(x.value(''(dateFrom)[1]'', ''datetime''),''''),
                @dateTo = NULLIF(x.value(''(dateTo)[1]'', ''datetime''),''''),
				@itemGroups = @xmlVar.query(''*/itemGroups'').value(''.'', ''varchar(max)''),
				@containers =  x.value(''(containers)[1]'', ''varchar(8000)''),
				@filter = x.query(''filters/*''),
				@query = ISNULL(REPLACE(REPLACE(RTRIM(NULLIF(@xmlVar.query(''*/query'').value(''.'', ''nvarchar(1000)''),'''')), ''*'', ''%''),'''''''',''''''''''''),'''') + ''%'' 
        FROM    @xmlVar.nodes(''/*'') a(x)


	    SELECT @condition = (
				SELECT dbo.Concat( '' AND '' + x.value(''(.)[1]'',''varchar(max)'') )
						FROM @xmlVar.nodes(''searchParams/sqlConditions/condition'') a(x)
						)
		SELECT @where = '' 1 = 1 '' + @condition
		
		/*Pobieranie klienta - ma to znaczenie przy sortowaniu, ktore działa tylko dla Unigumu*/
		SELECT @client_name = shortName
		FROM contractor.Contractor
		WHERE isOwnCompany = 1
					
		/*Pobranie konfiguracji*/
		SELECT	@replaceConf_item = xmlValue.value(''(root/indexing/object[@name="item"]/replaceConfiguration)[1]'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''


		SELECT @includeUnassignedItems = x.value(''@includeUnassigned'', ''char(1)'')
		FROM @xmlVar.nodes(''/searchParams/itemGroups'') AS a (x)

/*
Wartość wg. cen zakupu
Wartość wg. ceny netto
Wartość wg. ceny brutto
*/
        SELECT  @opakowanie = ''	DECLARE @return XML '',
                @select = ''SELECT @return = (  
								SELECT * FROM (		
									SELECT top 100 convert(xml, convert(varchar(500), b.xmlLabels)).value(''''(/labels/label)[1]'''',''''varchar(50)'''') branchSymbol,
									convert(xml, convert(varchar(500), w.xmlLabels)).value(''''(/labels/label)[1]'''',''''varchar(50)'''') warehouseSymbol, 
									isnull(x.quantity,0) quantity, 
									x.cost cost, 
									x.byNetPriceValue byNetPriceValue, 
									x.byGrossPriceValue byGrossPriceValue
									from dictionary.Branch b WITH(NOLOCK)
									JOIN dictionary.Warehouse w WITH(NOLOCK) ON b.id = w.branchId
									left join (
									SELECT b.id branchId, w.id warehouseId,
										ISNULL(sum(l.quantity * direction),0) quantity 
										, ISNULL(sum(ISNULL(ABS(l.value) * SIGN(l.quantity * l.direction),0)),0) cost 
										, ISNULL(sum(l.quantity * direction * i.defaultPrice),0) byNetPriceValue
										, ISNULL(sum(l.quantity * direction * i.defaultPrice * ((100 + v.rate) / 100)),0) byGrossPriceValue '',
                @from = ''			FROM dictionary.Branch b WITH(NOLOCK)
										JOIN dictionary.Warehouse w WITH(NOLOCK) ON b.id = w.branchId
										LEFT JOIN document.WarehouseDocumentHeader h WITH(NOLOCK) ON h.warehouseId = w.id
										LEFT JOIN document.WarehouseDocumentLine l WITH(NOLOCK) ON h.id = l.warehouseDocumentHeaderId  
										LEFT JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id --AND documentCategory = 1 
										LEFT JOIN item.Item i WITH(NOLOCK) ON l.itemId = i.id 
										LEFT JOIN dictionary.VatRate v WITH(NOLOCK) ON  i.vatRateId = v.id
										 '' 
										


      	/* Filtr daty */
        IF @dateFrom IS NOT NULL OR @dateTo IS NOT NULL 
                SELECT  @filtrDat =  ISNULL('' ( issueDate <= '''''' + CONVERT(VARCHAR(30), @dateTo, 21) + '''''' OR issueDate IS NULL ) '','''')
		

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
					SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + '' cwr_c.id '' + CASE @field_value WHEN  1 THEN '' IS NOT NULL '' WHEN 0 THEN '' IS NULL '' END,
							@from = @from + char(10) +'' LEFT JOIN document.CommercialWarehouseRelation cwr_c ON  l.id = cwr_c.warehouseDocumentLineId  AND cwr_c.isCommercialRelation = 1''
				ELSE	
				IF @field_name = ''documentTypeId''
					SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + ''( h.documentTypeId = '''''' + REPLACE(@field_value,'','','''''' OR h.documentTypeId = '''''') + '''''' ) ''
				ELSE	
				IF @field_name = ''companyId''
					SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + ''( h.companyId = '''''' + REPLACE(@field_value,'','','''''' OR h.companyId = '''''') + '''''' ) ''
				ELSE	
				IF @field_name = ''branchId''
					BEGIN
						SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + ''( b.id = '''''' + REPLACE(@field_value,'','','''''' OR b.id = '''''') + '''''' ) ''
						SELECT	@end_where = '' ( b.id = '''''' + REPLACE(@field_value,'','','''''' OR b.id = '''''') + '''''' ) ''
					END
				ELSE
				IF @field_name = ''warehouseId''
					BEGIN
						SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + ''( w.id = '''''' + REPLACE(@field_value,'','','''''' OR w.id = '''''') + '''''' ) ''
						SELECT	@end_where = ISNULL( @end_where + char(10) +'' AND '','' '' )  + ''( w.id = '''''' + REPLACE(@field_value,'','','''''' OR w.id = '''''') + '''''' ) ''
					END
				ELSE
				IF @field_name = ''status''
					SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + '' h.status IN ('' + @field_value + '')''
				ELSE
--				IF @field_name = ''paymentMethodId''
--						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''h.id IN ( SELECT DISTINCT pmi.commercialDocumentHeaderId FROM   finance.Payment pmi  WHERE pmi.paymentMethodId = '''''' + REPLACE(@field_value,'','','''''' OR  pmi.paymentMethodId = '''''') + '''''' ) ''
--				ELSE
				IF @field_name = ''itemTypeId''
					BEGIN
						IF (SELECT COUNT(id) FROM dictionary.ItemType) <> (SELECT COUNT(*) FROM dbo.xp_split(@field_value, '',''))
						
						SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + ''( i.itemTypeId  = '''''' + REPLACE(@field_value,'','','''''' OR i.itemTypeId = '''''') + '''''' ) ''
					END
				ELSE

				IF @field_name = ''numberSettingId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( Series.numberSettingId = '''''' + REPLACE(@field_value,'','','''''' OR Series.numberSettingId = '''''') + '''''' ) '',
								@from = @from + char(10) +'' LEFT JOIN document.Series ON h.seriesId = Series.id ''
				ELSE
				SELECT @where = ISNULL( @where + '' AND '','' '' )  + @field_name + '' = '''''' + @field_value + ''''''''
		
				SELECT @i = @i + 1
			END			

		/*Sklejam zapytanie z filtrem dat*/
		IF @filtrDat <> ''''
			SELECT  @where = ISNULL(@where + char(10) + '' AND ''  + @filtrDat  , @filtrDat )
                              


		/*filtrowanie po query */
		IF @query <> ''%''
			BEGIN
				/*Przeniesione do funkcji, bałagan robił się przy przeszukiwaniu dictionary wielu obiektów jednocześnie*/
				SELECT @from = @from + '' '' + dbo.f_getQueryFilter(@query ,@replaceConf_item , '' l.itemId '', ''itemId '',''item.v_itemDictionary'', null, null, NULL ) 
			END    

DECLARE @itemGoupsList varchar(max)
SELECT @itemGoupsList = NULLIF(REPLACE(ISNULL(@itemGroups.value(''.'',''varchar(8000)''),'''') ,'','','''''',''''''),'''')
		/*Warunki dla grup towarów*/
		IF NULLIF(CAST(@itemGroups AS varchar(max)), '''') IS NOT NULL OR @includeUnassignedItems IS NOT NULL
			BEGIN
				SELECT  @where = ISNULL( @where + char(10) + '' AND '', '' '' ) + ''
						 (  i.id IN (
									SELECT itm.id 
									FROM item.item itm WITH( NOLOCK )  
										LEFT JOIN item.ItemGroupMembership igm WITH( NOLOCK ) ON itm.id = igm.itemId 
									WHERE igm.itemId IS NULL AND 1 = '' + CAST(ISNULL(@includeUnassignedItems,0) AS VARCHAR(10)) + ''
									GROUP BY itm.id '' + 
									ISNULL( ''
									UNION 
									SELECT itemId 
									FROM item.ItemGroupMembership  WITH( NOLOCK )
									WHERE itemGroupId IN ('''''' + @itemGoupsList + '''''') 
									GROUP BY itemId '' , '''' ) + ''
									)
							)''
			END

 
			
 		IF NULLIF(RTRIM(@containers),'''') IS NOT NULL
			BEGIN
				SELECT @where = ISNULL( @where + char(10) + '' AND '', '' '' ) + ''
				( i.id IN ( SELECT hh.itemId
				FROM warehouse.Container c  WITH( NOLOCK ) 
					JOIN warehouse.Shift s WITH( NOLOCK ) ON s.containerId  = c.id
					LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx  WITH( NOLOCK ) GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
					JOIN document.WarehouseDocumentLine hh ON s.incomeWarehouseDocumentLineId = hh.id
				WHERE ISNULL((s.quantity - ISNULL(x.q,0)),0) > 0 AND s.containerId IS NOT NULL AND c.name LIKE  REPLACE(RTRIM('''''' + @containers + ''''''),''''*'''', ''''%'''') )
				)''
			END
--HAVING sum(l.quantity * direction) <> 0 OR sum(ISNULL(ABS(l.value) * SIGN(l.quantity * l.direction),0)) <> 0



SELECT @end = '' GROUP BY b.id, w.id
		) x on  b.id = x.branchId and w.id = x.warehouseId ''

		
		
/*Sklejanie całości*/
		SELECT @exec	= @opakowanie + @select + @from + ISNULL( char(10) + '' WHERE w.isActive = 1 AND  ( h.status >= 40 OR h.status is null) AND '' + @where ,'' WHERE w.isActive = 1 AND   (h.status >= 40 OR h.status is null) '') + @end + ISNULL( char(10) + '' WHERE '' + @end_where ,'''') 
		IF @client_name = ''PPH UNIGUM Wrotek Zbigniew''
			SELECT @exec = @exec + '' GROUP BY  convert(varchar(500), b.xmlLabels), convert(varchar(500), w.xmlLabels), x.quantity, x.cost, x.byNetPriceValue, x.byGrossPriceValue,  b.[order], w.[order] ORDER BY b.[order], w.[order]''
		SELECT @exec = @exec + ''  ) line  FOR XML AUTO);
				 SELECT  @return FOR XML PATH(''''root''''),TYPE ''
		PRINT @exec
        EXECUTE ( @exec ) 
    END
' 
END
GO

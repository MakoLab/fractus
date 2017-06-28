/*
name=[reports].[p_getItemsByMinimalStock]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ibCWPhfxGSBjg0uJoALd9Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getItemsByMinimalStock]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getItemsByMinimalStock]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getItemsByMinimalStock]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [reports].[p_getItemsByMinimalStock]
--declare 
@xmlVar XML
AS
BEGIN

--set @xmlVar = ''<searchParams type="CommercialDocument">
--  <filters>
--    <column field="companyId">26F958D1-06D7-4CDB-8002-9205F5871BE3</column>
--    <column field="branchId">DFC07022-2743-4C03-8960-8FB62A85B524,1225C626-C6CD-4CED-A6AC-FA3439E66963,3A8D5267-2721-4D2A-9260-73F538521F46</column>
--    <column field="warehouseId">ABCBE9D0-A7BB-4A52-B35D-9E49CECD737F,5D1E6A78-8C69-4079-B9B4-175727EF62E8,8B280148-650D-4A47-8F30-CE629C2AC14A,8844D6D8-5C0F-4691-8D47-DAE647BD285C,CE76A74A-F36E-4ABA-ACCD-FADB178DA940,4B1238F6-FC99-4578-BEB4-A65848DA78F5,666A2823-7E23-4DEF-9ED8-1288694F4272,D53CC907-0FA8-4197-BB72-DE78F87E350B,67DEC679-8029-4326-88E0-F6D704C0A484</column>
--    <column field="itemTypeId">DD659840-E90E-4C28-8774-4D07B307909A,1E12846A-C0BF-4ADA-B571-2E6140507A02,1FF5B3D4-F8BC-4B66-8D85-FE10DF7EAFE7,EA3AA3F3-61AA-4625-9D46-AC5ACDE68EC5</column>
--  </filters>
--  <dateTo>2010-03-19T23:59:59.997</dateTo>
--  <itemGroups includeUnassigned="1">BCB0C424-FD13-4DC7-9B54-BBCCE1627832,4FF5EB60-3652-4D91-8D83-7819E5305F64,1B11E13E-CD1F-47A1-BAFE-45723FAEF8F7,50312114-F1C3-4480-8D6F-803715A1E72A,E4497BAD-1525-4335-BD32-31CB5CE9F9A4,317D2CD9-55D6-45F8-A9D3-EDA267C2EAD6,DF3D763A-5DCE-47E7-B3B5-03A7C0796259,3D51C021-5F6D-45A5-960B-FB84B5C35492,B0C3C476-55F6-4E2D-908F-912C3A765507,E61F9E26-8728-4F74-9B6E-31DCB5C252CC,DAF176E5-6097-432E-A363-8D8B101E6DD2,13A7518E-E82F-4765-AE6B-644BEFDA02B1,6B00694B-B2D1-4EF1-B4FD-50BD2BB9B91E,238A92E0-5096-4CDC-8D44-50BAC7C0E6CE,3DC1F6B3-E230-4D87-A7D7-82B42BC7FA2D,CCE25DF4-EA0D-4C60-924D-3F48CD614399,9A84FCB6-5CE5-4DF8-A86E-A43BEE4EF79B,81EB4220-C1CF-477F-91B3-B806B29E9EF8,717601C4-01FE-4E9B-A2E3-2C33ED590EB3,80D8E3E0-6195-4C58-B63A-17B02B1C84C2,8F9E4921-5C3E-43EF-98C8-8D52FDCF15B7,A6B56AD4-1CE1-40A1-A179-B5926371FF1A,0479086D-FA25-4347-801C-AE2DD1D2A930,F9058F6C-06B8-4F10-A1F9-F74C86E42E15,D4440806-2792-4195-8467-D57F9FBD42A9,29DB2C3F-0280-49BA-A372-806BD66A289A,646352C0-D14D-496F-B263-650EE9C26E54,55D8AC80-BE67-4250-B002-2D89E490A51F,32F4C358-D589-48EC-A882-2F11A2011C0F,AE9231AA-94AA-4F3B-8E70-4ADBF19DE608,E3513787-FD52-437F-A60E-7196249EDBCC,F546CF78-D53B-4CC7-9E0E-0DF6C99139B0,06582EA2-326D-4F42-9A48-505DF5FEE7AF,D9EDE7C1-41AC-4729-88F4-D02B5AC53593</itemGroups>
--</searchParams>''

        DECLARE 
			@max INT,
            @i INT,
            @column NVARCHAR(255),
            @select NVARCHAR(max),
            @from1 NVARCHAR(max),
            @from1a NVARCHAR(max),
            @from2 NVARCHAR(max),
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
			@replaceConf_item VARCHAR(8000),
			@query NVARCHAR(max),
			@condition VARCHAR(max),
			@having NVARCHAR(MAX)		



        SELECT  
                @dateFrom = NULLIF(x.query(''dateFrom'').value(''.'', ''datetime''),''''),
                @dateTo = NULLIF(x.query(''dateTo'').value(''.'', ''datetime''),''''),
				@itemGroups = @xmlVar.query(''*/itemGroups'').value(''.'', ''varchar(max)''),
				@containers =  x.value(''containers[1]'', ''varchar(8000)''),
				@filter = x.query(''filters/*''),
				@query = ISNULL(REPLACE(REPLACE(RTRIM(NULLIF(@xmlVar.query(''*/query'').value(''.'', ''nvarchar(1000)''),'''')), ''*'', ''%''),'''''''',''''''''''''),'''') + ''%'' 
        FROM    @xmlVar.nodes(''/*'') a(x)


	    SELECT @condition = (
				SELECT dbo.Concat( '' AND '' + x.value(''(.)[1]'',''varchar(max)'') )
						FROM @xmlVar.nodes(''searchParams/sqlConditions/condition'') a(x)
						)
		SELECT @where = '' 1 = 1 '' + @condition
					
		/*Pobranie konfiguracji*/
		SELECT	@replaceConf_item = xmlValue.value(''(root/indexing/object[@name="item"]/replaceConfiguration)[1]'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''
		

		SELECT @includeUnassignedItems = x.value(''@includeUnassigned'', ''char(1)'')
		FROM @xmlVar.nodes(''/searchParams/itemGroups'') AS a (x)



        SELECT  @opakowanie = ''	DECLARE @return XML '',
                @select = ''SELECT @return = (  
								SELECT * FROM (	
									SELECT i.id AS ''''@id'''',i.name ''''@itemName'''' , i.code ''''@itemCode'''',ISNULL( minStock.decimalValue,0) ''''@minimalStock'''', (SELECT top 1 textValue FROM item.ItemAttrValue va WHERE va.itemId = i.id AND va.itemFieldId = (select id from dictionary.ItemField where name like ''''Attribute_Manufacturer'''')) ''''@manufacturer'''', 
									 (SELECT TOP 1 textValue FROM item.ItemAttrValue va WHERE va.itemId = i.id AND va.itemFieldId = (select id from dictionary.ItemField where name like ''''Attribute_ManufacturerCode'''')) ''''@manufacturerCode'''', 
											ws.quantity ''''@stock'''' , 
											SUM(CASE WHEN DATEDIFF(dd,h.issueDate ,getdate()) < 14 THEN  ABS(l.quantity) ELSE 0 END ) ''''@outcome14'''',
											SUM(CASE WHEN DATEDIFF(dd,h.issueDate ,getdate()) < 30 THEN  ABS(l.quantity) ELSE 0 END ) ''''@outcome30'''',
											SUM(CASE WHEN DATEDIFF(dd,h.issueDate ,getdate()) < 60 THEN  ABS(l.quantity) ELSE 0 END ) ''''@outcome60'''',
											SUM(CASE WHEN DATEDIFF(dd,h.issueDate ,getdate()) < 90 THEN  ABS(l.quantity) ELSE 0 END ) ''''@outcome90'''''',
											
                @from1 = ''			FROM item.Item i WITH(NOLOCK) 
										JOIN (SELECT itemId, sum(ISNULL(quantity,0)) quantity FROM document.WarehouseStock WITH(NOLOCK) '',
				@from2 = ''					GROUP BY itemId) ws  ON i.id = ws.itemId
										LEFT JOIN document.WarehouseDocumentLine l WITH(NOLOCK) ON i.id = l.itemId  --AND SIGN( l.quantity * l.direction) < 0
										LEFT JOIN document.WarehouseDocumentHeader h WITH(NOLOCK) ON h.id = l.warehouseDocumentHeaderId  AND h.status >= 40
										LEFT JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id --AND documentCategory = 1 ??
										LEFT JOIN item.ItemAttrValue minStock WITH(NOLOCK) ON i.id = minStock.itemId AND minStock.itemFieldId = (select id from dictionary.ItemField where [name] = ''''Attribute_MinimalStock'''')
										'' 
										

      	/* Filtr daty */
      	--Komentuję filtr daty, poniewaz dla tego zestawienia nie ma on sensu i nie działa poprawnie (Agnieszka)
        --IF @dateFrom IS NOT NULL OR @dateTo IS NOT NULL 
        --        SELECT  @filtrDat =  ISNULL('' issueDate <= '''''' + CAST(@dateTo AS VARCHAR(20)) + '''''' '','''')
		

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
							@from2 = @from2 + char(10) +'' LEFT JOIN document.CommercialWarehouseRelation cwr_c ON  l.id = cwr_c.warehouseDocumentLineId  AND cwr_c.isCommercialRelation = 1''
				ELSE	
				IF @field_name = ''documentTypeId''
					SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + ''( h.documentTypeId = '''''' + REPLACE(@field_value,'','','''''' OR h.documentTypeId = '''''') + '''''' ) ''
				ELSE	
				IF @field_name = ''companyId''
					SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + ''( h.companyId = '''''' + REPLACE(@field_value,'','','''''' OR h.companyId = '''''') + '''''' ) ''
				ELSE	
				IF @field_name = ''branchId''
					SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + ''( h.branchId = '''''' + REPLACE(@field_value,'','','''''' OR h.branchId = '''''') + '''''' ) ''
				ELSE
				IF @field_name = ''warehouseId''
					SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + ''( l.warehouseId = '''''' + REPLACE(@field_value,'','','''''' OR l.warehouseId = '''''') + '''''' ) '',
							@from1a = '' WHERE'' + ''( warehouseId = '''''' + REPLACE(@field_value,'','','''''' OR warehouseId = '''''') + '''''' ) ''
				ELSE
				IF @field_name = ''status''
					SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + '' h.status IN ('' + @field_value + '')''
				ELSE
--				IF @field_name = ''paymentMethodId''
--						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''h.id IN ( SELECT DISTINCT pmi.commercialDocumentHeaderId FROM   finance.Payment pmi  WHERE pmi.paymentMethodId = '''''' + REPLACE(@field_value,'','','''''' OR  pmi.paymentMethodId = '''''') + '''''' ) ''
--				ELSE
				IF @field_name = ''itemTypeId''
						SELECT	@where = ISNULL( @where + char(10) +'' AND '','' '' )  + ''( i.itemTypeId = '''''' + REPLACE(@field_value,'','','''''' OR i.itemTypeId = '''''') + '''''' ) ''
				ELSE

				IF @field_name = ''numberSettingId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( Series.numberSettingId = '''''' + REPLACE(@field_value,'','','''''' OR Series.numberSettingId = '''''') + '''''' ) '',
								@from2 = @from2 + char(10) +'' LEFT JOIN document.Series ON h.seriesId = Series.id ''
				ELSE
				IF @field_name = ''zeroStock''
					IF @field_value IN (''1'',''0'')
						BEGIN
							SELECT @where = ISNULL( @where + char(10) +'' AND '','' '' )  + '' ( ws.quantity '' + CASE @field_value WHEN ''1'' THEN ''='' ELSE ''<>'' END +'' 0 ) ''
							--SELECT	@having =  '' HAVING SUM(l.quantity * direction) '' + CASE @field_value WHEN ''1'' THEN ''='' ELSE ''<>'' END +'' 0  ''
						END
				ELSE


				SELECT @where = ISNULL( @where + '' AND '','' '' )  + @field_name + '' = '''''' + @field_value + ''''''''
		
				SELECT @i = @i + 1
			END			

		/*Sklejam zapytanie z filtrem dat*/
      	--Komentuję filtr daty, poniewaz dla tego zestawienia nie ma on sensu i nie działa poprawnie (Agnieszka)
		--IF @filtrDat <> ''''
		--	SELECT  @where = ISNULL(@where + char(10) + '' AND ''  + @filtrDat  , @filtrDat )
                              


		/*filtrowanie po query */
		IF @query <> ''%''
			BEGIN
				/*Przeniesione do funkcji, bałagan robił się przy przeszukiwaniu dictionary wielu obiektów jednocześnie*/
				SELECT @from2 = @from2 + '' '' + dbo.f_getQueryFilter(@query ,@replaceConf_item , '' l.itemId '', ''itemId '',''item.v_itemDictionary'', null, null, NULL ) 
			END    


		/*Warunki dla grup towarów*/
		IF NULLIF(CAST(@itemGroups AS varchar(max)), '''') IS NOT NULL 
			BEGIN
				SELECT  @where = ISNULL( @where + char(10) + '' AND '', '' '' ) + ''
						 (  i.id IN (
									SELECT itm.id 
									FROM item.item itm WITH( NOLOCK )  
										LEFT JOIN item.ItemGroupMembership igm WITH( NOLOCK ) ON itm.id = igm.itemId 
									WHERE igm.itemId IS NULL AND 1 = '' + CAST(ISNULL(@includeUnassignedItems,0) AS VARCHAR(10)) + ''
									UNION 
									SELECT itemId 
									FROM item.ItemGroupMembership  WITH( NOLOCK )
									WHERE itemGroupId IN ('''''' + REPLACE(ISNULL(@itemGroups.value(''.'',''varchar(8000)''),'''') ,'','','''''','''''') + '''''') 
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

		SELECT @exec	= @opakowanie + @select + @from1 + ISNULL(@from1a, '''') + @from2 + ISNULL( char(10) + '' WHERE '' + @where ,'''') + '' GROUP BY i.id, i.name, i.code,  minStock.decimalValue, ws.quantity
		
 ) line  FOR XML PATH(''''line''''), TYPE);
				 SELECT  @return FOR XML PATH(''''root''''),TYPE ''
		PRINT @exec
        EXECUTE ( @exec ) 
    END
' 
END
GO

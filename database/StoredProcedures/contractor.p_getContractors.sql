/*
name=[contractor].[p_getContractors]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
3OdoC/YxpHW5Zy2A345mHg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getContractors]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractors]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N' 

CREATE PROCEDURE [contractor].[p_getContractors] @xmlVar XML
AS 
    BEGIN

		/*Deklaracja zmiennych*/
        DECLARE @max INT,
            @i INT,
            @column NVARCHAR(255),
            @from NVARCHAR(MAX),
			@from_group NVARCHAR(MAX),
            @where NVARCHAR(MAX),
            @groups NVARCHAR(MAX),
            @includeUnassigned CHAR(1),
            @select NVARCHAR(MAX),
            @addressFlag BIT,
            @servicedObjectFlag BIT,
            @query NVARCHAR(MAX),
            @dataColumn NVARCHAR(255),
            @contractorFieldId CHAR(36),
            @exec NVARCHAR(MAX),
            @condition NVARCHAR(2000),
            @page INT,
            @pageSize INT,
			@select_page NVARCHAR(MAX),
            @sort NVARCHAR(1000),
            @sortOrder NVARCHAR(MAX),
			@sortList NVARCHAR(MAX),
			@sortType NCHAR(4),
			@visible BIT,
            @pageOrder NVARCHAR(MAX),
			@filter XML,
			@field_name NVARCHAR(255),
			@field_value NVARCHAR(500),
			@filter_count INT,
			@external_flag INT,
			@replaceConf VARCHAR(8000)


		/*Pobranie danych o kofiguracji*/
        SELECT  @max = @xmlVar.query(''<a>{ count(/*/columns/column)}</a>'').value(''a[1]'', ''int''),
                @query = REPLACE(REPLACE(NULLIF(RTRIM(@xmlVar.query(''*/query'').value(''.'', ''nvarchar(1000)'')),''''), ''*'', ''%''),'''''''','''''''''''') + ''%'',
                @groups = @xmlVar.query(''*/groups'').value(''.'', ''varchar(8000)''),
				@condition = NULLIF(REPLACE(NULLIF(REPLACE(REPLACE(REPLACE(CAST(@xmlVar.query(''*/sqlConditions/condition'')AS VARCHAR(MAX)),''</condition><condition>'','') AND (''),''<condition>'', ''( ''),''</condition>'', '') ''), '''') , ''<condition/>'',''''),''''),
				@pageSize = @xmlVar.query(''*/pageSize'').value(''.'', ''int''),
                @page = ISNULL(@xmlVar.query(''*/page'').value(''.'', ''int'') , 0),
				@filter = @xmlVar.query(''*/filters/*'')
				
		SELECT @condition = ISNULL( '' AND '' + @condition ,'''') +  (
				SELECT dbo.Concat( '' AND '' + x.value(''(.)[1]'',''varchar(max)'') )
						FROM @xmlVar.nodes(''searchParams/condition'') a(x)
						) 

		
		/*Pobranie konfiguracji*/
		SELECT @replaceConf = xmlValue.query(''root/indexing/object[@name="contractor"]/replaceConfiguration'').value(''.'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.Configuration''

		/*Pobranie wartości z atrybutu z root*/
        SELECT  @includeUnassigned = x.value(''@includeUnassigned'', ''char(1)'')
        FROM    @xmlVar.nodes(''*/groups'') AS a ( x )


        SELECT  @select_page =  ''DECLARE @count INT, '' + char(10) +
        						''	    @return XML,	'' + CHAR(10) + 
							    ''	    @x XML	'' + CHAR(10) + 
							    ''DECLARE @tmp TABLE (id int identity(1,1), contractor UNIQUEIDENTIFIER, object UNIQUEIDENTIFIER);'' + char(10) +
								''DECLARE @tmp_contractorGroup TABLE (id uniqueidentifier, color nvarchar(500));
								SELECT @x = xmlValue 
								FROM configuration.Configuration 
								WHERE [key] like ''''contractors.group''''
								
								/* pobieranie koloru z grupy nadrzednej (by gdereck)*/
								select @x = 
								(
									select @x.query(''''
										for $group in (//group)
										return element group
										{
										attribute id {$group/@id},
										attribute color {
										(//group[descendant-or-self::group[. is $group]]/attributes/attribute[@type="color"])[1]
										}
									}
									'''') as result
								)

								INSERT INTO @tmp_contractorGroup
								SELECT x.value(''''@id'''',''''char(36)''''),
									   x.value(''''@color'''',''''nvarchar(500)'''')
								FROM @x.nodes(''''group'''') AS a(x)
								WHERE  x.value(''''@color'''',''''nvarchar(500)'''') IS NOT NULL
							   
								INSERT INTO  @tmp (contractor, object)'' + char(10) +
								''SELECT Contractor.id , null object FROM contractor.Contractor '' + char(10) 
				,
				@select = ''		 '' + char(10) +
								char(9) + ''SELECT @return = ('' + char(10) + 
								char(9) + char(9) + ''SELECT * FROM ( '' + char(10) + 
								char(9) + char(9) + char(9) + ''SELECT DISTINCT Contractor.id AS ''''@id'''', c.id ''''@ordinalNumber'''' '' ,

                @from =  char(10) + char(9) + char(9) + char(9) + ''FROM @tmp c JOIN contractor.Contractor ON c.contractor = Contractor.id '',
				@from_group = '''',
                @where = '' 1 = 1'',
				@sort = '''',
				@sortList = '''',
                @addressFlag = 0,
				@external_flag = 0,
                @i = 1 

/*-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------Kolumny z konfiguracji----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------*/

        WHILE @i <= @max 
            BEGIN		/*Pętla po kolumnach z kofiguracji*/

				/*Dane o kolumni wyświetlanej*/
                SELECT  @column = x.value(''@field[1]'', ''nvarchar(255)''),
                        @dataColumn = x.value(''@column[1]'', ''nvarchar(255)''),
                        @contractorFieldId = x.value(''@contractorFieldId[1]'',''char(36)''),
						@sortOrder = x.value(''@sortOrder'', ''int''),
                        @sortType = x.value(''@sortType'', ''VARCHAR(50)''),
						@visible = ISNULL(x.value(''@visible'', ''BIT''),1) 						
                FROM    @xmlVar.nodes(''/*/columns/column[position()=sql:variable("@i")]'') a ( x )
				

				/*Kolumna z tabeli Contractor*/
                IF @column IN ( ''id'', ''code'', ''isSupplier'', ''isReceiver'',
                                ''isBusinessEntity'', ''isBank'', ''isEmployee'',
                                ''isTemplate'', ''isOwnCompany'', ''fullName'',
                                ''shortName'', ''nip'', ''strippedNip'',
                                ''nipPrefixCountryId'', ''version'' ) 
                    BEGIN
						IF @visible = 1
							BEGIN
								SELECT  @select = @select + CASE @column WHEN ''shortName'' THEN '' , ISNULL(NULLIF(Contractor.shortName,''''''''), Contractor.fullName) '' ELSE '' , Contractor.'' + @column END + '' ''''@''+@column+'''''''' 
							END
                        SELECT  @sort = @sort
                                + CASE WHEN @sortOrder <> ''''
                                       THEN CASE WHEN LEN(@sort) > 2 THEN '','' ELSE '''' END + CASE @column WHEN ''shortName'' THEN ''  ISNULL(NULLIF(Contractor.shortName,''''''''), Contractor.fullName) '' ELSE ''Contractor.'' + ISNULL(NULLIF(@column, ''''),@DataColumn) END + '' '' + ISNULL(@sortType, '''') 
                                       ELSE ''''
                                  END,
									@sortList = @sortList + CASE WHEN @sortOrder <> ''''
											   THEN ISNULL(NULLIF(@column, ''''),@DataColumn) + '' '' + ISNULL(@sortType, '''') 
											   ELSE '''' END
                    END

				/*Kolumna z accounting oznaczająca status wyeksportowania*/
                IF @column IN ( ''objectExported'' ) 
                    BEGIN
						
						SELECT  @from = @from + '' LEFT JOIN accounting.ExternalMapping em WITH(NOLOCK) ON em.id = Contractor.id '',
								@from_group = @from_group + '' LEFT JOIN accounting.ExternalMapping em WITH(NOLOCK) ON em.id = Contractor.id '',
								@external_flag = 1,
								@select = @select + '' , CASE 
															WHEN em.id IS NOT NULL AND em.objectVersion = Contractor.version  THEN ''''exportedAndUnchanged'''' 
															WHEN em.id IS NOT NULL AND em.objectVersion <> Contractor.version  THEN ''''exportedAndChanged'''' 
															ELSE ''''unexported'''' END  AS ''''@objectExported'''' ''

                    END
                        
				/*Kolumna z serwisu, włączane przy uruchomionym module serwis*/
                ELSE 
                    IF @column IN ( ''servicedObject'' ) 
                        BEGIN
							
							SELECT @select_page = REPLACE(@select_page, '', null ''''@object'''' '', '', so.id ''''@object'''' '')
							
							SELECT  --@from = @from + char(10) + char(9) + char(9) + char(9) +'' LEFT JOIN service.ServicedObject so WITH(NOLOCK) ON so.ownerContractorId = Contractor.id '',
									@from_group = @from_group + char(10) + char(9) + char(9) + char(9) +'' LEFT JOIN ( SELECT sob.id, sob.ownerContractorId FROM service.ServicedObject sob WITH(NOLOCK) WHERE sob.identifier LIKE ''''%'' + @query + ''%'''' ) so ON so.ownerContractorId = Contractor.id '',
									@servicedObjectFlag = 1

							
							IF @visible = 1
								SELECT  @select = @select + '' , c.object  AS ''''@servicedObjectId'''' ''

                        END
				
				/*color*/
                IF @column = ''color''  
                    BEGIN
						SELECT  @select = @select + '' ,  (SELECT top 1 color FROM @tmp_contractorGroup tg JOIN contractor.ContractorGroupMembership im ON tg.id = im.contractorGroupId WHERE NULLIF(color,'''''''') IS NOT NULL AND im.contractorId = Contractor.id ) AS ''''@'' + @column + ''''''''
					END	
				 IF @column = ''contractorRemark''  
                    BEGIN
						
						SELECT  @from = @from + char(10) + char(9) + char(9) + char(9) +'' LEFT JOIN (  
																										SELECT dbo.Concatenate(rem.xmlValue.value(''''(note/data)[1]'''',''''nvarchar(4000)''''))  remark ,rem.contractorId
																										FROM contractor.ContractorAttrValue rem WITH(NOLOCK) 
																										WHERE  rem.contractorFieldId = '''''' + (SELECT CAST(id as varchar(50)) FROM dictionary.ContractorField WHERE name = ''Attribute_Remark'' ) + ''''''
																										GROUP BY rem.contractorId
																										) Remark
																										ON Remark.contractorId = Contractor.id ''
						SELECT  @select = @select + '' , Remark.remark ''''@contractorRemark'''' ''
					END
				/*Kolumna contractorBalance*/
                ELSE 
                    IF @column IN ( ''contractorBalance'' ) 
                        BEGIN
							
							SELECT  @from = @from + char(10) + char(9) + char(9) + char(9) +'' LEFT JOIN finance.v_contractorBalance cb WITH(NOLOCK) ON cb.contractorId = Contractor.id ''--,
							
							IF @visible = 1
								SELECT  @select = @select + '' , cb.balance ''''@contractorBalance'''' ''

                        END
				  /*Kolumna adresu kontrahenta*/
				 ELSE 
                    IF @column IN ( ''address'', ''city'', ''postCode'',''postOffice'' ) 
                        BEGIN
							IF @contractorFieldId IS NULL
								SELECT @contractorFieldId = id 
								FROM dictionary.ContractorField
								WHERE name = ''Address_Default''							

                            IF @addressFlag = 0 
                                SELECT  @from = @from +char(10) + char(9) + char(9) + char(9) + '' LEFT JOIN contractor.ContractorAddress WITH(NOLOCK) ON ContractorAddress.contractorId = Contractor.id AND ContractorAddress.contractorFieldId = '''''' + @contractorFieldId + '''''' '',
										@from_group = @from_group +char(10) + char(9) + char(9) + char(9) + '' LEFT JOIN contractor.ContractorAddress WITH(NOLOCK) ON ContractorAddress.contractorId = Contractor.id AND ContractorAddress.contractorFieldId = '''''' + @contractorFieldId + '''''' '',
									    @addressFlag = 1
								
							IF @visible = 1
								SELECT  @select = @select + '' , ContractorAddress.'' + @column + '' ''''@''+@column+''''''''

							SELECT  @sort = @sort
										+ CASE WHEN @sortOrder <> ''''
											   THEN CASE WHEN LEN(@sort) > 2 THEN '','' ELSE '''' END + ''ContractorAddress.''
													+ ISNULL(NULLIF(@column, ''''),@DataColumn) + '' '' + ISNULL(@sortType, '''') 
											   ELSE ''''
										  END,
									@sortList = @sortList + CASE WHEN @sortOrder <> ''''
											   THEN ISNULL(NULLIF(@column, ''''),@DataColumn) + '' '' + ISNULL(@sortType, '''') 
											   ELSE ''''
										  END
                        END
				ELSE 
                    IF @column IN ( ''login'' ) 
                        BEGIN
							
                            SELECT  @from = @from + char(10) + char(9) + char(9) + char(9) +'' LEFT JOIN contractor.ApplicationUser WITH(NOLOCK) ON ApplicationUser.contractorId = Contractor.id '',
									@from_group = @from_group + char(10) + char(9) + char(9) + char(9) +'' LEFT JOIN  contractor.ApplicationUser WITH(NOLOCK) ON ApplicationUser.contractorId = Contractor.id ''
								
							IF @visible = 1
								SELECT  @select = @select + '' , ApplicationUser.'' + @column+ '' ''''@''+@column+''''''''

							SELECT  @sort = @sort
										+ CASE WHEN @sortOrder <> ''''
											   THEN CASE WHEN LEN(@sort) > 2 THEN '','' ELSE '''' END + ''ApplicationUser.''
													+ ISNULL(NULLIF(@column, ''''),@DataColumn) + '' '' + ISNULL(@sortType, '''') 
											   ELSE ''''
										  END,
									@sortList = @sortList + CASE WHEN @sortOrder <> ''''
											   THEN ISNULL(NULLIF(@column, ''''),@DataColumn) + '' '' + ISNULL(@sortType, '''') 
											   ELSE ''''
										  END
                        END
				ELSE 
                    IF @column IN ( ''objects'', ''offer'', ''offerQuestion'' ) 
                        BEGIN
							

							IF @visible = 1
								SELECT  @select = @select + '' , rand() * 10 AS ''''@''+ @column+''''''''


                        END   
				ELSE 
                    IF @column IN ( ''agent'' ) 
                        BEGIN
							
							IF @visible = 1
								SELECT  @select = @select + '' , ''''agent'''' AS ''''@''+ @column+''''''''

                        END                                              
					/*Kolumna z tabeli ContractorAttrValue*/
                    ELSE 
						IF @dataColumn IN (''textValue'')
                        BEGIN
							IF @visible = 1
								SELECT  @select = @select + '' , ca'' + CAST(@i AS VARCHAR(10)) + ''.attrValue as ''''@'' + @column + ''''''''

	                            SELECT  @from = @from + char(10) + char(9) + char(9) + char(9) +'' LEFT JOIN (
																												SELECT  
																												CAST( (	SELECT STUFF(attr.textValue + char(10),1,0,'''''''') 
																													FROM  contractor.ContractorAttrValue attr WITH(NOLOCK)  
																													WHERE attr.contractorFieldId = '''''' +  CAST(ISNULL(@contractorFieldId, '''') AS CHAR(36)) + ''''''
																														AND attr.contractorId = cx.id
																													FOR XML PATH(''''''''), TYPE ) AS nvarchar(max)) attrValue , cx.id
																												FROM contractor.Contractor cx WITH(NOLOCK) ) ca'' + CAST(@i AS VARCHAR(10)) + '' ON Contractor.id  = ca'' + CAST(@i AS VARCHAR(10)) + ''.id '' ,
	                            
										@from_group = @from_group + char(10) + char(9) + char(9) + char(9) +'' LEFT JOIN (
																												SELECT  
																												CAST( (	SELECT STUFF(attr.textValue + char(10),1,0,'''''''') 
																													FROM  contractor.ContractorAttrValue attr WITH(NOLOCK)  
																													WHERE attr.contractorFieldId = '''''' +  CAST(ISNULL(@contractorFieldId, '''') AS CHAR(36)) + ''''''
																														AND attr.contractorId = cx.id
																													FOR XML PATH(''''''''), TYPE ) AS nvarchar(max)) attrValue , cx.id
																												FROM contractor.Contractor cx WITH(NOLOCK) ) ca'' + CAST(@i AS VARCHAR(10)) + '' ON Contractor.id  = ca'' + CAST(@i AS VARCHAR(10)) + ''.id ''

							SELECT  @sort = @sort
										+ CASE WHEN @sortOrder <> ''''
											   THEN CASE WHEN LEN(@sort) > 2 THEN '','' ELSE '''' END + ''ca'' + CAST(@i AS VARCHAR(10)) + ''.attrValue '' + ISNULL(@sortType, '''') 
											   ELSE ''''
										  END ,
									@sortList = @sortList  + CASE WHEN @sortOrder <> ''''
											   THEN ''id '' 
											   ELSE '''' END
                        END
                SELECT  @i = @i + 1

            END

/*-----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- KONIEC WYBIERANIA KOLUMN-------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- PARSOWANIE QUERY---------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------*/

print @replaceConf
        IF NULLIF(RTRIM(@query), '''') IS NOT NULL 
			IF @servicedObjectFlag = 1
				SELECT @from_group = @from_group + '' '' + dbo.f_getQueryFilter(@query ,@replaceConf , '' Contractor.id '',''contractorId'','' contractor.v_contractorDictionary '', ''contractor.v_contractorServicedObjectsIdentifier'', ''[contractor].[v_contractorNip]'', NULL ) 
            ELSE
				SELECT @from_group = @from_group + '' '' + dbo.f_getQueryFilter(@query ,@replaceConf , '' Contractor.id '',''contractorId'','' contractor.v_contractorDictionary '', null, null,null ) 
         
/*-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------KONIEC PARSOWANIA QUERY---------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------*/

		/*Warunki dla grup kontrahentów*/
        IF NULLIF(@includeUnassigned, '''') IS NOT NULL 
            BEGIN
		
                IF @where <> '''' 
                    SELECT  @where = @where + '' AND ( CGM.id IS NULL ''
                ELSE 
                    SELECT  @where = @where + '' ( CGM.id IS NULL ''

				SELECT  @from_group = @from_group + char(10) + char(9) + char(9) + char(9) +'' LEFT JOIN contractor.ContractorGroupMembership CGM WITH(NOLOCK) on Contractor.id = CGM.contractorId ''
            END

        IF NULLIF(@groups, '''') IS NOT NULL 
            BEGIN
                IF @where <> '''' 
                    SELECT  @where = @where
                            + CASE WHEN NULLIF(@includeUnassigned, '''') IS NOT NULL
                                   THEN '' OR ''
                                   ELSE '' AND ''
                              END
                            + '' Contractor.id IN (SELECT CGM2.contractorId FROM contractor.ContractorGroupMembership CGM2 WITH(NOLOCK) WHERE CGM2.contractorGroupId in ('' + @groups + ''))''
                ELSE 
                    SELECT  @where = @where + '' Contractor.id IN (SELECT CGM2.contractorId FROM contractor.ContractorGroupMembership CGM2 WITH(NOLOCK) WHERE CGM2.contractorGroupId in ('' + @groups + ''))''
            END

		/*Uzupełnienie nawiasu po @includeUnassigned*/
        IF NULLIF(@includeUnassigned, '''') IS NOT NULL 
            SELECT  @where = @where + '')''



		/*Filtry - filters*/	
		DECLARE @tmp_filters TABLE (id int identity(1,1), field nvarchar(255), [value] nvarchar(500))

		DECLARE @flag_filter VARCHAR(500)

		INSERT INTO @tmp_filters (field, [value] )
		SELECT  x.value(''@field'',''nvarchar(50)''),
				x.value(''.'',''nvarchar(50)'')
		FROM @filter.nodes(''column'') AS a(x)

		SELECT @filter_count = @@ROWCOUNT , @i = 1

		WHILE @i <= @filter_count
			BEGIN
				SELECT @field_name = field, @field_value = [value]
				FROM @tmp_filters WHERE id = @i
				
				IF @field_name = ''nip''
					SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' Contractor.nip like '''''' + @field_value + ''%'''' ''
				ELSE
				IF @field_name = ''name''
					SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' Contractor.fullName like '''''' + @field_value + ''%'''' ''
				ELSE
				IF @field_name IN (''isSupplier'',''isReceiver'',''isBusinessEntity'',''isBank'',''isEmployee'', ''isOwnCompany'',''isSalesman'')
					BEGIN
						IF @field_name = ''isSalesman''
							BEGIN
								SELECT	@from_group	= @from_group + '' LEFT JOIN contractor.ContractorAttrValue cav WITH(NOLOCK) ON Contractor.id = cav.contractorId AND cav.contractorFieldId = (SELECT id FROM dictionary.ContractorField WHERE [name] = ''''Attribute_IsSalesman'''' ) AND cav.decimalValue = 1.0 '',
									    @flag_filter = ISNULL(@flag_filter + '' OR '' , '' '') + '' cav.id is not null ''
							END		
						ELSE
							BEGIN
								SELECT  @flag_filter = ISNULL(@flag_filter + '' OR '' , '' '') + @field_name + '' = '' +  @field_value
							END
					END
				ELSE
				
				IF @field_name = ''city''
					SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' ca.city like '''''' + @field_value + ''%'''' '',
							@from_group	= @from_group + ''LEFT JOIN contractor.ContractorAddress ca WITH(NOLOCK) ON ca.contractorId = Contractor.id ''	
				ELSE
				IF @field_name = ''objectExported''
					SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' (
																CASE 
																WHEN em.id IS NOT NULL AND em.objectVersion = Contractor.version  THEN ''''exportedAndUnchanged'''' 
																WHEN em.id IS NOT NULL AND em.objectVersion <> Contractor.version  THEN ''''exportedAndChanged'''' 
																ELSE ''''unexported'''' END   = '''''' + @field_value  + '''''' ) '',
							@from_group	= @from_group + CASE WHEN @external_flag = 0 THEN '' LEFT JOIN accounting.ExternalMapping em WITH(NOLOCK) ON em.id =  Contractor.id ''  ELSE '''' END
				ELSE
				IF @field_name = ''contractorsRelated''
					SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' Contractor.Id '' + CASE WHEN @field_value = ''related''  THEN  '' IN '' ELSE '' NOT IN '' END + ''
																	( 
																	SELECT contractorId 
																	FROM document.CommercialDocumentHeader h1 WITH(NOLOCK)
																		JOIN dictionary.DocumentType dt1 WITH(NOLOCK) ON h1.documentTypeId = dt1.id
																	WHERE dt1.documentCategory = 0	AND contractorId IS NOT NULL
																	UNION
																	SELECT contractorId 
																	FROM document.WarehouseDocumentHeader h1 WITH(NOLOCK)
																	WHERE contractorId IS NOT NULL
																	UNION
																	SELECT contractorId 
																	FROM finance.Payment  WITH(NOLOCK)
																	WHERE contractorId IS NOT NULL
																	)''
				ELSE
				IF @field_name = ''contractorBalance''
					SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' ISNULL(cb.balance,0) <> 0 '',
							@from_group	= @from_group + '' LEFT JOIN finance.v_contractorBalance cb WITH(NOLOCK) ON Contractor.id = cb.contractorId ''
				ELSE
				IF @field_name = ''address''
					SELECT	@where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + '' ca.address like '''''' + @field_value + ''%'''' '',
							@from_group	= @from_group + ''LEFT JOIN contractor.ContractorAddress ca WITH(NOLOCK) ON ca.contractorId = Contractor.id ''	
				ELSE
				SELECT @where = ISNULL( NULLIF(@where,'''') + '' AND '','' '' )  + @field_name + '' = '''''' + @field_value + ''''''''
		
				SELECT @i = @i + 1
			END		

		IF @flag_filter IS NOT NULL
			SELECT @where = ISNULL(NULLIF(@where,'''') + '' AND '' ,'' '' ) +  ISNULL( ''( '' + @flag_filter + '' ) '', '' '' ) 

		/*Obsługa condition*/
		SELECT @where = @where + ISNULL( @condition,'''')

		/*Zapytanie do page*/           
		SELECT @select_page = @select_page + '' '' + @from_group + '' '' +
			CASE WHEN ISNULL(RTRIM(@where),'''') <> '''' THEN char(10) + char(9) + char(9) + char(9) +'' WHERE '' ELSE '''' END + @where + ISNULL('' ORDER BY '' + NULLIF(@sort,''''), '''') + '' ; SELECT @count = @@ROWCOUNT''


        SELECT  @exec = @select_page + ''; '' + @select + '' '' + REPLACE( @from ,char(10) + char(9) + char(9) + char(9) +'' WHERE Contractor.id IN ('' , '''')  + CASE WHEN @page <> 0 THEN  char(10) + char(9) + char(9) + char(9) +'' WHERE c.id > '' + CAST((@pageSize * @page) - @pageSize AS VARCHAR(50)) +  '' AND c.id <= '' + CAST((@pageSize * @page)  AS VARCHAR(50)) ELSE '''' END + '' )  contractor  ORDER BY ''''@ordinalNumber'''' FOR XML PATH(''''contractor'''') ,TYPE); SELECT '' + CAST(@page AS VARCHAR(50))
                + '' ''''@page'''' ,'' + CAST(@pageSize AS VARCHAR(50))
                + '' ''''@pageSize'''',@count ''''@rowCount'''', @return FOR XML PATH(''''contractors'''')''

  print @exec
     EXECUTE ( @exec )
 
    END
' 
END
GO

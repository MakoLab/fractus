/*
name=[item].[p_createPriceRule]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
xcHtjzeQf+P/D5EIxaj9Uw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_createPriceRule]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_createPriceRule]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_createPriceRule]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_createPriceRule] @xmlVar XML
AS

BEGIN

	DECLARE @id char(36),
			@name nvarchar(500),
			@order int,
			@procedureName nvarchar(500),
			@conditionName nvarchar(500),
			@conditionLabel nvarchar(500),
			@conditionEnabled int,
			@conditionXml XML,
			@i int,
			@count int,
			@sql nvarchar(max),
			@value_1 nvarchar(max),
			@value_2 nvarchar(max),
			@action varchar(50),
			@communication varchar(50)
			

	DECLARE @tmp_conditions TABLE ( i int identity(1,1),  name nvarchar(500), label nvarchar(500), enabled int, conditionXml XML)
	DECLARE @tmp_actions TABLE ( i int identity(1,1),  name nvarchar(500), label nvarchar(500), enabled int, conditionXml XML)			
			

	SELECT	@id = NULLIF(x.query(''id'').value(''.'',''char(36)''),'''') ,
			@name = x.query(''name'').value(''.'',''nvarchar(500)''),
			@order =  x.query(''order'').value(''.'',''int''),
			@communication =  x.value(''(@isCommunication)[1]'',''varchar(50)'')
	FROM @xmlVar.nodes(''root'') as a(x)


	SET @xmlVar.modify('' delete (/root/@isCommunication)[1] '')
	
	IF @id IS NOT NULL
		BEGIN
			IF EXISTS( SELECT * FROM sys.procedures WHERE name = ''p_getItemPrice_'' + REPLACE(@id ,''-'','''')  )
				BEGIN
					SELECT @action = ''update'', @procedureName = '' DROP PROCEDURE '' + [procedure] + ''; '' FROM item.PriceRule WHERE id = @id

					EXECUTE( @procedureName )
				END
			IF EXISTS( SELECT * FROM item.PriceRule WHERE id = @id)
				DELETE FROM item.PriceRule WHERE id = @id
		END
	ELSE
		SELECT @id = newid()

	-- gdereck - wstawienie id reguly do paczki XML reguly
	IF @xmlVar.exist(''/root/id'') = 0 SET @xmlVar.modify(''insert <id>{sql:variable("@id")}</id> as first into (/root)[1]'')
		
	/*Komunikacja dla tej paczki*/
	IF ISNULL(@communication,''false'') <> ''true''
		BEGIN
			INSERT INTO communication.OutgoingXmlQueue ( id, localTransactionId, deferredTransactionId, databaseId, [type], [xml],sendDate,creationDate)
			SELECT newid(), newid(),newid(),(SELECT textValue FROM configuration.Configuration WHERE [key] = ''communication.databaseId''), ''PriceRule'',@xmlVar, null, getdate()
		END


	
	
	SELECT  @procedureName = ''item.p_getItemPrice_'' + REPLACE(@id ,''-'','''') ,
			@sql = '' CREATE PROCEDURE item.p_getItemPrice_'' + REPLACE(@id ,''-'','''') + '' @xmlVar XML, @initialNetPrice decimal(18,2) OUTPUT, @netPriceCatalogue decimal(18,2) OUTPUT, @discoutRateValue decimal(18,2) OUTPUT
						AS
						BEGIN
						/*
							Procedura generowana automatycznie, jest implementacją reguł określających kryteria wyznaczania ceny dla towaru
						*/
						
						DECLARE 
							@conditionValue int,
							@itemId uniqueidentifier, 
							@contractorId uniqueidentifier,
							@documentTypeId uniqueidentifier
	
						SELECT @contractorId  = ISNULL( NULLIF(x.value(''''(@contractorId)[1]'''',''''char(36)''''),''''''''), x.value(''''(contractorId)[1]'''',''''char(36)'''')),
							   @itemId = NULLIF(x.value(''''(item/@id)[1]'''',''''char(36)''''),''''''''),
							   @documentTypeId = NULLIF(x.value(''''(documentTypeId)[1]'''',''''char(36)''''),'''''''')
						FROM @xmlVar.nodes(''''root'''') as a (x)
						
						SELECT @conditionValue = 1
						''

	/*Tena fragment implementuje warunki jakie musi spełnić obiekt by jego cena była przetworzona przez zestaw zdefiniowanych akcji*/
	INSERT INTO @tmp_conditions ( name, label, [enabled], conditionXml)
	SELECT 
			x.value(''@name[1]'',''nvarchar(500)''),
			x.value(''@label[1]'',''nvarchar(500)''),
			x.value(''@enabled[1]'',''int''),
			x.query(''*'')
	FROM @xmlVar.nodes(''root/conditions/condition'') as a(x)
	SELECT @count = @@ROWCOUNT, @i = 1
	
	
	
	SELECT @sql = @sql + '' 
							/*Warunki dla cennika*/
							''
	
	WHILE @i <= @count
		BEGIN
			SELECT @conditionName = name, @conditionLabel = label, @conditionEnabled = enabled, @conditionXml = conditionXml
			FROM @tmp_conditions WHERE i = @i

			IF @conditionName = ''all''
				BEGIN
				SELECT  @value_1 = @conditionXml.query(''//value/dateFrom'').value(''.'',''nvarchar(max)''),
						@value_2 = @conditionXml.query(''//value/dateTo'').value(''.'',''nvarchar(max)'')
				SELECT @sql = @sql + '' 
							
							SELECT @conditionValue = 1
						''
				END
			ELSE IF @conditionName = ''contractors''
				BEGIN
				SELECT @value_1 = @conditionXml.query(''//value'').value(''.'',''nvarchar(max)'')
				SELECT @sql = @sql + '' 
							IF  NOT(@contractorId IS NOT NULL AND @contractorId IN ('''''' + REPLACE(@value_1,'','','''''','''''') + ''''''))
								RETURN 0;	--SELECT @conditionValue = 0
					''
				END
			ELSE IF @conditionName = ''dateRange''
				BEGIN
				SELECT  @value_1 = @conditionXml.query(''//value/dateFrom'').value(''.'',''nvarchar(max)''),
						@value_2 = @conditionXml.query(''//value/dateTo'').value(''.'',''nvarchar(max)'')
				SELECT @sql = @sql + '' 
							IF NOT( (SELECT getdate()) >= '''''' + @value_1 + '''''' AND (SELECT getdate()) <= '''''' + @value_2 + '''''' ) 
								RETURN 0; --SELECT @conditionValue = 0
						''
				END
			ELSE IF @conditionName = ''contractorDealing''
				BEGIN
				SELECT  @value_1 = @conditionXml.query(''//value/salesValue'').value(''.'',''nvarchar(max)''),
						@value_2 = @conditionXml.query(''//value/range'').value(''.'',''nvarchar(max)'')
				SELECT @sql = @sql + '' 
							IF NOT EXISTS(	SELECT contractorId 
										FROM document.CommercialDocumentHeader 
										WHERE contractorId = @contractorId 
											AND status >= 40 
											AND issueDate >= '''''' + CAST( DATEADD( dd, -CAST(@value_2 AS int) , getdate() ) AS varchar(100))+ '''''' 
										GROUP BY contractorId
										HAVING SUM(netValue) >= '' +ISNULL( NULLIF(@value_1 ,''''),0) + '' )
								RETURN 0; --SELECT @conditionValue = 0
					''
				END
			ELSE IF @conditionName = ''branch''
				BEGIN
					SELECT @value_1 = @conditionXml.query(''//value'').value(''.'',''nvarchar(max)'')
					SELECT @sql = @sql + '' 
							IF NOT EXISTS ( 
										SELECT b.id
										FROM configuration.Configuration c
											JOIN dictionary.Branch b ON CAST(c.textValue AS uniqueidentifier) = b.databaseId 
										WHERE c.[key] like ''''communication.DatabaseId'''' AND b.id IN ('''''' + REPLACE(@value_1,'','','''''','''''') + '''''')
										 )

							RETURN 0; --SELECT @conditionValue = 0
					''		
				END 
			ELSE IF @conditionName = ''documentCategory''
				BEGIN
					SELECT @value_1 = @conditionXml.query(''//value'').value(''.'',''nvarchar(max)'')
					SELECT @sql = @sql + '' 
							IF NOT EXISTS ( 
										SELECT dt.id
										FROM dictionary.DocumentType dt
										WHERE dt.id = @documentTypeId  AND dt.documentCategory IN ('' + @value_1 + '')
										 )
							RETURN 0; --SELECT @conditionValue = 1
					''		
				END
			ELSE IF @conditionName = ''documentType''
				BEGIN
					SELECT @value_1 = @conditionXml.query(''//value'').value(''.'',''nvarchar(max)'')
					SELECT @sql = @sql + '' 
							IF NOT EXISTS ( 
										SELECT dt.id
										FROM dictionary.DocumentType dt
										WHERE dt.id = @documentTypeId  AND dt.symbol IN ('''''' + REPLACE(@value_1,'','','''''','''''') + '''''')
										 )
							RETURN 0; --SELECT @conditionValue = 1
					''		
				END
			ELSE IF @conditionName = ''itemGroups''
				BEGIN
					SELECT @value_1 = @conditionXml.query(''//value'').value(''.'',''nvarchar(max)'')
					SELECT @sql = @sql + '' 
							IF NOT(@itemId IS NOT NULL AND EXISTS ( SELECT id FROM item.ItemGroupMembership WHERE itemId = @itemId  AND itemGroupId IN ('''''' + REPLACE(@value_1,'','','''''','''''') + '''''')))
							RETURN 0; --SELECT @conditionValue = 0
					''		
				END
			ELSE IF @conditionName = ''contractorGroups''
				BEGIN
				SELECT @value_1 = @conditionXml.query(''//value'').value(''.'',''nvarchar(max)'')
				SELECT @sql = @sql + '' 
							IF  NOT(@contractorId IS NOT NULL AND EXISTS ( SELECT id FROM contractor.ContractorGroupMembership WHERE contractorId = @contractorId  AND contractorGroupId IN ('''''' + REPLACE(@value_1,'','','''''','''''') + '''''')))
							RETURN 0; --SELECT @conditionValue = 0
					''
				END
				 	
			
			SELECT @i = @i + 1
		END
	

	
	
/*Tena fragment implementuje akcje jakie zostaną podjęte w celu wyznaczenia ceny*/
	INSERT INTO @tmp_actions ( name, label, [enabled], conditionXml)
	SELECT 
			x.value(''@name[1]'',''nvarchar(500)''),
			x.value(''@label[1]'',''nvarchar(500)''),
			x.value(''@enabled[1]'',''int''),
			x.query(''*'')
	FROM @xmlVar.nodes(''root/actions/action'') as a(x)
	SELECT @count = @@ROWCOUNT, @i = 1
	
	
	
	SELECT @sql = @sql + '' 
							/*Akcje dla cennika*/
	IF @conditionValue = 1
		BEGIN
		
		''
	
	WHILE @i <= @count
		BEGIN
			SELECT @conditionName = name, @conditionLabel = label, @conditionEnabled = enabled, @conditionXml = conditionXml
			FROM @tmp_actions WHERE i = @i
			
			IF @conditionName = ''initialNetPriceCatalogue''
				BEGIN
					SELECT @value_1 = @conditionXml.query(''//value'').value(''.'',''nvarchar(max)'')
					SELECT @sql = @sql + '' 
							
							SELECT @initialNetPrice = defaultPrice FROM item.Item WITH(NOLOCK) WHERE id = @itemId  
							
							''		
				END
			ELSE IF @conditionName = ''netPriceCatalogue''
				BEGIN
					SELECT @value_1 = @conditionXml.query(''//value'').value(''.'',''nvarchar(max)'')
					SELECT @sql = @sql + '' 
							SELECT @netPriceCatalogue = defaultPrice FROM item.Item WITH(NOLOCK) WHERE id = @itemId 
							
						 
							''		
				END
			ELSE IF @conditionName = ''discoutRateValue''
				BEGIN
				SELECT @value_1 = @conditionXml.query(''//value'').value(''.'',''nvarchar(max)'')
				SELECT @sql = @sql + '' 
							SELECT @discoutRateValue = ''''''+ @value_1 + ''''''
							
						''
				END
			ELSE IF @conditionName = ''initialNetPricePriceList''
				BEGIN
				SELECT @value_1 = @conditionXml.query(''//value'').value(''.'',''nvarchar(max)'')
				SELECT @sql = @sql + ''
							SELECT @initialNetPrice = price FROM item.PriceListHeader ph WITH(NOLOCK) JOIN item.PriceListLine l WITH(NOLOCK)  ON  l.priceListHeaderId = ph.id WHERE l.itemId = @itemId  AND ph.id ='''''' + @value_1 + ''''''
						''
				END	
			ELSE IF @conditionName = ''netPricePriceList''
				BEGIN
				SELECT @value_1 = @conditionXml.query(''//value'').value(''.'',''nvarchar(max)'')
				SELECT @sql = @sql + '' 
							SELECT @netPriceCatalogue = price FROM item.PriceListHeader ph WITH(NOLOCK) JOIN item.PriceListLine l WITH(NOLOCK)  ON  l.priceListHeaderId = ph.id WHERE l.itemId = @itemId  AND ph.id ='''''' + @value_1 + ''''''
						''
				END	
			ELSE IF @conditionName = ''initialAttributeNetPricePriceList''
				BEGIN
				SELECT @value_1 = @conditionXml.query(''//value'').value(''.'',''nvarchar(max)'')
				SELECT @sql = @sql + ''
							SELECT @initialNetPrice = decimalValue FROM item.ItemAttrValue ph WITH(NOLOCK) WHERE ph.itemId = @itemId  AND ph.itemFieldId ='''''' + @value_1 + ''''''
						''
				END
			ELSE IF @conditionName = ''netAttributePricePriceList''
				BEGIN
				SELECT @value_1 = @conditionXml.query(''//value'').value(''.'',''nvarchar(max)'')
				SELECT @sql = @sql + '' 
							SELECT @netPriceCatalogue = decimalValue FROM item.ItemAttrValue ph WITH(NOLOCK)  WHERE ph.itemId = @itemId  AND ph.itemFieldId ='''''' + @value_1 + ''''''
						''
				END

			SELECT @i = @i + 1
		END
		SELECT @sql = @sql + ''
			
		END
	END
							''
	print @sql						
	EXEC ( @sql )
	 --select @sql s  FOR XML PATH('''') , TYPE
	IF @@error = 0							
		BEGIN			
		
		
			IF @action = ''update''
				DELETE FROM item.PriceRule WHERE id = @id
			
			-- gdereck - usuniecie atrybutu dodawanego przez kernel przed zapisem do bazy
			SET @xmlVar.modify(''delete /*/@applicationUserId'')

			INSERT INTO item.PriceRule ([id],[name],[definition],[procedure],[status],[version], [order])
			SELECT @id,@name,@xmlVar,@procedureName ,1, newid(), @order
			
			SELECT @id AS id FOR XML PATH(''root''), TYPE
		END
	ELSE
		SELECT @@error
END
' 
END
GO

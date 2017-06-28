/*
name=[item].[p_getItemsDetailsForDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
FsRN3+SGUje259yOO5Jc8Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsDetailsForDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemsDetailsForDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsDetailsForDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getItemsDetailsForDocument] 
@xmlVar XML
AS
BEGIN

	DECLARE 
		@lastPurchasePrice INT,
		@contractorId UNIQUEIDENTIFIER,
		@price DECIMAL(18, 2),
		@sql nvarchar(max),
		@param nvarchar(max),
		@return XML,
		@count int,
		@i int,
		@initialNetPrice decimal(18,2),
		@netPriceCatalogue decimal(18,2),
		@discoutRateValue decimal(18,2),
		@priceName varchar(4000),
		@documentTypeId UNIQUEIDENTIFIER,
		@defaultVatRate UNIQUEIDENTIFIER
	
	DECLARE @tmp TABLE ( id uniqueidentifier)
	
	DECLARE  @priceRule TABLE (	i int identity(1,1),
								id char(36), 
								name nvarchar(500), 
								[procedure] nvarchar(500)
							) 
		
	DECLARE  @priceResult TABLE (	i int identity(1,1),
									initialNetPrice decimal(18,2),
									netPriceCatalogue decimal(18,2),
									discoutRateValue decimal(18,2),
									name varchar(50)
							)
	


	/*Pobranie parametrów wejściowych*/
	SELECT  @contractorId = NULLIF(x.value(''@contractorId[1]'',''char(36)''),''''),
			@lastPurchasePrice = x.value(''@lastPurchasePrice[1]'',''int'')
	FROM @xmlVar.nodes(''root'') as a (x)

	/*Prowizorka - pobieranie danych na podstawie kodu paskowego a nie id*/	
	IF @xmlVar.exist(''root/item/@barcode'') = 1
	BEGIN
	
	DECLARE @itemId uniqueidentifier

	declare @barcode nvarchar(200)
	declare cur cursor for select  x.value(''(@barcode)'',''nvarchar(200)'') FROM @xmlVar.nodes(''//root/item'') AS a (x) 
											where x.value(''(@id)'',''nvarchar(200)'') is null
	open cur 
		fetch next from cur into @barcode
		while @@fetch_status=0
	begin

		SELECT @itemId = I.id
		FROM item.Item I
		JOIN item.itemAttrValue AV ON AV.itemId = I.id
		JOIN dictionary.ItemField F ON F.id = AV.itemFieldId
		WHERE F.[name] = ''Attribute_Barcode'' AND AV.textValue =@barcode --@xmlVar.value(''(root/item/@barcode)[1]'', ''varchar(100)'')

	IF @itemId IS NOT NULL set @xmlVar.modify(''insert attribute id { sql:variable("@itemId") }  into 
											(/root/item[@barcode=sql:variable("@barcode")])[1] '')
	
				fetch next from cur into @barcode
							
	end

	close cur 
	deallocate cur	
		
	END

	/*Lista towarów dla których pobieram dane*/
	INSERT INTO @tmp (id)
	SELECT  x.value(''@id'',''char(36)'')
	FROM @xmlVar.nodes(''root/item'') as a (x)

	SELECT  @documentTypeId = @xmlVar.value(''(root/@documentTypeId)[1]'',''char(36)'')
 
	if @documentTypeId IS NOT NULL
		SELECT @defaultVatRate = xmlOptions.value(''(root/commercialDocument/defaultVatRateId)[1]'',''varchar(36)'')
		FROM dictionary.DocumentType
		WHERE id = @documentTypeId
 	 
	/*Pobranie danych z ostatnią ceną zakupu*/
	IF @lastPurchasePrice = 1
		BEGIN

			SELECT ( 
				SELECT defaultPrice as ''@initialNetPrice'', defaultPrice as ''@defaultPrice'', unitId ''@unitId'', itemTypeId as ''@itemTypeId'', ISNULL(@defaultVatRate, vatRateId) as ''@vatRateId'', version as ''@version'', [name] as ''@name'', [code] as ''@code'',
						( 	SELECT TOP 1 netPrice
							FROM document.CommercialDocumentLine L WITH ( NOLOCK )
								JOIN document.CommercialDocumentHeader H WITH ( NOLOCK ) ON H.id = L.commercialDocumentHeaderId
							WHERE
								L.commercialDirection = 1 AND H.status >= 40
								AND ( @contractorId IS NULL OR H.contractorId = @contractorId )
								AND L.itemId = i.id AND L.initialCommercialDocumentLineId IS NULL
							ORDER BY H.issueDate DESC
						) AS ''@lastPurchasePrice'' , i.id as ''@id'',
						( SELECT
							(	SELECT f.name  ''@name'', va.decimalValue ''@value'' 
								FROM item.ItemAttrValue va
									JOIN dictionary.ItemField f ON va.itemFieldId = f.id
								WHERE f.name LIKE ''Price_%'' AND va.itemId = i.id
								FOR XML PATH(''price''),TYPE
							)
						FOR XML PATH(''priceList''),TYPE 
						)															
			FROM item.Item i
				JOIN @tmp t ON i.id = t.id
			FOR XML PATH(''item''), TYPE )
			FOR XML PATH(''root''), TYPE
 
		END
	ELSE /*Bez ostatniej ceny*/
		BEGIN
		
			/* Moduł cenników */
			IF EXISTS( SELECT id FROM item.PriceRule WITH(NOLOCK) WHERE [status] = 1 )
				BEGIN

											
					INSERT INTO @priceRule (id,name, [procedure])
					SELECT id, name, [procedure]
					FROM item.PriceRule
					WHERE [status] >= 1
					ORDER BY [order] ASC
					SELECT @count = @@rowcount, @i = 1
					
					
					WHILE @i  <= @count
						BEGIN
							SELECT TOP 1 @priceName = name, @sql = '' EXEC '' + [procedure] + '' @x , @initialNetPrice OUTPUT, @netPriceCatalogue OUTPUT, @discoutRateValue OUTPUT'', @param = N''@x XML , @initialNetPrice decimal(18,2) OUTPUT, @netPriceCatalogue decimal(18,2) OUTPUT, @discoutRateValue decimal(18,2) OUTPUT'' 
							FROM @priceRule
							WHERE i = @i

							SELECT @initialNetPrice = NULL, @netPriceCatalogue = NULL, @discoutRateValue = NULL
							PRINT @sql
							EXECUTE sp_executesql @sql, @param ,@x = @xmlVar ,@initialNetPrice =  @initialNetPrice OUTPUT, @netPriceCatalogue = @netPriceCatalogue OUTPUT, @discoutRateValue= @discoutRateValue OUTPUT
			
							INSERT INTO @priceResult (initialNetPrice ,netPriceCatalogue ,discoutRateValue, name)
							SELECT @initialNetPrice, @netPriceCatalogue, @discoutRateValue, CASE 
								WHEN @initialNetPrice IS NOT NULL 
									OR @netPriceCatalogue IS NOT NULL 
									OR @discoutRateValue IS NOT NULL THEN @priceName ELSE null END

							SELECT @i = @i + 1
						END
						
					SELECT TOP 1 @initialNetPrice = initialNetPrice FROM @priceResult WHERE initialNetPrice IS NOT NULL ORDER BY i DESC
					SELECT TOP 1 @netPriceCatalogue = netPriceCatalogue FROM @priceResult WHERE netPriceCatalogue IS NOT NULL ORDER BY i DESC
					SELECT TOP 1 @discoutRateValue = discoutRateValue FROM @priceResult WHERE discoutRateValue IS NOT NULL ORDER BY i DESC
					SELECT @priceName = dbo.Concatenate(name ) from @priceResult
					SELECT ( 
						SELECT @initialNetPrice as ''@initialNetPrice'',@netPriceCatalogue ''@netPrice'',@priceName ''@priceName'', CASE WHEN @initialNetPrice IS NOT NULL THEN ''true'' ELSE NULL END ''@priceRuleActive'', i.defaultPrice ''@defaultPrice'', @discoutRateValue ''@discountRate'',itemTypeId ''@itemTypeId'',  unitId ''@unitId'', ISNULL( @defaultVatRate, vatRateId) as ''@vatRateId'', [i].[version] as ''@version'', [i].[name] as ''@name'', i.id as ''@id'', [code] as ''@code'',
								( SELECT
									(	SELECT f.name  ''@name'', va.decimalValue ''@value'' 
										FROM item.ItemAttrValue va
											JOIN dictionary.ItemField f ON va.itemFieldId = f.id
										WHERE f.name LIKE ''Price_%'' AND va.itemId = i.id
										FOR XML PATH(''price''),TYPE
									)
								FOR XML PATH(''priceList''),TYPE 
								),
								( SELECT
									(	SELECT [_iav].[textValue] AS ''text()'' 
										FROM [item].[ItemAttrValue] [_iav]
										JOIN [dictionary].[ItemField] [_if] ON [_if].[id] = [_iav].[itemFieldId]
										AND [_if].[Name] = ''Attribute_Barcode''
										WHERE [_iav].[itemId] = [i].[id]
										FOR XML PATH(''barcode''),TYPE
									)
								FOR XML PATH(''barcodes''),TYPE 
								)
						FROM item.Item i
							JOIN @tmp t ON i.id = t.id
						FOR XML PATH(''item''), TYPE )
					FOR XML PATH(''root''), TYPE
				END
				ELSE
					SELECT ( 
						SELECT defaultPrice as ''@initialNetPrice'', defaultPrice as ''@defaultPrice'', @netPriceCatalogue ''@netPrice'', @discoutRateValue ''@discoutRate'',itemTypeId ''@itemTypeId'',  unitId ''@unitId'', ISNULL( @defaultVatRate, vatRateId) as ''@vatRateId'', [i].[version] as ''@version'', [i].[name] as ''@name'', i.id as ''@id'', [code] as ''@code'',
								( SELECT
									(	SELECT f.name  ''@name'', va.decimalValue ''@value'' 
										FROM item.ItemAttrValue va
											JOIN dictionary.ItemField f ON va.itemFieldId = f.id
										WHERE f.name LIKE ''Price_%'' AND va.itemId = i.id
										FOR XML PATH(''price''),TYPE
									)
								FOR XML PATH(''priceList''),TYPE 
								),
								( SELECT
									(	SELECT [_iav].[textValue] AS ''text()'' 
										FROM [item].[ItemAttrValue] [_iav]
										JOIN [dictionary].[ItemField] [_if] ON [_if].[id] = [_iav].[itemFieldId]
										AND [_if].[Name] = ''Attribute_Barcode''
										WHERE [_iav].[itemId] = [i].[id]
										FOR XML PATH(''barcode''),TYPE
									)
								FOR XML PATH(''barcodes''),TYPE 
								)
						FROM item.Item [i]
							JOIN @tmp t ON i.id = t.id
						FOR XML PATH(''item''), TYPE )
					FOR XML PATH(''root''), TYPE
			
			
			
		END
END
' 
END
GO

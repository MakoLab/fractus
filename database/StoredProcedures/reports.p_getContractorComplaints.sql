/*
name=[reports].[p_getContractorComplaints]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
jS4hM7v2+1xwpbFiYPqn6g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getContractorComplaints]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getContractorComplaints]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getContractorComplaints]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [reports].[p_getContractorComplaints]
@xmlVar XML
AS
BEGIN
		DECLARE 
			@i int,
			@status int,
			@contractorId char(36),
			@includeUnassignedItems bit,
			@itemGroups varchar(8000),
			@containers varchar(8000),
			@item	char(36),
			@itemType varchar(8000),
			@period_1 int,
			@period_2 int,
			@dateFrom varchar(50),
			@dateTo varchar(50),
			@today datetime,
			@companyId varchar(8000),
			@branchId varchar(8000),
			@warehouseId varchar(8000),
			@replaceConf_item varchar(8000),
			@manufacturer varchar(8000),
			@query NVARCHAR(max)	
			
		/*Przenoszę ponieważ bardzo to muli w podzapytaniu*/
		DECLARE @tmp TABLE (i int identity(1,1), complaintDocumentHeaderId uniqueidentifier,contractorId  uniqueidentifier,contractorName nvarchar(500),itemId uniqueidentifier, itemName nvarchar(500), issueDate datetime,  reportedQuantity numeric(18,6),unrealizedQuantity numeric(18,6) )
		DECLARE @tmp_i TABLE (i int identity(1,1) , word nvarchar(500))
		DECLARE @items TABLE (i int identity,id UNIQUEIDENTIFIER)
		
		SELECT 
			@status = NULLIF(x.value(''(//filters/column[@field="realizationStatus"])[1]'', ''int''),''''),
			@contractorId = NULLIF(x.value(''(//filters/column[@field="contractorId"])[1]'', ''char(36)''),''''),
			@manufacturer = NULLIF(x.value(''(//filters/column[@field="manufacturer"])[1]'', ''varchar(500)''),''''),
			@itemGroups = ISNULL(x.value(''itemGroups[1]'', ''varchar(8000)''),''''),
--			@containers = x.value(''containers[1]'', ''varchar(8000)''),
			@item = x.value(''(//filters/column[@field="itemId"])[1]'', ''char(36)''),
            @dateFrom = NULLIF(x.query(''dateFrom'').value(''.'', ''varchar(50)''),''''),
            @dateTo = NULLIF(x.query(''dateTo'').value(''.'', ''varchar(50)'') ,''''),	
			@companyId = x.value(''(//filters/column[@field="companyId"])[1]'', ''varchar(8000)''),
			@branchId = x.value(''(//filters/column[@field="branchId"])[1]'', ''varchar(8000)''),
			@warehouseId = x.value(''(//filters/column[@field="warehouseId"])[1]'', ''varchar(8000)''),
			@itemType = ISNULL(x.value(''(//filters/column[@field="itemType"])[1]'', ''varchar(8000)''),''''),
			@query = ISNULL(REPLACE(REPLACE(RTRIM(NULLIF(@xmlVar.query(''*/query'').value(''.'', ''nvarchar(1000)''),'''')), ''*'', ''%''),'''''''',''''''''''''),'''') 
		FROM @xmlVar.nodes(''/searchParams'') AS a (x)


		SELECT @includeUnassignedItems = x.value(''@includeUnassigned'', ''char(1)'')
		FROM @xmlVar.nodes(''/searchParams/itemGroups'') AS a (x)

		/*Pobranie konfiguracji*/
		SELECT	@replaceConf_item = xmlValue.query(''root/indexing/object[@name="item"]/replaceConfiguration'').value(''.'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''

	
		IF (NULLIF(@query,'''') IS NOT NULL)
			BEGIN
				SET @i = 0
				
				INSERT INTO @tmp_i (word)
				SELECT word 
				FROM xp_split(ISNULL(dbo.f_replace2(@query,@replaceConf_item),''''),  '' '')
				
				WHILE @@rowcount > 0
					BEGIN 
						SET @i = @i + 1
						
						INSERT INTO @items (id)
						SELECT DISTINCT itemId            
						FROM item.v_itemDictionary cd WITH(NOLOCK)             
							JOIN @tmp_i xp ON cd.field LIKE xp.word + ''%''             
						WHERE cd.field <> '' '' AND xp.i = @i
					END
					
				DELETE 
				FROM @items 
				WHERE  id IN (	SELECT id 
								FROM @items
								GROUP BY id 
								HAVING COUNT(i) < (@i-1) 
								)
			END	

		/*Pobieram dane o liniach */
		INSERT INTO @tmp ( complaintDocumentHeaderId ,contractorId,contractorName, itemId, itemName , reportedQuantity ,unrealizedQuantity)
		SELECT	 cl.complaintDocumentHeaderId,ch.contractorId, null,  cl.itemId, itemName , cl.quantity ,(cl.quantity - ISNULL(cd.quantity ,0))
			FROM complaint.ComplaintDocumentLine cl  WITH(NOLOCK) 
				JOIN complaint.ComplaintDocumentHeader ch WITH(NOLOCK)  ON ch.id = cl.complaintDocumentHeaderId
				JOIN item.Item i WITH(NOLOCK) ON cl.itemId = i.id
				LEFT JOIN item.ItemAttrValue iav  WITH(NOLOCK) ON i.id = iav.itemId AND iav.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_Manufacturer'')
				LEFT JOIN @items ii ON i.id = ii.id
				LEFT JOIN (
						SELECT SUM(quantity) quantity, complaintDocumentLineId 
						FROM complaint.ComplaintDecision   WITH(NOLOCK) 
						GROUP BY  complaintDocumentLineId 
					) cd ON cd.complaintDocumentLineId = cl.id	

			WHERE ch.status > 0
						AND ( ( @status IS NOT NULL AND (
												   ( @status = 1 AND cl.quantity - ISNULL(cd.quantity ,0) > 0)
												OR ( @status = 0 AND cd.complaintDocumentLineId IS NULL )
												OR ( @status = 2 AND cl.quantity - ISNULL(cd.quantity ,0) = 0 )
											   )
								) OR @status IS NULL
							)	
						AND ( (@item IS NOT NULL AND cl.itemId = @item) OR @item IS NULL)
						AND (  (cl.itemId IN (
										SELECT itm.id 
										FROM item.item itm WITH( NOLOCK )  
											LEFT JOIN item.ItemGroupMembership igm WITH( NOLOCK ) ON itm.id = igm.itemId 
										WHERE igm.itemId IS NULL AND @includeUnassignedItems = 1
										UNION 
										SELECT itemId 
										FROM item.ItemGroupMembership  WITH( NOLOCK )
										WHERE itemGroupId IN (SELECT CAST(NULLIF(word ,'''') AS char(36)) FROM dbo.xp_split(@itemGroups, '','') )
								)
								) OR ( NULLIF(@itemGroups,'''') IS NULL )
							)
						AND ( (NULLIF( @itemType , '''' ) IS NOT NULL AND i.itemTypeId IN (SELECT CAST( NULLIF(word ,'''') AS char(36) ) FROM dbo.xp_split(@itemType, '','') )  ) OR (NULLIF( @itemType , '''' ) IS NULL ) )
						AND ( (NULLIF(@query,'''') IS NULL ) OR ( NULLIF(@query,'''') IS NOT NULL AND ii.id IS NOT NULL ))
						AND ((NULLIF(@manufacturer,'''') IS NOT NULL AND iav.textValue like @manufacturer + ''%'') OR NULLIF(@manufacturer,'''') IS NULL)
						AND ( ( @dateFrom IS NOT NULL AND cl.issueDate >= @dateFrom) OR @dateFrom IS NULL)
						AND ( ( @dateTo IS NOT NULL AND cl.issueDate < DATEADD(dd,1, CAST(CONVERT(char(10),@dateTo,120) as datetime)) ) OR @dateTo IS NULL)
						
						
						
						
						
						
						
						
						
						

SELECT (
	SELECT c.shortName ''@contractorName'', SUM(ISNULL(reportedQuantity,0)) ''@reportedQuantity'', SUM(ISNULL(unrealizedQuantity,0)) ''@unrealizedQuantity'', 
 
		(	SELECT	 itemName AS ''@itemName'',SUM(reportedQuantity) as ''@reportedQuantity'', SUM(unrealizedQuantity) as ''@unrealizedQuantity'' ,
				ISNULL((
					SELECT ABS(SUM( ll.quantity * ll.commercialDirection)) 
					FROM document.CommercialDocumentLine ll WITH(NOLOCK) 
						JOIN document.CommercialDocumentHeader hh WITH(NOLOCK) ON ll.commercialDocumentHeaderId = hh.id
					WHERE ll.commercialDirection < 0 AND hh.contractorId = c.id AND ll.itemId = tmp.itemId
					GROUP BY itemId ),0) ''@salesTotal'',
				ISNULL((	
					SELECT ABS(SUM( ll.quantity * ll.commercialDirection)) 
					FROM document.CommercialDocumentLine ll WITH(NOLOCK) 
						JOIN document.CommercialDocumentHeader hh WITH(NOLOCK) ON ll.commercialDocumentHeaderId = hh.id
						JOIN item.Item i WITH(NOLOCK) ON ll.itemId = i.id
						LEFT JOIN item.ItemAttrValue iav  WITH(NOLOCK) ON i.id = iav.itemId AND iav.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_Manufacturer'')
						LEFT JOIN @items ii ON i.id = ii.id
					WHERE 
							ll.commercialDirection < 0
							AND ( (@item IS NOT NULL AND ll.itemId = @item) OR @item IS NULL)
							AND (  (ll.itemId IN (
									SELECT itm.id 
									FROM item.item itm WITH( NOLOCK )  
										LEFT JOIN item.ItemGroupMembership igm WITH( NOLOCK ) ON itm.id = igm.itemId 
									WHERE igm.itemId IS NULL AND @includeUnassignedItems = 1
									UNION 
									SELECT itemId 
									FROM item.ItemGroupMembership  WITH( NOLOCK )
									WHERE itemGroupId IN (SELECT CAST(NULLIF(word ,'''') AS char(36)) FROM dbo.xp_split(@itemGroups, '','') )
									)
									) OR ( NULLIF(@itemGroups,'''') IS NULL )
								)
							AND ( (NULLIF( @itemType , '''' ) IS NOT NULL AND i.itemTypeId IN (SELECT CAST( NULLIF(word ,'''') AS char(36) ) FROM dbo.xp_split(@itemType, '','') )  ) OR (NULLIF( @itemType , '''' ) IS NULL ) )
							AND ( (NULLIF(@query,'''') IS NULL ) OR ( NULLIF(@query,'''') IS NOT NULL AND i.id IS NOT NULL ))
							AND ( ( @dateFrom IS NOT NULL AND hh.issueDate >= @dateFrom) OR @dateFrom IS NULL)
							AND ( ( @dateTo IS NOT NULL AND hh.issueDate < DATEADD(dd,1, CAST(CONVERT(char(10),@dateTo,120) as datetime)) ) OR @dateTo IS NULL)
							AND ( (NULLIF(@query,'''') IS NULL ) OR ( NULLIF(@query,'''') IS NOT NULL AND ii.id IS NOT NULL ))
							AND ((NULLIF(@manufacturer,'''') IS NOT NULL AND iav.textValue like @manufacturer + ''%'') OR NULLIF(@manufacturer,'''') IS NULL)
							AND hh.contractorId = c.id AND i.id = tmp.itemId
					GROUP BY ll.itemId
				),0) ''@filteredSalesTotal''	
					
					
		
			FROM @tmp tmp	
			WHERE c.id = tmp.contractorId
			GROUP BY itemName, itemId
			FOR XML PATH(''line''),TYPE	
		)			
	FROM contractor.Contractor c  WITH(NOLOCK) 
		JOIN (  SELECT  itemId , itemName,contractorId, SUM(reportedQuantity) reportedQuantity, SUM(unrealizedQuantity) unrealizedQuantity 
				FROM @tmp 
				GROUP BY contractorId, itemName ,itemId
			)tmp ON c.id = tmp.contractorId
	WHERE 
		  ( (@contractorId IS NOT NULL AND c.id = @contractorId) OR @contractorId IS NULL)
	GROUP BY c.shortName ,c.id 
	ORDER BY c.shortName 
	FOR XML PATH(''complaintDocument''), TYPE )
FOR XML PATH(''root''), TYPE

END
' 
END
GO

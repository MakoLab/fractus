/*
name=[reports].[p_getItemComplaints]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
q8Qg7g3/ujaPXYxSMVvuQw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getItemComplaints]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getItemComplaints]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getItemComplaints]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [reports].[p_getItemComplaints] @xmlVar XML 

AS
BEGIN

		DECLARE 
			@status int,
			@i int,
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
			@manufacturer varchar(8000),
			@replaceConf_item varchar(8000),
			@query NVARCHAR(max)
			
	/*
EXEC reports.p_getItemComplaints 
''<searchParams type="CommercialDocument" applicationUserId="AEB5C0EF-1560-4F9D-8B5B-F8049C27C3E3">
  <filters>
    <column field="itemTypeId">DD659840-E90E-4C28-8774-4D07B307909A,1E12846A-C0BF-4ADA-B571-2E6140507A02</column>
  </filters>
  <dateFrom>2010-12-01</dateFrom>
  <dateTo>2010-12-31T23:59:59.997</dateTo>
</searchParams>''
	*/
			
		/*Przenoszę ponieważ bardzo to muli w podzapytaniu*/
		DECLARE @tmp TABLE (i int identity(1,1), complaintDocumentHeaderId uniqueidentifier,itemId uniqueidentifier, itemName nvarchar(500), issueDate datetime,  reportedQuantity numeric(18,6),unrealizedQuantity numeric(18,6), realized numeric(18,6), notRealized numeric(18,6)  , wholeSale numeric(18,6))
		DECLARE @tmp_i TABLE (i int identity(1,1) , word nvarchar(500))
		DECLARE @items TABLE (i int identity,id UNIQUEIDENTIFIER)
		DECLARE @branch TABLE (id UNIQUEIDENTIFIER)
		
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
		SELECT	@replaceConf_item = xmlValue.value(''(root/indexing/object[@name="item"]/replaceConfiguration)[1]'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''
		
		IF NULLIF(@branchId,'''') IS NOT NULL
			INSERT INTO @branch
			SELECT  NULLIF(word ,'''') FROM dbo.xp_split(@branchId, '','')
		
		IF (NULLIF(@query,'''') IS NOT NULL)
			BEGIN
				SET @i = 0
				
				INSERT INTO @tmp_i (word)
				SELECT word 
				FROM xp_split(ISNULL(dbo.f_replace2(@query,@replaceConf_item),''''),  '' '')
				WHERE RTRIM(word) <> ''''
				
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
		INSERT INTO @tmp (  itemId, itemName , reportedQuantity ,unrealizedQuantity, realized, notRealized, wholeSale )
		SELECT	clc.itemId, i.name , clc.quantity ,(clc.quantity - ISNULL(cd.quantity ,0)), uzn.quantity, nuzn.quantity,0
		FROM item.Item i WITH(NOLOCK) 
			JOIN (	SELECT l.itemId ,	SUM(l.quantity) quantity
					FROM complaint.ComplaintDocumentLine l  WITH(NOLOCK) 
						JOIN complaint.ComplaintDocumentHeader ch WITH(NOLOCK) ON ch.id = l.complaintDocumentHeaderId
						JOIN document.DocumentRelation v ON ch.id = v.firstComplaintDocumentHeaderId
						JOIN document.WarehouseDocumentHeader w ON v.secondWarehouseDocumentHeaderId = w.id
						--JOIN document.Series s WITH(NOLOCK) ON ch.seriesId = s.id
						--JOIN dictionary.Branch b WITH(NOLOCK) ON b.symbol = LEFT( SUBSTRING( seriesValue, CHARINDEX(''/'',seriesValue)+ 1 , LEN(seriesValue) - CHARINDEX(''/'',seriesValue) ) , CHARINDEX(''/'',SUBSTRING( seriesValue, CHARINDEX(''/'',seriesValue)+ 1 , LEN(seriesValue) - CHARINDEX(''/'',seriesValue) ))- 1)
						LEFT JOIN @branch br ON w.branchId = br.id
					WHERE ch.status > 0
						AND ( ( @dateFrom IS NOT NULL AND l.issueDate >= @dateFrom) OR @dateFrom IS NULL)
						AND ( ( @dateTo IS NOT NULL AND l.issueDate < DATEADD(dd,1, CAST(CONVERT(char(10),@dateTo,120) as datetime)) ) OR @dateTo IS NULL)
						AND  (br.id IS NOT NULL OR NULLIF(@branchId,'''') IS NULL)
						AND (ch.contractorId = @contractorId OR NULLIF(@contractorId,'''') IS NULL) -- by Agnieszka
					GROUP BY  l.itemId 
				) clc ON i.id = clc.itemId
			LEFT JOIN @items ii ON i.id = ii.id
			LEFT JOIN (
					SELECT SUM(ccd.quantity) quantity, cdl.itemId
					FROM complaint.ComplaintDecision ccd  WITH(NOLOCK) 
						JOIN complaint.ComplaintDocumentLine cdl WITH(NOLOCK) ON ccd.complaintDocumentLineId = cdl.id
						JOIN complaint.ComplaintDocumentHeader ch WITH(NOLOCK)  ON ch.id = cdl.complaintDocumentHeaderId
						JOIN document.DocumentRelation v ON ch.id = v.firstComplaintDocumentHeaderId
						JOIN document.WarehouseDocumentHeader w ON v.secondWarehouseDocumentHeaderId = w.id
						--JOIN document.Series s WITH(NOLOCK) ON ch.seriesId = s.id
						--JOIN dictionary.Branch b WITH(NOLOCK) ON b.symbol = LEFT( SUBSTRING( seriesValue, CHARINDEX(''/'',seriesValue)+ 1 , LEN(seriesValue) - CHARINDEX(''/'',seriesValue) ) , CHARINDEX(''/'',SUBSTRING( seriesValue, CHARINDEX(''/'',seriesValue)+ 1 , LEN(seriesValue) - CHARINDEX(''/'',seriesValue) ))- 1)
						LEFT JOIN @branch br ON w.branchId = br.id
					WHERE ch.status > 0
						AND ( ( @dateFrom IS NOT NULL AND cdl.issueDate >= @dateFrom) OR @dateFrom IS NULL)
						AND ( ( @dateTo IS NOT NULL AND cdl.issueDate < DATEADD(dd,1, CAST(CONVERT(char(10),@dateTo,120) as datetime)) ) OR @dateTo IS NULL)
						AND  (br.id IS NOT NULL OR NULLIF(@branchId,'''') IS NULL)
						AND (ch.contractorId = @contractorId OR NULLIF(@contractorId,'''') IS NULL) -- by Agnieszka
					GROUP BY  cdl.itemId 
				) cd ON cd.itemId = i.id	
			LEFT JOIN (
					SELECT SUM(ccd.quantity) quantity, cdl.itemId
					FROM complaint.ComplaintDecision ccd  WITH(NOLOCK) 
						JOIN complaint.ComplaintDocumentLine cdl WITH(NOLOCK) ON ccd.complaintDocumentLineId = cdl.id
						JOIN complaint.ComplaintDocumentHeader ch WITH(NOLOCK)  ON ch.id = cdl.complaintDocumentHeaderId
						--JOIN document.Series s WITH(NOLOCK) ON ch.seriesId = s.id
						--JOIN dictionary.Branch b WITH(NOLOCK) ON b.symbol = LEFT( SUBSTRING( seriesValue, CHARINDEX(''/'',seriesValue)+ 1 , LEN(seriesValue) - CHARINDEX(''/'',seriesValue) ) , CHARINDEX(''/'',SUBSTRING( seriesValue, CHARINDEX(''/'',seriesValue)+ 1 , LEN(seriesValue) - CHARINDEX(''/'',seriesValue) ))- 1)
						JOIN document.DocumentRelation v ON ch.id = v.firstComplaintDocumentHeaderId
						JOIN document.WarehouseDocumentHeader w ON v.secondWarehouseDocumentHeaderId = w.id
						LEFT JOIN @branch br ON w.branchId = br.id
					WHERE decisionType in(3,4)
						AND ch.status > 0
						AND ( ( @dateFrom IS NOT NULL AND cdl.issueDate >= @dateFrom) OR @dateFrom IS NULL)
						AND ( ( @dateTo IS NOT NULL AND cdl.issueDate < DATEADD(dd,1, CAST(CONVERT(char(10),@dateTo,120) as datetime)) ) OR @dateTo IS NULL)
						AND  (br.id IS NOT NULL OR NULLIF(@branchId,'''') IS NULL)
						AND (ch.contractorId = @contractorId OR NULLIF(@contractorId,'''') IS NULL) -- by Agnieszka
					GROUP BY  cdl.itemId 
				) uzn ON uzn.itemId = i.id		
			LEFT JOIN (
					SELECT SUM(ccd.quantity) quantity, cdl.itemId
					FROM complaint.ComplaintDecision ccd  WITH(NOLOCK) 
						JOIN complaint.ComplaintDocumentLine cdl WITH(NOLOCK) ON ccd.complaintDocumentLineId = cdl.id
						JOIN complaint.ComplaintDocumentHeader ch WITH(NOLOCK)  ON ch.id = cdl.complaintDocumentHeaderId
						----JOIN document.Series s WITH(NOLOCK) ON ch.seriesId = s.id
						----JOIN dictionary.Branch b WITH(NOLOCK) ON b.symbol = LEFT( SUBSTRING( seriesValue, CHARINDEX(''/'',seriesValue)+ 1 , LEN(seriesValue) - CHARINDEX(''/'',seriesValue) ) , CHARINDEX(''/'',SUBSTRING( seriesValue, CHARINDEX(''/'',seriesValue)+ 1 , LEN(seriesValue) - CHARINDEX(''/'',seriesValue) ))- 1)
						JOIN document.DocumentRelation v ON ch.id = v.firstComplaintDocumentHeaderId
						JOIN document.WarehouseDocumentHeader w ON v.secondWarehouseDocumentHeaderId = w.id
						LEFT JOIN @branch br ON w.branchId = br.id
					WHERE decisionType = 0
						AND ch.status > 0
						AND ( ( @dateFrom IS NOT NULL AND cdl.issueDate >= @dateFrom) OR @dateFrom IS NULL)
						AND ( ( @dateTo IS NOT NULL AND cdl.issueDate < DATEADD(dd,1, CAST(CONVERT(char(10),@dateTo,120) as datetime)) ) OR @dateTo IS NULL)
						AND  (br.id IS NOT NULL OR NULLIF(@branchId,'''') IS NULL)
						AND (ch.contractorId = @contractorId OR NULLIF(@contractorId,'''') IS NULL) -- by Agnieszka
					GROUP BY   cdl.itemId 
				) nuzn ON nuzn.itemId = i.id	
				
		WHERE 	 ( (@item IS NOT NULL AND clc.itemId = @item) OR @item IS NULL)
						AND (  (clc.itemId IN (
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
					
						
						
		--GROUP BY cl.itemId, itemName , cd.quantity , uzn.quantity, nuzn.quantity


						

SELECT (
	SELECT  iav.textValue ''@manufacturer'',i.name AS ''@item_name'',i.code ''@item_code'',
			SUM(ISNULL(reportedQuantity,0)) ''@reported'', 
			SUM(ISNULL(unrealizedQuantity,0)) ''@notProcessed'', 
			SUM(ISNULL(notRealized,0)) ''@notRealized'', 
			SUM(ISNULL(realized,0)) ''@realized'', 
			SUM(ISNULL(wholeSale,0)) ''@wholesale_quantity'',
			ISNULL(SUM(ISNULL(realized / NULLIF(wholeSale,0),0)),0)  ''@percent''
				
	FROM item.Item i  WITH(NOLOCK)
		JOIN (  SELECT tt.itemId , sum(tt.reportedQuantity) reportedQuantity, sum(tt.unrealizedQuantity) unrealizedQuantity ,sum(tt.realized) realized,sum(tt.notRealized)  notRealized ,
				 (wholeSale.wholeSale) wholeSale
				FROM @tmp tt
					LEFT JOIN (	-- by Agnieszka zmiana z JOIN na LEFT JOIN
							SELECT ABS(SUM( ll.quantity * ll.commercialDirection)) wholeSale ,ll.itemId
							FROM document.CommercialDocumentLine ll WITH(NOLOCK) 
								JOIN document.CommercialDocumentHeader hh WITH(NOLOCK) ON ll.commercialDocumentHeaderId = hh.id
								LEFT JOIN @branch br ON hh.branchId = br.id
							WHERE 
									ll.commercialDirection < 0
									AND ( ( @dateFrom IS NOT NULL AND hh.issueDate >= @dateFrom) OR @dateFrom IS NULL)
									AND ( ( @dateTo IS NOT NULL AND hh.issueDate < DATEADD(dd,1, CAST(CONVERT(char(10),@dateTo,120) as datetime)) ) OR @dateTo IS NULL)
									AND  (br.id IS NOT NULL OR NULLIF(@branchId,'''') IS NULL)
									AND (hh.contractorId = @contractorId OR NULLIF(@contractorId,'''') IS NULL) -- by Agnieszka
							GROUP BY  ll.itemId
					) wholeSale ON wholeSale.itemId = tt.itemId
				GROUP BY wholeSale.wholeSale,tt.itemId 
			)tmp ON i.id = tmp.itemId
		LEFT JOIN item.ItemAttrValue iav  WITH(NOLOCK) ON i.id = iav.itemId AND iav.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE [name] = ''Attribute_Manufacturer'')
	WHERE 	((NULLIF(@manufacturer,'''') IS NOT NULL AND iav.textValue like @manufacturer + ''%'') OR NULLIF(@manufacturer,'''') IS NULL)
		
	GROUP BY iav.textValue ,i.name ,i.code, tmp.itemId, i.id 
	ORDER BY i.name 
	FOR XML PATH(''complaintDocument''), TYPE )
FOR XML PATH(''root''), TYPE

END
' 
END
GO

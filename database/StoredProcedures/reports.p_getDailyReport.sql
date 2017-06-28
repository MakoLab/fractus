/*
name=[reports].[p_getDailyReport]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
hQPdydR3zkQO01j1hCHSIw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getDailyReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getDailyReport]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getDailyReport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [reports].[p_getDailyReport]
@xmlVar XML
AS
BEGIN
	
	DECLARE 
		@dateFrom varchar(50),
		@dateTo varchar(50),
		@applicationUsers varchar(max)
		
	DECLARE @tmpApplicationUser TABLE( id uniqueidentifier)


	SELECT @dateFrom = NULLIF(x.query(''dateFrom'').value(''.'', ''varchar(50)''),''''),
           @dateTo = NULLIF(x.query(''dateTo'').value(''.'', ''varchar(50)''),'''') 
	FROM @xmlVar.nodes(''/*'') AS a(x)
	
	SELECT @applicationUsers = NULLIF(@xmlVar.query(''/searchParams/filters/column[@field="applicationUsers"]'').value(''.'',''varchar(max)''),'''') 
	

	IF @applicationUsers IS NOT NULL
		BEGIN
			INSERT INTO @tmpApplicationUser
			SELECT CAST( word  as uniqueidentifier) 
			FROM dbo.xp_split(@applicationUsers,'','')
		END

	IF @dateTo is NOT NULL
		SELECT @dateTo = DATEADD(dd,1,CONVERT( varchar(10) ,CAST(@dateTo AS datetime),21))--,
			  -- @dateFrom = DATEADD(dd,-1,CONVERT( varchar(10) ,CAST(@dateTo AS datetime),21))


SELECT (
	SELECT sales.*, warehouse.*,finance.*,ememki.value emmeki, financeSum.*, b.symbol,   
		   (	
			SELECT  sum(ISNULL(p_.amount ,0) * ISNULL(p_.direction,0))  --, re.branchId
			FROM dictionary.FinancialRegister re_ WITH(NOLOCK)
				LEFT JOIN finance.FinancialReport fre_ WITH(NOLOCK) ON re_.id = fre_.financialRegisterId
				LEFT JOIN document.FinancialDocumentHeader fdh_ WITH(NOLOCK) ON fre_.id  = fdh_.financialReportId
				LEFT JOIN finance.Payment p_ WITH(NOLOCK) ON fdh_.id = p_.financialDocumentHeaderId
			WHERE re_.registerCategory = 0 AND status >= 40 AND re_.branchId = b.id AND ISNULL(fdh_.issuedate , GETDATE()) < @dateFrom
				AND ( fdh_.issuingPersonContractorId IN (SELECT id FROM @tmpApplicationUser) OR @applicationUsers IS NULL)
			GROUP BY re_.branchId
			) initialBalance,
		
	
	
	b.xmlLabels.value(''(//label)[1]'',''nvarchar(500)'') label
	FROM dictionary.Branch b  WITH(NOLOCK)
		LEFT JOIN 
		(	SELECT  (sum(l.sysNetValue )) netValue, 
					(sum(l.sysGrossValue )) grossValue,
					 /*sum(l.sysGrossValue ) - SUM( ISNULL(cost.value,0 )) profitValue,*/
					 sum((l.netValue * h.exchangeRate)/h.exchangeScale) - SUM( ABS(ISNULL(cost.value,0)) * SIGN(l.quantity) )  profitValue, 
					sum(ABS(ISNULL(cost.value,0)) * SIGN(l.quantity )) costValue,
					-(SUM(CASE WHEN ISNULL(retail.x,0) = 1 THEN l.sysGrossValue * l.commercialDirection ELSE 0 END )) retailGrossValue,
					-(SUM(CASE WHEN ISNULL(retail.x,0) = 1 THEN l.sysNetValue * l.commercialDirection ELSE 0 END )) retailNetValue,
					-(SUM(CASE WHEN it.IsWarehouseStorable = 1 THEN l.sysGrossValue * l.commercialDirection ELSE 0 END )) goodGrossValue,
					-(SUM(CASE WHEN it.IsWarehouseStorable = 1 THEN l.sysNetValue * l.commercialDirection ELSE 0 END )) goodNetValue,
					-(SUM(CASE WHEN it.IsWarehouseStorable = 0 THEN l.sysGrossValue * l.commercialDirection ELSE 0 END )) serviceGrossValue,
					-(SUM(CASE WHEN it.IsWarehouseStorable = 0 THEN l.sysNetValue * l.commercialDirection ELSE 0 END )) serviceNetValue,
					h.branchId
			FROM document.CommercialDocumentHeader h WITH(NOLOCK) 
				JOIN document.CommercialDocumentLine l WITH(NOLOCK) ON h.id = l.CommercialDocumentHeaderId 
				JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id
				LEFT JOIN (		SELECT  SUM(ISNULL(v.value,0)) value , v.commercialDocumentLineId 
								FROM document.CommercialWarehouseValuation v WITH(NOLOCK) 
								--JOIN document.WarehouseDocumentLine ll WITH(NOLOCK) ON v.warehouseDocumentLineId = ll.id 
								Group by  v.commercialDocumentLineId  
							) cost ON l.id = cost.commercialDocumentLineId	
				LEFT  JOIN (	SELECT decimalValue x, commercialDocumentHeaderId 
								FROM document.DocumentAttrValue WITH(NOLOCK)
								WHERE commercialDocumentHeaderId IS NOT NULL 
									AND documentFieldId = (
									SELECT id FROM dictionary.DocumentField WITH(NOLOCK) WHERE name = ''DocumentFeature_RetailSales'' )
							) retail ON h.id = retail.commercialDocumentHeaderId
				JOIN item.Item i WITH(NOLOCK) ON l.itemId = i.id
				JOIN dictionary.ItemType it	WITH(NOLOCK) ON i.itemTypeId = it.id		
			WHERE dt.documentCategory  IN (0,5)
				AND l.commercialDirection <> 0
				AND h.status >= 40
				AND ((@dateFrom IS NOT NULL AND h.issueDate >= @dateFrom) OR (@dateFrom IS NULL))
				AND ((@dateTo IS NOT NULL AND h.issueDate < @dateTo ) OR @dateTo IS NULL)
				AND ( h.issuingPersonContractorId IN (SELECT id FROM @tmpApplicationUser) OR @applicationUsers IS NULL)
			GROUP BY h.branchId
		) sales ON b.id = sales.branchId
		LEFT JOIN 
		(	SELECT SUM(l.value * l.direction) value ,
				   ABS (SUM( CASE WHEN (l.quantity * l.direction) > 0 THEN (l.value * l.direction) ELSE 0 END )) income,
				   ABS (SUM( CASE WHEN (l.quantity * l.direction) < 0 THEN (l.value * l.direction) ELSE 0 END )) outcome,
				   ABS (SUM( CASE WHEN (l.quantity * l.direction) > 0 THEN (l.quantity * l.direction) ELSE 0 END )) incomeQuantity,
				   ABS (SUM( CASE WHEN (l.quantity * l.direction) < 0 THEN (l.quantity * l.direction) ELSE 0 END )) outcomeQuantity,
				   h.branchId
			FROM document.WarehouseDocumentHeader h WITH(NOLOCK) 
				JOIN document.WarehouseDocumentLine l WITH(NOLOCK) ON h.id = l.warehouseDocumentHeaderId 
				JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id
			WHERE dt.documentCategory = 1 
				AND h.status >= 40
				AND ((@dateFrom IS NOT NULL AND h.issueDate >= @dateFrom) OR (@dateFrom IS NULL))
				AND ((@dateTo IS NOT NULL AND h.issueDate < @dateTo ) OR @dateTo IS NULL)
				AND ( h.modificationApplicationUserId IN (SELECT id FROM @tmpApplicationUser) OR @applicationUsers IS NULL)
			GROUP BY  h.branchId
		) 	warehouse ON b.id = warehouse.branchId
		LEFT JOIN 
		(   SELECT  
					SUM((CASE WHEN (p.sysAmount * p.direction) > 0 THEN (p.sysAmount * p.direction) ELSE 0 END )) incomeValue,
					SUM((CASE WHEN (p.sysAmount * p.direction) < 0 THEN (p.sysAmount * p.direction) ELSE 0 END )) outcomeValue,
					SUM(ABS(CASE WHEN dav_.textValue = ''KWB'' THEN (p.sysAmount * p.direction) ELSE 0 END )) bank,
					fdh.branchId
			FROM dictionary.FinancialRegister re WITH(NOLOCK)
				LEFT JOIN finance.FinancialReport fre WITH(NOLOCK) ON re.id = fre.financialRegisterId
				LEFT JOIN document.FinancialDocumentHeader fdh WITH(NOLOCK) ON fre.id  = fdh.financialReportId
				LEFT JOIN finance.Payment p WITH(NOLOCK) ON fdh.id = p.financialDocumentHeaderId
				LEFT JOIN (	SELECT  DISTINCT dav.textValue , dav.financialDocumentHeaderId 
							FROM document.DocumentAttrValue dav WITH(NOLOCK) 
							WHERE dav.documentFieldId in (
																SELECT id 
																FROM dictionary.DocumentField 
																WHERE [name] in( ''Attribute_StatusFinancialOutcome'' , ''Attribute_StatusFinancial'' ) )
									AND dav.textValue IS NOT NULL
							)  dav_ ON dav_.financialDocumentHeaderId = fdh.id
			WHERE re.registerCategory = 0 AND fdh.status >= 40 AND ISNULL(p.requireSettlement,1) <> 0
				AND ((@dateFrom IS NOT NULL AND fdh.issueDate >= @dateFrom) OR (@dateFrom IS NULL))
				AND ((@dateTo IS NOT NULL AND fdh.issueDate < @dateTo ) OR @dateTo IS NULL)
				AND ( fdh.issuingPersonContractorId IN (SELECT id FROM @tmpApplicationUser) OR @applicationUsers IS NULL)
			GROUP BY fdh.branchId
		)	finance	ON b.id = finance.branchId
		LEFT JOIN 
		(   SELECT  sum(ISNULL(p.sysAmount ,0) * ISNULL(p.direction,0)) cashReportBalance,
					re.branchId
			FROM dictionary.FinancialRegister re WITH(NOLOCK)
				LEFT JOIN finance.FinancialReport fre WITH(NOLOCK) ON re.id = fre.financialRegisterId
				LEFT JOIN document.FinancialDocumentHeader fdh WITH(NOLOCK) ON fre.id  = fdh.financialReportId
				LEFT JOIN finance.Payment p WITH(NOLOCK) ON fdh.id = p.financialDocumentHeaderId
			WHERE re.registerCategory = 0 AND status >= 40
			AND ( fdh.issuingPersonContractorId IN (SELECT id FROM @tmpApplicationUser) OR @applicationUsers IS NULL)
			GROUP BY re.branchId
		)	financeSum ON b.id = financeSum.branchId
		LEFT JOIN 
		(   SELECT sum(ISNULL(l.value ,0)) value, h.branchId
			FROM document.WarehouseDocumentHeader h WITH(NOLOCK) 
				JOIN document.WarehouseDocumentLine l WITH(NOLOCK) ON h.id = l.warehouseDocumentHeaderId 
				JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id
			WHERE symbol = ''MM+'' AND h.status = 20
				AND ( h.modificationApplicationUserId IN (SELECT id FROM @tmpApplicationUser) OR @applicationUsers IS NULL)
			GROUP BY  h.branchId
		) ememki ON b.id =  ememki.branchId
	
		
		WHERE b.id IN (SELECT branchId FROM dictionary.Warehouse WHERE isActive = 1)
		ORDER BY b.symbol
		FOR XML PATH(''line''), TYPE
	) FOR XML PATH(''root''), TYPE

/*
exec reports.p_getDailyReport ''
<root>  
	<dateFrom>2010-03-01</dateFrom>
	<dateTo>2010-03-31T23:59:59.997</dateTo>
 </root>''
*/
END
' 
END
GO

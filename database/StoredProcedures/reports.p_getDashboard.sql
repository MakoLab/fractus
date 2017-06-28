/*
name=[reports].[p_getDashboard]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
YCp/OC+yTkYzrSW3ES+MvA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getDashboard]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getDashboard]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getDashboard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [reports].[p_getDashboard]
@xmlVar XML
AS
BEGIN

        DECLARE 
            @dateFrom DATETIME,
            @dateTo DATETIME,
			@dateFrom2 DATETIME,
            @dateTo2 DATETIME,
			@raport varchar(50),
			@pageSize int,
			@branchId uniqueidentifier,
			@pamentMethod varchar(50)

        SELECT  
                @dateFrom = NULLIF(x.query(''dateFrom'').value(''.'', ''datetime''),''''),
                @dateTo = DATEADD(dd,1,NULLIF(x.query(''dateTo'').value(''.'', ''datetime''),'''')),
				@dateFrom2 = NULLIF(x.query(''dateFrom1'').value(''.'', ''datetime''),''''),
                @dateTo2 = DATEADD(dd,1,NULLIF(x.query(''dateTo1'').value(''.'', ''datetime''),'''')),
				@raport = NULLIF(x.query(''report'').value(''.'', ''varchar(50)''),''''),
				@pageSize = NULLIF(x.query(''pageSize'').value(''.'', ''varchar(50)''),''''),
				@branchId = NULLIF(x.query(''branchId'').value(''.'', ''char(36)''),''''),
				@pamentMethod = NULLIF(x.query(''pamentMethod'').value(''.'', ''varchar(50)''),'''')
        FROM    @xmlVar.nodes(''/*'') a(x)

       IF @raport = ''obroty'' 
		BEGIN
			SELECT (
			SELECT (
			   SELECT * 
			   FROM (
					SELECT top 100 b.id as ''@branchID'' , pm.id as ''@label'', x.amount as ''@grossValue'', y.amount ''@grossValue1''
					FROM  dictionary.Branch b  WITH(NOLOCK) 
						CROSS JOIN (select id, xmlLabels.value(''(labels/label[@lang="pl"])[1]'',''varchar(100)'') label from dictionary.PaymentMethod WITH(NOLOCK)  ) pm  
						LEFT JOIN (
								SELECT c.branchId  , p.paymentMethodId, SUM(p.amount) amount
								FROM document.CommercialDocumentHeader c  WITH(NOLOCK) 
									JOIN finance.Payment p  WITH(NOLOCK)  ON p.commercialDocumentHeaderId = c.id
									JOIN dictionary.DocumentType dt WITH(NOLOCK) ON c.documentTypeId = dt.id AND dt.documentCategory IN (0,5) AND c.status >= 40
								WHERE (@dateFrom IS NULL OR ( c.issueDate >= @dateFrom ))
										AND (@dateTo IS NOT NULL AND (c.issueDate <= @dateTo))
								GROUP BY c.branchId  , p.paymentMethodId
							) x ON x.branchId = b.id AND x.paymentMethodId = pm.id
						LEFT JOIN (
								SELECT  c.branchId  , p.paymentMethodId, SUM(p.amount) amount
								FROM document.CommercialDocumentHeader c  WITH(NOLOCK) 
									JOIN finance.Payment p  WITH(NOLOCK)  ON p.commercialDocumentHeaderId = c.id
									JOIN dictionary.DocumentType dt WITH(NOLOCK) ON c.documentTypeId = dt.id AND dt.documentCategory IN (0,5) AND c.status >= 40
								WHERE (@dateFrom2 IS NULL OR ( c.issueDate >= @dateFrom2 ))
										AND (@dateTo2 IS NOT NULL AND (c.issueDate <= @dateTo2))
								GROUP BY c.branchId  , p.paymentMethodId
							) y ON y.branchId = b.id AND y.paymentMethodId = pm.id

						ORDER BY b.id
					) x  FOR XML PATH(''lines''),TYPE
					)FOR XML PATH(''obroty''),TYPE
			)FOR XML PATH(''root''),TYPE
		END
       IF @raport = ''rejestr'' 
		BEGIN
			SELECT (
			SELECT (
			   SELECT * 
			   FROM (
					SELECT top 100 
						r.xmlLabels.value(''(labels/label[@lang="pl"])[1]'',''varchar(50)'') as  ''@label'', 
						ISNULL( (
								SELECT  ISNULL(sum(ISNULL(p.amount ,0) * ISNULL(p.direction,0)) ,0)
								FROM finance.FinancialReport fre 
									LEFT JOIN document.FinancialDocumentHeader fdh  ON fre.id  = fdh.financialReportId
									LEFT JOIN finance.Payment p ON fdh.id = p.financialDocumentHeaderId
								WHERE fre.financialRegisterId = r.id  AND status >= 40
						), 0 ) ''@balance''
					FROM  dictionary.Branch b  WITH(NOLOCK) 
						JOIN dictionary.FinancialRegister r WITH(NOLOCK) ON r.branchId = b.id
						LEFT JOIN finance.FinancialReport fr WITH(NOLOCK) ON r.id = fr.financialRegisterId AND  isClosed = 0
					ORDER BY 1
					) x  FOR XML PATH(''lines''),TYPE
					)FOR XML PATH(''rejestr''),TYPE
			)FOR XML PATH(''root''),TYPE
		END

	ELSE IF @raport = ''nierozliczone''
		BEGIN
			SELECT (
				SELECT (
					SELECT * 
						FROM (
								SELECT TOP ( @pageSize) h.id as ''@id'', h.documentTypeId as ''@documentTypeId'' , h.status as ''@status'',  h.fullNumber as ''@fullNumber'', h.issueDate as ''@issueDate'',
										c.fullName as ''@fullName'', h.value as ''@grossValue''
								FROM  document.WarehouseDocumentHeader h  WITH(NOLOCK) 
									JOIN contractor.Contractor c  WITH(NOLOCK) ON  h.contractorId = c.id
									LEFT JOIN (SELECT wl.warehouseDocumentHeaderId ,  SUM(CAST(isCommercialRelation AS int)) isR, count(wl.id) lCount
												FROM document.WarehouseDocumentLine wl WITH(NOLOCK) 
													LEFT JOIN document.CommercialWarehouseRelation r ON  wl.id = r.warehouseDocumentLineId  AND r.isCommercialRelation = 1 
												GROUP BY  wl.warehouseDocumentHeaderId ) cwr_c ON  cwr_c.warehouseDocumentHeaderId = h.id 
								WHERE ISNULL(cwr_c.isR,0) < cwr_c.lCount 
									AND h.status >= 40
									AND (@branchId IS NULL OR @branchId = h.branchId)
									AND h.id NOT IN (SELECT l.warehouseDocumentHeaderId id
													FROM document.WarehouseDocumentLine l  WITH(NOLOCK) 
														JOIN document.WarehouseDocumentLine lk WITH(NOLOCK)  ON l.id = lk.correctedWarehouseDocumentLineId AND lk.quantity < 0
													GROUP BY l.warehouseDocumentHeaderId 
													HAVING  SUM(l.quantity) + SUM(lk.quantity ) = 0)
									AND h.documentTypeId = ''1AB89244-413F-4296-B623-B326803DB3C8''
								ORDER BY  h.issueDate DESC
							) x  FOR XML PATH(''lines''),TYPE
					) FOR XML PATH(''nierozliczone''),TYPE
				) FOR XML PATH(''root''),TYPE
		END
	ELSE IF @raport = ''platnosci''
		BEGIN
			SELECT (
				SELECT (
					SELECT * 
						FROM (
								SELECT  TOP ( @pageSize) h.id as ''@id'', h.documentTypeId as ''@documentTypeId'' , h.status as ''@status'',  h.fullNumber as ''@fullNumber'', p.dueDate as ''@issueDate'',
										c.fullName as ''@fullName'', h.grossValue as ''@grossValue''
								FROM document.CommercialDocumentHeader h  WITH(NOLOCK) 
									JOIN contractor.Contractor c  WITH(NOLOCK) ON  h.contractorId = c.id
									JOIN finance.Payment p  WITH(NOLOCK)  ON p.commercialDocumentHeaderId = h.id
									JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id 
										AND dt.documentCategory IN (6, 2) 
										AND h.status >= 40
								WHERE CAST(getdate()  as date) >= CAST(p.dueDate as date) AND p.unsettledAmount <> 0 
									AND (@branchId IS NULL OR @branchId = h.branchId)
									AND (@pamentMethod IS NULL OR p.paymentMethodId in (SELECT id FROM dictionary.PaymentMethod WHERE isIncrementingDueAmount = 0))
								ORDER BY  h.issueDate DESC
							) x  FOR XML PATH(''lines''),TYPE
					) FOR XML PATH(''platnosci''),TYPE
				) FOR XML PATH(''root''),TYPE
		END
	ELSE IF @raport = ''akceptacja''
		BEGIN
			SELECT (
				SELECT (
					SELECT * 
						FROM (
								SELECT  TOP ( @pageSize) h.id as ''@id'', h.documentTypeId as ''@documentTypeId'' , h.status as ''@status'',  h.fullNumber as ''@fullNumber'', h.issueDate as ''@issueDate'',
										c.fullName as ''@fullName'', h.grossValue as ''@grossValue''
								FROM document.CommercialDocumentHeader h  WITH(NOLOCK) 
									JOIN contractor.Contractor c  WITH(NOLOCK) ON  h.contractorId = c.id
									JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id 
										AND dt.documentCategory IN (6, 2) 
										AND h.status >= 40
									LEFT JOIN document.DocumentAttrValue v ON h.id = v.commercialDocumentHeaderId AND v.documentFieldId = (SELECT id FROM dictionary.DocumentField WHERE name = ''Attribute_Acceptation'')
								WHERE  ISNULL(v.decimalValue,0)  = 0 --(@branchId IS NULL OR @branchId = h.branchId)

								ORDER BY  h.issueDate DESC
							) x  FOR XML PATH(''lines''),TYPE
					) FOR XML PATH(''akceptacja''),TYPE
				) FOR XML PATH(''root''),TYPE
		END
	ELSE IF @raport = ''stany''
		BEGIN
			SELECT (
				SELECT (
					SELECT * 
						FROM (
								SELECT i.id AS ''@id'',i.name ''@itemName'' , i.code ''@itemCode'',ISNULL( minStock.decimalValue,0) ''@minimalStock'',
									ws.quantity ''@stock'' 
								FROM item.Item i WITH(NOLOCK) 
									LEFT JOIN (
										SELECT itemId, sum(ISNULL(quantity,0)) quantity 
										FROM document.WarehouseStock WITH(NOLOCK) 
										GROUP BY itemId
											) ws  ON i.id = ws.itemId
									JOIN item.ItemAttrValue minStock WITH(NOLOCK) ON i.id = minStock.itemId AND minStock.itemFieldId = (select id from dictionary.ItemField where [name] = ''Attribute_MinimalStock'')
								WHERE ISNULL( minStock.decimalValue,0) > ws.quantity
								GROUP BY i.id ,i.name  , i.code ,ISNULL( minStock.decimalValue,0),ws.quantity
							) x  FOR XML PATH(''lines''),TYPE
					) FOR XML PATH(''stany''),TYPE
				) FOR XML PATH(''root''),TYPE
		END
      ELSE IF @raport = ''zlecenia'' 
		BEGIN
			SELECT (
			SELECT (
			   SELECT * 
			   FROM (
						SELECT top 100 percent i.name as ''@itemName'', v.dateValue as ''@dateValue'', l.quantity ''@quantity''
						FROM document.CommercialDocumentHeader c  WITH(NOLOCK) 
							JOIN document.CommercialDocumentLine l WITH(NOLOCK) ON c.id = l.commercialDocumentHeaderId
							JOIN document.DocumentAttrValue v WITH(NOLOCK) ON c.id = v.commercialDocumentHeaderId 
								AND v.documentFieldId = ''33D5D89F-E3EB-4ED6-BA65-20C724AC07BA''
							JOIN item.Item i WITH(NOLOCK) ON l.itemId = i.id
							JOIN dictionary.DocumentType dt WITH(NOLOCK) ON c.documentTypeId = dt.id 
								AND dt.symbol = ''ZP'' 
								AND c.status = 20
						ORDER BY  v.dateValue ASC
					) x  FOR XML PATH(''lines''),TYPE
					)FOR XML PATH(''zlecenia''),TYPE
			)FOR XML PATH(''root''),TYPE
		END
	  ELSE IF @raport = ''przeterminowane''
		BEGIN
			SELECT (
				SELECT (
					SELECT * 
						FROM (
								SELECT  TOP 100 PERCENT i.id AS ''@id'',i.name ''@itemName'' , i.code ''@itemCode'',  SUM((l.quantity * l.direction) - ISNULL(r.q, 0)) ''@quantity'', av.dateValue ''@expirationDate''
								FROM item.Item i WITH(NOLOCK) 
									JOIN document.WarehouseDocumentLine l WITH(NOLOCK) ON i.id = l.itemId 
									LEFT JOIN (
												SELECT SUM(quantity) q, ir.incomeWarehouseDocumentLineId id
												FROM document.IncomeOutcomeRelation ir WITH(NOLOCK) 
												GROUP BY  ir.incomeWarehouseDocumentLineId ) r ON r.id = l.id
									JOIN document.DocumentLineAttrValue av WITH(NOLOCK) ON av.warehouseDocumentLineId = l.id 
										AND av.documentFieldId = ( SELECT id FROM dictionary.DocumentField WHERE name = ''LineAttribute_expirationDate'' )
								WHERE l.quantity * l.direction > 0 
									AND (l.quantity * l.direction) > ISNULL(r.q, 0)
								GROUP BY i.id, i.name ,i.code ,av.dateValue
								ORDER BY av.dateValue ASC  
							) x  FOR XML PATH(''lines''),TYPE
					) FOR XML PATH(''przeterminowane''),TYPE
				) FOR XML PATH(''root''),TYPE
		END
      ELSE IF @raport = ''dostawy'' 
		BEGIN
			SELECT (
			SELECT (
			   SELECT * 
			   FROM (
					SELECT top 100 percent i.name as ''@itemName'', l.quantity ''@quantity'', c.eventDate as ''@dateValue'' 
					FROM document.CommercialDocumentHeader c  WITH(NOLOCK) 
						JOIN document.CommercialDocumentLine l WITH(NOLOCK) ON c.id = l.commercialDocumentHeaderId
						JOIN item.Item i WITH(NOLOCK) ON l.itemId = i.id
						JOIN dictionary.DocumentType dt WITH(NOLOCK) ON c.documentTypeId = dt.id 
							AND dt.symbol = ''ZD'' 
							AND c.status >= 20
					ORDER BY   c.issueDate ASC
					) x  FOR XML PATH(''lines''),TYPE
					)FOR XML PATH(''dostawy''),TYPE
			)FOR XML PATH(''root''),TYPE
		END
    END
' 
END
GO

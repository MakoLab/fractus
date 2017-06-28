/*
name=[reports].[p_getDailyReportMobile2]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
nb7ccDgN7FM3he9hDCgu8Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getDailyReportMobile2]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getDailyReportMobile2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getDailyReportMobile2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [reports].[p_getDailyReportMobile2]
AS
------------ procedura dla zestawień na urządzenia mobilne ---------

DECLARE @branches TABLE (id uniqueidentifier, symbol varchar(100))

INSERT INTO @branches (id, symbol)
SELECT id, symbol
FROM dictionary.Branch

-- wiersze
SELECT b.symbol, ISNULL(s.netValue,0) [Sprzedaż],
	REPLACE(CAST(CAST(ROUND(100 * (s.net - ISNULL(s.costValue,0)) / NULLIF(s.net, 0), 2) AS float) AS varchar(100)) + ''%'', ''.'', '','') [Marża %],
	ISNULL(cashReportBalance,0) [Kasa], ISNULL(xx.monthNetValue,0) [Sprzedaż mies.] --,getdate() [Data]
	FROM @branches b
		LEFT JOIN ( --sprzedaz bez zamowien
				SELECT  (sum(l.netValue )) netValue, 
						 SUM( CASE WHEN x.id IS NULL AND i.code  IN (''UC22'',''UC7'') THEN l.netValue ELSE  it.isWarehouseStorable * l.netValue END) net,
						 SUM( ISNULL(cost.value,0 )) costValue,--( it.isWarehouseStorable = 0 x.id IS NULL AND i.code  IN (''UC22'',''UC7'') )
						h.branchId
				FROM document.CommercialDocumentHeader h WITH(NOLOCK) 
					JOIN document.CommercialDocumentLine l WITH(NOLOCK) ON h.id = l.CommercialDocumentHeaderId 
					JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id
					LEFT JOIN (		SELECT SUM(ISNULL(value,0)) value , commercialDocumentLineId
									FROM document.CommercialWarehouseValuation cwv WITH(NOLOCK) 
									GROUP BY commercialDocumentLineId
								) cost ON l.id = cost.commercialDocumentLineId	
					--LEFT  JOIN (	SELECT decimalValue x, commercialDocumentHeaderId 
					--				FROM document.DocumentAttrValue WITH(NOLOCK)
					--				WHERE commercialDocumentHeaderId IS NOT NULL 
					--					AND documentFieldId = (
					--					SELECT id FROM dictionary.DocumentField WITH(NOLOCK) WHERE name = ''DocumentFeature_RetailSales'' )
					--			) retail ON h.id = retail.commercialDocumentHeaderId
					
					LEFT JOIN ( SELECT hz.id
								FROM document.CommercialDocumentHeader hz  WITH(NOLOCK)
									LEFT JOIN document.CommercialDocumentLine cl  WITH(NOLOCK) ON hz.id = cl.commercialDocumentHeaderId
									LEFT JOIN item.Item ci  WITH(NOLOCK) ON cl.itemId = ci.id
									LEFT JOIN dictionary.ItemType ric  WITH(NOLOCK) ON ci.itemTypeId = ric.id
								WHERE ric.isWarehouseStorable = 0  
									AND ci.code NOT IN (''UC22'',''UC7'')
								GROUP BY hz.id
								 ) x ON h.id = x.id
					
					
					JOIN item.Item i WITH(NOLOCK) ON l.itemId = i.id
					JOIN dictionary.ItemType it	WITH(NOLOCK) ON i.itemTypeId = it.id		
				WHERE dt.documentCategory  IN (0,5)
					 
					AND l.commercialDirection <> 0
					AND ISNULL(xmlOptions.value(''(/root/commercialDocument/@isPrepaymentInvoice)[1]'',''char(6)''),'''') <> ''true''
					AND h.status >= 40
					AND  [dbo].[f_reportsSalesDateSelector]( h.issueDate, h.eventDate, dt.documentCategory , dt.symbol ) >= CONVERT(varchar(10),getdate(),120) AND  [dbo].[f_reportsSalesDateSelector]( h.issueDate, h.eventDate, dt.documentCategory , dt.symbol ) < CONVERT(varchar(10),DATEADD(d,1,getdate()),120)
				GROUP BY h.branchId
					
			) s ON b.id = s.branchId
		LEFT JOIN (	--stan kasy	
					 SELECT  sum(ISNULL(p.amount ,0) * ISNULL(p.direction,0)) cashReportBalance,
							re.branchId
					FROM dictionary.FinancialRegister re WITH(NOLOCK)
						LEFT JOIN finance.FinancialReport fre WITH(NOLOCK) ON re.id = fre.financialRegisterId
						LEFT JOIN document.FinancialDocumentHeader fdh WITH(NOLOCK) ON fre.id  = fdh.financialReportId
						LEFT JOIN finance.Payment p WITH(NOLOCK) ON fdh.id = p.financialDocumentHeaderId
					WHERE re.registerCategory = 0 AND status >= 40
					GROUP BY re.branchId
		)	financeSum ON b.id = financeSum.branchId
		
		LEFT JOIN ( --miesięczna sprzedaż
				SELECT  (sum(l.netValue )) monthNetValue,
						h.branchId
				FROM document.CommercialDocumentHeader h WITH(NOLOCK) 
					JOIN document.CommercialDocumentLine l WITH(NOLOCK) ON h.id = l.CommercialDocumentHeaderId 
					JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id
					LEFT JOIN (		SELECT SUM(ISNULL(value,0)) value , commercialDocumentLineId
									FROM document.CommercialWarehouseValuation cwv WITH(NOLOCK) 
									GROUP BY commercialDocumentLineId
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
					AND ISNULL( xmlOptions.value(''(/root/commercialDocument/@isPrepaymentInvoice)[1]'',''char(6)''),'''') <> ''true''
					AND  YEAR([dbo].[f_reportsSalesDateSelector]( h.issueDate, h.eventDate, dt.documentCategory , dt.symbol )) = year(getdate()) AND MONTH([dbo].[f_reportsSalesDateSelector]( h.issueDate, h.eventDate, dt.documentCategory , dt.symbol )) = MONTH(getdate())
				GROUP BY h.branchId
			) xx ON b.id = xx.branchId
			
			
		WHERE symbol NOT IN (''CE'', ''GR'')			
			
			
-- podsumowanie
SELECT ''SUMA'',  	SUM(netValue) [Sprzedaż], 
		REPLACE(CAST(CAST(ROUND((100 * (SUM(net)- SUM(costValue)) / NULLIF(SUM(net), 0)), 2) AS float) AS varchar(100)) + ''%'', ''.'', '','')  [Marża %],
		SUM(cashReportBalance) [Kasa],SUM(monthNetValue) [Sprzedaż miesiac]
	FROM dictionary.Branch b
		LEFT JOIN ( --sprzedaz bez zamowien
				SELECT  (sum(l.netValue )) netValue, 
						 --SUM(CASE WHEN it.isWarehouseStorable = 0 THEN 0 ELSE l.netValue END) net,
						 SUM( CASE WHEN x.id IS NULL AND i.code  IN (''UC22'',''UC7'') THEN l.netValue ELSE  it.isWarehouseStorable * l.netValue END) net,
						 SUM( ISNULL(cost.value,0 )) costValue,
						h.branchId
				FROM document.CommercialDocumentHeader h WITH(NOLOCK) 
					JOIN document.CommercialDocumentLine l WITH(NOLOCK) ON h.id = l.CommercialDocumentHeaderId 
					JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id
					LEFT JOIN (		SELECT SUM(ISNULL(value,0)) value , commercialDocumentLineId
									FROM document.CommercialWarehouseValuation cwv WITH(NOLOCK) 
									GROUP BY commercialDocumentLineId
								) cost ON l.id = cost.commercialDocumentLineId	
					LEFT JOIN ( SELECT hz.id
								FROM document.CommercialDocumentHeader hz  WITH(NOLOCK)
									LEFT JOIN document.CommercialDocumentLine cl  WITH(NOLOCK) ON hz.id = cl.commercialDocumentHeaderId
									LEFT JOIN item.Item ci  WITH(NOLOCK) ON cl.itemId = ci.id
									LEFT JOIN dictionary.ItemType ric  WITH(NOLOCK) ON ci.itemTypeId = ric.id
								WHERE ric.isWarehouseStorable = 0  
									AND ci.code NOT IN (''UC22'',''UC7'')
								GROUP BY hz.id
								 ) x ON h.id = x.id
								 
					JOIN item.Item i WITH(NOLOCK) ON l.itemId = i.id
					JOIN dictionary.ItemType it	WITH(NOLOCK) ON i.itemTypeId = it.id		
				WHERE dt.documentCategory  IN (0,5)
					AND l.commercialDirection <> 0
					AND h.status >= 40
					AND ISNULL(xmlOptions.value(''(/root/commercialDocument/@isPrepaymentInvoice)[1]'',''char(6)''),'''') <> ''true''
					AND  [dbo].[f_reportsSalesDateSelector]( h.issueDate, h.eventDate, dt.documentCategory , dt.symbol ) >= CONVERT(varchar(10),getdate(),120) AND  [dbo].[f_reportsSalesDateSelector]( h.issueDate, h.eventDate, dt.documentCategory , dt.symbol ) < CONVERT(varchar(10),DATEADD(d,1,getdate()),120)
				GROUP BY h.branchId
					
			) s ON b.id = s.branchId
		LEFT JOIN (	--stan kasy	
					 SELECT  sum(ISNULL(p.amount ,0) * ISNULL(p.direction,0)) cashReportBalance,
							re.branchId
					FROM dictionary.FinancialRegister re WITH(NOLOCK)
						LEFT JOIN finance.FinancialReport fre WITH(NOLOCK) ON re.id = fre.financialRegisterId
						LEFT JOIN document.FinancialDocumentHeader fdh WITH(NOLOCK) ON fre.id  = fdh.financialReportId
						LEFT JOIN finance.Payment p WITH(NOLOCK) ON fdh.id = p.financialDocumentHeaderId
					WHERE re.registerCategory = 0 AND status >= 40
					GROUP BY re.branchId
		)	financeSum ON b.id = financeSum.branchId
		
		LEFT JOIN ( --miesięczna sprzedaż
				SELECT  (sum(l.netValue )) monthNetValue,
						h.branchId
				FROM document.CommercialDocumentHeader h WITH(NOLOCK) 
					JOIN document.CommercialDocumentLine l WITH(NOLOCK) ON h.id = l.CommercialDocumentHeaderId 
					JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id
					LEFT JOIN (		SELECT SUM(ISNULL(value,0)) value , commercialDocumentLineId
									FROM document.CommercialWarehouseValuation cwv WITH(NOLOCK) 
									GROUP BY commercialDocumentLineId
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
					AND ISNULL(xmlOptions.value(''(/root/commercialDocument/@isPrepaymentInvoice)[1]'',''char(6)''),'''') <> ''true''
					AND  YEAR([dbo].[f_reportsSalesDateSelector]( h.issueDate, h.eventDate, dt.documentCategory , dt.symbol )) = year(getdate()) AND MONTH([dbo].[f_reportsSalesDateSelector]( h.issueDate, h.eventDate, dt.documentCategory , dt.symbol )) = MONTH(getdate())
				GROUP BY h.branchId
			) xx ON b.id = xx.branchId
		WHERE symbol NOT IN (''CE'', ''GR'')			
			
--SELECT ''SUMA'',  	SUM(netValue) [Sprzedaż], 
-- REPLACE(CAST(CAST(ROUND((100 * (SUM(netValue)- SUM(cost)) / NULLIF(SUM(netValue), 0)), 2) AS float) AS varchar(100)) + ''%'', ''.'', '','')  [Marża %],
--SUM(cashReportBalance) [Kasa],SUM(monthNetValue) [Sprzedaż miesiac]--,  getdate()  [Data]
--FROM
--(
--	SELECT b.symbol, ISNULL(s.netValue,0) netValue,  ISNULL(z.cost,0) cost, ISNULL(cashReportBalance,0)cashReportBalance, ISNULL(xx.monthNetValue,0) monthNetValue
--	FROM dictionary.Branch b
--		LEFT JOIN ( --sprzedaz bez zamowien
--					SELECT  (sum(l.netValue )) netValue, 
--							h.branchId
--					FROM document.CommercialDocumentHeader h WITH(NOLOCK) 
--						JOIN document.CommercialDocumentLine l WITH(NOLOCK) ON h.id = l.CommercialDocumentHeaderId 
--						JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id
--						JOIN item.Item i ON l.itemId = i.id
--						JOIN dictionary.ItemType it ON i.itemTypeId = it.id	
--					WHERE dt.documentCategory  IN (0,5)
--						AND l.commercialDirection <> 0
--						AND h.status >= 40
--						AND it.name <> ''Prepaid''
--						AND  h.issueDate >= CONVERT(varchar(10),getdate(),120) AND  h.issueDate < CONVERT(varchar(10),DATEADD(d,1,getdate()),120)
--					GROUP BY h.branchId
--			) s ON b.id = s.branchId
--		LEFT JOIN(
--				SELECT SUM(value) cost, branchId
--				FROM (
--					SELECT  -SUM(wl.value* wl.direction) value, 
--							h.branchId
--					FROM document.CommercialDocumentHeader h WITH(NOLOCK) 
--						JOIN document.CommercialDocumentLine l WITH(NOLOCK) ON h.id = l.CommercialDocumentHeaderId 
--						JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id
--						JOIN document.CommercialWarehouseRelation cr  WITH(NOLOCK) ON cr.commercialDocumentLineId = l.id
--						JOIN document.WarehouseDocumentLine wl WITH(NOLOCK) ON cr.warehouseDocumentLineId = wl.id
--					WHERE dt.documentCategory  IN (0,5)
--						AND l.commercialDirection <> 0
--						AND h.status >= 40
--						AND  h.issueDate >= CONVERT(varchar(10),getdate(),120) AND  h.issueDate < CONVERT(varchar(10),DATEADD(d,1,getdate()),120)
--					GROUP BY h.branchId
--					UNION ALL
--					SELECT  -SUM(wl.value * wl.direction)  value,
--							h.branchId
--					FROM document.CommercialDocumentHeader h WITH(NOLOCK) 
--						JOIN document.DocumentRelation dr  WITH(NOLOCK) ON dr.secondCommercialDocumentHeaderId = h.id
--						JOIN document.CommercialDocumentHeader h2 WITH(NOLOCK) ON dr.firstCommercialDocumentHeaderId = h2.id
--						JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h2.documentTypeId = dt.id AND dt.documentCategory  = 13
--						JOIN document.DocumentRelation dr2  WITH(NOLOCK) ON dr2.firstCommercialDocumentHeaderId = h2.id
--						JOIN document.WarehouseDocumentLine wl WITH(NOLOCK) ON ISNULL(dr2.firstWarehouseDocumentHeaderId,dr2.secondWarehouseDocumentHeaderId) = wl.warehouseDocumentHeaderId
--					WHERE h.status >= 40 
--						AND  h.issueDate >= CONVERT(varchar(10),getdate(),120) 
--						AND  h.issueDate < CONVERT(varchar(10),DATEADD(d,1,getdate()),120)
--					GROUP BY h.branchId	
--					UNION ALL
--					SELECT  SUM(dr.decimalValue)  value,
--							h.branchId
--					FROM document.CommercialDocumentHeader h WITH(NOLOCK) 
--						JOIN document.DocumentRelation dr  WITH(NOLOCK) ON dr.secondCommercialDocumentHeaderId = h.id
--						JOIN document.CommercialDocumentHeader h2 WITH(NOLOCK) ON dr.firstCommercialDocumentHeaderId = h2.id
--						JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h2.documentTypeId = dt.id AND dt.documentCategory  = 13
--						JOIN document.DocumentRelation dr2  WITH(NOLOCK) ON dr2.firstCommercialDocumentHeaderId = h2.id
--					WHERE h.status >= 40
--						AND  h2.issueDate >= CONVERT(varchar(10),getdate(),120) AND  h2.issueDate < CONVERT(varchar(10),DATEADD(d,1,getdate()),120)						
--						AND dr2.secondFinancialDocumentHeaderId IS NOT NULL
--					GROUP BY h.branchId
--				) zs 
--			GROUP BY branchId		
--			) z ON b.id = z.branchId
--		LEFT JOIN (	--stan kasy	
--					SELECT  sum(ISNULL(p.amount ,0) * ISNULL(p.direction,0)) cashReportBalance,
--						re.branchId
--					FROM dictionary.FinancialRegister re WITH(NOLOCK)
--						LEFT JOIN finance.FinancialReport fre WITH(NOLOCK) ON re.id = fre.financialRegisterId
--						LEFT JOIN document.FinancialDocumentHeader fdh WITH(NOLOCK) ON fre.id  = fdh.financialReportId
--						LEFT JOIN finance.Payment p WITH(NOLOCK) ON fdh.id = p.financialDocumentHeaderId
--					WHERE re.registerCategory = 0 AND status >= 40
--					GROUP BY re.branchId
--		)	financeSum ON b.id = financeSum.branchId
		
--		LEFT JOIN ( --miesięczna sprzedaż
--				SELECT  sum(l.netValue ) monthNetValue,
--						h.branchId
--				FROM document.CommercialDocumentHeader h WITH(NOLOCK) 
--					JOIN document.CommercialDocumentLine l WITH(NOLOCK) ON h.id = l.CommercialDocumentHeaderId 
--					JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id
--					JOIN item.Item i ON l.itemId = i.id
--					JOIN dictionary.ItemType it ON i.itemTypeId = it.id	
--				WHERE dt.documentCategory  IN (0,5)
--					AND l.commercialDirection <> 0
--					AND h.status >= 40
--					AND it.name <> ''Prepaid''
--					AND  YEAR(h.issueDate) = year(getdate()) AND MONTH(h.issueDate) = MONTH(getdate())
--				GROUP BY h.branchId
--			) xx ON b.id = xx.branchId
--) X 
--		WHERE symbol NOT IN (''CE'', ''GR'')	' 
END
GO

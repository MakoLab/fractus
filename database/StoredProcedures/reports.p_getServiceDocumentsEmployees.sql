/*
name=[reports].[p_getServiceDocumentsEmployees]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Qxyykywmj8Hfb4MX23ZssA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getServiceDocumentsEmployees]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getServiceDocumentsEmployees]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getServiceDocumentsEmployees]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [reports].[p_getServiceDocumentsEmployees]-- ''<root />''
@xmlVar XML
AS
BEGIN
DECLARE @dateFrom varchar(50),
		@dateTo varchar(50),
		@employeeId char(36)
		
SELECT  @dateFrom = NULLIF(x.query(''dateFrom'').value(''.'',''varchar(50)''),''''),
		@dateTo = NULLIF( x.query(''dateTo'').value(''.'',''varchar(50)''),''''),
		@employeeId = NULLIF( x.query(''employeeId'').value(''.'',''char(36)''), '''')
FROM @xmlVar.nodes(''*'') AS a(x)

	
SELECT (
	SELECT ch.issueDate as ''@issueDate'', sh.commercialDocumentHeaderId as ''@serviceId'',  ch.fullNumber as ''@fullNumber'', ch.documentTypeId as ''@documentTypeId'', us as ''@labour'' , tow as ''@materials'',  grossValue as ''@value'' , (	
				SELECT  c.fullName as ''@name'', se.timeFraction as ''@timeFraction'', x.tow *( se.timeFraction /100) as ''@employee_materials'',  x.us *( se.timeFraction /100) AS ''@employee_labour'' ,x.tow as ''@total_materials'', x.us as ''@total_labour'', x.razem * (se.timeFraction /100) as ''@employee_value''
				FROM  service.ServiceHeaderEmployees se WITH(NOLOCK) 
				LEFT JOIN contractor.Contractor c ON se.employeeId = c.id
				LEFT JOIN (
						SELECT  SUM(l.grossValue) AS razem, SUM(l.grossValue * it.isWarehouseStorable) AS tow,  SUM(l.grossValue * (CASE it.isWarehouseStorable WHEN 0 THEN 1 ELSE 0 END) ) as us, commercialDocumentHeaderId as id
						FROM document.CommercialDocumentLine l  WITH(NOLOCK)
							JOIN item.Item i  WITH(NOLOCK) ON l.itemId = i.id
							JOIN dictionary.ItemType it  WITH(NOLOCK) ON i.itemTypeId = it.id
						GROUP BY commercialDocumentHeaderId
						) x ON x.id = ch.id
				WHERE  ch.id = se.serviceHeaderId
					AND (NULLIF(@employeeId, c.id) IS NULL)
				FOR XML PATH(''employee'') ,TYPE ) 
	FROM (
		SELECT h.documentTypeId, SUM(l.grossValue * it.isWarehouseStorable) AS tow,  SUM(l.grossValue * (CASE it.isWarehouseStorable WHEN 0 THEN 1 ELSE 0 END) ) as us, (h.grossValue) grossValue ,commercialDocumentHeaderId as id, h.fullNumber , h.[status], h.issueDate
		FROM document.CommercialDocumentHeader h WITH(NOLOCK) 
			JOIN document.CommercialDocumentLine l  WITH(NOLOCK) ON  h.id = l.commercialDocumentHeaderId
			JOIN item.Item i  WITH(NOLOCK) ON l.itemId = i.id
			JOIN dictionary.ItemType it  WITH(NOLOCK) ON i.itemTypeId = it.id
		WHERE [status] > 0
		GROUP BY commercialDocumentHeaderId, h.documentTypeId,  h.fullNumber, h.grossValue, h.[status], h.issueDate
	) ch 
		JOIN service.ServiceHeader sh WITH(NOLOCK) ON ch.id = sh.commercialDocumentHeaderId
	WHERE ch.status > 0
		AND ( (@dateFrom IS NOT NULL AND ch.issueDate >= @dateFrom) OR @dateFrom IS NULL)
		AND ( (@dateTo IS NOT NULL AND ch.issueDate < DATEADD(dd,1,CAST(LEFT(@dateTo,10) as datetime))) OR @dateTo IS NULL)
		AND ( ( @employeeId IS NOT NULL AND sh.commercialDocumentHeaderId IN (SELECT serviceHeaderId FROM service.ServiceHeaderEmployees WHERE employeeId = @employeeId ) ) OR @employeeId IS NULL)
	ORDER BY issueDate DESC
	FOR XML PATH(''serviceDocument''), TYPE
) FOR XML PATH(''root''), TYPE 

END
' 
END
GO

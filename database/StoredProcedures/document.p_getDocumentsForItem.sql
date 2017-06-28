/*
name=[document].[p_getDocumentsForItem]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
WwY6USHLkxTrCCwFcKmtjw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDocumentsForItem]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getDocumentsForItem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDocumentsForItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_getDocumentsForItem]
@xmlVar XML
AS

BEGIN
	DECLARE 
	@itemId UNIQUEIDENTIFIER,
	@dateFrom DATETIME,
	@dateTo DATETIME,
	@documentTypeId UNIQUEIDENTIFIER

	SELECT 
	@itemId = x.query(''itemId'').value(''.'',''char(36)''),
	@dateFrom = NULLIF(x.query(''dateFrom'').value(''.'',''datetime''),''''),
	@dateTo = NULLIF(x.query(''dateTo'').value(''.'',''datetime''),''''),
	@documentTypeId = NULLIF(x.query(''documentTypeId[1]'').value(''.'',''char(36)''),'''')
	FROM @xmlVar.nodes(''params'') AS a (x)

SELECT (
	SELECT * FROM (
		SELECT h.id AS ''@id'',  documentTypeId AS ''@documentTypeId'', [status] AS ''@status'', issueDate AS ''@issueDate'', fullNumber AS ''@fullNumber'', lines AS ''@lines'', quantity AS ''@quantity'', [value] AS ''@netValue'',NULL  AS ''@grossValue'',documentCurrencyId  AS ''@documentCurrencyId'', contrx.fullName AS ''@contractor''
		FROM (
			SELECT warehouseDocumentHeaderId, COUNT(id) lines, SUM(quantity * direction ) quantity 
			FROM document.WarehouseDocumentLine
			WHERE   itemId = @itemId
			GROUP BY warehouseDocumentHeaderId
			) l
			JOIN document.WarehouseDocumentHeader h ON h.id = l.warehouseDocumentHeaderId
			LEFT  JOIN [contractor].[contractor] contrx ON h.contractorId = contrx.id
		WHERE h.status >= 20 AND  ( @dateFrom IS NULL OR (@dateFrom IS NOT NULL AND h.issueDate >= @dateFrom AND h.issueDate <= @dateTo) )
				AND ( @documentTypeId IS NULL OR h.documentTypeId IN ( SELECT NULLIF(x.query(''documentTypeId'').value(''.'',''char(36)''),'''')
																	FROM @xmlVar.nodes(''params'') AS a (x) ))
		UNION ALL
		
		SELECT c.id AS ''@id'',  documentTypeId AS ''@documentTypeId'', [status] AS ''@status'', issueDate AS ''@issueDate'', fullNumber AS ''@fullNumber'', lines AS ''@lines'', quantity AS ''@quantity'', netValue AS ''@netValue'', grossValue AS ''@grossValue'',documentCurrencyId  AS ''@documentCurrencyId'', contrx.fullName AS ''@contractor''
		FROM  (
			SELECT commercialDocumentHeaderId, COUNT(id) lines, SUM(quantity * (commercialDirection + orderDirection)) quantity 
			FROM document.CommercialDocumentLine 
			WHERE itemId = @itemId
			GROUP BY commercialDocumentHeaderId
			) l 
			JOIN document.CommercialDocumentHeader c ON c.id = l.commercialDocumentHeaderId
			LEFT  JOIN [contractor].[contractor] contrx ON c.contractorId = contrx.id
		WHERE c.status >= 20 AND ( @dateFrom IS NULL OR (@dateFrom IS NOT NULL AND c.issueDate >= @dateFrom AND c.issueDate <= @dateTo) )
				AND ( @documentTypeId IS NULL OR c.documentTypeId IN ( SELECT NULLIF(x.query(''documentTypeId'').value(''.'',''char(36)''),'''')
																	FROM @xmlVar.nodes(''params'') AS a (x) ))
	) [documents]
	ORDER BY ''@issueDate'' DESC
	FOR XML PATH(''document''), TYPE
)
FOR XML PATH(''documents''), TYPE

END
' 
END
GO

/*
name=[document].[p_getDocumentsForContractor]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
69LSulYf/U/L9quassjFqw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDocumentsForContractor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getDocumentsForContractor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDocumentsForContractor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [document].[p_getDocumentsForContractor]
@xmlVar XML
AS

BEGIN
DECLARE 
@contractorId UNIQUEIDENTIFIER,
@dateFrom DATETIME,
@dateTo DATETIME,
@documentTypeId UNIQUEIDENTIFIER


SELECT 
@contractorId = x.query(''contractorId'').value(''.'',''char(36)''),
@dateFrom = NULLIF(x.query(''dateFrom'').value(''.'',''datetime''),''''),
@dateTo = NULLIF(x.query(''dateTo'').value(''.'',''datetime''),''''),
@documentTypeId = NULLIF(x.query(''documentTypeId[1]'').value(''.'',''char(36)''),'''')
FROM @xmlVar.nodes(''params'') AS a (x)


SELECT (
	SELECT * FROM (
		SELECT id AS ''@id'',  documentTypeId AS ''@documentTypeId'', [status] AS ''@status'', issueDate AS ''@issueDate'', fullNumber AS ''@fullNumber'', [value] AS ''@netValue'',NULL  AS ''@grossValue'', documentCurrencyId AS ''@documentCurrencyId''
		FROM document.WarehouseDocumentHeader h
		WHERE h.status >= 20 AND  h.contractorId = @contractorId
			AND ( @dateFrom IS NULL OR (@dateFrom IS NOT NULL AND h.issueDate >= @dateFrom AND h.issueDate <= @dateTo) )
			AND ( @documentTypeId IS NULL OR h.documentTypeId IN ( SELECT NULLIF(x.query(''documentTypeId'').value(''.'',''char(36)''),'''')
																	FROM @xmlVar.nodes(''params'') AS a (x) ))
		UNION
		SELECT id AS ''@id'',  documentTypeId AS ''@documentTypeId'', [status] AS ''@status'', issueDate AS ''@issueDate'', fullNumber AS ''@fullNumber'', netValue AS ''@netValue'', grossValue AS ''@grossValue'',documentCurrencyId  AS ''@documentCurrencyId''
		FROM document.CommercialDocumentHeader c
		WHERE  c.status >= 20 AND  c.contractorId = @contractorId
			AND ( @dateFrom IS NULL OR (@dateFrom IS NOT NULL AND c.issueDate >= @dateFrom AND c.issueDate <= @dateTo) )
			AND ( @documentTypeId IS NULL OR c.documentTypeId IN ( SELECT NULLIF(x.query(''documentTypeId'').value(''.'',''char(36)''),'''')
																	FROM @xmlVar.nodes(''params'') AS a (x) ))
		UNION
		SELECT DISTINCT
			WH2.id AS ''@id'', WH2.documentTypeId AS ''@documentTypeId'', [status] AS ''@status'',  WH2.issueDate AS ''@issueDate'', WH2.fullNumber AS ''@fullNumber'',  NULL AS ''@netValue'', amount AS ''@grossValue'', documentCurrencyId  AS ''@documentCurrencyId ''
		FROM document.FinancialDocumentHeader WH2 WITH (NOLOCK) 
		WHERE WH2.contractorId = @contractorId AND WH2.status >= 20 AND ( @dateFrom IS NULL OR (@dateFrom IS NOT NULL AND WH2.issueDate >= @dateFrom AND WH2.issueDate <= @dateTo) )
			AND ( @documentTypeId IS NULL OR WH2.documentTypeId IN ( SELECT NULLIF(x.query(''documentTypeId'').value(''.'',''char(36)''),'''')
																	FROM @xmlVar.nodes(''params'') AS a (x) ))
		) AS [document]
		ORDER BY ''@issueDate'' DESC
		FOR XML PATH(''document''), TYPE 
) FOR XML PATH(''documents''), TYPE
END
' 
END
GO

/*
name=[accounting].[p_getExportStatus]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Zx4YQ3C7vXu5XJdimkHLKw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getExportStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_getExportStatus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getExportStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [accounting].[p_getExportStatus]
( 
	@xmlVar xml
)
AS

BEGIN
	SELECT 
		(
			SELECT documentId,fullNumber,issueDate,documentTypeId
			FROM document.ExportStatus s 
			LEFT JOIN 
			(
				SELECT id, fullNumber, issueDate, documentTypeId
				FROM document.CommercialDocumentHeader 
				UNION
				SELECT id, fullNumber, issueDate, documentTypeId
				FROM document.FinancialDocumentHeader 
				UNION
				SELECT id, fullNumber, openingDate, null
				FROM finance.financialReport 
				UNION
				SELECT p.id, c.fullNumber, c.issueDate, c.documentTypeId
				FROM finance.Payment p 
					JOIN document.CommercialDocumentHeader c ON p.commercialDocumentHeaderId = c.id
			) h ON s.documentId = h.id 
			FOR XML PATH(''document''), TYPE)
	FOR XML PATH(''root'');
END
' 
END
GO

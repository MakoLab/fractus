/*
name=[document].[p_getCommercialCorrectiveDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
VImKPGmlaMhaY0qIn4+wHQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCommercialCorrectiveDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getCommercialCorrectiveDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCommercialCorrectiveDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getCommercialCorrectiveDocuments] 
@commercialDocumentHeaderId uniqueidentifier
AS
BEGIN

DECLARE @x XML 
SELECT @x = (
SELECT id FROM (
	SELECT DISTINCT l2.commercialDocumentHeaderId id, h2.creationDate, h2.issueDate
	FROM document.CommercialDocumentLine l1 
		JOIN document.CommercialDocumentHeader h1  ON l1.commercialDocumentHeaderId = h1.id
		JOIN document.CommercialDocumentLine l2 ON  l1.id = l2.initialCommercialDocumentLineId
		JOIN document.CommercialDocumentHeader h2  ON l2.commercialDocumentHeaderId = h2.id
	WHERE l1.commercialDocumentHeaderId = @commercialDocumentHeaderId AND h2.status >= 40
) [document] 
ORDER BY issueDate, creationDate
FOR XML AUTO , TYPE
)	

SELECT ISNULL(@x,'''') FOR XML PATH(''root'') , TYPE
END
' 
END
GO

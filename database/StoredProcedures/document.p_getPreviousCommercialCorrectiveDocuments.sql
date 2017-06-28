/*
name=[document].[p_getPreviousCommercialCorrectiveDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
VHRPww34o9lri6zh4HkoUg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getPreviousCommercialCorrectiveDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getPreviousCommercialCorrectiveDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getPreviousCommercialCorrectiveDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [document].[p_getPreviousCommercialCorrectiveDocuments] 
@commercialDocumentHeaderId UNIQUEIDENTIFIER
AS

BEGIN

	DECLARE @x XML
	SELECT @x = (
	SELECT commercialDocumentHeaderId id FROM (
		SELECT DISTINCT l2.commercialDocumentHeaderId commercialDocumentHeaderId, h2.issueDate, h2.creationDate,   h2.number
		FROM document.CommercialDocumentLine l 
			JOIN document.CommercialDocumentHeader h ON h.id = l.commercialDocumentHeaderId
			JOIN document.CommercialDocumentLine l2 ON l.initialCommercialDocumentLineId = l2.initialCommercialDocumentLineId
			JOIN document.CommercialDocumentHeader h2 ON h2.id = l2.commercialDocumentHeaderId
		WHERE l.commercialDocumentHeaderId = @commercialDocumentHeaderId --AND h2.status >= 40
			AND h2.issueDate < h.issueDate
		UNION 
		SELECT l2.commercialDocumentHeaderId commercialDocumentHeaderId,  h2.issueDate , h2.creationDate, h2.number
		FROM document.CommercialDocumentLine l
			JOIN document.CommercialDocumentLine l2 ON l.initialCommercialDocumentLineId = l2.id
			JOIN document.CommercialDocumentHeader h2 ON h2.id = l2.commercialDocumentHeaderId
		WHERE l.commercialDocumentHeaderId = @commercialDocumentHeaderId  
	) [document]
	ORDER BY  issueDate, creationDate,  number
	FOR XML AUTO, TYPE
	)


SELECT ISNULL(@x,'''') FOR XML PATH(''root''), TYPE
END
' 
END
GO

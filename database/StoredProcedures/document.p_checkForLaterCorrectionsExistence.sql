/*
name=[document].[p_checkForLaterCorrectionsExistence]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
gpMv1c4MgIpY6rO0VDhAUQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkForLaterCorrectionsExistence]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_checkForLaterCorrectionsExistence]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkForLaterCorrectionsExistence]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_checkForLaterCorrectionsExistence] 
@documentId UNIQUEIDENTIFIER
AS

BEGIN

IF EXISTS (
	SELECT * 
	FROM document.CommercialDocumentLine ll
		JOIN document.CommercialDocumentHeader hh ON ll.commercialDocumentHeaderId = hh.id
	WHERE correctedCommercialDocumentLineId IN (
		SELECT l.id 
		FROM document.CommercialDocumentLine l
			JOIN document.CommercialDocumentHeader h ON l.commercialDocumentHeaderId = h.id
		WHERE commercialDocumentHeaderId = @documentId AND h.status >= 40 )
		AND hh.status >= 40 AND ll.commercialDocumentHeaderId <>  @documentId)
	SELECT CAST( ''<root>true</root>'' AS XML ) xml
ELSE
	SELECT CAST( ''<root>false</root>'' AS XML ) xml

END
' 
END
GO

/*
name=[document].[p_getCorrectiveCommercialDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
vcvaj828SvTwXNrQN3DApw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCorrectiveCommercialDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getCorrectiveCommercialDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCorrectiveCommercialDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getCorrectiveCommercialDocuments]
@xmlVar XML
AS
BEGIN
	DECLARE @documentId UNIQUEIDENTIFIER

	SELECT
		@documentId = NULLIF(@xmlVar.query(''/*/documentId'').value(''.'',''char(36)''),'''')

	SELECT (
		SELECT * FROM (

--			SELECT DISTINCT
--				CH.fullNumber AS ''@fullNumber'', CH.id AS ''@id'', CH.issueDate AS ''@issueDate'', CH.documentTypeId AS ''@documentTypeId''
--			FROM document.CommercialDocumentLine CL WITH (NOLOCK) 
--			JOIN document.CommercialDocumentHeader CH WITH (NOLOCK) ON CL.commercialDocumentHeaderId = CH.id
--			WHERE
--				CL.correctedCommercialDocumentLineId IN (
--						SELECT id 
--						FROM document.CommercialDocumentLine WITH (NOLOCK) 
--						WHERE commercialDocumentHeaderId = @documentId
--						)
--UNION
			SELECT DISTINCT
				CH.fullNumber AS ''@fullNumber'', CH.id AS ''@id'', CH.issueDate AS ''@issueDate'', CH.documentTypeId AS ''@documentTypeId''
			FROM document.CommercialDocumentLine CL WITH (NOLOCK) 
			JOIN document.CommercialDocumentHeader CH WITH (NOLOCK) ON CL.commercialDocumentHeaderId = CH.id
			WHERE
				CH.id IN (
						SELECT commercialDocumentHeaderId 
						FROM document.[p_getCompleteCommercialCorective](@documentId) f
						WHERE commercialDocumentHeaderId <> @documentId
						) AND CH.status >= 40
-- Wykomentowane -- bugTracker id 177
--UNION
--			SELECT DISTINCT
--				CH.fullNumber AS ''@fullNumber'', CH.id AS ''@id'', CH.issueDate AS ''@issueDate'', CH.documentTypeId AS ''@documentTypeId''
--			FROM document.CommercialDocumentHeader CH WITH (NOLOCK) 
--			WHERE id = @documentId
		) x
		FOR XML PATH(''document'') , TYPE 
	) FOR XML PATH(''relatedDocuments''), TYPE


END
' 
END
GO

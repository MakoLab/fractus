/*
name=[document].[p_getCompleteCommercialCorective]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
+4741RyzW9Z3MAEI9LaVbA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCompleteCommercialCorective]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [document].[p_getCompleteCommercialCorective]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCompleteCommercialCorective]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [document].[p_getCompleteCommercialCorective](@commercialDocumentHeaderId UNIQUEIDENTIFIER)
RETURNS  @param TABLE  (
	commercialDocumentHeaderId UNIQUEIDENTIFIER
) 
AS 
BEGIN

	DECLARE @tmp TABLE (commercialDocumentHeaderId UNIQUEIDENTIFIER, lineId UNIQUEIDENTIFIER, correctedCommercialDocumentLineId UNIQUEIDENTIFIER )

	INSERT INTO @tmp (commercialDocumentHeaderId, lineId, correctedCommercialDocumentLineId)
	SELECT h.id, l.id, l.correctedCommercialDocumentLineId
	FROM document.CommercialDocumentHeader h WITH(NOLOCK)
		JOIN document.CommercialDocumentLine l WITH(NOLOCK) ON h.id = l.commercialDocumentHeaderId 
		WHERE h.id = @commercialDocumentHeaderId


	WHILE @@rowcount > 0 
	BEGIN

	INSERT INTO @tmp (commercialDocumentHeaderId, lineId, correctedCommercialDocumentLineId)
	SELECT h.id, l.id, l.correctedCommercialDocumentLineId
	FROM document.CommercialDocumentHeader h WITH(NOLOCK)
		JOIN document.CommercialDocumentLine l WITH(NOLOCK) ON h.id = l.commercialDocumentHeaderId 
		WHERE ( l.correctedCommercialDocumentLineId IN (SELECT lineId FROM @tmp) OR l.id IN ( SELECT correctedCommercialDocumentLineId FROM @tmp)  )
			AND l.id NOT IN (SELECT lineId FROM @tmp)
	END

	INSERT INTO @param (commercialDocumentHeaderId)
	SELECT DISTINCT commercialDocumentHeaderId FROM @tmp

RETURN
END
' 
END

GO

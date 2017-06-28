/*
name=[document].[p_getCommercialDocumentLines]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ZCm30plhOzc1gX//wXbLDQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCommercialDocumentLines]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getCommercialDocumentLines]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCommercialDocumentLines]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getCommercialDocumentLines] 
@xmlVar XML
AS
BEGIN
DECLARE @tmp_ TABLE (id uniqueidentifier)


INSERT INTO @tmp_ (id)
SELECT x.value(''.'',''char(36)'')
FROM @xmlVar.nodes(''/root/id'') AS a( x )

SELECT (
	SELECT (
		SELECT *, h.netCalculationType   
		FROM document.CommercialDocumentLine l
			JOIN document.CommercialDocumentHeader h ON l.commercialDocumentHeaderId = h.id
		WHERE l.id IN (SELECT id FROM @tmp_)
		FOR XML PATH(''entry''), TYPE
	) FOR XML PATH(''commercialDocumentLine''), TYPE
) FOR XML PATH(''root''), TYPE

END
' 
END
GO

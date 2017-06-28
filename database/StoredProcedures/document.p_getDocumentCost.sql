/*
name=[document].[p_getDocumentCost]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
/SC+/P8xb2KAj2a6petTnA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDocumentCost]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getDocumentCost]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDocumentCost]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getDocumentCost] 
@commercialDocumentHeaderId  uniqueidentifier
AS
	BEGIN
		SELECT (
			SELECT l.id AS ''@id'', SUM(v.quantity) AS ''@quantity'', sum(v.value) ''@value''
			FROM document.CommercialDocumentLine l WITH(NOLOCK) 
				LEFT JOIN document.CommercialWarehouseValuation v  WITH(NOLOCK) ON  v.commercialDocumentLineId = l.id
			WHERE l.commercialDocumentHeaderId = @commercialDocumentHeaderId
			GROUP BY l.id 
			FOR XML PATH(''line''),TYPE 
				)
		FOR XML PATH(''root''),TYPE	
	END
' 
END
GO

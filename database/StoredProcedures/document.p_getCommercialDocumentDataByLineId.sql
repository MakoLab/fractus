/*
name=[document].[p_getCommercialDocumentDataByLineId]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
3hhL2DFgksATfJWJ2QE1lA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCommercialDocumentDataByLineId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getCommercialDocumentDataByLineId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCommercialDocumentDataByLineId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getCommercialDocumentDataByLineId] @id UNIQUEIDENTIFIER
AS
	SELECT @id = commercialDocumentHeaderId FROM document.CommercialDOcumentLine WHERE id = @id
	EXEC [document].[p_getCommercialDocumentData] @id
' 
END
GO

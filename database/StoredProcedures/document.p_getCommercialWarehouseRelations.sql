/*
name=[document].[p_getCommercialWarehouseRelations]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
cY0I6cO4O1r1r/e0F7fDmw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCommercialWarehouseRelations]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getCommercialWarehouseRelations]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCommercialWarehouseRelations]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getCommercialWarehouseRelations]
@xmlVar XML
AS
BEGIN
	DECLARE @warehouseDocumentId char(36), @commercialDocumentId char(36)

	SELECT
		@warehouseDocumentId = @xmlVar.query(''/*/warehouseDocumentId'').value(''.'',''char(36)''),
		@commercialDocumentId = @xmlVar.query(''/*/commercialDocumentId'').value(''.'',''char(36)'')

	IF (@warehouseDocumentId <> '''')
		SELECT (
			SELECT DISTINCT
				CH.fullNumber AS ''@fullNumber'', CH.id AS ''@id'', CH.issueDate AS ''@issueDate'', CH.documentTypeId AS ''@documentTypeId''
			FROM document.WarehouseDocumentHeader WH WITH (NOLOCK)
			JOIN document.WarehouseDocumentLine WL WITH (NOLOCK) ON WL.warehouseDocumentHeaderId = WH.id
			JOIN document.CommercialWarehouseRelation CWR WITH (NOLOCK) ON CWR.warehouseDocumentLineId = WL.id
			JOIN document.CommercialDocumentLine CL WITH (NOLOCK) ON CL.id = CWR.commercialDocumentLineId
			JOIN document.CommercialDocumentHeader CH WITH (NOLOCK) ON CL.commercialDocumentHeaderId = CH.id
			WHERE
				WH.id = CAST(NULLIF(@warehouseDocumentId, '''') AS uniqueidentifier)
			FOR XML PATH(''document'') , TYPE 
		) FOR XML PATH(''relatedDocuments''), TYPE
	ELSE IF (@commercialDocumentId <> '''')
		SELECT (
			SELECT DISTINCT
				WH.fullNumber AS ''@fullNumber'', WH.id AS ''@id'', WH.issueDate AS ''@issueDate'', WH.documentTypeId AS ''@documentTypeId''
			FROM document.WarehouseDocumentHeader WH WITH (NOLOCK)
			JOIN document.WarehouseDocumentLine WL WITH (NOLOCK) ON WL.warehouseDocumentHeaderId = WH.id
			JOIN document.CommercialWarehouseRelation CWR WITH (NOLOCK) ON CWR.warehouseDocumentLineId = WL.id
			JOIN document.CommercialDocumentLine CL WITH (NOLOCK) ON CL.id = CWR.commercialDocumentLineId
			JOIN document.CommercialDocumentHeader CH WITH (NOLOCK) ON CL.commercialDocumentHeaderId = CH.id
			WHERE
				CH.id = CAST(NULLIF(@commercialDocumentId, '''') AS uniqueidentifier)
			FOR XML PATH(''document'') , TYPE 
		) FOR XML PATH(''relatedDocuments''), TYPE

/*
	Procedure by gdereck - co zlego to nie Czarek ;-)
*/
END
' 
END
GO

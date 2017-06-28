/*
name=[document].[p_getRelatedWarehouseDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
oL2990uNjczkUENBEDdHeA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getRelatedWarehouseDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getRelatedWarehouseDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getRelatedWarehouseDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getRelatedWarehouseDocuments]
@xmlVar XML
AS
BEGIN
	DECLARE @incomeDocumentId char(36), @outcomeDocumentId char(36), @documentFieldId uniqueidentifier

	SELECT
		@incomeDocumentId = @xmlVar.query(''/*/incomeDocumentId'').value(''.'',''char(36)''),
		@outcomeDocumentId = @xmlVar.query(''/*/outcomeDocumentId'').value(''.'',''char(36)'')

SELECT @documentFieldId = id FROM dictionary.DocumentField WHERE [name] = ''ShiftDocumentAttribute_OppositeDocumentId''

	IF (@incomeDocumentId <> '''')
		SELECT (
		SELECT * FROM (
			SELECT DISTINCT
				WH2.fullNumber AS ''@fullNumber'', WH2.id AS ''@id'', WH2.issueDate AS ''@issueDate'', WH2.documentTypeId AS ''@documentTypeId''
			FROM document.warehousedocumentheader WH1 WITH (NOLOCK)
			JOIN document.warehousedocumentline WL1 WITH (NOLOCK) ON WL1.warehousedocumentheaderid = WH1.id
			JOIN document.incomeoutcomerelation IOR WITH (NOLOCK) ON IOR.incomewarehousedocumentlineid = WL1.id
			JOIN document.warehousedocumentline WL2 WITH (NOLOCK) ON WL2.id = IOR.outcomewarehousedocumentlineid
			JOIN document.warehousedocumentheader WH2 WITH (NOLOCK) ON WL2.warehousedocumentheaderid = WH2.id
			WHERE
				WH1.id = CAST(@incomeDocumentId AS uniqueidentifier) AND WH2.status >= 40
UNION
			SELECT DISTINCT
				WH2.fullNumber AS ''@fullNumber'', WH2.id AS ''@id'', WH2.issueDate AS ''@issueDate'', WH2.documentTypeId AS ''@documentTypeId''
			FROM document.warehousedocumentheader WH1 WITH (NOLOCK)
			JOIN document.warehousedocumentline WL1 WITH (NOLOCK) ON WL1.warehousedocumentheaderid = WH1.id
			JOIN document.warehousedocumentline WL2 WITH (NOLOCK) ON WL2.correctedWarehouseDocumentLineId = WL1.id
			JOIN document.warehousedocumentheader WH2 WITH (NOLOCK) ON WL2.warehousedocumentheaderid = WH2.id
			WHERE
				WH1.id = CAST(@incomeDocumentId AS uniqueidentifier) AND WH2.status >= 40
UNION
			SELECT DISTINCT
				WH2.fullNumber AS ''@fullNumber'', WH2.id AS ''@id'', WH2.issueDate AS ''@issueDate'', WH2.documentTypeId AS ''@documentTypeId''
			FROM document.warehousedocumentheader WH1 WITH (NOLOCK)
			JOIN document.warehousedocumentline WL1 WITH (NOLOCK) ON WL1.warehousedocumentheaderid = WH1.id
			JOIN document.warehousedocumentline WL2 WITH (NOLOCK) ON WL2.id = WL1.correctedWarehouseDocumentLineId
			JOIN document.warehousedocumentheader WH2 WITH (NOLOCK) ON WL2.warehousedocumentheaderid = WH2.id
			WHERE
				WH1.id = CAST(@incomeDocumentId AS uniqueidentifier) AND WH2.status >= 40

UNION
			SELECT DISTINCT 
				WH2.fullNumber AS ''@fullNumber'', WH2.id AS ''@id'', WH2.issueDate AS ''@issueDate'', WH2.documentTypeId AS ''@documentTypeId''
			FROM document.warehousedocumentheader WH1 WITH (NOLOCK) 
				JOIN document.DocumentAttrValue dav WITH(NOLOCK) ON dav.documentFieldId = @documentFieldId AND WH1.id = dav.warehouseDocumentHeaderId 
			    JOIN document.warehousedocumentheader WH2 WITH (NOLOCK) ON NULLIF(dav.textValue,'''') = WH2.id
			WHERE WH1.id = CAST(@incomeDocumentId AS uniqueidentifier) AND WH2.status >= 40
					

) x
ORDER BY  ''@issueDate'' DESC
			FOR XML PATH(''warehouseDocument'') , TYPE 
		) FOR XML PATH(''relatedDocuments''), TYPE
	ELSE IF (@outcomeDocumentId <> '''')
		SELECT (
SELECT * FROM (
			SELECT DISTINCT
				WH1.fullNumber AS ''@fullNumber'', WH1.id AS ''@id'', WH1.issueDate AS ''@issueDate'', WH1.documentTypeId AS ''@documentTypeId''
			FROM document.warehousedocumentheader WH1 WITH (NOLOCK)
			JOIN document.warehousedocumentline WL1 WITH (NOLOCK) ON WL1.warehousedocumentheaderid = WH1.id
			JOIN document.incomeoutcomerelation IOR WITH (NOLOCK) ON IOR.incomewarehousedocumentlineid = WL1.id
			JOIN document.warehousedocumentline WL2 WITH (NOLOCK) ON WL2.id = IOR.outcomewarehousedocumentlineid
			JOIN document.warehousedocumentheader WH2 WITH (NOLOCK) ON WL2.warehousedocumentheaderid = WH2.id
			WHERE
				WH2.id = CAST(@outcomeDocumentId AS uniqueidentifier) AND WH1.status >= 40
UNION
			SELECT DISTINCT
				WH2.fullNumber AS ''@fullNumber'', WH2.id AS ''@id'', WH2.issueDate AS ''@issueDate'', WH2.documentTypeId AS ''@documentTypeId''
			FROM document.warehousedocumentheader WH1 WITH (NOLOCK)
			JOIN document.warehousedocumentline WL1 WITH (NOLOCK) ON WL1.warehousedocumentheaderid = WH1.id
			JOIN document.warehousedocumentline WL2 WITH (NOLOCK) ON WL2.correctedWarehouseDocumentLineId = WL1.id
			JOIN document.warehousedocumentheader WH2 WITH (NOLOCK) ON WL2.warehousedocumentheaderid = WH2.id
			WHERE
				WH1.id = CAST(@outcomeDocumentId AS uniqueidentifier) AND WH2.status >= 40
UNION
			SELECT DISTINCT
				WH2.fullNumber AS ''@fullNumber'', WH2.id AS ''@id'', WH2.issueDate AS ''@issueDate'', WH2.documentTypeId AS ''@documentTypeId''
			FROM document.warehousedocumentheader WH1 WITH (NOLOCK)
			JOIN document.warehousedocumentline WL1 WITH (NOLOCK) ON WL1.warehousedocumentheaderid = WH1.id
			JOIN document.warehousedocumentline WL2 WITH (NOLOCK) ON WL2.id = WL1.correctedWarehouseDocumentLineId
			JOIN document.warehousedocumentheader WH2 WITH (NOLOCK) ON WL2.warehousedocumentheaderid = WH2.id
			WHERE
				WH1.id = CAST(@outcomeDocumentId AS uniqueidentifier) AND WH2.status >= 40
UNION
			SELECT DISTINCT 
				WH2.fullNumber AS ''@fullNumber'', WH2.id AS ''@id'', WH2.issueDate AS ''@issueDate'', WH2.documentTypeId AS ''@documentTypeId''
			FROM document.warehousedocumentheader WH1 WITH (NOLOCK) 
				JOIN document.DocumentAttrValue dav WITH(NOLOCK) ON dav.documentFieldId = @documentFieldId AND WH1.id = dav.warehouseDocumentHeaderId 
			    JOIN document.warehousedocumentheader WH2 WITH (NOLOCK) ON  NULLIF(dav.textValue,'''') = WH2.id
			WHERE WH1.id = CAST(@outcomeDocumentId AS uniqueidentifier) AND WH2.status >= 40
					AND dav.documentFieldId = @documentFieldId

)x
ORDER BY  ''@issueDate'' DESC
			FOR XML PATH(''warehouseDocument'') , TYPE 
		) FOR XML PATH(''relatedDocuments''), TYPE


/*
	Procedure by gdereck - co zlego to nie Czarek ;-)

	exec document.p_getRelatedWarehouseDocuments @xmlVar =
		''<root><incomeDocumentId>B450FAD7-CC80-42E6-A312-DB9137AA79BC</incomeDocumentId></root>''

	exec document.p_getRelatedWarehouseDocuments @xmlVar =
		''<root><outcomeDocumentId>FE295C16-84D1-4F81-B387-73E5724809F9</outcomeDocumentId></root>''
*/
END
' 
END
GO

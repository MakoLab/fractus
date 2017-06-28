/*
name=[document].[p_getTechnologiesNames]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
xYo7BAkQOaDwXuF4ymj3+g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getTechnologiesNames]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getTechnologiesNames]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getTechnologiesNames]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_getTechnologiesNames]
@xmlVar XML
AS
BEGIN

	DECLARE @itemId UNIQUEIDENTIFIER,  @procedure varchar(500)

	DECLARE @tmp TABLE ( id char(36))
	

	IF EXISTS (SELECT id FROM configuration.Configuration WHERE textValue = ''custom.p_getCommercialDocumentData'')
	 BEGIN
		SELECT @procedure = ''EXEC custom.p_getCommercialDocumentData '''''' + CAST(@xmlVar as varchar(max))+ ''''''''
		EXEC ( @procedure )
		RETURN 0;
	 END

	INSERT INTO @tmp
	SELECT x.value(''(@id)[1]'',''char(36)'')
	FROM @xmlVar.nodes(''root/technology'') AS a(x)
	
	

	SELECT (
		SELECT distinct h.id ''@id'', dv.textValue ''@technologyName''
		FROM document.CommercialDOcumentHeader h WITH(NOLOCK)
			JOIN @tmp t ON h.id = t.id
			JOIN document.DocumentAttrValue dv WITH(NOLOCK) ON h.id = dv.commercialDocumentHeaderId
			JOIN dictionary.DocumentField dff  WITH(NOLOCK) ON dv.documentFieldId = dff.id AND dff.name = ''Attribute_ProductionTechnologyName''
		FOR XML PATH(''technology''),TYPE )
		FOR XML PATH(''root''),TYPE

END
' 
END
GO

/*
name=[document].[p_getTechnologyByItem]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
MKmvi99Lza1oRmeZ4esO+w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getTechnologyByItem]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getTechnologyByItem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getTechnologyByItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_getTechnologyByItem]
@xmlVar XML
AS
BEGIN

DECLARE @itemId UNIQUEIDENTIFIER , @procedure varchar(200)

SELECT @itemId = @xmlVar.value(''itemId[1]'',''char(36)'')

	/*Sprawdzenie, czy jest procedura customowa do indeksacji - jeśli jest to ją wywołujemy*/	
	IF  (SELECT xmlValue.value(''(root/indexing/object[@name="item"]/customProcedures/@update)[1]'',''varchar(50)'') 
		FROM configuration.Configuration 
		WHERE [key] like ''Dictionary.configuration'')  IS NOT NULL
		BEGIN
				SELECT @procedure = ''EXEC '' + textValue +  '' '''''' + CAST(@itemId AS varchar(36)) + ''''''''
				FROM configuration.Configuration 
				WHERE [key] like ''custom.p_getTechnologyByItem''
				EXECUTE(@procedure)
				PRINT @procedure
				RETURN 0;
		END
	
	ELSE
		SELECT (
		SELECT distinct h.id ''@id'', dv.textValue ''@technologyName''
		FROM document.COmmercialDOcumentHeader h 
			JOIN document.COmmercialDOcumentLine l ON h.id = l.commercialDocumentHeaderId
			LEFT JOIN document.DocumentLineAttrValue dav ON dav.commercialDocumentLineId = l.id AND dav.documentFieldId = (SELECT id FROM dictionary.DocumentField df WHERE df.name = ''LineAttribute_ProductionItemType'')
			LEFT JOIN document.DocumentAttrValue dv ON h.id = dv.commercialDocumentHeaderId AND dv.documentFieldId = (SELECT id FROM dictionary.DocumentField dff WHERE dff.name = ''Attribute_ProductionTechnologyName'' )
		WHERE dav.textValue = ''product'' AND l.itemId = @itemId AND h.status >= 20
		FOR XML PATH(''technology''),TYPE )
	FOR XML PATH(''root''),TYPE


END
' 
END
GO

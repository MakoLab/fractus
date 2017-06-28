/*
name=[tools].[p_exportMB]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Wxfw54ECeavsomhvR5R8Lw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_exportMB]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_exportMB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_exportMB]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tools].[p_exportMB] 
AS
BEGIN
	SELECT (
		SELECT ISNULL(
				ISNULL (
						(	SELECT a.textValue
							FROM document.DocumentAttrValue a 
								JOIN dictionary.DocumentField f ON a.documentFieldId = f.id 
							WHERE f.name = ''Attribute_SupplierDocumentNumber''
								AND a.commercialDocumentHeaderId = h.id
						),
						(	SELECT a.textValue
							FROM document.DocumentAttrValue a 
								JOIN dictionary.DocumentField f ON a.documentFieldId = f.id 
							WHERE f.name = ''Attribute_Remarks''
								AND a.commercialDocumentHeaderId = h.id
						)
					   )
				, h.fullNumber) as ''@fullNumber'', netValue as ''@netValue'' , CONVERT(varchar(10), issueDate, 120) as ''@issueDate'' 
		FROM document.CommercialDocumentHeader h WITH (NOLOCK) WHERE contractorId in (
			SELECT id FROM contractor.Contractor where [fullname] like ''Moto Budrex%'' )
		FOR XML PATH(''line''),TYPE 
	)
	FOR XML PATH(''line''),TYPE 
END
' 
END
GO

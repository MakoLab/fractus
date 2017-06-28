/*
name=[document].[p_getCommercialDocumentByOppositeDocumentId]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
DCP31e6UO4+gLGz2UrZUrg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCommercialDocumentByOppositeDocumentId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getCommercialDocumentByOppositeDocumentId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getCommercialDocumentByOppositeDocumentId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_getCommercialDocumentByOppositeDocumentId] 
@oppositeId UNIQUEIDENTIFIER
AS
BEGIN

DECLARE 
@rowcount INT,
@attribute UNIQUEIDENTIFIER,
@id UNIQUEIDENTIFIER


SELECT @attribute = id 
FROM dictionary.DocumentField 
WHERE name = ''ShiftDocumentAttribute_OppositeDocumentId''

SELECT TOP 1 @id = commercialDocumentHeaderId
FROM document.DocumentAttrValue
WHERE documentFieldId = @attribute --AND CAST(textValue as UNIQUEIDENTIFIER)  = @oppositeId
IF @id is null
	SELECT CAST(''<root><commercialDocumentHeader/></root>'' as xml)
ELSE
EXEC document.p_getCommercialDocumentData @id
 
END
' 
END
GO

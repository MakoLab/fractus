/*
name=[document].[p_getComplaintDiscount]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
zKJ/3wxLV/ZGunIfvZcdZw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getComplaintDiscount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getComplaintDiscount]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getComplaintDiscount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [document].[p_getComplaintDiscount] 
@xmlVar XML
AS
DECLARE @id UNIQUEIDENTIFIER

SELECT @id = @xmlVar.value(''(root/commercialDocument/id)[1]'',''char(36)'')

PRINT @id

SELECT SUM((( l.initialNetPrice  - (l.initialNetPrice *  (l.discountRate /100) ) ) - l.netPrice ) * ABS(l.quantity)) complaintDiscount
FROM document.CommercialDocumentHeader h 
	JOIN document.CommercialDocumentLine l ON h.id = l.commercialDocumentHeaderId
	JOIN document.DocumentAttrValue a ON h.id = a.commercialDOcumentHeaderId
	JOIN dictionary.documentFIeld v ON a.documentFieldId = v.id
WHERE v.[name] = ''Attribute_ComplaintDiscount''
	AND h.id = @id
FOR XML PATH(''root'') ,TYPE
' 
END
GO

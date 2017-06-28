/*
name=[document].[p_getRealizedSalesOrderLines]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Vm0z05oLmaRzqTcULmTzBw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getRealizedSalesOrderLines]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getRealizedSalesOrderLines]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getRealizedSalesOrderLines]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getRealizedSalesOrderLines] 
--@xmlVar XML
@id uniqueidentifier
AS
BEGIN
--declare @id uniqueidentifier

--SELECT @id = x.value(''.'',''char(36)'')
--FROM @xmlVar.nodes(''/root/id'') AS a( x )

SELECT (
		SELECT l.id, l.itemId, abs(l.quantity * l.commercialDirection) AS quantity , dlv.guidValue
		FROM document.CommercialDocumentLine l
			JOIN document.DocumentLineAttrValue  dlv ON l.id = dlv.commercialDocumentLineId
			JOIN dictionary.DocumentField df ON dlv.documentFieldId = df.id
			JOIN document.CommercialDocumentLine cl ON dlv.guidValue = cl.id
		WHERE df.name = ''LineAttribute_RealizedSalesOrderLineId'' AND cl.CommercialDocumentHeaderId = @id
		FOR XML PATH(''commercialDocumentLine''), TYPE
) FOR XML PATH(''root''), TYPE

END' 
END
GO

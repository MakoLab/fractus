/*
name=[document].[p_getLastPurchasePrice]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
HaPK3BHBQPlsJGSEehPxHA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getLastPurchasePrice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getLastPurchasePrice]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getLastPurchasePrice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- proc by gdereck

CREATE PROCEDURE [document].[p_getLastPurchasePrice]
	@xmlVar XML
AS
BEGIN
	DECLARE @itemId uniqueidentifier, @contractorId uniqueidentifier, @price DECIMAL(18, 2)

	SELECT 
		@itemId = x.query(''itemId'').value(''.'', ''uniqueidentifier''),
		@contractorId = NULLIF(x.query(''contractorId'').value(''.'', ''char(36)''), '''')
	FROM @xmlVar.nodes(''/*'') AS C(x)


	SELECT TOP 1 @price = netPrice
	FROM document.CommercialDocumentLine L WITH ( NOLOCK )
		JOIN document.CommercialDocumentHeader H WITH ( NOLOCK ) ON H.id = L.commercialDocumentHeaderId
	WHERE
		L.commercialDirection = 1
		AND H.status >= 40
		AND ( @contractorId IS NULL OR H.contractorId = @contractorId )
		AND L.itemId = @itemId
		AND L.initialCommercialDocumentLineId IS NULL
	ORDER BY H.issueDate DESC

	SELECT @price AS netPrice FOR XML PATH(''root'')

END
' 
END
GO

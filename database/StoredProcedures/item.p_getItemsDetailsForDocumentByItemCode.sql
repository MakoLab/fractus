/*
name=[item].[p_getItemsDetailsForDocumentByItemCode]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
0yQzVg6TnSL6CAGIT19DWQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsDetailsForDocumentByItemCode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemsDetailsForDocumentByItemCode]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsDetailsForDocumentByItemCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getItemsDetailsForDocumentByItemCode] 
@xmlVar XML
AS
BEGIN

	DECLARE 
		@lastPurchasePrice INT,
		@contractorId UNIQUEIDENTIFIER,
		@price DECIMAL(18, 2)

	SELECT  @contractorId = NULLIF(x.value(''@contractorId[1]'',''char(36)''),''''),
			@lastPurchasePrice = x.value(''@lastPurchasePrice[1]'',''int'')
	FROM @xmlVar.nodes(''root'') as a (x)

	DECLARE @tmp TABLE ( code nvarchar(500))
	INSERT INTO @tmp (code)
	SELECT  x.value(''@code'',''nvarchar(500)'')
	FROM @xmlVar.nodes(''root/item'') as a (x)

	IF @lastPurchasePrice = 1
		BEGIN

			SELECT ( 
				SELECT defaultPrice as ''@initialNetPrice'', unitId ''@unitId'', vatRateId as ''@vatRateId'', version as ''@version'', [name] as ''@name'', t.code as ''@code'',
																							( 		SELECT TOP 1 netPrice
																								FROM document.CommercialDocumentLine L WITH ( NOLOCK )
																									JOIN document.CommercialDocumentHeader H WITH ( NOLOCK ) ON H.id = L.commercialDocumentHeaderId
																								WHERE
																									L.commercialDirection = 1 AND H.status >= 40
																									AND ( @contractorId IS NULL OR H.contractorId = @contractorId )
																									AND L.itemId = i.id AND L.initialCommercialDocumentLineId IS NULL
																								ORDER BY H.issueDate DESC
																							) AS ''@lastPurchasePrice'' , id as ''@id''
			FROM item.Item i
				JOIN @tmp t ON i.code = t.code
			FOR XML PATH(''item''), TYPE )
			FOR XML PATH(''root''), TYPE
 
		END
	ELSE
		BEGIN
			SELECT ( 
				SELECT defaultPrice as ''@initialNetPrice'', unitId ''@unitId'', vatRateId as ''@vatRateId'', version as ''@version'', [name] as ''@name'', id as ''@id'', t.code as ''@code''
				FROM item.Item i
					JOIN @tmp t ON i.code = t.code
				FOR XML PATH(''item''), TYPE )
			FOR XML PATH(''root''), TYPE
		END
END
' 
END
GO

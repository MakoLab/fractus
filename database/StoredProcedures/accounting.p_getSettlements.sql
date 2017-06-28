/*
name=[accounting].[p_getSettlements]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
NQs9GuecuA22xbpjXOixnQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getSettlements]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_getSettlements]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getSettlements]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [accounting].[p_getSettlements]
( 
	@xmlVar xml
)
AS
BEGIN

	DECLARE @month		int
	DECLARE @year		int
	DECLARE @receipts	varchar(50)
	DECLARE @shifts		varchar(50)
	
	SET @month = @xmlVar.query(''root/month'').value(''.'',''int'')
	SET @year = @xmlVar.query(''root/year'').value(''.'',''int'')
	SET @receipts = @xmlVar.query(''root/receipts'').value(''.'',''varchar(50)'')
	SET @shifts = @xmlVar.query(''root/shifts'').value(''.'',''varchar(50)'')
	
	SELECT 
		(SELECT newid()  FOR XML PATH(''requestId''), TYPE),
		(SELECT ''Settlements''   FOR XML PATH(''method''), TYPE ),
		(SELECT 
			@month AS [month],
			@year AS [year],
			@receipts AS [receipts] ,
			@shifts AS [shifts],
			(SELECT
			  (SELECT 
					DISTINCT em.externalId AS FZ,
					SUM(cdl.netValue) AS FZVal,
					M.externalId AS PZ,
					H.value AS PZVal 
				FROM document.WarehouseDocumentHeader wdh
				JOIN document.WarehouseDocumentLine wdl ON wdl.warehouseDocumentHeaderId = wdh.id
				JOIN document.CommercialWarehouseRelation cwr ON cwr.warehouseDocumentLineId = wdl.id
				JOIN document.CommercialDocumentLine cdl ON cwr.commercialDocumentLineId = cdl.id
				JOIN document.CommercialDocumentHeader cdh ON cdh.id=cdl.commercialDocumentHeaderId
				JOIN accounting.ExternalMapping em ON em.id=cdh.id
				WHERE wdh.id=H.id
				GROUP BY em.externalId
				FOR XML PATH(''''), TYPE
			   ) AS Row
				
			FROM document.WarehouseDocumentHeader H
			JOIN dictionary.DocumentType T ON H.documentTypeId = T.id
			JOIN accounting.ExternalMapping M ON M.id=H.id
			WHERE T.symbol = ''PZ'' and YEAR(H.issueDate)=@year and MONTH(H.issueDate)=@month and @receipts = ''true''
			FOR XML PATH(''''), TYPE
			)
			
		 FOR XML PATH(''root''), TYPE
		
		)

    FOR XML PATH(''request''), TYPE

	select @month,@year,@receipts,@shifts

END
' 
END
GO

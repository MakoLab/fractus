/*
name=[document].[p_getSalesOrderSettledAmount]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
eCnyMAH3R7DzxNsuDEhKOw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getSalesOrderSettledAmount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getSalesOrderSettledAmount]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getSalesOrderSettledAmount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'--exec document.p_getSalesOrderSettledAmount ''cf18151f-43db-4b06-8e48-0a1bac2a047e'' 


			
			
CREATE  PROCEDURE [document].[p_getSalesOrderSettledAmount] -- ''CAF1E3BB-963D-47F1-95A7-2D7B02B3A2CB''
--declare
@commercialDocumentHeaderId  uniqueidentifier
AS
--set @commercialDocumentHeaderId = ''cf18151f-43db-4b06-8e48-0a1bac2a047e'' 
DECLARE @xml XML,
		@i INT,
		@count INT, 
		@id UNIQUEIDENTIFIER

DECLARE @tmp TABLE (i int identity(1,1), id uniqueidentifier)

	/*Zebranie listy powiązanych dokumentów*/
	INSERT INTO @tmp
	SELECT DISTINCT dr.secondCommercialDocumentHeaderId 
	FROM document.DocumentRelation dr 
	WHERE dr.firstCommercialDocumentHeaderId = @commercialDocumentHeaderId AND dr.relationType = 9
	
	/*Dodaje faktóry detaliczne*/
	INSERT INTO @tmp
	SELECT DISTINCT dr.secondCommercialDocumentHeaderId 
	FROM @tmp t 
		LEFT JOIN document.DocumentRelation dr ON t.id = dr.firstCommercialDocumentHeaderId OR t.id = dr.secondCommercialDocumentHeaderId
	WHERE dr.relationType = 1
	
	SELECT @count = COUNT(id), @i = 1
	FROM @tmp
	
	/*Uzupełniam listę o korekty do wybranych wcześniej dokumentów*/
	WHILE @i <= @count
		BEGIN 
			SELECT @id = id FROM @tmp WHERE i = @i
			
			INSERT INTO @tmp
			SELECT commercialDocumentHeaderId
			FROM [document].[p_getCompleteCommercialCorective](@id)
			WHERE commercialDocumentHeaderId NOT IN (select id from @tmp)
			SELECT @i = @i + 1
		END

SELECT @xml = (
	SELECT (
		SELECT (
			SELECT vt.vatRateId ''@id'',SUM(vt.netValue) ''@netValue'',SUM(vt.grossValue) ''@grossValue'', SUM(vt.vatValue) ''@vatValue''
			FROM document.CommercialDocumentHeader ch
				JOIN @tmp t ON ch.id = t.id
				JOIN dictionary.DocumentType dt ON ch.documentTypeId = dt.id
				JOIN document.CommercialDocumentVatTable vt ON ch.id = vt.commercialDocumentHeaderId
			WHERE  dt.symbol <> ''FD'' AND ch.status >= 40
			GROUP BY vt.vatRateId
			HAVING SUM(vt.netValue) <> 0 AND SUM(vt.grossValue) <> 0 AND SUM(vt.vatValue) <> 0
		FOR XML PATH(''vatRate''),TYPE	
			)
	FOR XML PATH(''root''),TYPE	
		)
	)
	
SELECT @xml
	 ' 
END
GO

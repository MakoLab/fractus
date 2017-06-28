/*
name=[document].[p_unrelateCommercialDocumentFromWarehouseDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
WWoDX8SxpOHl4mT350PtXw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_unrelateCommercialDocumentFromWarehouseDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_unrelateCommercialDocumentFromWarehouseDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_unrelateCommercialDocumentFromWarehouseDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_unrelateCommercialDocumentFromWarehouseDocuments] 
@commercialDocumentHeaderId UNIQUEIDENTIFIER,
@localTransactionId UNIQUEIDENTIFIER,
@deferredTransactionId UNIQUEIDENTIFIER,
@databaseId UNIQUEIDENTIFIER
AS
BEGIN

DECLARE @tmp_ TABLE (lp int identity(1,1) ,id uniqueidentifier)

DECLARE @i INT, @rowcount INT, @warehouseDocumentHeaderId UNIQUEIDENTIFIER

/*Sprawdzenie dokumentu odwiązywanego*/
IF EXISTS (SELECT id FROM document.CommercialDocumentHeader WHERE id = @commercialDocumentHeaderId AND [status] >= 60)
	BEGIN
	SELECT CAST ( ''<root><bookedOutcome><number>'' + fullNumber + ''</number></bookedOutcome></root>'' AS XML) FROM document.CommercialDocumentHeader WHERE id = @commercialDocumentHeaderId
	RETURN 0;
	END

	
	IF NOT EXISTS(
	SELECT  h.id
	FROM document.CommercialDocumentHeader h 
		JOIN dictionary.Branch b ON h.branchId = b.id 
	WHERE b.databaseId = ( SELECT textValue FROM configuration.Configuration WHERE [key] = ''communication.databaseId'' )
		AND h.id = @commercialDocumentHeaderId 
	) AND ( ISNULL(( SELECT textValue FROM configuration.Configuration WHERE [key] = ''system.isHeadquarter''),''false'') = ''true''	
			AND NOT EXISTS( SELECT id FROM communication.IncomingXmlQueue WITH(NOLOCK) WHERE executionDate IS NULL  AND  deferredTransactionId = @deferredTransactionId AND [type] = ''UnrelateCommercialDocument'')
		)
		BEGIN
			RAISERROR ( ''Nieprawidłowy oddział'', 16, 1 )
			RETURN 0;
		END
		
	
IF EXISTS (
		SELECT h.id 
		FROM document.WarehouseDocumentHeader h 
			JOIN document.WarehouseDocumentLine l ON h.id = l.warehouseDocumentHeaderId
			JOIN document.CommercialWarehouseValuation v ON l.id = v.warehouseDocumentLineId 
			JOIN document.CommercialDocumentLine c ON v.commercialDocumentLineId = c.id
		WHERE  c.commercialDocumentHeaderId = @commercialDocumentHeaderId AND h.status >= 60)
	BEGIN
	SELECT (
		SELECT ( 
			SELECT fullNumber number 
			FROM document.WarehouseDocumentHeader h 
				JOIN document.WarehouseDocumentLine l ON h.id = l.warehouseDocumentHeaderId
				JOIN document.CommercialWarehouseValuation v ON l.id = v.warehouseDocumentLineId 
				JOIN document.CommercialDocumentLine c ON v.commercialDocumentLineId = c.id
			WHERE  c.commercialDocumentHeaderId = @commercialDocumentHeaderId AND h.status >= 60
			FOR XML PATH(''''),TYPE
		) FOR XML PATH(''bookedOutcome''),TYPE
	) FOR XML PATH(''root''),TYPE
	RETURN 0;
	END

/*I po walidacji, znaczy zakwalikowaliśmy się do drugiego etapu*/
/*Tu zapiszę sobię dokumenty magazynowe bo zaraz by się zrobił bałagan*/
INSERT INTO @tmp_ ( id )
SELECT distinct h.id 
FROM document.WarehouseDocumentHeader h 
	JOIN dictionary.DocumentType dt ON h.documentTypeId = dt.id
	JOIN document.WarehouseDocumentLine l ON h.id = l.warehouseDocumentHeaderId
	JOIN document.CommercialWarehouseRelation v ON l.id = v.warehouseDocumentLineId 
	JOIN document.CommercialDocumentLine c ON v.commercialDocumentLineId = c.id
WHERE  c.commercialDocumentHeaderId = @commercialDocumentHeaderId  
	AND  dt.documentCategory IN (1) 
	AND dt.xmlOptions.value(''(/root/warehouseDocument/@warehouseDirection)[1]'', ''varchar(100)'') IN (''income'',''incomeShift'')  /*Tylko dla wybranych*/
SELECT @rowcount = @@rowcount, @i = 1

/*Titaj robię bałagan czyli odpinam doki magazynowe od handlowych*/
DELETE FROM document.CommercialWarehouseValuation
WHERE CommercialWarehouseValuation.commercialDocumentLineId IN ( 
		SELECT id FROM document.CommercialDocumentLine WHERE CommercialDocumentHeaderId = @commercialDocumentHeaderId
		)

DELETE FROM document.CommercialWarehouseRelation
WHERE CommercialWarehouseRelation.commercialDocumentLineId IN ( 
		SELECT id FROM document.CommercialDocumentLine WHERE CommercialDocumentHeaderId = @commercialDocumentHeaderId
			)


/*Kręcimy się w koło wesoło i... wyceniamy */
WHILE @i <= @rowcount
	BEGIN
		SELECT @warehouseDocumentHeaderId = id FROM @tmp_ WHERE lp = @i

		
		
		/*Nie zerujemy jeśli wszystkie pozycje są ślepo wycenione*/
		UPDATE wdl
		SET [price] = 0 ,[value] = 0
		FROM document.WarehouseDocumentLine wdl
		LEFT JOIN 
		(
			SELECT WarehouseDocumentLineId, SUM(ISNULL(Quantity, 0)) Quantity
			FROM document.CommercialWarehouseValuation
			GROUP BY WarehouseDocumentLineId
		) cwv ON cwv.WarehouseDocumentLineId = wdl.Id
		WHERE warehouseDocumentHeaderId = @warehouseDocumentHeaderId
		AND wdl.Quantity != ISNULL(cwv.Quantity, 0) 
			--OR cwv.commercialDocumentHeaderId IS NOT NULL 
			--	AND cqv.commercialDocumentHeaderID IN (
			--		SELECT id FROM document.CommercialDocumentLine 
			--		WHERE CommercialDocumentHeaderId = @commercialDocumentHeaderId
			--	)
			--)
		
		IF EXISTS(
			SELECT [id] FROM document.WarehouseDocumentLine
			WHERE warehouseDocumentHeaderId = @warehouseDocumentHeaderId
			AND [price] = 0
		)
		BEGIN
			UPDATE document.WarehouseDocumentHeader 
			SET [value] = 0
			WHERE id = @warehouseDocumentHeaderId
		END
		

		EXEC [document].[p_valuateIncome] @warehouseDocumentHeaderId, @localTransactionId ,@deferredTransactionId ,@databaseId, 1
		SELECT @i = @i + 1
	END
 
SELECT CAST( ''<root></root>'' AS XML ) XML

END
' 
END
GO

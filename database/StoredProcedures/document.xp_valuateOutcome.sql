/*
name=[document].[xp_valuateOutcome]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
nm1wpaFJ0ezpCkrk0Bvybw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[xp_valuateOutcome]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[xp_valuateOutcome]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[xp_valuateOutcome]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[xp_valuateOutcome] 
	@warehouseDocumentHeaderId uniqueidentifier, 
	@localTransactionId uniqueidentifier,
	@deferredTransactionId uniqueidentifier, 
	@databaseId uniqueidentifier,
	@valuationsChanged bit = null output
AS
BEGIN 
	DECLARE 
		@deletesnap XML,
		@snap XML
	
	--Aktualne wyceny dla dokumentu
	DECLARE @cached_valuations TABLE (id uniqueidentifier,
		incomeWarehouseDocumentLineId uniqueidentifier ,
		outcomeWarehouseDocumentLineId uniqueidentifier,
		valuationId uniqueidentifier,
		quantity numeric(18,6),
		incomePrice numeric(18,2),
		incomeValue numeric(18,2),
		version uniqueidentifier)
	
	INSERT INTO @cached_valuations
		SELECT wdv.*
		FROM document.WarehouseDocumentValuation wdv
		JOIN document.WarehouseDocumentLine wdl ON wdv.outcomeWarehouseDocumentLineId = wdl.id
		WHERE wdl.warehouseDocumentHeaderId = @warehouseDocumentHeaderId
	
	--Tabela z id wycen, które by były do usunięcia
	DECLARE @toDelete TABLE (id uniqueidentifier) 

	--Tabela na wygenerowane wyceny
	DECLARE @rdy_valuation TABLE (id uniqueidentifier,
		incomeWarehouseDocumentLineId uniqueidentifier,
		outcomeWarehouseDocumentLineId uniqueidentifier,
		valuationId uniqueidentifier,
		quantity numeric(18,6),
		incomePrice numeric(18,2),
		incomeValue numeric(18,2),
		incomeDate datetime,
		version uniqueidentifier,
		isDistributed bit)


		SELECT @deletesnap = (
			SELECT (
				SELECT (
					SELECT ''delete'' AS ''@action'', 
							v.id AS ''id'', 
							v.version AS ''version'',
							CASE l.isDistributed WHEN 1 THEN ''True'' ELSE ''False'' END ''isDistributed'',
							@warehouseDocumentHeaderId ''warehouseDocumentHeaderId''
					FROM document.WarehouseDocumentValuation v
						LEFT JOIN document.WarehouseDocumentLine l ON v.outcomeWarehouseDocumentLineId = l.id
					WHERE l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId AND (l.direction * l.quantity) < 0
					FOR XML PATH(''entry''), TYPE)
					FOR XML PATH(''warehouseDocumentValuation''), TYPE
			) FOR XML PATH(''root''),TYPE );

    IF (SELECT x.query(''<e>{ count(entry) } </e>'').value(''e[1]'', ''int'') FROM @deletesnap.nodes(''root/warehouseDocumentValuation'') AS a ( x ) ) > 0
        BEGIN
           
           INSERT INTO @toDelete
           SELECT id
                FROM document.WarehouseDocumentLine 
                WHERE warehouseDocumentHeaderId = @warehouseDocumentHeaderId 
                    AND (direction * quantity) < 0
           
           DELETE FROM @cached_valuations 
           WHERE outcomeWarehouseDocumentLineId IN 
            (	SELECT id
                FROM @toDelete)

       END 


	INSERT INTO @rdy_valuation 
	SELECT	newid(),
			x.incomeWarehouseDocumentLineId, 
			x.outcomeWarehouseDocumentLineId, 
			x.id,
			CASE WHEN x.usedQuantity < x.quantity THEN x.usedQuantity ELSE x.quantity END,							
			x.incomePrice,
			((CASE WHEN x.usedQuantity < x.quantity THEN x.usedQuantity ELSE x.quantity END ) * x.incomePrice) incomeValue,
			incomeDate,
			NEWID(),
			x.isDistributed
    FROM  
		(	SELECT 
				ir.incomeWarehouseDocumentLineId, 
				ir.outcomeWarehouseDocumentLineId,
				cv.id,
				ir.quantity,
				ABS(cv.quantity - ISNULL( (SELECT SUM( quantity ) FROM @cached_valuations wv WHERE wv.valuationId = cv.id ), 0 ) ) usedQuantity, 
				ABS(cv.price) incomePrice,
				ir.incomeDate,
				l.ordinalNumber,
				l.isDistributed
			FROM document.IncomeOutcomeRelation ir
				JOIN document.CommercialWarehouseValuation cv ON ir.incomeWarehouseDocumentLineId = cv.warehouseDocumentLineId
				JOIN document.WarehouseDocumentLine l ON ir.outcomeWarehouseDocumentLineId = l.id
			WHERE l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId 
				AND (l.direction * l.quantity) < 0  
				AND ABS(cv.quantity - ISNULL( (SELECT SUM( quantity ) FROM @cached_valuations wv WHERE wv.valuationId = cv.id ), 0 ) ) <> 0
		) x 
		
			ORDER BY incomeDate, ordinalNumber

	/*Sprawdzenie czy nowowygenerowane wyceny się różnią od istniejących - poza id i version, które się generują od nowa
	jeśli tak to propagujemy zmiany*/
	
	SET @valuationsChanged = 0
	
	IF EXISTS (
		SELECT rdy.qty
		FROM (SELECT ISNULL(SUM(quantity), 0) qty, ISNULL(SUM(incomePrice), 0) incPrice, ISNULL(SUM(incomeValue), 0) incValue,
				incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId, valuationId
				FROM @rdy_valuation GROUP BY incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId, valuationId) rdy
		FULL JOIN (SELECT ISNULL(SUM(wdv.quantity), 0) qty, ISNULL(SUM(wdv.incomePrice), 0) incPrice, ISNULL(SUM(wdv.incomeValue), 0) incValue,
				incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId, valuationId
				FROM document.WarehouseDocumentValuation wdv
					JOIN document.WarehouseDocumentLine wdl ON wdv.outcomeWarehouseDocumentLineId = wdl.id
					WHERE wdl.warehouseDocumentHeaderId = @warehouseDocumentHeaderId 
					GROUP BY incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId, valuationId) cval 
		ON rdy.incomeWarehouseDocumentLineId = cval.incomeWarehouseDocumentLineId
		AND rdy.outcomeWarehouseDocumentLineId = cval.outcomeWarehouseDocumentLineId
		AND rdy.valuationId = cval.valuationId
		WHERE ISNULL(rdy.qty, 0) != ISNULL(cval.qty, 0) 
			OR ISNULL(rdy.incPrice, 0) != ISNULL(cval.incPrice, 0) 
			OR ISNULL(rdy.incValue, 0) != ISNULL(cval.incValue, 0)
	)
		BEGIN

		SET @valuationsChanged = 1
		--najpierw usuwanie tych które zostały przegenerowane z tabeli (jeśli było wcześniej co usuwać) wycen oraz wstawienie paczki z usunieciem
		DELETE FROM document.WarehouseDocumentValuation 
		WHERE outcomeWarehouseDocumentLineId IN 
		(	SELECT id
			FROM @toDelete)
			
		IF @@rowcount > 0
			BEGIN
				/*Pomijanie tworzenia paczek*/
				IF EXISTS (SELECT id FROM configuration.Configuration WHERE [key] =''system.packageCreateOmit'')
					BEGIN
						PRINT ''Pomijanie paczki''
					END
				ELSE
					BEGIN
						INSERT  INTO communication.OutgoingXmlQueue
						(
						  id,
						  localTransactionId,
						  deferredTransactionId,
						  databaseId,
						  [type],
						  [xml],
						  creationDate
						)
						SELECT  NEWID(),
								@localTransactionId,
								@deferredTransactionId,
								@databaseId,
								''WarehouseDocumentValuation'',
								@deletesnap,
								GETDATE()
					END
			END

		/*Wstawienie wycen dokumentu magazynowego*/
		INSERT INTO document.WarehouseDocumentValuation
		SELECT id,incomeWarehouseDocumentLineId, outcomeWarehouseDocumentLineId, valuationId, quantity, incomePrice,incomeValue, version
		FROM @rdy_valuation

		IF @@rowcount > 0
			BEGIN
							/*Pomijanie tworzenia paczek*/
				IF EXISTS (SELECT id FROM configuration.Configuration WHERE [key] =''system.packageCreateOmit'')
					BEGIN
						PRINT ''Pomijanie paczki''
					END
				ELSE
					BEGIN
						/*Budowa obrazu danych*/
						SELECT  @snap = (SELECT (

											SELECT ( 
											SELECT    id ''id'',
													incomeWarehouseDocumentLineId ''incomeWarehouseDocumentLineId'',
													outcomeWarehouseDocumentLineId ''outcomeWarehouseDocumentLineId'',
													valuationId ''valuationId'',
													quantity ''quantity'',
													incomePrice ''incomePrice'',
													incomeValue ''incomeValue'',
													version ''version'',
													CASE isDistributed WHEN 1 THEN ''True'' ELSE ''False'' END ''isDistributed'',
													@warehouseDocumentHeaderId ''warehouseDocumentHeaderId''
										  FROM      @rdy_valuation
										FOR XML PATH(''entry''), TYPE
									  )	FOR XML PATH(''warehouseDocumentValuation''), TYPE
									) FOR XML PATH(''root''),TYPE );


						/* Wstawienie paczki komunikacyjnej z wyceną magazynu*/
						INSERT  INTO communication.OutgoingXmlQueue
							( id, localTransactionId, deferredTransactionId, databaseId, [type], [xml], creationDate )
						SELECT  NEWID(),
								@localTransactionId,
								@deferredTransactionId,
								@databaseId,
								''WarehouseDocumentValuation'',
								@snap,
								GETDATE()
					END
			END
		END
END
' 
END
GO

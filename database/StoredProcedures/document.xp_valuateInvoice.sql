/*
name=[document].[xp_valuateInvoice]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
BKR/fz/pHLoe63suNJdCYA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[xp_valuateInvoice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[xp_valuateInvoice]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[xp_valuateInvoice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[xp_valuateInvoice] 
	@commercialDocumentHeaderId uniqueidentifier, 
	@localTransactionId uniqueidentifier,
	@deferredTransactionId uniqueidentifier, 
	@databaseId uniqueidentifier
AS

	DECLARE 
	@snap XML,
	@il int, @ci int, @iv int, @cv int, @iw int, @cw int,@idl uniqueidentifier,@idv uniqueidentifier,@quantity numeric(18,6), @vquantity numeric(18,6), @vvalue numeric(18,6)


	DECLARE @rdy_valuation TABLE (id uniqueidentifier, warehouseDocumentLineId uniqueidentifier , commercialDocumentLineId uniqueidentifier, quantity numeric(18,6), price numeric(18,2), value numeric(18,2), version uniqueidentifier)
	DECLARE @tmp_lines TABLE (i int identity(1,1), id uniqueidentifier)
	DECLARE @tmp_commercial TABLE (i int identity(1,1), id uniqueidentifier, issueDate datetime, quantity numeric(18,6))
	DECLARE @tmp_valuations TABLE (i int identity(1,1), id uniqueidentifier)


	    SELECT @snap = (
		SELECT (
			SELECT (
				SELECT ''delete'' AS ''@action'', 
						v.id AS ''id'', 
						v.version AS ''version''
				FROM document.CommercialWarehouseValuation v
				WHERE commercialDocumentLineId IN 
									(	SELECT id
										FROM document.CommercialDocumentLine 
										WHERE commercialDocumentHeaderId = @commercialDocumentHeaderId 
											AND quantity > 0 )
				FOR XML PATH(''entry''), TYPE )
			FOR XML PATH(''commercialWarehouseValuation''), TYPE
		) FOR XML PATH(''root''),TYPE );

    IF (SELECT x.query(''<e>{ count(entry) } </e>'').value(''e[1]'', ''int'') FROM @snap.nodes(''root/commercialWarehouseValuation'') AS a ( x ) ) > 0
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
								''CommercialWarehouseValuation'',
								@snap,
								GETDATE()
      
				END

           DELETE FROM document.CommercialWarehouseValuation 
           WHERE commercialDocumentLineId IN 
            (	SELECT id
                FROM document.CommercialDocumentLine 
                WHERE commercialDocumentHeaderId = @commercialDocumentHeaderId 
                    AND quantity * commercialDirection <> 0 )		
       END 


	INSERT INTO @tmp_lines (id)
	SELECT id
	FROM document.CommercialDocumentLine 
	WHERE commercialDOcumentHeaderId = @commercialDocumentHeaderId
		AND quantity * commercialDirection <> 0 
	
	
	SELECT @il = 1,@iv = 1, @cv = 0, @iw = 1, @cw = 0,@ci = @@rowcount

	
	WHILE @il <= @ci
		BEGIN
			SELECT @idl = id FROM @tmp_lines WHERE i = @il
			
			INSERT INTO @tmp_commercial (id, issueDate, quantity)
			SELECT distinct  commercialDocumentLineId ,issueDate, cl.quantity
			FROM document.CommercialWarehouseRelation cwr
				JOIN document.CommercialDocumentLine cl ON cwr.commercialDocumentLineId = cl.id
				JOIN document.CommercialDocumentHeader h ON cl.commercialDOcumentHeaderId = h.id
			WHERE cwr.warehouseDocumentLineId IN 
				( /*Pobranie listy pozycji dokumentów magazynowych podpiętych do fakt.*/
					SELECT warehouseDocumentLineId
					FROM  document.CommercialDocumentLine l 
						JOIN document.CommercialWarehouseRelation cr ON  cr.commercialDocumentLineId = l.id AND cr.isCommercialRelation = 1
					WHERE l.id = @idl
						AND cr.quantity <> 0
					)
			ORDER BY issueDate
			
			SELECT  @cv = @cv + @@rowcount

				/*Pętla po liście powiązanych linii dokumentów sprzedaży do jednej pozycji dokumentu magazynowego stanowiącego koszt*/
				WHILE @iv <= @cv
					BEGIN
						/*Mamy linie powiązanych dokumentów sprzedażowych i trzeba dopisać powiązania wycenowe od początku do tych dokumentów*/
						SELECT @idv = id, @quantity = ABS(quantity)
						FROM @tmp_commercial 
						WHERE i = @iv
				
						INSERT INTO @tmp_valuations(id)
						SELECT wv.id
						FROM  document.CommercialDocumentLine l 
							JOIN document.CommercialWarehouseRelation cr ON  cr.commercialDocumentLineId = l.id AND cr.isCommercialRelation = 1
							JOIN document.WarehouseDocumentValuation wv ON cr.warehouseDocumentLineId = wv.outcomeWarehouseDocumentLineId OR cr.warehouseDocumentLineId = wv.incomeWarehouseDocumentLineId
							LEFT JOIN document.WarehouseDocumentLine wl ON cr.warehouseDocumentLineId = wl.id
							LEFT JOIN document.WarehouseDocumentHeader wh ON wl.warehouseDocumentHeaderId = wh.id
						WHERE l.id = @idv 
							AND cr.quantity <> 0 
						ORDER BY wh.issueDate
						
						SELECT @cw = @cw + @@rowcount
						
						WHILE @iw <= @cw AND @quantity > 0
							BEGIN 
															
								IF EXISTS (SELECT * FROM document.CommercialDocumentLine WHERE id = @idv  AND commercialDocumentHeaderId = @commercialDocumentHeaderId)
									BEGIN
										
							 			INSERT INTO @rdy_valuation ( id,commercialDocumentLineId, warehouseDocumentLineId,  quantity, value, price, version)
										SELECT	NEWID(),
												x.commercialDocumentLineId, 
												x.warehouseDocumentLineId, 
												x.quantity,
												x.incomeValue,
												x.incomePrice,
												NEWID()
										FROM  
											(	
												SELECT 
													@idv commercialDocumentLineId, 
													wv.outcomeWarehouseDocumentLineId warehouseDocumentLineId,
													CASE WHEN @quantity < wv.quantity THEN @quantity ELSE  wv.quantity END quantity,
													 wv.incomePrice * CASE WHEN @quantity < wv.quantity THEN @quantity ELSE  wv.quantity END  incomeValue,
													wv.incomePrice
												FROM @tmp_valuations t 
													JOIN document.WarehouseDocumentValuation wv ON t.id = wv.id
												WHERE t.i = @iw	
												
											) x 
											
									 END
									 
								SELECT  @quantity = @quantity - CASE WHEN wv.quantity >= @quantity THEN  @quantity ELSE wv.quantity END
								FROM @tmp_valuations t 
									JOIN document.WarehouseDocumentValuation wv ON t.id = wv.id
								WHERE i = @iw
								

							SELECT @iw = @iw + 1
							END
						
					SELECT @iv = @iv + 1
					END
		
		SELECT @il = @il + 1
		END

	/*Wstawienie wycen dokumentu magazynowego*/
	INSERT INTO document.CommercialWarehouseValuation ( id,commercialDocumentLineId, warehouseDocumentLineId,  quantity, value, price, version)
	SELECT id,commercialDocumentLineId, warehouseDocumentLineId,  quantity, value, price, version
	FROM @rdy_valuation

	IF @@rowcount > 0
		BEGIN
		/*Budowa obrazu danych*/
		SELECT  @snap = (SELECT (

							SELECT ( 
							SELECT    id ''id'',
									commercialDocumentLineId ''commercialDocumentLineId'',
									warehouseDocumentLineId ''warehouseDocumentLineId'',
									quantity ''quantity'',
									value ''value'',
									price ''price'',
									version ''version''
						  FROM      @rdy_valuation
						FOR XML PATH(''entry''), TYPE
					  )	FOR XML PATH(''commercialWarehouseValuation''), TYPE
					) FOR XML PATH(''root''),TYPE );

   IF (SELECT x.query(''<e>{ count(entry) } </e>'').value(''e[1]'', ''int'') FROM @snap.nodes(''root/commercialWarehouseValuation'') AS a ( x ) ) > 0
        BEGIN
			/*Pomijanie tworzenia paczek*/
			IF EXISTS (SELECT id FROM configuration.Configuration WHERE [key] =''system.packageCreateOmit'')
				BEGIN
					PRINT ''Pomijanie paczki''
				END
			ELSE
				BEGIN
					/* Wstawienie paczki komunikacyjnej z wyceną magazynu*/
					INSERT  INTO communication.OutgoingXmlQueue
						( id, localTransactionId, deferredTransactionId, databaseId, [type], [xml], creationDate )
					SELECT  NEWID(),
							@localTransactionId,
							@deferredTransactionId,
							@databaseId,
							''CommercialWarehouseValuation'',
							@snap,
							GETDATE()
				END
		END		
		END
' 
END
GO

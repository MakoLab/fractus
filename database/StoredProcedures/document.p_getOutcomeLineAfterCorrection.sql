/*
name=[document].[p_getOutcomeLineAfterCorrection]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
DgBXuHYlGNAHntokT8zJqA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getOutcomeLineAfterCorrection]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getOutcomeLineAfterCorrection]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getOutcomeLineAfterCorrection]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getOutcomeLineAfterCorrection] 
@warehouseDocumentLineId uniqueidentifier
AS
BEGIN

/*
Funkcja zwraca 3 rodzaje wyników:
- nie istnieje korekta linii dokumentu , wtedy zwracam <root><warehouseDocumentLine/></root>
- pozycja została całkowicie zwrócona , wtedy zwracam <root>
- pozycja została skorygowana , wtedy zwracam linię wraz z jej powiązaniami
*/

DECLARE 
	@correctedDocumentLineId UNIQUEIDENTIFIER,
	@x XML,
	@stat INT


IF EXISTS(		SELECT l.id 
				FROM document.WarehouseDocumentLine l 
					JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id  
				WHERE l.correctedWarehouseDocumentLineId  = @warehouseDocumentLineId AND lineType = 2 AND h.status >= 40 ) 
	AND NOT EXISTS (	SELECT l.id 
						FROM document.WarehouseDocumentLine l 
							JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id 
						WHERE l.correctedWarehouseDocumentLineId  = @warehouseDocumentLineId AND lineType = -2 AND h.status >= 40)
	BEGIN
		SELECT @x = CAST (  ''<root/>'' AS XML )
		SELECT @x
		RETURN 0;
	END
ELSE
	BEGIN
		SELECT @stat = 1, @correctedDocumentLineId = @warehouseDocumentLineId

		WHILE @stat > 0
			BEGIN

				IF EXISTS( SELECT l.id 
							FROM document.WarehouseDocumentLine l 
								JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id 
							WHERE l.correctedWarehouseDocumentLineId  = @correctedDocumentLineId AND lineType = -2 AND h.status >= 40)
						
					SELECT @correctedDocumentLineId = l.id
					FROM document.WarehouseDocumentLine l 
						JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id 
					WHERE l.correctedWarehouseDocumentLineId  = @correctedDocumentLineId  
					AND l.lineType = -2
					AND status >= 40
					
				ELSE IF EXISTS( SELECT l.id 
								FROM document.WarehouseDocumentLine l 
									JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id 
								WHERE l.correctedWarehouseDocumentLineId  = @correctedDocumentLineId AND lineType = -3  AND h.status >= 40)
				
					SELECT  @correctedDocumentLineId = l.id
					FROM document.WarehouseDocumentLine l 
					JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id 
					WHERE l.correctedWarehouseDocumentLineId  = @correctedDocumentLineId 
						AND l.lineType = -3
						AND h.status >= 40

				ELSE SET @stat = 0		
				
			END

	END

	IF CAST(ISNULL(@correctedDocumentLineId,'''') AS VARCHAR(50)) = CAST(ISNULL(@warehouseDocumentLineId, '''') AS VARCHAR(50))
		SELECT @x = CAST (  ''<root wasCorrected="0"/>'' AS XML )
	ELSE

		SELECT @x = ( SELECT
                            ( SELECT    ( SELECT    WarehouseDocumentLine.*, i.code itemCode, i.name itemName
                                          FROM      document.WarehouseDocumentLine
											JOIN item.Item i ON WarehouseDocumentLine.itemId = i.id
                                          WHERE     WarehouseDocumentLine.id = @correctedDocumentLineId
                                          FOR XML PATH(''entry''),TYPE
                                        )
                            FOR XML PATH(''warehouseDocumentLine''), TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      document.DocumentLineAttrValue 
                                          WHERE     warehouseDocumentLineId = @correctedDocumentLineId
                                          FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''documentLineAttrValue''), TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      document.WarehouseDocumentValuation
                                          WHERE     outcomeWarehouseDocumentLineId = @correctedDocumentLineId
                                          FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''warehouseDocumentValuation''), TYPE
                            ),
							( SELECT    ( SELECT    *
										  FROM      [document].IncomeOutcomeRelation
										  WHERE     outcomeWarehouseDocumentLineId = @correctedDocumentLineId
										  FOR XML PATH(''entry''), TYPE
										)
							FOR XML PATH(''incomeOutcomeRelation''), TYPE
							),
							( SELECT    ( SELECT    *
										  FROM      [document].CommercialWarehouseRelation
										  WHERE     warehouseDocumentLineId = @correctedDocumentLineId
										  FOR XML PATH(''entry''), TYPE
										)
							FOR XML PATH(''commercialWarehouseRelation''), TYPE
							)
              FOR XML PATH(''root''), TYPE
                ) 

SELECT @x


END
' 
END
GO

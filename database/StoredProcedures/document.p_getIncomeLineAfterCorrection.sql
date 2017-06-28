/*
name=[document].[p_getIncomeLineAfterCorrection]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
+PRmXB+w3oxGl3jGkCHk/w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getIncomeLineAfterCorrection]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getIncomeLineAfterCorrection]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getIncomeLineAfterCorrection]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getIncomeLineAfterCorrection]
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


IF EXISTS( SELECT id FROM document.WarehouseDocumentLine l WHERE l.direction <> 0 AND l.correctedWarehouseDocumentLineId  = @warehouseDocumentLineId AND lineType = -1) 
	AND NOT EXISTS ( SELECT id FROM document.WarehouseDocumentLine l WHERE l.direction <> 0 AND l.correctedWarehouseDocumentLineId  = @warehouseDocumentLineId AND lineType = 1 )
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

				IF EXISTS( SELECT id FROM document.WarehouseDocumentLine l WHERE l.direction <> 0 AND l.correctedWarehouseDocumentLineId  = @correctedDocumentLineId AND lineType = 1 )
						
					SELECT @correctedDocumentLineId = id
					FROM document.WarehouseDocumentLine l 
					WHERE l.correctedWarehouseDocumentLineId  = @correctedDocumentLineId 
					AND lineType = 1
					AND l.direction <> 0 

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
                                          FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''warehouseDocumentLine''), TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      document.DocumentLineAttrValue 
                                          WHERE     warehouseDocumentLineId  = @correctedDocumentLineId
                                          FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''documentLineAttrValue''), TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      document.WarehouseDocumentValuation
                                          WHERE     incomeWarehouseDocumentLineId = @correctedDocumentLineId
                                          FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''warehouseDocumentValuation''), TYPE
                            ),
							( SELECT    ( SELECT    *
										  FROM      [document].IncomeOutcomeRelation
										  WHERE     incomeWarehouseDocumentLineId = @correctedDocumentLineId
										  FOR XML PATH(''entry''),TYPE
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

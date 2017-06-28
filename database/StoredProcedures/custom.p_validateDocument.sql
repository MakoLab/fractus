/*
name=[custom].[p_validateDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
9iLefWIqsHYll5mCajY2hg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_validateDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_validateDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_validateDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
				
CREATE PROCEDURE [custom].[p_validateDocument]
	@xmlVar xml
AS
	DECLARE  @action varchar(10), @documentId uniqueidentifier, @documentTypeId uniqueidentifier, @documentTypeSymbol varchar(10)
	DECLARE @message TABLE (error varchar(max))
	
    SELECT  
            @action = x.value(''@action[1]'', ''varchar(10)''),
			@documentId = x.value(''id[1]'', ''uniqueidentifier''),
			@documentTypeId = x.value(''documentTypeId[1]'', ''uniqueidentifier''),
			@documentTypeSymbol = x.value(''symbol[1]'', ''varchar(10)'')
    FROM    @xmlVar.nodes(''/*'') a(x)
	
	
	  
	IF @documentTypeSymbol IN (''FVZ'', ''FZ'', ''ZSP'')
		BEGIN
		
		    DECLARE @errorLines TABLE (id INT IDENTITY(1,1), [order] INT, price BIT, [group] BIT, [marza] BIT);
			IF @documentTypeSymbol IN (''FVZ'', ''FZ'', ''ZSP'')
				BEGIN
					--Wczytanie linii gdzie są braki
					INSERT INTO @errorLines ([order], [group], [price],[marza])
					SELECT CAST(l.ordinalNumber AS varchar(100))
						, CASE WHEN ig.id IS NULL THEN 1 ELSE 0 END
						, CASE WHEN i.defaultPrice = 0.0 AND @documentTypeSymbol != ''ZSP'' THEN 1 ELSE 0 END
						, CASE WHEN l.initialNetPrice <= l.netPrice AND @documentTypeSymbol != ''ZSP'' THEN 1 ELSE 0 END
					FROM document.CommercialDocumentLine l 
						LEFT JOIN item.item i ON l.itemId = i.id
						LEFT JOIN item.ItemGroupMembership ig ON l.itemId = ig.itemId
						JOIN document.DocumentAttrValue dav ON l.commercialDocumentHeaderId = dav.commercialDocumentHeaderId 
							AND dav.documentFieldId = (SELECT id FROM dictionary.DocumentField  WHERE name = ''Attribute_DocumentSourceType'')
					WHERE l.commercialDocumentHeaderId = @documentId
						AND  ((i.defaultPrice = 0.0 OR ig.id IS NULL) OR l.initialNetPrice <= l.netPrice)
					ORDER BY l.ordinalNumber
				END		
				
			--Zbudowanie komunikatów
			DECLARE @groupFirst INT
			DECLARE @priceFirst INT
			DECLARE @profitFirst INT
			
			SELECT @groupFirst = MIN(id) FROM @errorLines WHERE [group] = 1
			SELECT @priceFirst = MIN(id) FROM @errorLines WHERE [price] = 1
			SELECT @profitFirst = MIN(id) FROM @errorLines WHERE [marza] = 1
			
		
			IF EXISTS(SELECT * FROM @errorLines WHERE [group] = 1)
			BEGIN
				DECLARE @tmpmsg VARCHAR(max)
				
				SET @tmpmsg = ''Towary nieprzypisane do grup w ''
					+ CASE WHEN (SELECT COUNT(*) FROM @errorLines WHERE [group] = 1) = 1 THEN ''linii'' ELSE ''liniach'' END + '': '' 
				
				SELECT @tmpmsg = @tmpmsg + CAST([order] AS VARCHAR(100))
					FROM @errorLines e
					WHERE e.id = @groupFirst AND [group] = 1
					
				SELECT @tmpmsg = @tmpmsg + 
					ISNULL((SELECT '', '' + CAST([order] AS VARCHAR(100))
					FROM @errorLines e
					WHERE e.id != @groupFirst AND [group] = 1
					FOR XML PATH('''')), '''')
					
				INSERT INTO @message (error) SELECT @tmpmsg 
					
			END

			IF EXISTS(SELECT * FROM @errorLines WHERE [price] = 1)
			BEGIN
				
				SET @tmpmsg = ''Towary o cenie 0 w ''
					+ CASE WHEN (SELECT COUNT(*) FROM @errorLines WHERE [price] = 1) = 1 THEN ''linii'' ELSE ''liniach'' END + '': '' 
				
				SELECT @tmpmsg = @tmpmsg + CAST([order] AS VARCHAR(100))
					FROM @errorLines e
					WHERE e.id = @priceFirst AND [price] = 1

				SELECT @tmpmsg = @tmpmsg + 
					ISNULL((SELECT '', '' + CAST([order] AS VARCHAR(100))
					FROM @errorLines e
					WHERE e.id != @priceFirst AND [price] = 1
					FOR XML PATH('''')), '''')
					
				INSERT INTO @message (error) SELECT @tmpmsg
					
			END
			
		IF EXISTS(SELECT * FROM @errorLines WHERE [marza] = 1)
			BEGIN
				
				SET @tmpmsg = ''Towary o cenie zakupu większej od ceny sprzedaży w ''
					+ CASE WHEN (SELECT COUNT(*) FROM @errorLines WHERE [marza] = 1) = 1 THEN ''linii'' ELSE ''liniach'' END + '': '' 
				
				SELECT @tmpmsg = @tmpmsg + CAST([order] AS VARCHAR(100))
					FROM @errorLines e
					WHERE  e.id = @profitFirst AND [marza] = 1

				SELECT @tmpmsg = @tmpmsg + 
					ISNULL((SELECT '', '' + CAST([order] AS VARCHAR(100))
					FROM @errorLines e
					WHERE e.id != @profitFirst AND [marza] = 1
					FOR XML PATH('''')), '''')
					
				INSERT INTO @message (error) SELECT @tmpmsg
					
			END
	
		END

	-- zwrócenie wyniku
	SELECT
		(SELECT error FROM @message FOR XML PATH(''''), TYPE)
	FOR XML PATH(''root'')
' 
END
GO

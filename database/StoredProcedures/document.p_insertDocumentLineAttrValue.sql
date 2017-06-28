/*
name=[document].[p_insertDocumentLineAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
7Fp9nppID9jtTEyMXYPlgw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertDocumentLineAttrValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertDocumentLineAttrValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertDocumentLineAttrValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_insertDocumentLineAttrValue] 
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT

	/*Odpalić dla inserta do tabeli*/
	
	INSERT INTO document.DocumentLineAttrValue ([id],  [commercialDocumentLineId],  [warehouseDocumentLineId],  [financialDocumentLineId],  [documentFieldId],  [decimalValue],  [dateValue],  [textValue],  [xmlValue],  [version],  [order], [guidValue],[offerLineId])   
    SELECT  con.query(''id'').value(''.'', ''char(36)''),
            NULLIF(con.value(''(commercialDocumentLineId)[1]'', ''char(36)''),''''),
			NULLIF(con.value(''(warehouseDocumentLineId)[1]'', ''char(36)''),''''),
			NULLIF(con.value(''(financialDocumentLineId)[1]'', ''char(36)''),''''),
            con.value(''(documentFieldId)[1]'', ''char(36)''),
			NULLIF(con.value(''(decimalValue)[1]'', ''varchar(500)''),''''),
            NULLIF(con.value(''(dateValue)[1]'', ''datetime''), ''''),
            NULLIF(con.value(''(textValue)[1]'', ''varchar(500)''),''''),
            CASE WHEN con.exist(''xmlValue'') = 1
                 THEN con.query(''xmlValue/*'')
                 ELSE NULL
            END,
            con.value(''(version)[1]'', ''char(36)''),
            con.value(''(order)[1]'', ''int''),
            con.value(''(guidValue)[1]'', ''char(36)''),
            NULLIF(con.value(''(offerLineId)[1]'', ''char(36)''),'''')
    FROM    @xmlVar.nodes(''/root/documentLineAttrValue/entry'') AS C ( con )
	WHERE con.query(''id'').value(''.'', ''char(36)'') NOT IN   (SELECT id from  document.DocumentLineAttrValue )
				

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:DocumentLineAttrValue; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
 

END
' 
END
GO

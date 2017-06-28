/*
name=[document].[p_insertDocumentAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
hVrEZlxDuUemHtZyY3bQVQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertDocumentAttrValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertDocumentAttrValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertDocumentAttrValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_insertDocumentAttrValue]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    

	/*Wstawienie danych o atrybutach dokumentu*/
    INSERT  INTO [document].[DocumentAttrValue] WITH(TABLOCK)
            (
              id,
              commercialDocumentHeaderId,
			  warehouseDocumentHeaderId,
			  financialDocumentHeaderId,
			  complaintDocumentHeaderId,
			  inventoryDocumentHeaderId,
              documentFieldId,
              decimalValue,
              dateValue,
              textValue,
              xmlValue,
              version,
              [order],
              offerId
            )
            SELECT  con.query(''id'').value(''.'', ''char(36)''),
                    NULLIF(con.query(''commercialDocumentHeaderId'').value(''.'', ''char(36)''),''''),
					NULLIF(con.query(''warehouseDocumentHeaderId'').value(''.'', ''char(36)''),''''),
					NULLIF(con.query(''financialDocumentHeaderId'').value(''.'', ''char(36)''),''''),
					NULLIF(con.query(''complaintDocumentHeaderId'').value(''.'', ''char(36)''),''''),
					NULLIF(con.query(''inventoryDocumentHeaderId'').value(''.'', ''char(36)''),''''),
                    con.query(''documentFieldId'').value(''.'', ''char(36)''),
					NULLIF(con.query(''decimalValue'').value(''.'', ''varchar(500)''),''''),
                    NULLIF(con.query(''dateValue'').value(''.'', ''datetime''), ''''),
                    NULLIF(con.query(''textValue'').value(''.'', ''varchar(500)''),''''),
                    CASE WHEN con.exist(''xmlValue'') = 1
                         THEN con.query(''xmlValue/*'')
                         ELSE NULL
                    END,
                    con.query(''version'').value(''.'', ''char(36)''),
                    con.query(''order'').value(''.'', ''int''),
                    NULLIF(con.query(''offerId'').value(''.'', ''char(36)''),'''')
            FROM    @xmlVar.nodes(''/root/documentAttrValue/entry'') AS C ( con )
	
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:DocumentAttrValue; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            
            IF @rowcount = 0 
                RAISERROR ( 50011, 16, 1 ) ;
        END
' 
END
GO

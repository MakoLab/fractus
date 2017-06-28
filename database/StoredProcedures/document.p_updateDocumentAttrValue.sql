/*
name=[document].[p_updateDocumentAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
8L92bHugUUyJNSfsftPeEw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateDocumentAttrValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateDocumentAttrValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateDocumentAttrValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_updateDocumentAttrValue]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    BEGIN
		
		/*Aktualizacja danych o wartościach atrybutów dokumewntów*/
        UPDATE  [document].[DocumentAttrValue]
        SET     commercialDocumentHeaderId = CASE WHEN con.exist(''commercialDocumentHeaderId'') = 1
                                                  THEN con.query(''commercialDocumentHeaderId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
				warehouseDocumentHeaderId = CASE WHEN con.exist(''warehouseDocumentHeaderId'') = 1
                                                  THEN con.query(''warehouseDocumentHeaderId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
				financialDocumentHeaderId = CASE WHEN con.exist(''financialDocumentHeaderId'') = 1
                                                  THEN con.query(''financialDocumentHeaderId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
                complaintDocumentHeaderId = CASE WHEN con.exist(''complaintDocumentHeaderId'') = 1
                                                  THEN con.query(''complaintDocumentHeaderId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
                inventoryDocumentHeaderId = CASE WHEN con.exist(''inventoryDocumentHeaderId'') = 1
                                                  THEN con.query(''inventoryDocumentHeaderId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
                documentFieldId = CASE WHEN con.exist(''documentFieldId'') = 1
                                       THEN con.query(''documentFieldId'').value(''.'', ''char(36)'')
                                       ELSE NULL
                                  END,
                decimalValue = CASE WHEN con.exist(''decimalValue'') = 1
                                    THEN con.query(''decimalValue'').value(''.'', ''decimal(18,4)'')
                                    ELSE NULL
                               END,
                dateValue = CASE WHEN con.exist(''dateValue'') = 1
                                 THEN con.query(''dateValue'').value(''.'', ''datetime'')
                                 ELSE NULL
                            END,
                textValue = CASE WHEN con.exist(''textValue'') = 1
                                 THEN con.query(''textValue'').value(''.'', ''nvarchar(500)'')
                                 ELSE NULL
                            END,
                xmlValue = CASE WHEN con.exist(''xmlValue'') = 1
                                THEN con.query(''xmlValue/*'')
                                ELSE NULL
                           END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/documentAttrValue/entry'') AS C ( con )
        WHERE   DocumentAttrValue.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:DocumentAttrValue; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                
                IF @rowcount = 0 
                    RAISERROR ( 50012, 16, 1 ) ;
            END
    END


' 
END
GO

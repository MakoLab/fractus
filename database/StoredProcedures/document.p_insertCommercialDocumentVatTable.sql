/*
name=[document].[p_insertCommercialDocumentVatTable]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
BhYM/o4ODL1bTthwC6sLpw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertCommercialDocumentVatTable]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertCommercialDocumentVatTable]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertCommercialDocumentVatTable]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_insertCommercialDocumentVatTable]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    

	/*Wstawienie danych o pozycjach vat dokumentu handlowego*/
    INSERT  INTO [document].[CommercialDocumentVatTable]
            (
              id,
              commercialDocumentHeaderId,
              vatRateId,
              netValue,
              grossValue,
              vatValue,
              version,
              [order]
            )
            SELECT  con.value(''(id)[1]'', ''char(36)''),
                    con.value(''(commercialDocumentHeaderId)[1]'', ''char(36)''),
                    con.value(''(vatRateId)[1]'', ''char(36)''),
                    con.value(''(netValue)[1]'', ''numeric(18,2)''),
                    con.value(''(grossValue)[1]'', ''numeric(18,2)''),
                    con.value(''(vatValue)[1]'', ''numeric(18,2)''),
                    con.value(''(version)[1]'', ''char(36)''),
                    con.value(''(order)[1]'', ''int'')
            FROM    @xmlVar.nodes(''/root/commercialDocumentVatTable/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:CommercialDocumentVatTable; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
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

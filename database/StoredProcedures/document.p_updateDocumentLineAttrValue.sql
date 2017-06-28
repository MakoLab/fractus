/*
name=[document].[p_updateDocumentLineAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ZOwgsGI3Vcr4ZL411ygEkw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateDocumentLineAttrValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateDocumentLineAttrValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateDocumentLineAttrValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_updateDocumentLineAttrValue] 
@xmlVar XML
AS 
    BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT,
            @applicationUserId UNIQUEIDENTIFIER

		/*Pobranie uzytkownika aplikacji*/
        SELECT  @applicationUserId = a.value(''@applicationUserId'', ''char(36)'')
        FROM    @xmlVar.nodes(''root'') AS x ( a )

        /*Aktualizacja danych */
        UPDATE  document.DocumentLineAttrValue
        SET    
        [commercialDocumentLineId] =  CASE WHEN con.exist(''commercialDocumentLineId'') = 1 THEN con.value(''(commercialDocumentLineId)[1]'',''uniqueidentifier'') ELSE NULL END ,  
        [warehouseDocumentLineId] =  CASE WHEN con.exist(''warehouseDocumentLineId'') = 1 THEN con.value(''(warehouseDocumentLineId)[1]'',''uniqueidentifier'') ELSE NULL END ,  
        [financialDocumentLineId] =  CASE WHEN con.exist(''financialDocumentLineId'') = 1 THEN con.value(''(financialDocumentLineId)[1]'',''uniqueidentifier'') ELSE NULL END ,  
        [documentFieldId] =  CASE WHEN con.exist(''documentFieldId'') = 1 THEN con.value(''(documentFieldId)[1]'',''uniqueidentifier'') ELSE NULL END ,  
        [decimalValue] =  CASE WHEN con.exist(''decimalValue'') = 1 THEN con.value(''(decimalValue)[1]'',''decimal(18,4)'') ELSE NULL END ,  
        [dateValue] =  CASE WHEN con.exist(''dateValue'') = 1 THEN con.value(''(dateValue)[1]'',''datetime'') ELSE NULL END ,  
        [textValue] =  CASE WHEN con.exist(''textValue'') = 1 THEN con.value(''(textValue)[1]'',''nvarchar(500)'') ELSE NULL END ,  
        [xmlValue] =  CASE WHEN con.exist(''xmlValue'') = 1 THEN con.query(''xmlValue/*'')  ELSE NULL END ,  
        [version] =  CASE WHEN con.exist(''_version'') = 1 THEN con.value(''(_version)[1]'',''uniqueidentifier'') ELSE NULL END ,  
        [order] =  CASE WHEN con.exist(''order'') = 1 THEN con.value(''(order)[1]'',''int'') ELSE NULL END,                       
        [guidValue] =  CASE WHEN con.exist(''guidValue'') = 1 THEN con.value(''(guidValue)[1]'',''char(36)'') ELSE NULL END                          
        FROM    @xmlVar.nodes(''/root/documentLineAttrValue/entry'') AS C ( con )
        WHERE   DocumentLineAttrValue.id = con.value(''(id)[1]'', ''char(36)'')
                --AND DocumentLineAttrValue.version = con.query(''version'').value(''.'', ''char(36)'')


		/*Pobranie liczby pozycji*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:DocumentLineAttrValue; error:''
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

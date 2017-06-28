/*
name=[document].[p_deleteCommercialDocumentLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
QaYJf7/c1i0ahR+yIFGDPw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteCommercialDocumentLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_deleteCommercialDocumentLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteCommercialDocumentLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_deleteCommercialDocumentLine]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    
    /*Kasowanie wpisów o pozycjach dokumentu handlowego*/
    DELETE  FROM [document].CommercialDocumentLine
    WHERE   id IN (
            SELECT  CAST(con.value(''(id)[1]'', ''char(36)'') as uniqueidentifier)
            FROM    @xmlVar.nodes(''/root/commercialDocumentLine/entry'') AS C ( con )
            )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd kasowania danych:CommercialDocumentLine; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            
            IF @rowcount = 0 
                RAISERROR ( 50012, 16, 1 ) ;
        END
' 
END
GO

/*
name=[complaint].[p_deleteComplaintDocumentLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
peJJJHndWPzrmwYb7M8+1g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_deleteComplaintDocumentLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [complaint].[p_deleteComplaintDocumentLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_deleteComplaintDocumentLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [complaint].[p_deleteComplaintDocumentLine] 
	@xmlVar XML
AS 
	
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT


    /*Kasowanie danych o powiązaniach pozycji dokumentu magazynowego*/
    DELETE  FROM  complaint.ComplaintDocumentLine
    WHERE   id IN (
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''),'''')
            FROM    @xmlVar.nodes(''/root/complaintDocumentLine/entry'') AS C ( con )
            WHERE   id = NULLIF(con.query(''id'').value(''.'', ''char(36)''),'''') )

	/*Pobieranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            SET @errorMsg = ''Błąd kasowania danych:ComplaintDocumentLine; error:'' + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
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

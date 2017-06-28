/*
name=[document].[p_updateDraft]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ZweNo6ZpnjennBBefFAAHA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateDraft]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateDraft]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateDraft]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_updateDraft] 
	@xmlVar XML
AS
BEGIN
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT
        
        UPDATE document.Draft
        SET
			[documentTypeId] =  CASE WHEN con.exist(''documentTypeId'') = 1 THEN con.query(''documentTypeId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[date] =  getdate(),  
			[applicationUserId] =  CASE WHEN con.exist(''applicationUserId'') = 1 THEN con.query(''applicationUserId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[contractorId] =  CASE WHEN con.exist(''contractorId'') = 1 THEN con.query(''contractorId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[dataXml] =  CASE WHEN con.exist(''dataXml'') = 1 THEN con.query(''dataXml/*'') ELSE NULL END 
		FROM    @xmlVar.nodes(''/root/draft/entry'') AS C ( con )
        WHERE   Draft.id = con.query(''id'').value(''.'', ''char(36)'')
                
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obs?uga błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:Draft ; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            SELECT CAST(''<root>''+@errorMsg + ''</root>'' as XML) returnXml
           -- RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            IF @rowcount = 0 
                RAISERROR ( 50011, 16, 1 ) ;
        END
        
    SELECT CAST(''<root/>'' as XML) returnXml
END        
' 
END
GO

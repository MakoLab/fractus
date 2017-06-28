/*
name=[document].[p_deleteIncomeOutcomeRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ASoMyXJqap1uN2JaB//FhA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteIncomeOutcomeRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_deleteIncomeOutcomeRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteIncomeOutcomeRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_deleteIncomeOutcomeRelation]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    DECLARE @tmp TABLE (id uniqueidentifier)
    
    INSERT INTO @tmp (id)
    SELECT  NULLIF(con.value(''(id)[1]'', ''char(36)''),'''')
    FROM    @xmlVar.nodes(''/root/incomeOutcomeRelation/entry'') AS C ( con )
    
	/*Aktualizacja informacji o zejściach PZ*/    
	UPDATE [document].WarehouseDocumentLine
	SET outcomeDate = NULL
	WHERE outcomeDate IS NOT NULL AND id IN (
			SELECT incomeWarehouseDocumentLineId
            FROM  @tmp t
				JOIN [document].IncomeOutcomeRelation ir ON ir.id = t.id
	)

    /*Kasowanie danych o powiązaniach pozycji dokumentu magazynowego*/
    DELETE  FROM [document].IncomeOutcomeRelation
    WHERE   id IN (
            SELECT  t.id
            FROM    @tmp t
           )

	/*Pobieranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd kasowania danych:IncomeOutcomeRelation; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
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

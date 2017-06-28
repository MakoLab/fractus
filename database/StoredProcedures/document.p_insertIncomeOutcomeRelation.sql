/*
name=[document].[p_insertIncomeOutcomeRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
E6ZnMJQWvypHTTOBVcS7Kw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertIncomeOutcomeRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertIncomeOutcomeRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertIncomeOutcomeRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_insertIncomeOutcomeRelation]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@idoc int

    

	/*Wstawienie danych o seriach dokumentów*/
--    INSERT  INTO [document].[IncomeOutcomeRelation]
--            (
--              id,
--              incomeWarehouseDocumentLineId,
--              outcomeWarehouseDocumentLineId,
--			  incomeDate,
--			  quantity,
--			  version
--            )
--            SELECT  con.query(''id'').value(''.'', ''char(36)''),
--                    con.query(''incomeWarehouseDocumentLineId'').value(''.'', ''char(36)''),
--                    con.query(''outcomeWarehouseDocumentLineId'').value(''.'', ''char(36)''),
--					con.query(''incomeDate'').value(''.'', ''datetime''),
--                    con.query(''quantity'').value(''.'', ''numeric(18,6)''),
--					con.query(''version'').value(''.'', ''char(36)'')
--            FROM    @xmlVar.nodes(''/root/*/entry'') AS C ( con )


	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

    INSERT  INTO [document].[IncomeOutcomeRelation]
            (
              id,
              incomeWarehouseDocumentLineId,
              outcomeWarehouseDocumentLineId,
			  incomeDate,
			  quantity,
			  version
            )
	SELECT
			  id,
              incomeWarehouseDocumentLineId,
              outcomeWarehouseDocumentLineId,
			  incomeDate,
			  quantity,
			  version
	FROM OPENXML(@idoc, ''/root/*/entry'')
		WITH(
				id char(36) ''id'',
				incomeWarehouseDocumentLineId char(36) ''incomeWarehouseDocumentLineId'',
				outcomeWarehouseDocumentLineId char(36) ''outcomeWarehouseDocumentLineId'',
				incomeDate datetime ''incomeDate'',
				quantity numeric(18,6) ''quantity'',
				version char(36) ''version''
			)
EXEC sp_xml_removedocument @idoc

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
	/*Aktualizacja daty rozchodu na pozycji przychodowej*/
	UPDATE [document].WarehouseDocumentLine 
	SET outcomeDate = NULLIF(con.query(''_outcomeDate'').value(''.'', ''datetime''),'''')
	FROM [document].WarehouseDocumentLine  wl 
		JOIN @xmlVar.nodes(''/root/*/entry'') AS C ( con ) ON wl.id = con.query(''incomeWarehouseDocumentLineId'').value(''.'', ''char(36)'')
	WHERE outcomeDate IS NULL

    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:IncomeOutcomeRelation; error:''
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

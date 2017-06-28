/*
name=[document].[p_insertWarehouseDocumentValuation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
mPl9gqGmdBks7aQ/yPoeAA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertWarehouseDocumentValuation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertWarehouseDocumentValuation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertWarehouseDocumentValuation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N' 
CREATE PROCEDURE [document].[p_insertWarehouseDocumentValuation] @xmlVar XML
AS 
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
			@error int 

	DECLARE @tmp TABLE (id uniqueidentifier, incomeWarehouseDocumentLineId uniqueidentifier, outcomeWarehouseDocumentLineId uniqueidentifier
	, valuationId uniqueidentifier
	,quantity numeric(18,6), incomePrice numeric(18,2), incomeValue numeric(18,2), [version] uniqueidentifier )    
	BEGIN TRY

	INSERT INTO @tmp
	SELECT  con.value(''(id)[1]'', ''char(36)''),
			con.value(''(incomeWarehouseDocumentLineId)[1]'', ''char(36)''),
			con.value(''(outcomeWarehouseDocumentLineId)[1]'', ''char(36)''),
			con.value(''(valuationId)[1]'', ''char(36)''),
			con.value(''(quantity)[1]'', ''numeric(18,6)''),
			con.value(''(incomePrice)[1]'', ''numeric(18,2)''),
			con.value(''(incomeValue)[1]'', ''numeric(18,2)''),
			ISNULL(con.value(''(_version)[1]'', ''char(36)''), con.value(''(version)[1]'', ''char(36)''))
	FROM    @xmlVar.nodes(''/root/warehouseDocumentValuation/entry'') AS C ( con )
	

	
	/*Wstawienie danych o seriach dokumentów*/
    INSERT  INTO [document].[WarehouseDocumentValuation]
            (
              id,incomeWarehouseDocumentLineId,
              outcomeWarehouseDocumentLineId,
			  valuationId, quantity,
			  incomePrice, incomeValue, [version]
            )
    SELECT * 
    FROM @tmp 
    WHERE id NOT IN (SELECT id FROM [document].[WarehouseDocumentValuation])

       	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT     
    
		INSERT  INTO communication.OutgoingXmlQueue
        (
          id, localTransactionId, deferredTransactionId,
		  databaseId, [type], [xml], creationDate
        )
        SELECT  NEWID(),
                con.value(''@localTransactionId'', ''char(36)''),
                con.value(''@deferredTransactionId'', ''char(36)''),
				con.value(''@databaseId'', ''char(36)''),
                ''WarehouseDocumentValuation'',
                @xmlVar,
                GETDATE()
        FROM    @xmlVar.nodes(''/root'') AS C ( con )
		WHERE con.value(''@localTransactionId'', ''char(36)'') IS NOT NULL

    /*Obsługa błędów i wyjątków*/
 
     END TRY
	 BEGIN CATCH
			SELECT @errorMsg = ''Błąd wstawiania danych tabela:Item; error:''
				+ CAST(@@ERROR AS VARCHAR(50)) + '';Procedura:'' + ERROR_PROCEDURE() + '';Linia:'' + CAST(ERROR_LINE() as varchar(50))+ '';Opis:'' + ERROR_MESSAGE() 
            RAISERROR ( @errorMsg, 16, 1)
    END CATCH        
	IF @rowcount = 0 
		BEGIN
			EXEC [document].[p_updateWarehouseDocumentValuation] @xmlVar
		END
END

' 
END
GO

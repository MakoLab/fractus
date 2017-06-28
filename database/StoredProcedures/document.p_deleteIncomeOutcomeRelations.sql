/*
name=[document].[p_deleteIncomeOutcomeRelations]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
CBVjuzvEqCbXv0Avicb+ag==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteIncomeOutcomeRelations]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_deleteIncomeOutcomeRelations]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteIncomeOutcomeRelations]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_deleteIncomeOutcomeRelations] 
@xmlVar XML
AS 
	
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
            @localTransactionId UNIQUEIDENTIFIER,
            @deferredTransactionId UNIQUEIDENTIFIER,
			@databaseId UNIQUEIDENTIFIER,
			@warehouseDocumentHeaderId UNIQUEIDENTIFIER,
			@snap XML


	/*Pobranie danych o transakcji*/
    SELECT  @localTransactionId = x.value(''@localTransactionId'',''char(36)''),
            @deferredTransactionId = x.value(''@deferredTransactionId'',''char(36)''),
			@databaseId = x.value(''@databaseId'',''char(36)'')
    FROM    @xmlVar.nodes(''root'') AS a ( x )

	SELECT @warehouseDocumentHeaderId =  x.query(''warehouseDocumentHeaderId'').value(''.'' ,''char(36)'')
	FROM    @xmlVar.nodes(''root'') AS a ( x )



	/*Budowa obrazu danych*/
	SELECT  @snap = (SELECT (
						SELECT ( 
						SELECT  ''delete'' AS ''@action'',   
								ir.id ''id'',
								ir.version ''version'',
								CASE l.isDistributed WHEN 1 THEN ''True'' ELSE ''False'' END ''isDistributed''
					  FROM document.IncomeOutcomeRelation ir 
						JOIN document.WarehouseDocumentLine l ON ir.outcomeWarehouseDocumentLineId = l.id
					  WHERE l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId
					FOR XML PATH(''entry''), TYPE
				  )	FOR XML PATH(''incomeOutcomeRelation''), TYPE
				) FOR XML PATH(''root''),TYPE )


	/* Wstawienie paczki komunikacyjnej z wyceną magazynu*/
	INSERT  INTO communication.OutgoingXmlQueue
		( id, localTransactionId, deferredTransactionId, databaseId, [type], [xml], creationDate )
	SELECT  NEWID(),
			@localTransactionId,
			@deferredTransactionId,
			@databaseId,
			''IncomeOutcomeRelation'',
			@snap,
			GETDATE()

	/*Aktualizacja informacji o zejściach PZ*/    
	UPDATE [document].WarehouseDocumentLine
	SET outcomeDate = NULL
	WHERE outcomeDate IS NOT NULL 
		AND id IN (	SELECT incomeWarehouseDocumentLineId 
					FROM [document].IncomeOutcomeRelation 
					WHERE outcomeWarehouseDocumentLineId IN (
						SELECT  id
						FROM    [document].WarehouseDocumentLine
			            WHERE   warehouseDocumentHeaderId = @warehouseDocumentHeaderId 
															)
					)


    /*Kasowanie danych o powiązaniach pozycji dokumentu magazynowego*/
    DELETE  FROM [document].IncomeOutcomeRelation
    WHERE   outcomeWarehouseDocumentLineId IN (
            SELECT  id
            FROM    [document].WarehouseDocumentLine
            WHERE   warehouseDocumentHeaderId = @warehouseDocumentHeaderId )

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

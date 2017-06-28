/*
name=[communication].[p_createInventoryDocumentPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
DTfb8GWwstAYhS6U2rSc2w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createInventoryDocumentPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_createInventoryDocumentPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createInventoryDocumentPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_createInventoryDocumentPackage]
@xmlVar XML
AS
BEGIN
		/* Deklaracja zmiennych*/
        DECLARE @snap XML,
            @errorMsg VARCHAR(2000),
            @rowcount INT,
            @id UNIQUEIDENTIFIER,
            @previousVersion UNIQUEIDENTIFIER,
            @localTransactionId UNIQUEIDENTIFIER,
            @deferredTransactionId UNIQUEIDENTIFIER,
			@databaseId UNIQUEIDENTIFIER

		/*Pobranie danych o transakcji*/
        SELECT  @id = x.value(''@businessObjectId'', ''char(36)''),
                @previousVersion = x.value(''@previousVersion'', ''char(36)''),
                @localTransactionId = x.value(''@localTransactionId'',''char(36)''),
                @deferredTransactionId = x.value(''@deferredTransactionId'',''char(36)''),
				@databaseId = x.value(''@databaseId'',''char(36)'')
        FROM    @xmlVar.nodes(''root'') AS a ( x )

		/*Walidacja towaru*/
        IF NOT EXISTS ( SELECT  id
                        FROM    document.InventoryDocumentHeader
                        WHERE   id = @id ) 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych; table: OutgoingXmlQueue; Brak dokumentu o id = ''
					+ CAST(@id AS VARCHAR(36)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
                RETURN 0
            END

        
        /*Budowa obrazu danych*/
        SELECT  @snap = (
			SELECT   @previousVersion AS ''@previousVersion'',  ( SELECT    ( 
									SELECT    s.*
									FROM      document.InventoryDocumentHeader  s 
									WHERE     s.id = @id
									FOR XML PATH(''entry''), TYPE
								   )
								   FOR XML PATH(''inventoryDocumentHeader''), TYPE
					   ),(SELECT   (
									SELECT    e.*
									FROM      document.InventorySheet e
									WHERE     e.inventoryDocumentHeaderId = @id
									FOR XML PATH(''entry''), TYPE
								   )
								   FOR XML PATH(''inventorySheet''), TYPE
					   )
					   
					   ,(SELECT   (
									SELECT    e.*
									FROM      document.InventorySheetLine e
										JOIN document.InventorySheet ise  ON ise.id = e.inventorySheetId
									WHERE     ise.inventoryDocumentHeaderId = @id
									FOR XML PATH(''entry''), TYPE
								   )
								   FOR XML PATH(''inventorySheetLine''), TYPE
					   )
					   
					   ,(SELECT   (
									SELECT    e.*
									FROM      document.DocumentAttrValue e
									WHERE     e.inventoryDocumentHeaderId = @id
									FOR XML PATH(''entry''), TYPE
								   )
								   FOR XML PATH(''documentAttrValue''), TYPE
					   )
			FOR XML PATH(''root''),TYPE 
			)
			

		/*Wstawienie danych*/
        INSERT  INTO communication.OutgoingXmlQueue(id,localTransactionId,deferredTransactionId,databaseId,[type],[xml],creationDate )
        SELECT  NEWID(),@localTransactionId,@deferredTransactionId,@databaseId,''InventoryDocumentSnapshot'',@snap,GETDATE()
        
		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
        /*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table: OutgoingXmlQueue; error:''
                    + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                
                IF @rowcount = 0 
                    RAISERROR ( 50011, 16, 1 ) ;
            END			
END			' 
END
GO

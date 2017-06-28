/*
name=[communication].[p_createWarehouseDocumentPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
uvy3t4KZP8TbcAjyMDz2JA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createWarehouseDocumentPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_createWarehouseDocumentPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createWarehouseDocumentPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_createWarehouseDocumentPackage]
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
                        FROM    document.WarehouseDocumentHeader
                        WHERE   id = @id ) 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych; table: OutgoingXmlQueue; Brak dokumentu o id = ''
					+ CAST(@id AS VARCHAR(36)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
                RETURN 0
            END

        
        
		/*Budowa obrazu danych*/
        SELECT  @snap = ( SELECT    @previousVersion AS ''@previousVersion'',
                                    ( SELECT    ( SELECT    *
                                                  FROM      document.WarehouseDocumentHeader
                                                  WHERE     id = @id
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''warehouseDocumentHeader''),
                                          TYPE
                                    ),
                                    ( SELECT    ( SELECT    *
                                                  FROM      document.WarehouseDocumentLine
                                                  WHERE     warehouseDocumentHeaderId = @id
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''warehouseDocumentLine''),
                                          TYPE
                                    ),
									( SELECT    ( SELECT    *
                                          FROM      [document].DocumentAttrValue
                                          WHERE     warehouseDocumentHeaderId = @id
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
									FOR
									  XML PATH(''documentAttrValue''),
										  TYPE
									),
									( SELECT    ( SELECT    *
												  FROM      [document].DocumentLineAttrValue
												  WHERE     warehouseDocumentLineId IN ( SELECT   id
																   FROM     [document].WarehouseDocumentLine
																   WHERE    warehouseDocumentHeaderId = @id)
														
												  FOR
												  XML PATH(''entry''),
													  TYPE
												)
									FOR
									  XML PATH(''documentLineAttrValue''),
										  TYPE
									),

                                    ( SELECT    ( SELECT    *
                                                  FROM      document.WarehouseDocumentValuation
                                                  WHERE     incomeWarehouseDocumentLineId IN (SELECT id FROM document.WarehouseDocumentLine WHERE warehouseDocumentHeaderId = @id)
														OR  outcomeWarehouseDocumentLineId IN (SELECT id FROM document.WarehouseDocumentLine WHERE warehouseDocumentHeaderId = @id)
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''warehouseDocumentValuation''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''root''),
                              TYPE
                        )

		/*Wstawienie danych*/
        INSERT  INTO communication.OutgoingXmlQueue
                (
                  id,
                  localTransactionId,
                  deferredTransactionId,
				  databaseId,
                  [type],
                  [xml],
                  creationDate
                )
                SELECT  NEWID(),
                        @localTransactionId,
                        @deferredTransactionId,
						@databaseId,
                        ''WarehouseDocumentSnapshot'',
                        @snap,
                        GETDATE()
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

    END
' 
END
GO

/*
name=[communication].[p_createItemPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
+DOnBnngd0KuWgEO3UhpnA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createItemPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_createItemPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createItemPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_createItemPackage]
@xmlVar XML
AS
BEGIN
		/* Deklaracja zmiennych*/
        DECLARE @snap XML,
            @errorMsg VARCHAR(2000),
            @rowcount INT,
            @itemId UNIQUEIDENTIFIER,
            @previousVersion UNIQUEIDENTIFIER,
            @localTransactionId UNIQUEIDENTIFIER,
            @deferredTransactionId UNIQUEIDENTIFIER,
			@databaseId UNIQUEIDENTIFIER,
			@action varchar(50)

		/*Pobranie danych o transakcji*/
        SELECT  @itemId = x.value(''@businessObjectId'', ''char(36)''),
                @previousVersion = x.value(''@previousVersion'', ''char(36)''),
                @localTransactionId = x.value(''@localTransactionId'',''char(36)''),
                @deferredTransactionId = x.value(''@deferredTransactionId'',''char(36)''),
				@databaseId = x.value(''@databaseId'',''char(36)''),
				@action =  x.value(''@action'',''varchar(50)'')
        FROM    @xmlVar.nodes(''root'') AS a ( x )

		/*Walidacja towaru*/
        IF NOT EXISTS ( SELECT  id
                        FROM    item.Item
                        WHERE   id = @itemId ) 
           AND @action <> ''delete''             
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table: OutgoingXmlQueue; error:''
                    + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
                RETURN 0
            END

        
        IF @action = ''delete''
			BEGIN
							SELECT  @snap = (  SELECT       
												( SELECT    
														(	SELECT   @previousVersion AS ''@previousVersion'', @action AS ''@action'', @itemId AS  ''@id''
															FOR XML PATH(''entry''), TYPE
														)
													FOR XML PATH(''item''), TYPE
												)
									FOR XML PATH(''root'') ,TYPE
								) 
			END
		ELSE	
		/*Budowa obrazu danych*/
        SELECT  @snap = ( SELECT    @previousVersion AS ''@previousVersion'',
                                    ( SELECT    ( SELECT    *
                                                  FROM      item.Item
                                                  WHERE     id = @itemId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''item''),
                                          TYPE
                                    ),
                                    ( SELECT    ( SELECT    *
                                                  FROM      item.ItemAttrValue
                                                  WHERE     itemId = @itemId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''itemAttrValue''),
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
                        ''ItemSnapshot'',
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

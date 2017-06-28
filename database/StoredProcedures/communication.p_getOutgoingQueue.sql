/*
name=[communication].[p_getOutgoingQueue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
olengAb+Bol4/JzIlZDT3w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getOutgoingQueue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getOutgoingQueue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getOutgoingQueue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [communication].[p_getOutgoingQueue]
    @maxTransactionCount INT,
    @id UNIQUEIDENTIFIER = NULL,
	@databaseId UNIQUEIDENTIFIER
AS 
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE 
            @result XML

        DECLARE @tmp TABLE 
			( localTransactionId UNIQUEIDENTIFIER, [order] INT)     

		/*Przetwarzanie dla pustego id paczki komunikacji*/
        IF @id IS NULL 
            BEGIN
				INSERT INTO @tmp
                SELECT DISTINCT TOP ( SELECT @maxTransactionCount )
                        localTransactionId, [order]
                FROM    communication.OutgoingXmlQueue
                WHERE   sendDate IS NULL AND databaseId = @databaseId 
				ORDER BY [order]

				/*Budowa obrazu danych*/
                SELECT  @result = ( SELECT  *
                                    FROM    communication.OutgoingXmlQueue
									WHERE databaseId = @databaseId 
										AND OutgoingXmlQueue.localTransactionId IN
											(
												SELECT DISTINCT localTransactionId FROM @tmp
											)
										AND sendDate IS NULL
								--	GROUP BY id, localTransactionId,deferredTransactionId, databaseId, type
                                    ORDER BY OutgoingXmlQueue.[order]
                                  FOR
                                    XML PATH(''entry''),
                                        ELEMENTS
                                  )
            END
        ELSE 
            BEGIN
				/*Budowa obrazu danych*/
                SELECT  @result = ( SELECT TOP ( SELECT @maxTransactionCount )
                                            *
                                    FROM    communication.OutgoingXmlQueue
                                    WHERE   localTransactionId IN (
                                            SELECT  localTransactionId
                                            FROM    communication.OutgoingXmlQueue
                                            WHERE   id = @id AND databaseId = @databaseId 
                                            GROUP BY localTransactionId )
                                            AND sendDate IS NULL
											AND databaseId = @databaseId 
                                    ORDER BY [order]
                                  FOR
                                    XML PATH(''entry''),
                                        ELEMENTS
                                  )
				/*Obsługa pustego resulta*/
                IF @result IS NULL --@result.query(''entry'').exist(''.'') = 0
                    BEGIN

						/*Budowa obrazu danych*/
                        SELECT  @result = ( SELECT TOP ( SELECT @maxTransactionCount )
                                                    *
                                            FROM    communication.OutgoingXmlQueue
                                            WHERE   localTransactionId IN (
                                                    SELECT TOP 1
                                                            localTransactionId
                                                    FROM    communication.OutgoingXmlQueue
                                                    WHERE   sendDate IS NULL AND databaseId = @databaseId 
                                                    GROUP BY localTransactionId,
                                                            [order]
                                                    ORDER BY [order] )
												AND databaseId = @databaseId 
                                            ORDER BY [order]
                                          FOR
                                            XML PATH(''entry''),
                                                ELEMENTS
                                          )
                    END

            END
		/*Zwrócenie danych*/
        SELECT  @result
        FOR     XML PATH(''root'')
    END
' 
END
GO

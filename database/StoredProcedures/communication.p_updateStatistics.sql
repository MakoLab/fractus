/*
name=[communication].[p_updateStatistics]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
YqnB9u1HAxagZNLGnW10og==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_updateStatistics]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_updateStatistics]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_updateStatistics]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_updateStatistics]
@xmlVar XML
AS
BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT,
            @sql NVARCHAR(4000),
            @max INT,
            @a INT,
            @databaseId CHAR(36),
            @lastUpdate VARCHAR(50),
            @undeliveredPackagesQuantity VARCHAR(50),
            @unprocessedPackagesQuantity VARCHAR(50),
            @lastExecutionTime VARCHAR(50),
            @lastSentMessage NVARCHAR(MAX),
            @sentMessageTime VARCHAR(50),
            @lastExecutionMessage NVARCHAR(MAX),
            @executionMessageTime VARCHAR(50),
            @lastReceiveMessage NVARCHAR(MAX),
            @receiveMessageTime VARCHAR(50)
            
            
		/*Pobranie liczby wierszy przekazanej w XML*/
        SELECT  @max = @xmlVar.query(''<a>{ count(/root/statistics/entry)}</a>'').value(''a[1]'', ''int''),
                @a = 1
        WHILE @max >= @a 
            BEGIN
                
                /*Budowa obrazu danych*/
                SELECT  @databaseId = CASE WHEN con.exist(''databaseId'') = 1
                                             THEN con.query(''databaseId'').value(''.'', ''char(36)'')
                                             ELSE NULL
                                        END,
                        @lastUpdate = CASE WHEN con.exist(''lastUpdate'') = 1
                                           THEN con.query(''lastUpdate'').value(''.'', ''varchar(50)'')
                                           ELSE NULL
                                      END,
                        @undeliveredPackagesQuantity = CASE WHEN con.exist(''undeliveredPackagesQuantity'') = 1
                                                            THEN con.query(''undeliveredPackagesQuantity'').value(''.'', ''int'')
                                                            ELSE NULL
                                                       END,
                        @unprocessedPackagesQuantity = CASE WHEN con.exist(''unprocessedPackagesQuantity'') = 1
                                                            THEN con.query(''unprocessedPackagesQuantity'').value(''.'', ''int'')
                                                            ELSE NULL
                                                       END,
                        @lastExecutionTime = CASE WHEN con.exist(''lastExecutionTime'') = 1
                                                  THEN con.query(''lastExecutionTime'').value(''.'', ''varchar(50)'')
                                                  ELSE NULL
                                             END,
                        @lastSentMessage = CASE WHEN con.exist(''lastSentMessage'') = 1
                                                THEN con.query(''lastSentMessage'').value(''.'', ''nvarchar(max)'')
                                                ELSE NULL
                                           END,
                        @sentMessageTime = CASE WHEN con.exist(''sentMessageTime'') = 1
                                                THEN con.query(''sentMessageTime'').value(''.'', ''varchar(50)'')
                                                ELSE NULL
                                           END,
                        @lastExecutionMessage = CASE WHEN con.exist(''lastExecutionMessage'') = 1
                                                     THEN con.query(''lastExecutionMessage'').value(''.'', ''nvarchar(max)'')
                                                     ELSE NULL
                                                END,
                        @executionMessageTime = CASE WHEN con.exist(''executionMessageTime'') = 1
                                                     THEN con.query(''executionMessageTime'').value(''.'', ''varchar(50)'')
                                                     ELSE NULL
                                                END,
                        @lastReceiveMessage = CASE WHEN con.exist(''lastReceiveMessage'') = 1
                                                   THEN con.query(''lastReceiveMessage'').value(''.'', ''nvarchar(max)'')
                                                   ELSE NULL
                                              END,
                        @receiveMessageTime = CASE WHEN con.exist(''receiveMessageTime'') = 1
                                                   THEN con.query(''receiveMessageTime'').value(''.'', ''varchar(50)'')
                                                   ELSE NULL
                                              END
                FROM    @xmlVar.nodes(''/root/statistics/entry[position()=sql:variable("@a")]'')
                        AS C ( con )




				/*Budowa kwerendy do statystyk*/
                IF @databaseId IS NOT NULL 

                    UPDATE communication.[Statistics] SET
						lastUpdate = ISNULL(CAST(@lastUpdate AS DATETIME) ,lastUpdate) ,
                        undeliveredPackagesQuantity = ISNULL(@undeliveredPackagesQuantity ,undeliveredPackagesQuantity),
						unprocessedPackagesQuantity = ISNULL(@unprocessedPackagesQuantity ,unprocessedPackagesQuantity),
						lastExecutionTime = ISNULL(CAST(@lastExecutionTime AS DATETIME) ,lastExecutionTime),
						sentMessageTime = ISNULL(CAST(@sentMessageTime AS DATETIME) ,sentMessageTime),
						executionMessageTime = ISNULL(CAST(@executionMessageTime AS DATETIME), executionMessageTime),
						receiveMessageTime = ISNULL(CAST(@receiveMessageTime AS DATETIME), receiveMessageTime)
					WHERE databaseId = @databaseId 

                /*Pobranie liczby wierszy*/
                SET @rowcount = @@ROWCOUNT
                
                /*Obsługa błędów i wyjątków*/	
                IF @@ERROR <> 0 
                    BEGIN
                        
                        SET @errorMsg = ''Błąd wstawiania danych table:Statistics; error:''
                            + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
                        RAISERROR ( @errorMsg, 16, 1 )
                    END
                ELSE 
                    BEGIN
                        
                        IF @rowcount = 0 
                            RAISERROR ( 50012, 16, 1 ) ;
                    END
                SET @a = @a + 1

				/*Aktualizacja statystyk*/
                IF @lastExecutionMessage IS NOT NULL 
                    UPDATE  communication.[Statistics]
                    SET     lastExecutionMessage = @lastExecutionMessage
                    WHERE   databaseId = @databaseId 
                IF @lastSentMessage IS NOT NULL 
                    UPDATE  communication.[Statistics]
                    SET     lastSentMessage = @lastSentMessage
                    WHERE   databaseId = @databaseId 
                IF @lastReceiveMessage IS NOT NULL 
                    UPDATE  communication.[Statistics]
                    SET     lastReceiveMessage = @lastReceiveMessage
                    WHERE   databaseId = @databaseId 
            END
    END
' 
END
GO

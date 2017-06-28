/*
name=[communication].[p_getLastIncompleteTransactionByDatabase]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
DKx3OH7sfOGpt6l0lc2NLQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getLastIncompleteTransactionByDatabase]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getLastIncompleteTransactionByDatabase]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getLastIncompleteTransactionByDatabase]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getLastIncompleteTransactionByDatabase] 
    @databaseId uniqueidentifier 
AS 
    BEGIN 
        
        SELECT top 1 localTransactionId 
        FROM communication.IncomingXmlQueue WITH(NOLOCK) 
        WHERE databaseId = @databaseId AND isComplited = 0 
        ORDER BY [order] ASC 
             
    END' 
END
GO

/*
name=[communication].[p_getIncomingQueue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
3nksocxvhqnscFJaJ+W2Hg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getIncomingQueue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getIncomingQueue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getIncomingQueue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getIncomingQueue] 
    @maxTransactionCount INT
AS 

set nocount on 
    BEGIN
		/*Deklaracja zmiennych*/
	
		--set statistics time on
        DECLARE @result XML,
            @tmp_list XML,
            @localTransactionId UNIQUEIDENTIFIER
		/*Utworzenie obrazu danych*/
		
		
		declare @temp table(xmlvar uniqueidentifier)
		
		
		insert into @temp 
		select localTransactionId from 
		(SELECT distinct TOP (select @maxTransactionCount)  localTransactionId,[order]
				FROM      communication.IncomingXmlQueue
				WHERE     executionDate IS NULL
										AND isComplited = 1
								order by  [order]) x
		
             --  select * from @temp 
                      
                      
        SELECT  @result = ( SELECT  *
                            FROM    communication.IncomingXmlQueue
                            WHERE   localTransactionId in (
                           
								select * from @temp 
                           
                            ) 
                          FOR XML PATH(''entry''),ELEMENTS
                          )
		/*Zwrócenie danych*/
        SELECT  @result
        FOR     XML PATH(''root'')
	--set statistics time off
    END
' 
END
GO

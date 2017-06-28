/*
name=[journal].[p_insertJournalEntry]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
xhfSRLQJ+dAio0eciduytA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[journal].[p_insertJournalEntry]') AND type in (N'P', N'PC'))
DROP PROCEDURE [journal].[p_insertJournalEntry]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[journal].[p_insertJournalEntry]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [journal].[p_insertJournalEntry]
@applicationUserId UNIQUEIDENTIFIER, @journalActionId UNIQUEIDENTIFIER, @firstObjectId UNIQUEIDENTIFIER, @secondObjectId UNIQUEIDENTIFIER, @xmlParams XML, @kernelVersion VARCHAR (50), @thirdObjectId UNIQUEIDENTIFIER=NULL
AS
BEGIN

		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT
            
            
        
        
        
        /*Wstawienie danych do dzinnika zdarzeń*/
        INSERT  INTO journal.Journal (id,date,applicationUserId,journalActionId,firstObjectId, secondObjectId,thirdObjectId,xmlParams, kernelVersion)
                SELECT  NEWID(),
                        GETDATE(),
                        @applicationUserId,
                        @journalActionId,
                        @firstObjectId,
                        @secondObjectId,
                        @thirdObjectId,
                        @xmlParams,
                        @kernelVersion


		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
        /*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:Journal; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
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

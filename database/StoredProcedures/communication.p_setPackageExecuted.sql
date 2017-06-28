/*
name=[communication].[p_setPackageExecuted]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
9su84gzzVW3hgsfGPhinLQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_setPackageExecuted]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_setPackageExecuted]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_setPackageExecuted]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [communication].[p_setPackageExecuted]
@id UNIQUEIDENTIFIER, @executionTime float = null
AS
BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
		/*Aktualizacja danych*/
        UPDATE  communication.IncomingXmlQueue
        SET     executionDate = GETDATE(), executionTime = @executionTime
        WHERE   id = @id
		
		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT	
		
		/*Obsługa błędów i wyjątków*/	
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:IncomingXmlQueue; error:''
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

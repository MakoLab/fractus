/*
name=[communication].[p_setPackageSent]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
h2coZp71GBVhHaYdqEOaqA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_setPackageSent]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_setPackageSent]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_setPackageSent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [communication].[p_setPackageSent] @id UNIQUEIDENTIFIER
AS 
    BEGIN
		/*Deklaracja zmienncyh*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

		
		/*Aktualizacja danych*/	
        UPDATE  communication.OutgoingXmlQueue
        SET     sendDate = GETDATE()
        WHERE   id = @id
		
		/*Pobranie liczby wierszy*/
        SET @rowcount = @@rowcount
		
		/*Obsługa błędów i wyjątków*/
        IF @@error <> 0 
            BEGIN

                SET @errorMsg = ''Błąd wstawiania danych table:IncomingXmlQueue; error:''
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

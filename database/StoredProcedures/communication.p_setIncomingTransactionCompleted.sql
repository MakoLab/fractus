/*
name=[communication].[p_setIncomingTransactionCompleted]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
9a4makJNpYTf8gEIXYp0vQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_setIncomingTransactionCompleted]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_setIncomingTransactionCompleted]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_setIncomingTransactionCompleted]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [communication].[p_setIncomingTransactionCompleted]
@localTransactionId UNIQUEIDENTIFIER
AS
BEGIN
/*Deklaracja zmiennych*/
DECLARE 
@errorMsg varchar(2000),
@rowcount int

	

	/*Aktualizacja danych*/
	UPDATE communication.IncomingXmlQueue 
	SET isComplited = 1
	WHERE localTransactionId = @localTransactionId

	/*Pobranie liczby wierszy*/
	SET @rowcount = @@ROWCOUNT
	
			/*Obsługa błędów i wyjątków*/
			IF @@error <> 0 
				BEGIN
					
					SET @errorMsg = ''Błąd wstawiania danych table:IncomingXmlQueue; error:'' + cast(@@error as varchar(50)) + ''; ''
					RAISERROR(@errorMsg,16,1)
				END
			ELSE
				BEGIN
					
					IF @rowcount = 0 RAISERROR(50011,16,1);
				END
END



' 
END
GO

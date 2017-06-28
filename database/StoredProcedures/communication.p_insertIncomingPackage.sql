/*
name=[communication].[p_insertIncomingPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
AUPb9eSejTWTc5VepAVMbA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_insertIncomingPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_insertIncomingPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_insertIncomingPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_insertIncomingPackage]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    /*Wstawienie danych*/
    INSERT  INTO communication.IncomingXmlQueue
            (
              id,
              localTransactionId,
              deferredTransactionId,
			  databaseId,
              [type],
              [xml]
            )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''localTransactionId'').value(''.'', ''char(36)''),''''),
                    NULLIF(con.query(''deferredTransactionId'').value(''.'', ''char(36)''),''''),
                    NULLIF(con.query(''databaseId'').value(''.'', ''char(36)''),''''),
                    NULLIF(con.query(''type'').value(''.'', ''varchar(50)''), ''''),
                    con.query(''xml/*'')
            FROM    @xmlVar.nodes(''/root/incomingXmlQueue/entry'') AS C ( con )

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
' 
END
GO

/*
name=[communication].[p_insertOutgoingPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
uZ2QTmpY2zH8/QNnSTIBgw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_insertOutgoingPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_insertOutgoingPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_insertOutgoingPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_insertOutgoingPackage]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    /*Wstawienie danych*/
    INSERT  INTO communication.OutgoingXmlQueue
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
            FROM    @xmlVar.nodes(''/root/outgoingXmlQueue/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@rowcount
	/*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:OutgoingXmlQueue; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
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

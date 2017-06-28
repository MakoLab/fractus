/*
name=[service].[p_updateServiceHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
YjbQRxnKvC2j/DzDZzxxxA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_updateServiceHeader]') AND type in (N'P', N'PC'))
DROP PROCEDURE [service].[p_updateServiceHeader]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_updateServiceHeader]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [service].[p_updateServiceHeader]
@xmlVar XML
AS
BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT,
            @applicationUserId UNIQUEIDENTIFIER

		/*Pobranie uzytkownika aplikacji*/
        SELECT  @applicationUserId = a.value(''@applicationUserId'', ''char(36)'')
        FROM    @xmlVar.nodes(''root'') AS x ( a )

        
        
        /*Aktualizacja danych */
        UPDATE  service.ServiceHeader
        SET    
			[commercialDocumentHeaderId] = CASE WHEN con.exist(''commercialDocumentHeaderId'') = 1 THEN con.query(''commercialDocumentHeaderId'').value(''.'',''char(36)'') ELSE NULL END , 
			[plannedEndDate] = CASE WHEN con.exist(''plannedEndDate'') = 1 THEN con.query(''plannedEndDate'').value(''.'',''datetime'') ELSE NULL END , 
			[description] = CASE WHEN con.exist(''description'') = 1 THEN con.query(''description'').value(''.'',''nvarchar(max)'')  ELSE NULL END , 
			[version] = CASE WHEN con.exist(''version'') = 1 THEN con.query(''version'').value(''.'',''char(36)'') ELSE NULL END,
			[closureDate] = CASE WHEN con.exist(''closureDate'') = 1 THEN con.query(''closureDate'').value(''.'',''datetime'') ELSE NULL END                               
        FROM    @xmlVar.nodes(''/root/serviceHeader/entry'') AS C ( con )
        WHERE   ServiceHeader.commercialDocumentHeaderId = con.query(''commercialDocumentHeaderId'').value(''.'', ''char(36)'')
                AND ServiceHeader.version = con.query(''version'').value(''.'', ''char(36)'')


		/*Pobranie liczby pozycji*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:ServiceHeader; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                
                IF @rowcount = 0 
                    RAISERROR ( 50012, 16, 1 ) ;
            END
 END
' 
END
GO

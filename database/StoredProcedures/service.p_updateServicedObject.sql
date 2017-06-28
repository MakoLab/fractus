/*
name=[service].[p_updateServicedObject]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
rx0vAMNp428usxwRCDn8pg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_updateServicedObject]') AND type in (N'P', N'PC'))
DROP PROCEDURE [service].[p_updateServicedObject]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_updateServicedObject]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [service].[p_updateServicedObject] 
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
        UPDATE  service.ServicedObject
        SET    
			[identifier] =  CASE WHEN con.exist(''identifier'') = 1 THEN con.query(''identifier'').value(''.'',''nvarchar(50)'') ELSE NULL END ,  
			[servicedObjectTypeId] =  CASE WHEN con.exist(''servicedObjectTypeId'') = 1 THEN con.query(''servicedObjectTypeId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[ownerContractorId] =  CASE WHEN con.exist(''ownerContractorId'') = 1 THEN con.query(''ownerContractorId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[modificationDate] =  CASE WHEN con.exist(''modificationDate'') = 1 THEN con.query(''modificationDate'').value(''.'',''datetime'') ELSE NULL END ,  
			[version] =  CASE WHEN con.exist(''version'') = 1 THEN con.query(''version'').value(''.'',''uniqueidentifier'') ELSE NULL END,
			[remarks] =  CASE WHEN con.exist(''remarks'') = 1 THEN con.query(''remarks'').value(''.'',''nvarchar(500)'') ELSE NULL END,
			[description] =  CASE WHEN con.exist(''description'') = 1 THEN con.query(''description'').value(''.'',''nvarchar(500)'') ELSE NULL END                     
        FROM    @xmlVar.nodes(''/root/servicedObject/entry'') AS C ( con )
        WHERE   ServicedObject.id = con.query(''id'').value(''.'', ''char(36)'')
                AND ServicedObject.version = con.query(''version'').value(''.'', ''char(36)'')


		/*Pobranie liczby pozycji*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:ServicedObject; error:''
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

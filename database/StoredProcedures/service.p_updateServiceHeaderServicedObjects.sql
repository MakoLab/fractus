/*
name=[service].[p_updateServiceHeaderServicedObjects]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
b7sRk7L46+AlfIuWHNZE7w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_updateServiceHeaderServicedObjects]') AND type in (N'P', N'PC'))
DROP PROCEDURE [service].[p_updateServiceHeaderServicedObjects]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_updateServiceHeaderServicedObjects]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [service].[p_updateServiceHeaderServicedObjects] 
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
        UPDATE  service.ServiceHeaderServicedObjects
        SET    
        serviceHeaderId =  CASE WHEN con.exist(''serviceHeaderId'') = 1 THEN con.query(''serviceHeaderId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
        servicedObjectId =  CASE WHEN con.exist(''servicedObjectId'') = 1 THEN con.query(''servicedObjectId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
        incomeDate =  CASE WHEN con.exist(''incomeDate'') = 1 THEN con.query(''incomeDate'').value(''.'',''datetime'') ELSE NULL END ,  
        outcomeDate =  CASE WHEN con.exist(''outcomeDate'') = 1 THEN con.query(''outcomeDate'').value(''.'',''datetime'') ELSE NULL END ,  
        plannedEndDate =  CASE WHEN con.exist(''plannedEndDate'') = 1 THEN con.query(''plannedEndDate'').value(''.'',''datetime'') ELSE NULL END ,  
        [description] =  CASE WHEN con.exist(''description'') = 1 THEN con.query(''description'').value(''.'',''nvarchar(max)'') ELSE NULL END ,  
        ordinalNumber =  CASE WHEN con.exist(''ordinalNumber'') = 1 THEN con.query(''ordinalNumber'').value(''.'',''int'') ELSE NULL END ,  
        [version] =  CASE WHEN con.exist(''version'') = 1 THEN con.query(''version'').value(''.'',''uniqueidentifier'') ELSE NULL END  
                                 
        FROM    @xmlVar.nodes(''/root/serviceHeaderServicedObjects/entry'') AS C ( con )
        WHERE   ServiceHeaderServicedObjects.id = con.query(''id'').value(''.'', ''char(36)'')
                AND ServiceHeaderServicedObjects.[version] = con.query(''version'').value(''.'', ''char(36)'')


		/*Pobranie liczby pozycji*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:ServiceHeaderServicedObjects; error:''
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

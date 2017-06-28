/*
name=[service].[p_updateServiceHeaderEmployees]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
h7y1aZlWjs8z+8oPa7VVFg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_updateServiceHeaderEmployees]') AND type in (N'P', N'PC'))
DROP PROCEDURE [service].[p_updateServiceHeaderEmployees]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_updateServiceHeaderEmployees]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [service].[p_updateServiceHeaderEmployees] 
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
        UPDATE  service.ServiceHeaderEmployees
        SET    
			serviceHeaderId =  CASE WHEN con.exist(''serviceHeaderId'') = 1 THEN con.query(''serviceHeaderId'').value(''.'',''char(36)'') ELSE NULL END ,  
			employeeId =  CASE WHEN con.exist(''employeeId'') = 1 THEN con.query(''employeeId'').value(''.'',''char(36)'') ELSE NULL END ,  
			workTime =  CASE WHEN con.exist(''workTime'') = 1 THEN con.query(''workTime'').value(''.'',''numeric(18,6)'') ELSE NULL END ,  
			timeFraction =  CASE WHEN con.exist(''timeFraction'') = 1 THEN con.query(''timeFraction'').value(''.'',''numeric(18,6)'') ELSE NULL END ,  
			plannedStartDate =  CASE WHEN con.exist(''plannedStartDate'') = 1 THEN con.query(''plannedStartDate'').value(''.'',''datetime'') ELSE NULL END ,  
			plannedEndDate =  CASE WHEN con.exist(''plannedEndDate'') = 1 THEN con.query(''plannedEndDate'').value(''.'',''datetime'') ELSE NULL END ,  
			[description] =  CASE WHEN con.exist(''description'') = 1 THEN con.query(''description'').value(''.'',''nvarchar(max)'') ELSE NULL END ,  
			ordinalNumber =  CASE WHEN con.exist(''ordinalNumber'') = 1 THEN con.query(''ordinalNumber'').value(''.'',''int'') ELSE NULL END ,  
			[version] =  CASE WHEN con.exist(''version'') = 1 THEN con.query(''version'').value(''.'',''char(36)'') ELSE NULL END  
                                 
        FROM    @xmlVar.nodes(''/root/serviceHeaderEmployees/entry'') AS C ( con )
        WHERE   ServiceHeaderEmployees.id = con.query(''id'').value(''.'', ''char(36)'')
                AND ServiceHeaderEmployees.[version] = con.query(''version'').value(''.'', ''char(36)'')


		/*Pobranie liczby pozycji*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:ServiceHeaderEmployees; error:''
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

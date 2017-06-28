/*
name=[dictionary].[p_updateServicePlace]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
er3Dd5WIkcECMpK6OlHd/A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateServicePlace]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_updateServicePlace]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateServicePlace]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_updateServicePlace] 
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
        UPDATE  dictionary.ServicePlace
        SET    
			id = CASE WHEN con.exist(''id'') = 1 THEN con.query(''id'').value(''.'',''char(36)'') ELSE NULL END ,  
			name = CASE WHEN con.exist(''name'') = 1 THEN con.query(''name'').value(''.'',''nvarchar(100)'') ELSE NULL END ,  
			[version] = CASE WHEN con.exist(''version'') = 1 THEN con.query(''version'').value(''.'',''char(36)'') ELSE NULL END ,  
			[order] = CASE WHEN con.exist(''order'') = 1 THEN con.query(''order'').value(''.'',''int'') ELSE NULL END                     
        FROM    @xmlVar.nodes(''/root/servicePlace/entry'') AS C ( con )
        WHERE   ServicePlace.id = con.query(''id'').value(''.'', ''char(36)'')
                AND ServicePlace.version = con.query(''version'').value(''.'', ''char(36)'')


		/*Pobranie liczby pozycji*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:ServicePlace; error:''
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

/*
name=[contractor].[p_updateBank]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
rHT1v088py20pU4w19WWeA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_updateBank]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_updateBank]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_updateBank]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_updateBank]
@xmlVar XML
AS
BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
        /*Aktualizacja danych o bankach*/
        UPDATE  contractor.Bank
        SET     bankNumber = CASE WHEN con.exist(''bankNumber'') = 1
                                  THEN con.query(''bankNumber'').value(''.'', ''varchar(100)'')
                                  ELSE NULL
                             END,
                swiftNumber = CASE WHEN con.exist(''swiftNumber'') = 1
                                   THEN con.query(''swiftNumber'').value(''.'', ''varchar(20)'')
                                   ELSE NULL
                              END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/bank/entry'') AS C ( con )
        WHERE   Bank.contractorId = con.query(''contractorId'').value(''.'', ''char(36)'') 
			
		/*Pobranie liczby wierszy*/		
        SET @rowcount = @@ROWCOUNT	
        
        /*Obsługa błędów i wyjatków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:Bank; error:''
                    + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
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

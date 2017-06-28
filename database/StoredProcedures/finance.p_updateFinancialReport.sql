/*
name=[finance].[p_updateFinancialReport]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
o9CNOsTgBdLdjf2V3v2qvA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_updateFinancialReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_updateFinancialReport]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_updateFinancialReport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [finance].[p_updateFinancialReport] @xmlVar XML
AS 
    BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT,
            @applicationUserId UNIQUEIDENTIFIER

		/*Pobranie uzytkownika aplikacji*/
        SELECT  @applicationUserId = a.value(''@applicationUserId'', ''char(36)'')
        FROM    @xmlVar.nodes(''root'') AS x ( a )

        /*Aktualizacja danych o FinancialReport */
        UPDATE  [finance].[FinancialReport]

        SET     financialRegisterId = CASE WHEN con.exist(''financialRegisterId'') = 1
                                      THEN con.query(''financialRegisterId'').value(''.'', ''char(36)'')
                                      ELSE NULL
                                 END,
                closingApplicationUserId = CASE WHEN con.exist(''closingApplicationUserId'') = 1
                                    THEN con.query(''closingApplicationUserId'').value(''.'', ''char(36)'')
                                    ELSE NULL
                               END,
                closureDate = CASE WHEN con.exist(''closureDate'') = 1
                                    THEN con.query(''closureDate'').value(''.'', ''datetime'')
                                    ELSE NULL
                               END,
                openingApplicationUserId = CASE WHEN con.exist(''openingApplicationUserId'') = 1
                                    THEN con.query(''openingApplicationUserId'').value(''.'', ''char(36)'')
                                    ELSE NULL
                               END,
                openingDate = CASE WHEN con.exist(''openingDate'') = 1
                                                   THEN con.query(''openingDate'').value(''.'', ''datetime'')
                                                   ELSE NULL
                                              END,
                initialBalance = CASE WHEN con.exist(''initialBalance'') = 1
                                                     THEN con.query(''initialBalance'').value(''.'', ''numeric(18,2)'')
                                                     ELSE NULL
                                                END,
                incomeAmount = CASE WHEN con.exist(''incomeAmount'') = 1
                                          THEN con.query(''incomeAmount'').value(''.'', ''numeric(18,2)'')
                                          ELSE NULL
                                     END,
                outcomeAmount = CASE WHEN con.exist(''outcomeAmount'') = 1
                                           THEN con.query(''outcomeAmount'').value(''.'', ''numeric(18,2)'')
                                           ELSE NULL
                                      END,
				isClosed = CASE WHEN con.exist(''isClosed'') = 1
                                           THEN con.query(''isClosed'').value(''.'', ''bit'')
                                           ELSE NULL
                                      END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/financialReport/entry'') AS C ( con )
        WHERE   FinancialReport.id = con.query(''id'').value(''.'', ''char(36)'')
                AND FinancialReport.version = con.query(''version'').value(''.'', ''char(36)'')


		/*Pobranie liczby pozycji*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:FinancialReport; error:''
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

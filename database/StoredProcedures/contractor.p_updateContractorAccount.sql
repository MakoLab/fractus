/*
name=[contractor].[p_updateContractorAccount]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
GA1R+mz5Ig2jhPAOZd/tOA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_updateContractorAccount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_updateContractorAccount]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_updateContractorAccount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_updateContractorAccount] @xmlVar XML
AS 
    BEGIN

		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        /*Aktualizacja danych o kontach kontrahenta*/
        UPDATE  contractor.ContractorAccount
        SET     contractorId = CASE WHEN con.exist(''contractorId'') = 1
                                    THEN con.query(''contractorId'').value(''.'', ''char(36)'')
                                    ELSE NULL
                               END,
                bankContractorId = CASE WHEN con.exist(''bankContractorId'') = 1
                                        THEN con.query(''bankContractorId'').value(''.'', ''char(36)'')
                                        ELSE NULL
                                   END,
                accountNumber = CASE WHEN con.exist(''accountNumber'') = 1
                                     THEN con.query(''accountNumber'').value(''.'', ''varchar(40)'')
                                     ELSE NULL
                                END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END,
                [order] = CASE WHEN con.exist(''order'') = 1
                               THEN con.query(''order'').value(''.'', ''int'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/contractorAccount/entry'') AS C ( con )
        WHERE   ContractorAccount.id = CASE WHEN con.exist(''id'') = 1
                                            THEN con.query(''id'').value(''.'', ''char(36)'')
                                            ELSE NULL
                                       END 

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błedów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:ContractorAccount; error:''
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

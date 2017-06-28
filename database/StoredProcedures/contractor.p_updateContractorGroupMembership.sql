/*
name=[contractor].[p_updateContractorGroupMembership]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
8KtwT6WkxbLAppHv3vZSSg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_updateContractorGroupMembership]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_updateContractorGroupMembership]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_updateContractorGroupMembership]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_updateContractorGroupMembership]
@xmlVar XML
AS
BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
        /*Aktualizacja danych o przynalezności do grup kontrahenta*/
        UPDATE  contractor.ContractorGroupMembership
        SET     contractorId = CASE WHEN con.exist(''contractorId'') = 1
                                    THEN con.query(''contractorId'').value(''.'', ''char(36)'')
                                    ELSE NULL
                               END,
                contractorGroupId = CASE WHEN con.exist(''contractorGroupId'') = 1
                                         THEN con.query(''contractorGroupId'').value(''.'', ''char(36)'')
                                         ELSE NULL
                                    END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/contractorGroupMembership/entry'') AS C ( con )
        WHERE   ContractorGroupMembership.id = CASE WHEN con.exist(''id'') = 1
                                                    THEN con.query(''id'').value(''.'', ''char(36)'')
                                                    ELSE NULL
                                               END
                AND ContractorGroupMembership.version = con.query(''version'').value(''.'', ''char(36)'') 

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@error <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:ContractorGroupMembership; error:''
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

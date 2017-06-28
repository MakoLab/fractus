/*
name=[contractor].[p_deleteContractorGroupMembership]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
epGfi+RL9KN0Va5tEjdrMw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_deleteContractorGroupMembership]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_deleteContractorGroupMembership]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_deleteContractorGroupMembership]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [contractor].[p_deleteContractorGroupMembership]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    /*Kasowanie danych o przynalezności do grup kontrahentów*/
    DELETE  FROM contractor.ContractorGroupMembership
    WHERE   id IN (
            SELECT  NULLIF(con.value(''(id)[1]'', ''char(36)''), '''')
            FROM    @xmlVar.nodes(''/root/contractorGroupMembership/entry'') AS C ( con )
            WHERE   version = NULLIF(con.value(''(version)[1]'', ''char(36)''), '''') )
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            SET @errorMsg = ''Błąd kasowania danych:ContractorGroupMembership; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            IF @rowcount = 0 
                RAISERROR ( 50013, 16, 1 ) ;
        END
' 
END
GO

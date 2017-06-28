/*
name=[contractor].[p_insertContractorGroupMembership]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
tGd0jMw60CzDAlq7XnsgIg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertContractorGroupMembership]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_insertContractorGroupMembership]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertContractorGroupMembership]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_insertContractorGroupMembership]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

	/*Wstawienie adresu przynależności do grupy kontrahenta*/
    
	
	/*Wstawienie danych o przynależności kontrahenta do grup*/
    INSERT  INTO contractor.ContractorGroupMembership
            (
              id,
              contractorId,
              contractorGroupId,
              version
            )
            SELECT  con.query(''id'').value(''.'', ''char(36)''),
                    con.query(''contractorId'').value(''.'', ''char(36)''),
                    con.query(''contractorGroupId'').value(''.'', ''char(36)''),
                    con.query(''version'').value(''.'', ''char(36)'')
            FROM    @xmlVar.nodes(''/root/contractorGroupMembership/entry'') AS C ( con )
            
    /*Pbranie liczby wierszy*/        
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:GroupMembership; error:''
                + CAST(@@error AS VARCHAR(50)) + '';''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            
            IF @rowcount = 0 
                RAISERROR ( 50011, 16, 1 ) ;
        END
' 
END
GO

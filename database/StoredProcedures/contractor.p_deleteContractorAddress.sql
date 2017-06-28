/*
name=[contractor].[p_deleteContractorAddress]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
XNVL4oTcOAMDH2P0DaPKOw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_deleteContractorAddress]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_deleteContractorAddress]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_deleteContractorAddress]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_deleteContractorAddress]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT
	
	/*Kasowanie danych o adresach kontrahentów*/
    DELETE  FROM contractor.ContractorAddress
    WHERE   id IN (
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), '''')
            FROM    @xmlVar.nodes(''/root/contractorAddress/entry'') AS C ( con ) )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            SET @errorMsg = ''Błąd kasowania danych:ContractorAddress; error:''
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

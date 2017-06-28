/*
name=[contractor].[p_insertContractorAccount]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
xEaXy6suKaE1s6fX6b6FcA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertContractorAccount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_insertContractorAccount]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertContractorAccount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_insertContractorAccount]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT


    /*Wstawienie danych o kontach kontrahenta*/
    INSERT  INTO contractor.ContractorAccount
            (
              id,
              contractorId,
              bankContractorId,
              accountNumber,
              version,
              [order]
            )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''contractorId'').value(''.'', ''char(36)''),''''),
                    NULLIF(con.query(''bankContractorId'').value(''.'', ''char(36)''),''''),
                    NULLIF(con.query(''accountNumber'').value(''.'', ''varchar(40)''),''''),
                    NULLIF(con.query(''version'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''order'').value(''.'', ''int''), '''')
            FROM    @xmlVar.nodes(''/root/contractorAccount/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:ContractorAccount; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
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

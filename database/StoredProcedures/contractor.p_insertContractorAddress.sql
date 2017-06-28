/*
name=[contractor].[p_insertContractorAddress]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
qOe6tTL9i/5FST0iHeSY8g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertContractorAddress]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_insertContractorAddress]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertContractorAddress]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_insertContractorAddress]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

	/*Wstawienie adresu kontrahenta*/
	
	/*Wstawienie danych o adresach kontrahenta*/
    INSERT  INTO contractor.ContractorAddress
            (
              id,
              contractorId,
              contractorFieldId,
              address,
              addressNumber,
              flatNumber,
              city,
              postCode,
              postOffice,
              countryId,
              version,
              [order]
            )
            SELECT  con.query(''id'').value(''.'', ''char(36)''),
                    con.query(''contractorId'').value(''.'', ''char(36)''),
                    con.query(''contractorFieldId'').value(''.'', ''char(36)''),
                    con.query(''address'').value(''.'', ''nvarchar(300)''),
                    NULLIF(con.query(''addressNumber'').value(''.'', ''nvarchar(10)''), ''''),
                    NULLIF(con.query(''flatNumber'').value(''.'', ''nvarchar(10)''), ''''),
                    con.query(''city'').value(''.'', ''nvarchar(50)''),
                    con.query(''postCode'').value(''.'', ''nvarchar(30)''),
                    con.query(''city'').value(''.'', ''nvarchar(50)''),
                    con.query(''countryId'').value(''.'', ''char(36)''),
                    con.query(''version'').value(''.'', ''char(36)''),
                    con.query(''order'').value(''.'', ''int'')
            FROM    @xmlVar.nodes(''/root/contractorAddress/entry'') AS C ( con )
     
    /*Pobranie liczby wierszy*/       
    SET @rowcount = @@ROWCOUNT

	/*Obsługa błedów i wyjątków*/    
    IF @@ERROR <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:ContractorAddress; error:''
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

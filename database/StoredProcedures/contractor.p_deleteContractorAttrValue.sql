/*
name=[contractor].[p_deleteContractorAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
b+EbNM4CUfr3xhvlrkBLgg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_deleteContractorAttrValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_deleteContractorAttrValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_deleteContractorAttrValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_deleteContractorAttrValue]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    /*Kasowanie wpisów o atrybutach kotrachentów*/
    DELETE  FROM contractor.ContractorAttrValue
    WHERE   id IN (
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), '''')
            FROM    @xmlVar.nodes(''/root/contractorAttrValue/entry'') AS C ( con )
            WHERE   version = NULLIF(con.query(''version'').value(''.'', ''char(36)''),
                                     '''') )
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błedów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            SET @errorMsg = ''Błąd kasowania danych:ContractorAttrValue; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            IF @rowcount = 0 
                RAISERROR ( 50013, 16, 1 );
        END
' 
END
GO

/*
name=[contractor].[p_updateContractorAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
7DWfUIXuvRnmF4oXV/f1Hw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_updateContractorAttrValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_updateContractorAttrValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_updateContractorAttrValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_updateContractorAttrValue] @xmlVar XML
AS 
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        /*Aktualizacja danych o atrybutach kontrahenta*/
        UPDATE  contractor.ContractorAttrValue
        SET     contractorId = CASE WHEN con.exist(''contractorId'') = 1
                                    THEN con.query(''contractorId'').value(''.'', ''char(36)'')
                                    ELSE NULL
                               END,
                contractorFieldId = CASE WHEN con.exist(''contractorFieldId'') = 1
                                         THEN con.query(''contractorFieldId'').value(''.'', ''char(36)'')
                                         ELSE NULL
                                    END,
                decimalValue = CASE WHEN con.exist(''decimalValue'') = 1
                                    THEN con.query(''decimalValue'').value(''.'', ''decimal(18,4)'')
                                    ELSE NULL
                               END,
                dateValue = CASE WHEN con.exist(''dateValue'') = 1
                                 THEN con.query(''dateValue'').value(''.'', ''datetime'')
                                 ELSE NULL
                            END,
                textValue = CASE WHEN con.exist(''textValue'') = 1
                                 THEN con.query(''textValue'').value(''.'', ''nvarchar(max)'')
                                 ELSE NULL
                            END,
                xmlValue = CASE WHEN con.exist(''xmlValue'') = 1
                                THEN con.query(''xmlValue/*'')
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
        FROM    @xmlVar.nodes(''/root/contractorAttrValue/entry'') AS C ( con )
        WHERE   ContractorAttrValue.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:ContractorAttrValue; error:''
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

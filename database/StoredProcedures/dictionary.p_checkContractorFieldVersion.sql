/*
name=[dictionary].[p_checkContractorFieldVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
77iQ/+0z2N/X1JYfvAW/Eg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_checkContractorFieldVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_checkContractorFieldVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_checkContractorFieldVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_checkContractorFieldVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN
		/*Walidacja wersji pól kontrahenta*/
        IF NOT EXISTS ( SELECT  id
                        FROM    dictionary.ContractorField
                        WHERE   ContractorField.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO

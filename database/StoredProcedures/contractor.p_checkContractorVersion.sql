/*
name=[contractor].[p_checkContractorVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
5hEHJXJiRsUArG+peD7luQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_checkContractorVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_checkContractorVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_checkContractorVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_checkContractorVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN
		/*Walidacja wersji konrahenta*/
        IF NOT EXISTS ( SELECT  id
                        FROM    contractor.Contractor
                        WHERE   Contractor.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO

/*
name=[dictionary].[p_checkCompanyVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
poM324fDYQ/TTCD/MnzQxA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_checkCompanyVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_checkCompanyVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_checkCompanyVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_checkCompanyVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN

		/*Walidacja wersji*/
        IF NOT EXISTS ( SELECT  contractorId
                        FROM    dictionary.Company
                        WHERE   Company.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO

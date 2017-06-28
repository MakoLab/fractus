/*
name=[contractor].[p_getContractorGroupMembershipsCount]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
BLW9SAL/3W9kJuPf2N0vSw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorGroupMembershipsCount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getContractorGroupMembershipsCount]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorGroupMembershipsCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_getContractorGroupMembershipsCount]
    @contractorGroupId UNIQUEIDENTIFIER
AS 
	/*Deklaracja zmiennych*/
    DECLARE @count INT

	/*Pobranie liczby kontrahentów w grupie*/
    SELECT  @count = COUNT(id)
    FROM    contractor.ContractorGroupMembership
    WHERE   [contractorGroupId] = @contractorGroupId
	
	/*Zwrócenie wyników*/
    SELECT  ( SELECT    ISNULL(@count, 0)
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnXML
' 
END
GO

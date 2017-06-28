/*
name=[contractor].[p_getContractorGroupMembershipsCountWrapper]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
qeH8BgaYHKzheQSSMlbHTA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorGroupMembershipsCountWrapper]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getContractorGroupMembershipsCountWrapper]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorGroupMembershipsCountWrapper]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_getContractorGroupMembershipsCountWrapper]
    @xmlVar XML
AS 
	/*Deklaracja zmiennych*/
    DECLARE @count INT, @contractorGroupId UNIQUEIDENTIFIER
	SELECT @contractorGroupId = @xmlVar.query(''root'').value(''.'',''char(36)'')

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

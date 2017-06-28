/*
name=[communication].[p_getContractorGroupMembershipPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
OolJjjC6Sf2hOCuT4rm4+Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getContractorGroupMembershipPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getContractorGroupMembershipPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getContractorGroupMembershipPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getContractorGroupMembershipPackage] @id UNIQUEIDENTIFIER
AS /*Gets ContractorGroupMembership xml Package that match input parameter*/
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @snap XML
		/*Budowa obrazu danych*/
        SELECT  @snap = ( 
						SELECT (
						  SELECT    @id ''id'',
                                    contractorId ''contractorId'',
                                    contractorGroupId ''contractorGroupId'',
                                    version ''version''
                          FROM      contractor.ContractorGroupMembership
                          WHERE     ContractorGroupMembership.id = @id
						FOR XML PATH(''entry''), TYPE )
                        FOR XML PATH(''contractorGroupMembership''), TYPE
                        ) 

		/*Zwrócenie wyników*/
        SELECT  @snap
        FOR     XML PATH(''root''), TYPE
    END
' 
END
GO

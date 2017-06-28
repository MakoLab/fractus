/*
name=[contractor].[p_getContractorGroupMembership]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
58Atbi8tQZlH7dkRPM/H+w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorGroupMembership]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getContractorGroupMembership]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorGroupMembership]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_getContractorGroupMembership]
AS 
	/*Budowanie XML z danymi o przynaleznosic kontrhentów do grup*/
    SELECT  ( SELECT    ( SELECT    id,
                                    contractorId,
                                    contractorGroupId,
                                    version
                          FROM      contractor.ContractorGroupMembership
                        FOR
                          XML PATH(''entry''),
                              TYPE
                        )
            FOR
              XML PATH(''contractorGroupMembership''),
                  TYPE
            )
    FOR     XML PATH(''root''),
                TYPE
' 
END
GO

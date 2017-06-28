/*
name=[contractor].[p_getContractorData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
mA/ftWAswA24uugHdO6Wng==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getContractorData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_getContractorData]
    @contractorId UNIQUEIDENTIFIER
AS 
    BEGIN
		/*Budowanie kompletnego XML z danymi o kontrahencie*/
        SELECT  ( SELECT    ( SELECT    ( SELECT DISTINCT
                                                    c.*
                                          FROM      contractor.Contractor c
                                          WHERE     c.id = @contractorId
                                                    OR c.id IN (
                                                    SELECT  relatedContractorId
                                                    FROM    contractor.ContractorRelation
                                                    WHERE   ContractorId = @contractorId )
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractor''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      contractor.Employee
                                          WHERE     contractorId = @contractorId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''employee''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      contractor.Bank
                                          WHERE     contractorId = @contractorId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''bank''),
                                  TYPE
                            ),
							( SELECT    ( SELECT    *
                                          FROM      contractor.ApplicationUser
                                          WHERE     contractorId = @contractorId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''applicationUser''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      contractor.ContractorAddress
                                          WHERE     contractorId = @contractorId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractorAddress''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      contractor.ContractorRelation
                                          WHERE     contractorId = @contractorId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractorRelation''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      contractor.ContractorGroupMembership
                                          WHERE     contractorId = @contractorId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractorGroupMembership''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      contractor.ContractorAccount
                                          WHERE     contractorId = @contractorId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractorAccount''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      contractor.ContractorAttrValue
                                          WHERE     contractorId = @contractorId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractorAttrValue''),
                                  TYPE
                            )
                FOR
                  XML PATH(''root''),
                      TYPE
                ) AS returnsXML
    END
' 
END
GO

/*
name=[contractor].[p_getOwnCompanies]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
elPagrdStMzHz/hRXLxsCg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getOwnCompanies]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getOwnCompanies]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getOwnCompanies]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_getOwnCompanies]
@xmlVar XML
AS 
	BEGIN

		/*Pobranie danych o kontach kotrahenta*/
        SELECT  ( SELECT    ( SELECT    ( SELECT DISTINCT
                                                    c.*
                                          FROM      contractor.Contractor c
                                          WHERE     isOwnCompany = 1
                                                    OR c.id IN (
                                                    SELECT  relatedContractorId
                                                    FROM    contractor.ContractorRelation
                                                    WHERE   contractorId IN (	SELECT	cc.id
																				FROM      contractor.Contractor cc
																				WHERE     isOwnCompany = 1)
															)
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
                                          WHERE     contractorId IN (SELECT id FROM contractor.Contractor WHERE isOwnCompany = 1)
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
                                          WHERE     contractorId IN (SELECT id FROM contractor.Contractor WHERE isOwnCompany = 1)
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''bank''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      contractor.ContractorAddress
                                          WHERE     contractorId IN (SELECT id FROM contractor.Contractor WHERE isOwnCompany = 1)
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
                                          WHERE     contractorId IN (SELECT id FROM contractor.Contractor WHERE isOwnCompany = 1)
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
                                          WHERE     contractorId IN (SELECT id FROM contractor.Contractor WHERE isOwnCompany = 1)
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
                                          WHERE     contractorId IN (SELECT id FROM contractor.Contractor WHERE isOwnCompany = 1)
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
                                          WHERE     contractorId IN (SELECT id FROM contractor.Contractor WHERE isOwnCompany = 1)
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

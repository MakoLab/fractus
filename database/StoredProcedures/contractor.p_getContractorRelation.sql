/*
name=[contractor].[p_getContractorRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ddWXoXGstP4hT73Ry+5+aA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getContractorRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_getContractorRelation]
AS 
	/*Pobranie XML z danymi o powiązaniach kontrhenta*/
    SELECT  ( SELECT    ( SELECT    id,
                                    contractorId,
                                    contractorRelationTypeId,
                                    xmlAttributes,
                                    version
                          FROM      contractor.ContractorRelation
                          ORDER BY  [order]
                        FOR
                          XML PATH(''entry''),
                              TYPE
                        )
            FOR
              XML PATH(''contractorRelation''),
                  TYPE
            )
    FOR     XML PATH(''root''),
                TYPE
' 
END
GO

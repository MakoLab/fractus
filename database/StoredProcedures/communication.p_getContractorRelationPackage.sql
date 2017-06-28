/*
name=[communication].[p_getContractorRelationPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
WKG+rxIneqTLex8s5A+Hiw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getContractorRelationPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getContractorRelationPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getContractorRelationPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getContractorRelationPackage] @id UNIQUEIDENTIFIER
AS 
    BEGIN
	/*Deklaracja zmiennych*/
        DECLARE @result XML
	/*Budowanie obrazy danych*/
        SELECT  @result = ( 
							SELECT (
							SELECT  id ''id'',
                                    contractorId ''contractorId'',
                                    contractorRelationTypeId ''contractorRelationTypeId'',
                                    relatedContractorId ''relatedContractorId'',
                                    xmlAttributes ''xmlAttributes'',
                                    version ''version''
                            FROM    contractor.ContractorRelation
                            WHERE   ContractorRelation.id = @id
							FOR XML PATH(''entry''), TYPE )
                          FOR XML PATH(''contractorRelation''), TYPE
                          )
		
	/*Zwrócenie wyników*/
        SELECT  @result
        FOR     XML PATH(''root''),
                    TYPE
    END
' 
END
GO

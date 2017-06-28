/*
name=[contractor].[p_getContractorAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
G8LG4miH9GK1KpiRIjJMyQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorAttrValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getContractorAttrValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorAttrValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_getContractorAttrValue]
    @contractorId UNIQUEIDENTIFIER = NULL,
    @contractorFieldId UNIQUEIDENTIFIER = NULL
AS 
	/*Budowanie XML z danymi o atrybutach kontrahenta*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    id,
                                                contractorId,
                                                contractorFieldId,
                                                decimalValue,
                                                dateValue,
                                                textValue,
                                                xmlValue,
                                                version
                                      FROM      contractor.ContractorAttrValue
                                      WHERE     ( contractorId = @contractorId
                                                  OR @contractorId IS NULL
                                                )
                                                AND ( contractorFieldId = @contractorFieldId
                                                      OR @contractorFieldId IS NULL
                                                    )
                                      ORDER BY  [order]
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
            ) AS raturnsXML
' 
END
GO

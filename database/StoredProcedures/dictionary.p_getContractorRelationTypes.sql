/*
name=[dictionary].[p_getContractorRelationTypes]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
eYRqDx+lIf9YjyDxKbkAsg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getContractorRelationTypes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getContractorRelationTypes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getContractorRelationTypes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getContractorRelationTypes]
AS 

	/*Budowa XML typami powiązań kontrahenta*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    id,
                                                [name],
                                                xmlLabels,
                                                version
                                      FROM      dictionary.ContractorRelationType
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''contractorRelationType''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO

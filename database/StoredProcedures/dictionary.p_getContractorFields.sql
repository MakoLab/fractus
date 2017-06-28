/*
name=[dictionary].[p_getContractorFields]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JaQkFun78ia51H6tK1usTQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getContractorFields]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getContractorFields]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getContractorFields]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getContractorFields]
AS 
	/*Budowa XML z polami kontrahenta*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    id,
                                                name,
                                                xmlLabels,
                                                xmlMetadata,
                                                version
                                      FROM      dictionary.ContractorField
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''contractorField''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO

/*
name=[dictionary].[p_getCompanies]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JieHKE2AxZ5Skajmilw1FA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getCompanies]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getCompanies]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getCompanies]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getCompanies]
AS 
	/*Budowa XML z firmami*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    contractorId,
                                                xmlLabels,
                                                version
                                      FROM      dictionary.Company
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''company''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO

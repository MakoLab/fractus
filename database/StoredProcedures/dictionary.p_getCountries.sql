/*
name=[dictionary].[p_getCountries]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
OffdQc0Ciyt9vemLVfOVVw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getCountries]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getCountries]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getCountries]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getCountries]
AS 
	/*Budowa XML z krajami*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    id,
                                                symbol,
                                                xmlLabels,
                                                version
                                      FROM      dictionary.Country
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''country''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO

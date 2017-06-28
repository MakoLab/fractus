/*
name=[dictionary].[p_getUnitTypes]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
e9UkwnZpqJZXeBesLqC/3Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getUnitTypes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getUnitTypes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getUnitTypes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getUnitTypes]
AS 
	/*Budowa XML z typami jednostek miar*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.UnitType
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''unitType''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO

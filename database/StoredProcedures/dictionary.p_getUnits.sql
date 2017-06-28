/*
name=[dictionary].[p_getUnits]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
2vAda/7QzaSVs6PEzvdffw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getUnits]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getUnits]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getUnits]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getUnits]
AS 
	/*Budowanie XML z jednostkami miar*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.Unit
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''unit''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO

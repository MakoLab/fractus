/*
name=[dictionary].[p_getNumberSettings]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
lmkU/YKa0+82Oic/H32vtA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getNumberSettings]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getNumberSettings]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getNumberSettings]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getNumberSettings]
AS 
	/*Budowa XML z ustawieniami numeracji*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.NumberSetting
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''numberSetting''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO

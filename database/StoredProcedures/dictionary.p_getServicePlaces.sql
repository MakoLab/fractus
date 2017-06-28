/*
name=[dictionary].[p_getServicePlaces]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
C5wYBlQpBRU1/flPahxS6g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getServicePlaces]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getServicePlaces]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getServicePlaces]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getServicePlaces]
AS 
	/*Budowa XML z ServicePlace*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.ServicePlace
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''servicePlace''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO

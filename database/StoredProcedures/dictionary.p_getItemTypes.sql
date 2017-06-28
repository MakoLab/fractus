/*
name=[dictionary].[p_getItemTypes]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
iMAqUvMtbWElBIPKzw6veg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getItemTypes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getItemTypes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getItemTypes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getItemTypes]
AS 
	/*Budowa XML z typami towarów*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.ItemType
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''itemType''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO

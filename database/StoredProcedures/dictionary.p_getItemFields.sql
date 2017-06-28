/*
name=[dictionary].[p_getItemFields]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Eu+GgoONm/q3sx26o4oNtQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getItemFields]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getItemFields]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getItemFields]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getItemFields]
AS 
	/*Budowa XML z polami dodatkowymi towaru*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.ItemField
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''itemField''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO

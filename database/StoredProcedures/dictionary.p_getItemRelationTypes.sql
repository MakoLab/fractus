/*
name=[dictionary].[p_getItemRelationTypes]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
1bl40lYPmVvJW8VZRB76dQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getItemRelationTypes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getItemRelationTypes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getItemRelationTypes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getItemRelationTypes]
AS 
	/*Budowa XML z typami powiązań towarów*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.ItemRelationType
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''itemRelationType''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO

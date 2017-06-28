/*
name=[dictionary].[p_getItemRelationAttrValueTypes]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ABgvVZjNFQvzc0ubPpFXKg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getItemRelationAttrValueTypes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getItemRelationAttrValueTypes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getItemRelationAttrValueTypes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getItemRelationAttrValueTypes]
AS 
	/*Budowa XML z typami powiązań atrybutów towarów*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.ItemRelationAttrValueType
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''itemRelationAttrValueType''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO

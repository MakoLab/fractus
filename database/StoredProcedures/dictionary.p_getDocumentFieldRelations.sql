/*
name=[dictionary].[p_getDocumentFieldRelations]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ND3P9jH1ZS5TE1r3NQWvWA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getDocumentFieldRelations]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getDocumentFieldRelations]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getDocumentFieldRelations]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getDocumentFieldRelations]
AS
	/*Budowa XML z powiązaniami pól dodatkowych dokumentów*/ 
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.DocumentFieldRelation
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''documentFieldRelation''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO

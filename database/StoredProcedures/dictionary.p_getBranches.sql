/*
name=[dictionary].[p_getBranches]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fbEkbuG+ovtZ+awafOE4vw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getBranches]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getBranches]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getBranches]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getBranches]
AS 
	/*Budowa XML z oddziałami*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.Branch
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''branch''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
